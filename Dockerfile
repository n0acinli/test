FROM ubuntu:20.04

## Who am i
MAINTAINER n0acinli <a.palilov@me.com>

## Where am i
WORKDIR /tmp/builddir/
RUN cd /

##Zone
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## update repos
RUN apt-get update

## install all tools
RUN apt-get install -y ffmpeg gcc make git gzip unzip wget zlib1g-dev i965-va-driver intel-media-va-driver libass9 libcairo2 libgraphite2-3 libgsm1 libharfbuzz0b libigdgmm11 libmp3lame0 libopencore-amrnb0 libopencore-amrwb0 libopenjp2-7 libpixman-1-0 libspeex1 libtheora0 libva-drm2 libva-x11-2 libva2 libvdpau1 libvpx6 libx264-155 libx265-179 libxcb-render0 libxcb-shm0 libxvidcore4 libzvbi-common libzvbi0 mesa-va-drivers mesa-vdpau-drivers va-driver-all vdpau-driver-all x265 libxml2 libpcre3 libpcre3-dev

#download source, test, conf, custom index.html, custom test.json
RUN cd /tmp/builddir/
RUN wget https://dectures.s3.eu-central-1.amazonaws.com/rnd-test-master.zip 
RUN wget https://nginx.org/download/nginx-1.19.5.tar.gz
RUN git clone https://github.com/kaltura/nginx-vod-module.git
RUN git clone https://github.com/n0acinli/test.git


#generate video.mp4
RUN ffmpeg -f lavfi -i testsrc=duration=30:size=1280x720:rate=30 video.mp4

#unrar 0_o
RUN tar -xf nginx-1.19.5.tar.gz
RUN unzip rnd-test-master.zip


#install all
RUN mkdir /tmp/builddir/nginx-1.19.5/nginx-vod-module/
RUN cp -a /tmp/builddir/nginx-vod-module/* /tmp/builddir/nginx-1.19.5/nginx-vod-module/
WORKDIR /tmp/builddir/nginx-1.19.5/
RUN ./configure --add-module=/tmp/builddir/nginx-1.19.5/nginx-vod-module
RUN make
RUN make install

#delete all
RUN rm /usr/local/nginx/conf/nginx.conf
RUN rm /usr/local/nginx/html/index.html

#Copy files
RUN cp -a /tmp/builddir/rnd-test-master/player/* /usr/local/nginx/html/
RUN rm /usr/local/nginx/html/player-dash.html
RUN cp /tmp/builddir/video.mp4 /usr/local/nginx/html/
RUN cp /tmp/builddir/test/test.json /usr/local/nginx/html/
RUN cp /tmp/builddir/test/nginx.conf /usr/local/nginx/conf/nginx.conf
RUN cp /tmp/builddir/test/index.html /usr/local/nginx/html/
RUN cp /tmp/builddir/test/player-dash.html /usr/local/nginx/html/


