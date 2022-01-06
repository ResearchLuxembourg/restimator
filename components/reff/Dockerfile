ARG PYTHON_VERSION=3.9

FROM python:${PYTHON_VERSION}-slim

# create the working directory
RUN mkdir /covid19-reproductionNumber
WORKDIR /covid19-reproductionNumber

# add setup and install
ADD setup.py /covid19-reproductionNumber
RUN pip install -e .

# add source files
RUN mkdir /covid19-reproductionNumber/src
ADD src/* /covid19-reproductionNumber/src

# execute the pipeline
CMD ["python", "src/reff_estimator.py"]
