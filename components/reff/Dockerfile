ARG PYTHON_VERSION=3.9
ARG DEFAULT_REG="docker-registry.lcsb.uni.lu/library"

FROM ${DEFAULT_REG}/python:${PYTHON_VERSION}-slim

# create the working directory
RUN mkdir -p /covid19-reproductionNumber/src
WORKDIR /covid19-reproductionNumber

# add setup and install
ADD setup.py /covid19-reproductionNumber
RUN pip install -e .

# add source files
ADD src/* /covid19-reproductionNumber/src/

# execute the pipeline
CMD ["python"]
