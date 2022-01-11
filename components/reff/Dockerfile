ARG PYTHON_VERSION=3.9
ARG DEFAULT_REG=docker.io

FROM ${DEFAULT_REG}/library/python:${PYTHON_VERSION}-slim

# environment variables
ENV WORKING_DIR=/covid19-reproductionNumber

# create the working directory
RUN mkdir -p ${WORKING_DIR}/src
WORKDIR ${WORKING_DIR}/

# add setup and install
ADD setup.py ${WORKING_DIR}/
RUN pip install -e .

# add source files
ADD src/* ${WORKING_DIR}/src/

# execute the pipeline
CMD ["python"]
