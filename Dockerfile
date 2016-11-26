# Version: 1
# Name: agdc2 (agdc-v2)
# for Python 3.5

FROM yan047/anaconda3

MAINTAINER "boyan.au@gmail.com"

# In case someone loses the Dockerfile
RUN rm -rf /etc/Dockerfile
ADD Dockerfile /etc/Dockerfile

# set environment variables
ENV WORK_BASE /var/rs

# must run with user root
USER root

WORKDIR "$WORK_BASE"

# install dependencies
RUN conda install psycopg2 gdal libgdal hdf5 rasterio netcdf4 libnetcdf pandas -y --quiet

# download and build agdc v2 

RUN git clone https://github.com/data-cube/agdc-v2 
WORKDIR "$WORK_BASE"/agdc-v2

RUN git checkout develop 
RUN python setup.py install

