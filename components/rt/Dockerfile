ARG DEFAULT_REG=docker.io

# build from the MATLAB base image
FROM ${DEFAULT_REG}/mathworks/matlab:r2021b

# environment variables
ENV WORKING_DIR=/home/matlab/covid19-reproductionNumber
ENV DEFAULT_USER=matlab
ENV DEFAULT_USER_GROUP=restimator-group
ENV LOCAL_USER_ID=1002
ENV LOCAL_USER_GROUP=1003

# create the working directory
RUN mkdir -p ${WORKING_DIR}/src ${WORKING_DIR}/input ${WORKING_DIR}/output
WORKDIR ${WORKING_DIR}/

# add source files
ADD src/* ${WORKING_DIR}/src/

# this part is required in order to map the local
# username ID and GROUP to the matlab user in the container.
# In this case, the local userID is 1002 and 1003,
# so the docker container user `matlab` is modified to match these ids.
USER root
RUN groupadd -g ${LOCAL_USER_GROUP} ${DEFAULT_USER_GROUP}
RUN usermod -u ${LOCAL_USER_ID} -g ${LOCAL_USER_GROUP} ${DEFAULT_USER}
USER ${DEFAULT_USER}

# execute the pipeline
CMD ["matlab"]
