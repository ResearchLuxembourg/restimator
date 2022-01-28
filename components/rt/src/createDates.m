function [dates, longdates, day, month, firsts, labs] = createDates()

%Check the date for csv file names
day = datestr(clock, 7);
month = datestr(clock, 5);

%Create dates for plot axes
dates={'29/2'};
monthLengths = [31 28 31 30 31 30 31 31 30 31 30 31];
firsts=[2,2+cumsum(monthLengths(3:end)),2+sum(monthLengths(3:end))+cumsum(monthLengths), 2+sum(monthLengths(3:end))+sum(monthLengths)+cumsum(monthLengths)];
for jm = [3:12 1:12 1:12]
    for jd = 1:monthLengths(jm)
        dates={dates{1:length(dates)},[num2str(jd) '/' num2str(jm)]};
    end
end
for jt=1:length(firsts)-1
    if mod(jt,2) == 1
        labs{jt} = dates{firsts(jt)};
    else
        labs{jt} = ' ';
    end
end




%Long date format for csv-files
longdates={'2020-02-29'};
month_lengths=[31 28 31 30 31 30 31 31 30 31 30 31];
for jm=3:12
    for jd=1:month_lengths(jm)
        mark_m='-';
        if jm < 9.5
            mark_m='-0';
        end
        mark_d='-';
        if jd<9.5
            mark_d='-0';
        end
        longdates={longdates{1:length(longdates)},['2020' mark_m num2str(jm) mark_d num2str(jd)]};
    end
end
for jy=2021:2022
    for jm=1:12
        for jd=1:month_lengths(jm)
            mark_m='-';
            if jm < 9.5
                mark_m='-0';
            end
            mark_d='-';
            if jd<9.5
                mark_d='-0';
            end
            longdates={longdates{1:length(longdates)},[num2str(jy) mark_m num2str(jm) mark_d num2str(jd)]};
        end
    end
end
