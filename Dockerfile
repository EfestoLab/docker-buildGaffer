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

FROM centos:6
MAINTAINER Efesto Lab LTD version: 0.1

ENV OUT_FOLDER vfxlib
ENV BUILD_PROCS 7
ENV BUILD_DIR /opt/gafferDependencies
ENV PATH $BUILD_DIR/bin:$PATH

ENV LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH

# Add custom user
RUN useradd vfx

# basic tools
RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install \
    wget \
    cmake \
    openssl-devel \
    sqlite-devel \
    glibc-devel.x86_64 \
    glibc-devel.i686 \
    libicu-devel\
    wget \
    git \
    tar \
    bzip2 \
    bzip2-devel;


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
ENV DYLD_FALLBACK_FRAMEWORK_PATH=$BUILD_DIR/lib
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

#----------------------------------------------
# build and install JPEG
#----------------------------------------------
RUN wget http://www.ijg.org/files/jpegsrc.v8c.tar.gz  -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/jpegsrc.v8c.tar.gz && \
    cd /tmp/jpeg-8c && \
    ./configure \
        --prefix=$BUILD_DIR && \
    make clean && \
    make && \
    make install;

#----------------------------------------------
# build and install TIFF
#----------------------------------------------
RUN wget http://libtiff.maptools.org/dl/tiff-3.8.2.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/tiff-3.8.2.tar.gz && \
    cd /tmp/tiff-3.8.2 && \
    ./configure \
        --prefix=$BUILD_DIR && \
        make clean && \
        make && \
        make install;

#----------------------------------------------
# build and install PNG
#----------------------------------------------
# this seems to be a slow ftp, better look for something faster once it works...

RUN wget ftp://ftp.simplesystems.org/pub/libpng/png/src/history/libpng16/libpng-1.6.3.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/libpng-1.6.3.tar.gz && \
    cd /tmp/libpng-1.6.3 && \
    ./configure \
        --prefix=$BUILD_DIR && \
    make clean && \
    make && \
    make install;

#----------------------------------------------
# build and install Freetype
#----------------------------------------------
RUN wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.12.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/freetype-2.4.12.tar.gz && \
    cd /tmp/freetype-2.4.12 && \
    ./configure \
        --prefix=$BUILD_DIR && \
    make clean && \
    make && \
    make install;


#----------------------------------------------
# build and install TBB
#----------------------------------------------
ENV CXX gcc
RUN wget https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb42_20140601oss_src.tgz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/tbb42_20140601oss_src.tgz && \
    cd /tmp/tbb42_20140601oss && \
    make clean && \
    make compiler=$CXX && \
    cp build/*_release/*.so* $BUILD_DIR/lib;

#----------------------------------------------
# build and install OPENEXR
#----------------------------------------------
RUN wget http://download.savannah.nongnu.org/releases/openexr/openexr-2.1.0.tar.gz -P /tmp &&\
    wget http://download.savannah.nongnu.org/releases/openexr/ilmbase-2.1.0.tar.gz -P /tmp;

RUN cd /tmp &&\
    tar -zxvf /tmp/ilmbase-2.1.0.tar.gz &&\
    cd /tmp/ilmbase-2.1.0 &&\
    ./configure \
        CC=gcc \
        CXX=g++ \
        --prefix=$BUILD_DIR && \
    make clean && \
    make  -j ${BUILD_PROCS} && \
    make install;

RUN cd /tmp &&\
    tar -zxvf /tmp/openexr-2.1.0.tar.gz &&\
    cd /tmp/openexr-2.1.0 &&\
    ./configure \
        CC=gcc \
        CXX=g++ \
        --prefix=$BUILD_DIR && \
    make clean && \
    make  -j ${BUILD_PROCS} && \
    make install;

#----------------------------------------------
# build and install FONTS
#----------------------------------------------
RUN wget http://ftp.gnome.org/pub/GNOME/sources/ttf-bitstream-vera/1.10/ttf-bitstream-vera-1.10.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/ttf-bitstream-vera-1.10.tar.gz &&\
    cd /tmp/ttf-bitstream-vera-1.10 &&\
    mkdir -p $BUILD_DIR/fonts && \
    cp *.ttf $BUILD_DIR/fonts;

#----------------------------------------------
# build and install GLEW
#----------------------------------------------
RUN yum install -y glut glut-devel libXmu-devel libXi-devel
RUN wget http://downloads.sourceforge.net/project/glew/glew/1.7.0/glew-1.7.0.tgz -P /tmp
RUN mkdir -p $BUILD_DIR/lib64/pkgconfig &&\
    cd /tmp &&\
    tar -zxvf /tmp/glew-1.7.0.tgz &&\
    cd /tmp/glew-1.7.0 &&\
    make clean && \
    make install GLEW_DEST=$BUILD_DIR LIBDIR=$BUILD_DIR/lib;


#----------------------------------------------
# build and install OCIO
#----------------------------------------------
ENV CXX g++
RUN wget https://github.com/imageworks/OpenColorIO/archive/v1.0.8.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/v1.0.8.tar.gz &&\
    cd /tmp/OpenColorIO-1.0.8 &&\
    cmake \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DOCIO_BUILD_TRUELIGHT=OFF \
        -DOCIO_BUILD_APPS=OFF \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DOCIO_BUILD_NUKE=OFF &&\
    make clean && \
    make -j ${BUILD_PROCS} && \
    make install;

RUN mkdir -p $BUILD_DIR/python &&\
    mv $BUILD_DIR/lib/python*/site-packages/PyOpenColorIO* $BUILD_DIR/python

RUN wget http://github.com/imageworks/OpenColorIO-Configs/archive/v1.0_r2.tar.gz -P /tmp
RUN mkdir -p $BUILD_DIR/openColorIO &&\
    cd /tmp &&\
    tar -zxvf /tmp/v1.0_r2.tar.gz &&\
    cd /tmp/OpenColorIO-Configs-1.0_r2 &&\
    cp nuke-default/config.ocio $BUILD_DIR/openColorIO &&\
    cp -r nuke-default/luts $BUILD_DIR/openColorIO;
