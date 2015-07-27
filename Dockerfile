# Python-2.7.5
# subprocess32-3.2.6
# boost_1_51_0
# jpeg-8c
# tiff-3.8.2
# libpng-1.6.3
# freetype-2.4.12
# tbb42_20140601oss
# ilmbase-2.1.0
# openexr-2.1.0
# ttf-bitstream-vera-1.10
# glew-1.7.0
# OpenColorIO-1.0.8
# oiio-Release-1.5.17
# llvm-3.4
# OpenShadingLanguage-Release-1.6.8
# hdf5-1.8.11
# alembic-1.5.8
# xerces-c-3.1.2
# appleseed-1.2.0-beta
# cortex-9.0.0
# PyOpenGL-3.0.2
# qt-everywhere-opensource-src-4.8.5
# shiboken-1.2.2
# pyside-qt4.8+1.2.2
# imageworks-OpenColorIO-8883824
# imageworks-OpenColorIO-Configs-f931d77

FROM centos:7
MAINTAINER Efesto Lab LTD version: 0.1

ENV OUT_FOLDER vfxlib
ENV BUILD_PROCS 7
ENV BUILD_DIR /opt/gafferDependencies
ENV PATH $BUILD_DIR/bin:$PATH

ENV LD_LIBRARY_PATH=$BUILD_DIR/lib

# Add custom user
RUN useradd vfx

# basic tools
RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install \
    wget \
    cmake \
    openssl-devel \
    sqlite-devel;


# create build dir
RUN mkdir -p $BUILD_DIR;

#----------------------------------------------
# build and install PYTHON
#----------------------------------------------
RUN wget https://www.python.org/ftp/python/2.7.5/Python-2.7.5.tar.bz2 -P /tmp;

RUN cd /tmp && \
    tar -jxvf /tmp/Python-2.7.5.tar.bz2 && \
    cd /tmp/Python-2.7.5 && \
    ./configure \
         --prefix=$BUILD_DIR \
         --enable-unicode=ucs4 \
         --enable-shared && \
    make clean && \
    make -j $BUILD_PROCS && \
    make install;


#----------------------------------------------
# build and install subprocess
#----------------------------------------------
RUN wget https://pypi.python.org/packages/source/s/subprocess32/subprocess32-3.2.6.tar.gz -P /tmp;
RUN cd /tmp && \
    tar -zxvf /tmp/subprocess32-3.2.6.tar.gz && \
    cd subprocess32-3.2.6 && \
    python setup.py install;


#----------------------------------------------
# build and install boost
#----------------------------------------------
RUN wget http://downloads.sourceforge.net/project/boost/boost/1.51.0/boost_1_51_0.tar.bz2 -P /tmp
RUN cd /tmp &&\
    tar -jxvf /tmp/boost_1_51_0.tar.bz2 &&\
    cd /tmp/boost_1_51_0 &&\
    ./bootstrap.sh \
        --prefix=$BUILD_DIR \
        --with-python=$BUILD_DIR/bin/python \
        --with-python-root=$BUILD_DIR && \
    ./bjam \
        -d+2 \
        variant=release \
        link=shared \
        threading=multi \
        install;
