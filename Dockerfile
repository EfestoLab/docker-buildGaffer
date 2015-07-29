############################################################
# Dockerfile to build gafferDependencies
# Based on centos6

# BUILD WITH : sudo docker build -t <your_namespace>/gaffer .
# RUN WITH: docker run --rm -it -v `pwd`/volume:/gaffer <your_namespace>/gaffer
# The build will then be available in ./volume/gaffer-${GAFFER_VERSION}

# maintained by
# http://www.efestolab.uk
# for informations : info@efestolab.uk

# BASED ON GAFFER 0.15.0

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

# references used for the build:
# https://github.com/danbethell/vfxbits/blob/master/cortex/download.bash
# https://github.com/johnhaddon/gafferDependencies/tree/master/build

# NOTE:
# The build take long time, and around 9Gb of space.
# If the build hangs or crash try to lower BUILD_PROCS variable

FROM centos:6
MAINTAINER Efesto Lab LTD version: 0.1

ENV GAFFER_VERSION 0.15.0.0

ENV OUT_FOLDER gaffer
ENV BUILD_PROCS 7
ENV BUILD_DIR /opt/gaffer-${GAFFER_VERSION}

ENV PATH $BUILD_DIR/bin:$PATH

ENV LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH

# Add custom user
RUN useradd gaffer

# basic tools
RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install \
    wget \
    cmake \
    openssl-devel \
    openssl \
    sqlite-devel \
    sqlite \
    glibc-devel.x86_64 \
    glibc-devel.i686 \
    libicu-devel\
    libicu \
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
    $BUILD_DIR/bin/python setup.py install;


#----------------------------------------------
# build and install boost
#----------------------------------------------
# Isn't DYNLIB just for macos ?
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
    cp build/*_release/*.so* $BUILD_DIR/lib &&\
    cp -R include/* $BUILD_DIR/include/;

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

#----------------------------------------------
# build and install OIIO
#----------------------------------------------
RUN wget https://github.com/OpenImageIO/oiio/archive/Release-1.5.17.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/Release-1.5.17.tar.gz &&\
    cd oiio-Release-1.5.17 &&\
    mkdir -p gafferBuild &&\
    cd gafferBuild &&\
    rm -f CMakeCache.txt &&\
    cmake \
        -D CMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -D CMAKE_PREFIX_PATH=$BUILD_DIR \
        .. &&\
    make && \
    make install

#----------------------------------------------
# build and install LLVM
#http://www.linuxfromscratch.org/blfs/view/7.5/general/llvm.html
#----------------------------------------------
ENV CXX g++
ENV CC gcc
ENV REQUIRES_RTTI 1

# here a potential mirror if llvm is slow
RUN wget ftp://ftp.osuosl.org/.1/blfs/conglomeration/llvm/llvm-3.4.src.tar.gz -P /tmp &&\
    wget ftp://ftp.osuosl.org/.1/blfs/conglomeration/clang/clang-3.4.src.tar.gz -P /tmp &&\
    wget ftp://ftp.osuosl.org/.1/blfs/conglomeration/compiler-rt/compiler-rt-3.4.src.tar.gz -P /tmp

# RUN wget http://llvm.org/releases/3.4/llvm-3.4.src.tar.gz -P /tmp && \
#     wget http://llvm.org/releases/3.4/clang-3.4.src.tar.gz -P /tmp && \
#     wget http://llvm.org/releases/3.4/compiler-rt-3.4.src.tar.gz -P /tmp

RUN cd /tmp &&\
    tar -zxvf /tmp/llvm-3.4.src.tar.gz &&\
    cd llvm-3.4 &&\
    tar -xf ../clang-3.4.src.tar.gz -C tools && \
    tar -xf ../compiler-rt-3.4.src.tar.gz -C projects && \
    mv tools/clang-3.4 tools/clang &&\
    mv projects/compiler-rt-3.4 projects/compiler-rt &&\
    ./configure \
        --prefix=$BUILD_DIR \
        --enable-shared \
        --enable-optimized \
        --enable-assertions=no &&\
    make VERBOSE=1 -j ${BUILD_PROCS} && \
    make install


#----------------------------------------------
# build and install OSL
#----------------------------------------------
RUN wget https://github.com/imageworks/OpenShadingLanguage/archive/Release-1.6.8.tar.gz -P /tmp
ENV DYLD_LIBRARY_PATH $BUILD_DIR/lib
ENV LD_LIBRARY_PATH $BUILD_DIR/lib
RUN cd /tmp &&\
    tar -zxvf /tmp/Release-1.6.8.tar.gz &&\
    cd OpenShadingLanguage-Release-1.6.8 &&\
    mkdir -p gafferBuild &&\
    cd gafferBuild &&\
    rm -f CMakeCache.txt && \
    cmake \
    -D ENABLERTTI=1 \
    -D CMAKE_INSTALL_PREFIX=$BUILD_DIR \
    -D CMAKE_PREFIX_PATH=$BUILD_DIR \
    -D STOP_ON_WARNING=0 \
    .. &&\
    make && \
    make install

#----------------------------------------------
# build and install hdf5
#----------------------------------------------
RUN wget https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.11/src/hdf5-1.8.11.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/hdf5-1.8.11.tar.gz &&\
    cd hdf5-1.8.11 &&\
    ./configure \
        --prefix=$BUILD_DIR \
        --enable-threadsafe \
        --with-pthread=/usr/include &&\
     make clean && \
     make -j ${BUILD_PROCS} && \
     make install

#----------------------------------------------
# build and install alembic
#----------------------------------------------
# P1: https://github.com/johnhaddon/gafferDependencies/blob/master/build/buildAlembic.sh
# P2: https://code.google.com/p/alembic/issues/detail?id=343

RUN wget https://github.com/alembic/alembic/archive/1.5.8.zip -P /tmp
RUN cd /tmp &&\
    unzip /tmp/1.5.8.zip -d /tmp &&\
    cd alembic-1.5.8 &&\
    sed -i '/SET( Boost_USE_STATIC_LIBS TRUE )/d' build/AlembicBoost.cmake &&\
    sed -i 's/SET( ALEMBIC_GL_LIBS GLEW ${GLUT_LIBRARY} ${OPENGL_LIBRARIES} )/FIND_PACKAGE( GLEW )\n SET( ALEMBIC_GL_LIBS ${GLEW_LIBRARY} ${GLUT_LIBRARY} ${OPENGL_LIBRARIES} )/g' CMakeLists.txt &&\
    rm -f CMakeCache.txt &&\
    cmake \
        -D CMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -D CMAKE_PREFIX_PATH=$BUILD_DIR \
        -D Boost_NO_SYSTEM_PATHS=TRUE \
        -D Boost_NO_BOOST_CMAKE=TRUE \
        -D BOOST_ROOT=$BUILD_DIR \
        -D ILMBASE_ROOT=$BUILD_DIR \
        -D USE_PYILMBASE=FALSE \
        -D USE_PYALEMBIC=FALSE \
        -D USE_ARNOLD=FALSE \
        -D USE_PRMAN=FALSE \
        -D USE_MAYA=FALSE \
        . &&\
    make clean &&\
    make -j ${BUILD_PROCS} &&\
    make install &&\
    mv $BUILD_DIR/alembic-*/include/* $BUILD_DIR/include &&\
    mv $BUILD_DIR/alembic-*/lib/static/* $BUILD_DIR/lib

#----------------------------------------------
# build and install xerces
#----------------------------------------------
RUN wget https://www.apache.org/dist/xerces/c/3/sources/xerces-c-3.1.2.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/xerces-c-3.1.2.tar.gz &&\
    cd xerces-c-3.1.2 &&\
    ./configure \
        --prefix=$BUILD_DIR &&\
    make -j ${BUILD_PROCS} &&\
    make install

#----------------------------------------------
# build and install appleseed
#----------------------------------------------
RUN wget https://github.com/appleseedhq/appleseed/archive/1.2.0-beta.zip -P /tmp
RUN cd /tmp &&\
    unzip /tmp/1.2.0-beta.zip -d /tmp &&\
    cd appleseed-1.2.0-beta &&\
    mkdir -p sandbox/bin &&\
    mkdir -p sandbox/schemas &&\
    mkdir -p build &&\
    cd build &&\
    rm -f CMakeCache.txt &&\
    cmake \
        -D WITH_CLI=ON \
        -D WITH_STUDIO=OFF \
        -D WITH_TOOLS=OFF \
        -D WITH_PYTHON=ON \
        -D WITH_OSL=ON \
        -D USE_STATIC_BOOST=OFF \
        -D USE_STATIC_OIIO=OFF \
        -D USE_STATIC_OSL=OFF \
        -D USE_EXTERNAL_ZLIB=ON \
        -D USE_EXTERNAL_EXR=ON \
        -D USE_EXTERNAL_PNG=ON \
        -D USE_EXTERNAL_XERCES=ON \
        -D USE_EXTERNAL_OSL=ON \
        -D USE_EXTERNAL_OIIO=ON \
        -D USE_EXTERNAL_ALEMBIC=ON \
        -D CMAKE_PREFIX_PATH=$BUILD_DIR \
        -D CMAKE_INSTALL_PREFIX=$BUILD_DIR/appleseed \
        .. &&\
    make clean &&\
    make -j ${BUILD_PROCS} &&\
    make install

#----------------------------------------------
# build and install cortex
#----------------------------------------------
# TODO : Fix ARNOLD_ROOT

# Download 3delight installation
RUN wget -O /tmp/3delight-Linux-x86_64.tar.xz http://www.3delight.com/downloads/free/3delight-Linux-x86_64.tar.xz.php
RUN cd /tmp &&\
    tar -xJf 3delight-Linux-x86_64.tar.xz

RUN git clone https://github.com/ImageEngine/cortex.git /tmp/cortex &&\
    cd /tmp/cortex &&\
    git checkout 9.0.0-b9

RUN yum -y install scons
ENV LD_LIBRARY_PATH $BUILD_DIR/lib
RUN wget http://johanneskopf.de/publications/blue_noise/tilesets/tileset_2048.dat -P $BUILD_DIR/resources/cortex

# set DELIGHT environment
ENV DELIGHT /tmp/3delight-12.0.12-Linux-x86_64/3delight/Linux-x86_64

RUN cd /tmp/cortex &&\
    rm -rf .sconsign.dblite .sconf_temp &&\
    scons install installDoc \
        -j 3 \
        TBB_INCLUDE_PATH=$BUILD_DIR/include \
        TBB_LIB_PATH=$BUILD_DIR/include \
        INSTALL_PREFIX=$BUILD_DIR \
        INSTALL_DOC_DIR=$BUILD_DIR/doc/cortex \
        INSTALL_RMANPROCEDURAL_NAME=$BUILD_DIR/renderMan/procedurals/iePython \
        INSTALL_RMANDISPLAY_NAME=$BUILD_DIR/renderMan/displayDrivers/ieDisplay \
        INSTALL_PYTHON_DIR=$BUILD_DIR/python \
        INSTALL_ARNOLDPROCEDURAL_NAME=$BUILD_DIR/arnold/procedurals/ieProcedural.so \
        INSTALL_ARNOLDOUTPUTDRIVER_NAME=$BUILD_DIR/arnold/outputDrivers/ieOutputDriver.so \
        INSTALL_IECORE_OPS='' \
        PYTHON_CONFIG=$BUILD_DIR/bin/python-config \
        BOOST_INCLUDE_PATH=$BUILD_DIR/include/boost \
        LIBPATH=$BUILD_DIR/lib \
        BOOST_LIB_SUFFIX='' \
        OPENEXR_INCLUDE_PATH=$BUILD_DIR/include \
        FREETYPE_INCLUDE_PATH=$BUILD_DIR/include/freetype2 \
        RMAN_ROOT=$DELIGHT \
        WITH_GL=1 \
        GLEW_INCLUDE_PATH=$BUILD_DIR/include/GL \
        RMAN_ROOT=$RMAN_ROOT \
        NUKE_ROOT= \
        ARNOLD_ROOT=$ARNOLD_ROOT \
        APPLESEED_ROOT=$BUILD_DIR/appleseed \
        APPLESEED_INCLUDE_PATH=$BUILD_DIR/appleseed/include \
        APPLESEED_LIB_PATH=$BUILD_DIR/appleseed/lib \
        ENV_VARS_TO_IMPORT=LD_LIBRARY_PATH \
        OPTIONS='' \
        SAVE_OPTIONS=gaffer.options


#----------------------------------------------
# build and install PyOpenGL
#----------------------------------------------

ENV LD_LIBRARY_PATH $BUILD_DIR/lib
ENV DYLD_FRAMEWORK_PATH $BUILD_DIR/lib

RUN wget https://pypi.python.org/packages/source/P/PyOpenGL/PyOpenGL-3.0.2.tar.gz -P /tmp
RUN cd /tmp &&\
    tar -zxvf /tmp/PyOpenGL-3.0.2.tar.gz &&\
    cd PyOpenGL-3.0.2 &&\
    $BUILD_DIR/bin/python setup.py install \
        --prefix $BUILD_DIR \
        --install-lib $BUILD_DIR/python


#----------------------------------------------
# build and install Qt
#----------------------------------------------
ENV LD_LIBRARY_PATH $BUILD_DIR/lib
ENV DYLD_FRAMEWORK_PATH $BUILD_DIR/lib

RUN wget http://download.qt.io/archive/qt/4.8/4.8.5/qt-everywhere-opensource-src-4.8.5.tar.gz -P /tmp ;
RUN cd /tmp && \
    tar -zxvf qt-everywhere-opensource-src-4.8.5.tar.gz && \
    cd qt-everywhere-opensource-src-4.8.5 && \
    ./configure \
        -prefix $BUILD_DIR \
        -opensource \
        -confirm-license \
        -no-rpath \
        -no-declarative \
        -no-gtkstyle \
        -no-qt3support \
        -no-multimedia \
        -no-audio-backend \
        -no-webkit \
        -no-script \
        -no-dbus \
        -no-declarative \
        -no-svg \
        -nomake examples \
        -nomake demos \
        -nomake tools \
        -I $BUILD_DIR/include \
        -I $BUILD_DIR/include/freetype2 \
        -L $BUILD_DIR/lib &&\
    make -j ${BUILD_PROCS} && \
    make install


# #----------------------------------------------
# # build and install PySide
# #----------------------------------------------

RUN wget http://download.qt-project.org/official_releases/pyside/pyside-qt4.8+1.2.2.tar.bz2 -P /tmp &&\
    wget http://download.qt-project.org/official_releases/pyside/shiboken-1.2.2.tar.bz2 -P /tmp

ENV PYTHON_VERSION 2.7

RUN cd /tmp &&\
    tar -jxvf /tmp/pyside-qt4.8+1.2.2.tar.bz2 &&\
    tar -jxvf /tmp/shiboken-1.2.2.tar.bz2 &&\
    cd /tmp/shiboken-1.2.2 &&\
    rm -f build &&\
    mkdir build &&\
    cd build &&\
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DPYTHON_SITE_PACKAGES=$BUILD_DIR/python \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DPYTHON_EXECUTABLE=$BUILD_DIR/bin/python \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        -DPYTHON_INCLUDE_DIR=$BUILD_DIR/include/python$PYTHON_VERSION &&\
    make clean && \
    make VERBOSE=1 -j ${BUILD_PROCS} &&\
    make install &&\
    cd /tmp/pyside-qt4.8+1.2.2 &&\
    rm -f build &&\
    mkdir build &&\
    cd build &&\
    cmake \
        -D CMAKE_BUILD_TYPE=Release \
        -D SITE_PACKAGE=$BUILD_DIR/python \
        -D CMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -D ALTERNATIVE_QT_INCLUDE_DIR=$BUILD_DIR/include \
        .. &&\
    make clean && \
    make VERBOSE=1 -j ${BUILD_PROCS} &&\
    make install;

# #----------------------------------------------
# # build and install Gaffer
# #----------------------------------------------
RUN yum -y install inkscape doxygen
RUN git clone https://github.com/ImageEngine/gaffer.git /tmp/gaffer &&\
    cd /tmp/gaffer &&\
    git checkout 0.15.0.0 &&\
    scons BUILD_DIR=$BUILD_DIR build


# #----------------------------------------------
# # manually copy some missing libs
# #----------------------------------------------
RUN cp /usr/lib64/libicu* $BUILD_DIR/lib

# #----------------------------------------------
# # prepare the output
# #----------------------------------------------
RUN chown -R gaffer:gaffer /opt
VOLUME /$OUT_FOLDER
CMD cp -Rf -v /opt/* /$OUT_FOLDER && bash
