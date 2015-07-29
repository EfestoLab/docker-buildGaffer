Gaffer Dependencies
===================

Dockerfile for building gaffer and its dependencies.

DockerFile
==========

Based on centos6

BUILD WITH : sudo docker build -t <your_namespace>/gafferDependencies .
RUN WITH: docker run --rm -it -v `pwd`/volume:/vfxlib <your_namespace>/gafferDependencies
All the libraries will be then available in ./volume

maintained by
http://www.efestolab.uk
for informations : info@efestolab.uk

BASED ON GAFFER 0.15.0
======================

Python-2.7.5
subprocess32-3.2.6
boost_1_51_0
jpeg-8c
tiff-3.8.2
libpng-1.6.3
freetype-2.4.12
tbb42_20140601oss
ilmbase-2.1.0
openexr-2.1.0
ttf-bitstream-vera-1.10
glew-1.7.0
OpenColorIO-1.0.8
oiio-Release-1.5.17
llvm-3.4
OpenShadingLanguage-Release-1.6.8
hdf5-1.8.11
alembic-1.5.8
xerces-c-3.1.2
appleseed-1.2.0-beta
cortex-9.0.0
PyOpenGL-3.0.2
qt-everywhere-opensource-src-4.8.5
shiboken-1.2.2
pyside-qt4.8+1.2.2

references used for the build:
------------------------------
https://github.com/danbethell/vfxbits/blob/master/cortex/download.bash
https://github.com/johnhaddon/gafferDependencies/tree/master/build

NOTE:
-----
The build take long time, and around 6.5Gb of space, it will also eat all your cookies.
If the build hangs or crash try to lower BUILD_PROCS variable
