%% Atte Aalto
% 
% change to the root of the file
pathToFile = fileparts(mfilename('fullpath'));
if ~isempty(pathToFile)
    rootFolder = [pathToFile filesep '..'];
else
    rootFolder = pwd();
end

cd(rootFolder);
addpath(genpath(rootFolder));

% define output folder
outFolder = [rootFolder filesep 'output'];
checkFolder(outFolder);
inFolder = [rootFolder filesep 'input'];
checkFolder(inFolder);

%Read input data
today = datestr(clock, 29);
inFile = [inFolder filesep 'input-data.xlsx'];
if isfile(inFile)  % I keep this check in case anything appened
    TTin = readtable(inFile);
else
    error(['The input file ' inFile ' cannot be found.']);
end

day0 = find(datetime(2020,2,28) == TTin.report_date);
Y = flipud(TTin.new_cases_resident(1:day0))';

%Fixing some data anomalies (ad hoc)
Y(138) = Y(138) + 40;
Y(139) = Y(139) - 40;
Y(151) = Y(151) + 50;
Y(152) = Y(152) - 50;
Y(326) = Y(326) + 40;
Y(327) = Y(327) - 40;
Y(394) = Y(394) - 20;
Y(395) = Y(395) + 20;
Y(615) = Y(615) - 240;
Y(614) = Y(614) + 120;
Y(613) = Y(613) + 120;

% Data used until:
Tlim = length(Y);

% Rate for I -> R transition (often denoted by gamma)
mu = .25;

% Initial rate for S -> I transition (time-dependent parameter)
beta = mu/2;

% Coefficients for weekend effect
sun = .6;
mon = .3;
wed = 1.25;

%Ratio total / detected
darkNumber_1 = 3;    %Until May 2020
darkNumber_2 = 1.5;  %June 2020 onwards

% Output coefficient (weekday-dependent)
C = ones(1,length(Y)+2); %Tuesday - Saturday
C(2:7:end) = sun*ones(size(C(2:7:end))); %Sundays
C(3:7:end) = mon*ones(size(C(3:7:end))); %Mondays

%Dark number for March-May 2020
C(1:94) = C(1:94)/darkNumber_1;

%Tune the coefficients for the weekly rhythm based on the last four weeks
fprintf(' > Tune coefficients ... ')
for jt = 95:length(C)
    weekDay = mod(jt-3,7) + 1;

    dayCoef = 0;
    for jw = 1:4
        dayCoef = dayCoef + Y(jt-7*jw)/mean(Y(jt-weekDay-6-7*(jw-1):jt-weekDay-7*(jw-1)))/darkNumber_2/4;
    end
    C(jt) = dayCoef;
end
fprintf('Done.\n')

% Some special holidays
%2020
C(46) = mon;                            %Tue after Easter monday
C(84) = mon;                            %Fri after Ascension day
C(95) = mon;                            %Tue after Lundi de Pentecote
C(117) = mon;                           %Day after national day
C(302) = mon;                           %Christmas day
C(303) = mon;                           %Boxing day
C(304) = 1.21*mon - .21;                %Boxing day

%2021
C(309) = 1.21*mon - .21;                %New year
C(310) = mon;                           %Day after new year
C(403) = 1.3*mon - .3;                  %Day after easter monday
C(429) = sun;                           %Day after May 1st
C(441) = mon;                           %Fri after ascension
C(452) = 1.21*mon-.21;                  %Tue after Lundi de Pentecote
C(482) = mon;                           %Day after national day
C(667) = mon;                           %Christmas day
C(668) = mon;                           %Boxing day
C(669) = mon;                           %Boxing day

%2022
C(674) = mon;                           %New year
C(675) = mon;                           %Day after new year
C(781) = mon;                           %Day after easter monday
C(819) = mon;                          %Fri after ascension
C(830) = mon;                           %Tue after Lundi de Pentecote
C(847) = mon;                           %Day after national day
C(978) = mon;                           %Day after all saints day
C(1032) = mon;                          %Christmas day
C(1033) = mon;                          %Boxing day
C(1034) = mon;                          %Boxing day

% "Effective" population: smaller than true pop. Accounting for
% inhomogeneity in the population (SIR assumes perfect mixing).
N = 5e5;

% Initially infected
N_infected = 100; %Number of initially infected
S_infected = 250; %Variance of the size of the initially infected population

% Initial error variance of beta
S_beta = .15^2;

% Variance of daily change of beta (initially)
Q_beta = .05^2;

% State variables are:
% X(1): S(t),  X(2): I(t),  X(3): S(t-1),  X(4): beta(t)
X = zeros(4,Tlim+1);
X(:,1) = [N-N_infected; N_infected; N-N_infected+1; beta];

% Initial state error covariance
P = [S_infected -S_infected S_infected 0;
    -S_infected S_infected -S_infected 0;
    S_infected -S_infected S_infected 0;
    0 0 0 S_beta];

% Measurement error variance (depends on the number of infected)
Ysm = Y;
Ysm(1) = .5*(Y(1) + Y(2));
Ysm(end) = .5*(Y(end) + Y(end-1));
Ysm(2:end-1) = .5*Y(2:end-1) + .25*(Y(1:end-2)+Y(3:end));
R = (Ysm/25).^2.*(C(1)./C(1:length(Y))).^2 + 1;

% Model error term to scale up the Langevin covariance
CC = 4^2;

% Number of detected cases today depends linearly on the true number of new
% cases today
C0 = [-1 0 1 0];

Yest = zeros(1,Tlim); %Storage for predicted number of new cases
err_beta = zeros(1,Tlim);  %Storage for beta-estimate error variance
for jday=1:Tlim

    %Reduce the rate of change of beta-parameter after the effect of
    %lockdown has stabilised, since no bigger changes are expected anymore.
    if jday>30.5
        Q_beta=.005^2;
    end

    %State update (Kalman filter prediction step):
    X(1,jday+1) = X(1,jday) - X(4,jday)*X(2,jday)*X(1,jday)/N;
    X(2,jday+1) = (X(2,jday) + X(4,jday)*X(2,jday)*X(1,jday)/N)/(1+mu);
    X(3,jday+1) = X(1,jday);
    X(4,jday+1) = X(4,jday);

    %Jacobian of the dynamics function
    Jf = [1-X(4,jday)*X(2,jday)/N -X(4,jday)*X(1,jday)/N 0 -X(1,jday)*X(2,jday)/N;
        X(4,jday)*X(2,jday)/N (1+X(4,jday)*X(1,jday)/N)/(1+mu) 0 X(1,jday)*X(2,jday)/N;
        1 0 0 0;
        0 0 0 1];

    %"Process noise" covariance, assuming Langevin-type stochastics
    Q = [CC*X(4,jday)*X(1,jday)*X(2,jday)/N, -CC*X(4,jday)*X(1,jday)*X(2,jday)/N, 0, 0;
        -CC*X(4,jday)*X(1,jday)*X(2,jday)/N, CC*(X(4,jday)*X(1,jday)*X(2,jday)/N + mu*X(2,jday)), 0, 0;
        0, 0, 0, 0;
        0, 0, 0, Q_beta];

    %Prediction error covariance
    Phat = Jf*P*Jf' + Q;

    %Measurement covariance
    S = C(jday)^2*C0*Phat*C0'+R(jday);

    %Predicted number of daily new cases
    Yest(jday) = C(jday)*C0*X(:,jday+1);

    %Kalman filter update step based on true and predicted number
    X(:,jday+1) = X(:,jday+1) + Phat*C(jday)*C0'*(Y(jday)-Yest(jday))/S;

    %Covariance update
    P = Phat - C(jday)^2/S*Phat*C0'*C0*Phat;

    %Store the error variance of beta-estimate
    err_beta(jday) = P(4,4);

end

disp(' > Simulation done.')

% Create the output csv-file
[dates, longdates, day, month, firsts, labs] = createDates;
M = [X(4,20:end)/mu; err_beta(19:end).^.5/mu];
TTout = array2table(M','VariableNames',{'Rt_estimate','Standard_deviation'});
Tdate = cell2table(longdates(18+(1:size(M,2)))','VariableNames',{'Date'});
TTout = [Tdate,TTout];
filename = [today '_Rt_estimate.csv'];
writetable(TTout,[outFolder filesep filename])

disp([' > Outputfile written to ' outFolder])
