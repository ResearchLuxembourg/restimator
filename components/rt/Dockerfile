ARG DEFAULT_REG=docker.io

# build from the MATLAB base image
FROM ${DEFAULT_REG}/mathworks/matlab:r2021b

# create the working directory
RUN mkdir -p /home/matlab/covid19-reproductionNumber
WORKDIR /home/matlab/covid19-reproductionNumber

# create required directories
RUN mkdir src input output

# add source files
ADD src/* /home/matlab/covid19-reproductionNumber/src/

# this part is required in order to map the local
# username ID and GROUP to the matlab user in the container.
# In this case, the local userID is 1002 and 1003,
# so the docker container user `matlab` is modified to match these ids.
USER root
RUN groupadd -g 1003 restimator-group
RUN usermod -u 1002 -g 1003 matlab
USER matlab

# execute the pipeline
CMD ["matlab"]
