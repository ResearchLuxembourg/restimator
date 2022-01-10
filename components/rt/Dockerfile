ARG DEFAULT_REG="docker-registry.lcsb.uni.lu"

# Build from the MATLAB base image
FROM ${DEFAULT_REG}/mathworks/matlab:r2021b
# create the working directory
RUN mkdir -p /home/matlab/covid19-reproductionNumber
WORKDIR /home/matlab/covid19-reproductionNumber

RUN mkdir src input output

ADD src/* /home/matlab/covid19-reproductionNumber/src/

USER root
RUN groupadd -g 1003 restimator-group
RUN usermod -u 1002 -g 1003 matlab
USER matlab

# execute the pipeline
CMD ["matlab"]
