ARG DEFAULT_REG=""

# Build from the MATLAB base image
FROM ${DEFAULT_REG}/mathworks/matlab:r2021b

# create the working directory
RUN mkdir -p /home/matlab/covid19-reproductionNumber
WORKDIR /home/matlab/covid19-reproductionNumber
RUN mkdir -p src output input

ADD src/* /home/matlab/covid19-reproductionNumber/src

# execute the pipeline
CMD ["matlab"]