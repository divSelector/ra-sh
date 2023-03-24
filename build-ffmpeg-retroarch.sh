RETROARCH_BUILD_PATH="$HOME/retroarch"
FFMPEG_SOURCE_PATH="$HOME/ffmpeg_sources"
FFMPEG_BUILD_PATH="$HOME/ffmpeg_build"
BIN_PATH="$HOME/bin"

apt-get update -qq && apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libunistring-dev \
  meson \
  ninja-build \
  pkg-config \
  texinfo \
  wget \
  yasm \
  zlib1g-dev \
  libx11-xcb-dev

mkdir -p "$FFMPEG_SOURCE_PATH" ~/bin && \

cd "$FFMPEG_SOURCE_PATH" && \
wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2 && \
tar xjvf nasm-2.15.05.tar.bz2 && \
cd nasm-2.15.05 && \
./autogen.sh && \
PATH="$BIN_PATH:$PATH" ./configure --prefix="$FFMPEG_BUILD_PATH" --bindir="$BIN_PATH" && \
make && \
make install && \

cd "$FFMPEG_SOURCE_PATH" && \
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
cd x264 && \
PATH="$BIN_PATH:$PATH" PKG_CONFIG_PATH="$FFMPEG_BUILD_PATH/lib/pkgconfig" ./configure --prefix="$FFMPEG_BUILD_PATH" --bindir="$BIN_PATH" --enable-static --enable-pic && \
PATH="$BIN_PATH:$PATH" make && \
make install && \

apt-get install libnuma-dev && \
cd "$FFMPEG_SOURCE_PATH" && \
wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2 && \
tar xjvf x265.tar.bz2 && \
cd multicoreware*/build/linux && \
PATH="$BIN_PATH:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$FFMPEG_BUILD_PATH" -DENABLE_SHARED=off ../../source && \
PATH="$BIN_PATH:$PATH" make && \
make install && \

cd "$FFMPEG_SOURCE_PATH" && \
git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
cd libvpx && \
PATH="$BIN_PATH:$PATH" ./configure --prefix="$FFMPEG_BUILD_PATH" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
PATH="$BIN_PATH:$PATH" make && \
make install && \

cd "$FFMPEG_SOURCE_PATH" && \
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
./configure --prefix="$FFMPEG_BUILD_PATH" --disable-shared && \
make && \
make install && \

cd "$FFMPEG_SOURCE_PATH" && \
git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git && \
cd opus && \
./autogen.sh && \
./configure --prefix="$FFMPEG_BUILD_PATH" --disable-shared && \
make && \
make install && \

cd "$FFMPEG_SOURCE_PATH" && \
git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
mkdir -p SVT-AV1/build && \
cd SVT-AV1/build && \
PATH="$BIN_PATH:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$FFMPEG_BUILD_PATH" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF .. && \
PATH="$BIN_PATH:$PATH" make && \
make install && \

apt-get install python3-pip && \
pip3 install --user meson

cd "$FFMPEG_SOURCE_PATH" && \
git -C dav1d pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/dav1d.git && \
mkdir -p dav1d/build && \
cd dav1d/build && \
meson setup -Denable_tools=false -Denable_tests=false --default-library=static .. --prefix "$FFMPEG_BUILD_PATH" --libdir="$FFMPEG_BUILD_PATH/lib" && \
ninja && \
ninja install

cd "$FFMPEG_SOURCE_PATH" && \
wget https://github.com/Netflix/vmaf/archive/v2.1.1.tar.gz && \
tar xvf v2.1.1.tar.gz && \
mkdir -p vmaf-2.1.1/libvmaf/build &&\
cd vmaf-2.1.1/libvmaf/build && \
meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "$FFMPEG_BUILD_PATH" --bindir="$BIN_PATH" --libdir="$FFMPEG_BUILD_PATH/lib" && \
ninja && \
ninja install

cd "$FFMPEG_SOURCE_PATH" && \
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
tar xjvf ffmpeg-snapshot.tar.bz2 && \
cd ffmpeg && \
PATH="$BIN_PATH:$PATH" PKG_CONFIG_PATH="$FFMPEG_BUILD_PATH/lib/pkgconfig" ./configure \
  --prefix="$FFMPEG_BUILD_PATH" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$FFMPEG_BUILD_PATH/include" \
  --extra-ldflags="-L$FFMPEG_BUILD_PATH/lib" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir="$BIN_PATH" \
  --enable-gpl \
  --enable-gnutls \
  --enable-libaom \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsvtav1 \
  --enable-libdav1d \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
PATH="$BIN_PATH:$PATH" make && \
make install && \ && \
hash -r

if [ ! -d "$RETROARCH_BUILD_PATH" ]; then
  cd "$HOME" && \
  git clone https://github.com/libretro/RetroArch.git retroarch
fi

cd "$RETROARCH_BUILD_PATH" && \
git pull && \
PKG_CONFIG_PATH=$FFMPEG_BUILD_PATH/lib/pkgconfig ./configure && \
make clean && \
make -j4 && \
make install

apt-get -y remove \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libsdl2-dev \
  libunistring-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  meson \
  ninja-build \
  pkg-config \
  texinfo \
  wget \
  yasm \
  zlib1g-dev \
  libx11-xcb-dev

pip3 uninstall --user meson

