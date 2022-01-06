ARG PYTHON_VERSION=3.9

FROM python:${PYTHON_VERSION}-slim

RUN mkdir /covid19-reproductionNumber
WORKDIR /covid19-reproductionNumber

ADD requirements.txt /covid19-reproductionNumber
RUN pip install -r requirements.txt

RUN mkdir /covid19-reproductionNumber/src
ADD src/* /covid19-reproductionNumber/src

CMD ["python", "src/reff_estimator.py"]
