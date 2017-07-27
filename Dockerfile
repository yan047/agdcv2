# Version: 1.5
# Name: agdc2 (agdc-v2)
# for Python 3.5

FROM yan047/anaconda3

MAINTAINER "boyan.au@gmail.com"

# In case someone loses the Dockerfile
RUN rm -rf /etc/Dockerfile
COPY Dockerfile /etc/Dockerfile

# install gcc for compiling SharedArray
RUN apt-get update && apt-get install -y gcc

# set environment variables
ENV WORK_BASE /var/agdc
ENV DATACUBE_CONFIG_DIR "$WORK_BASE"/config
ENV DATACUBE_DATA_DIR "$WORK_BASE"/data
ENV DATACUBE_OUTPUT_DIR "$WORK_BASE"/output

# must run with user root
USER root

# create directories
RUN mkdir -p "$WORK_BASE" && \
    mkdir -p "$DATACUBE_CONFIG_DIR" && \
    mkdir -p "$DATACUBE_DATA_DIR" && \
    mkdir -p "$DATACUBE_OUTPUT_DIR"

# copy configuration files to image, and create links to /root 
COPY datacube.conf "$DATACUBE_CONFIG_DIR"
COPY pgpass "$DATACUBE_CONFIG_DIR"
RUN ln -sf "$DATACUBE_CONFIG_DIR"/datacube.conf /root/.datacube.conf && \
    ln -sf "$DATACUBE_CONFIG_DIR"/pgpass /root/.pgpass  && \
    chmod 0600 /root/.pgpass

# change to work directory
WORKDIR "$WORK_BASE"

# install dependencies
RUN conda install boto3=1.4.3 -y --quiet 
RUN conda install psycopg2 gdal libgdal hdf5 rasterio netcdf4 libnetcdf pandas -y --quiet
RUN conda config --add channels conda-forge && \
	conda install zstandard dill -y --quiet

# download and build agdc-v2 develop branch
# https://github.com/opendatacube/datacube-core/
RUN git clone https://github.com/opendatacube/datacube-core 

# change to source directory
WORKDIR "$WORK_BASE"/datacube-core

RUN python setup.py install

# the following language settings are required by datacube commands, to be compatible with OS settings.
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
