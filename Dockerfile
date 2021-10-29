FROM python:3.9
RUN export DEBIAN_FRONTEND="noninteractive"
ENV APP_HOME /app

RUN apt-get update && \
	apt-get install -qq -y \
		build-essential \
		autotools-dev \
		automake \
		cmake \
		libboost-all-dev \
		libeigen3-dev \
		libopencv-dev \
		cimg-dev \
		cimg-doc \
		cimg-examples \
		libpng-dev \
		libpng++-dev \
		git \
		potrace \
		graphicsmagick-imagemagick-compat \
		ffmpeg \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $APP_HOME/
# RUN cd /app && \
# 	git clone https://github.com/davidstutz/glog && \
# 	cd glog && \
# 	git reset --hard 0b0b022 && \
# 	./configure && \
# 	make

# libglog 0.3.3 is needed, edit cmake/FindGlog.cmake if using below
RUN apt-get update && \
	apt-get install -qq -y \
		libgoogle-glog-dev \
		libpcl-dev \
		libusb-1.0-0 \
		libopenni2-0 \
		libpcap0.8 \
		#python3-vtk7 \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# python-vtk bc of imported target warnings at build time.

RUN cd /usr/local/include && \
	ln -sf eigen3/Eigen Eigen
	#ln -sf eigen3/unsupported unsupported
# Superpixel comparison benchmarks
COPY ./superpixel-benchmark $APP_HOME/super
RUN cd /app/super && \
	mkdir build && \
	cd build && \
	#cmake .. -DGLOG_ROOT_DIR=/app/glog && \
	cmake .. && \
	make

# API components
COPY api/app.py $APP_HOME/
WORKDIR $APP_HOME

RUN pip install Flask requests
CMD ["python", "app.py"]
