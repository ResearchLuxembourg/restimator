ARG PYTHON_VERSION=3.9

FROM python:${PYTHON_VERSION}-slim

RUN mkdir /covid19-reproductionNumber
ADD . /covid19-reproductionNumber
WORKDIR /covid19-reproductionNumber

COPY requirements.txt /covid19-reproNumber/requirements.txt
RUN pip install -r requirements.txt

CMD ["python", "src/reff_estimator.py"]
