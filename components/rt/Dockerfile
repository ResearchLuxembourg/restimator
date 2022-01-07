# Build from the MATLAB base image
FROM mathworks/matlab:r2021b

# create the working directory
RUN mkdir /home/matlab/covid19-reproductionNumber
WORKDIR /home/matlab/covid19-reproductionNumber

# add source files
RUN mkdir /home/matlab/covid19-reproductionNumber/src
RUN mkdir /home/matlab/covid19-reproductionNumber/output
RUN mkdir /home/matlab/covid19-reproductionNumber/input

ADD src/* /home/matlab/covid19-reproductionNumber/src

# execute the pipeline
CMD ["matlab"]
