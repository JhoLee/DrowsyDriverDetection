FROM nvida/cuda:8.0-cudnn5-devel-ubuntu14.04

MAINTAINER Jho Lee <jho.lee@kakao.com>

ARG TENSORFLOW_VERSION=0.12.1
ARG TENSORFLOW_ARCH=gpu
ARG KERAS_VERSION=1.2.0
ARG LASGNE_VERSION=v0.1
ARG TORCH_VERSION=latest
ARG CAFFE_VERSIOIN=master

# Install dependencies
RUN apt-get update && apt-get install -y \
            bc \
            build-essential \
            cmake \
            curl \
            g++ \
            gfortran \
            git \
            libffi-dev \
            libfreetype6-dev \
            libhdf5-dev \
            libjpeg-dev \
            liblcms2-dev \
            libopenblas-dev \
            liblapack-dev \
            libopenjpeg2 \
            libpng12-dev \
            libssl-dev \
            libtiff5-dev \
            libwebp-dev \
            libzmq3-dev \
            nano \
            pkg-config \
            python-dev \
            software-properties-common \
            unzip \
            vim \
            wget \
            zlib1g-dev \
		    qt5-default \
		    libvtk6-dev \
		    zlib1g-dev \
		    libjpeg-dev \
		    libwebp-dev \
		    libpng-dev \
		    libtiff5-dev \
		    libjasper-dev \
		    libopenexr-dev \
		    libgdal-dev \
		    libdc1394-22-dev \
		    libavcodec-dev \
		    libavformat-dev \
		    libswscale-dev \
		    libtheora-dev \
		    libvorbis-dev \
		    libxvidcore-dev \
		    libx264-dev \
		    yasm \
		    libopencore-amrnb-dev \
		    libopencore-amrwb-dev \
		    libv4l-dev \
		    libxine2-dev \
		    libtbb-dev \
		    libeigen3-dev \
		    python-dev \
		    python-tk \
		    python-numpy \
		    python3-dev \
		    python3-tk \
		    python3-numpy \
		    ant \
		    default-jdk \
		    doxygen \
		    && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3


RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
        python get-pip.py && \
        rm get-pip.py


RUN pip --no-cache-dir install \
            pyopenssl \
            ndg-httpsclient \
            pyasn1

RUN apt-get update && apt-get install -y \
		python-numpy \
		python-scipy \
		python-nose \
		python-h5py \
		python-skimage \
		python-matplotlib \
		python-pandas \
		python-sklearn \
		python-sympy \
		&& \
	apt-get clean && \
	apt-get autoremove && \
	rm -rf /var/lib/apt/lists/*

RUN pip --no-cache-dir install --upgrade ipython && \
	pip --no-cache-dir install \
		Cython \
		ipykernel \
		jupyter \
		path.py \
		Pillow \
		pygments \
		six \
		sphinx \
		wheel \
		zmq \
		&& \
	python -m ipykernel.kernelspec


RUN pip --no-cache-dir install \
	https://storage.googleapis.com/tensorflow/linux/${TENSORFLOW_ARCH}/tensorflow_${TENSORFLOW_ARCH}-${TENSORFLOW_VERSION}-cp27-none-linux_x86_64.whl

RUN pip --no-cache-dir install git+git://github.com/fchollet/keras.git@${KERAS_VERSION}

RUN git clone --depth 1 https://github.com/opencv/opencv.git /root/opencv && \
	cd /root/opencv && \
	mkdir build && \
	cd build && \
	cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DWITH_XINE=ON -DBUILD_EXAMPLES=ON .. && \
	make -j"$(nproc)"  && \
	make install && \
	ldconfig && \
	echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc

# Set up notebook config
COPY jupyter_notebook_config.py /root/.jupyter/

# Jupyter has issues with being run directly: https://github.com/ipython/ipython/issues/7062
COPY run_jupyter.sh /root/

# Expose Ports for TensorBoard (6006), Ipython (8888)
EXPOSE 6006 8888

COPY . /src


WORKDIR "/root"
CMD ["/bin/bash"]