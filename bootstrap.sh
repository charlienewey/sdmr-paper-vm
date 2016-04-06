#!/bin/bash

PPA_REPOSITORIES=(
    'ppa:jon-severinsson/ffmpeg'
)

PKG_DEPENDENCIES=(
    'python-setuptools'
    'python-dev'
    'build-essential'
    'git'
    'g++'
    'gfortran'
    'libopenblas-dev'
    'liblapack-dev'
)

# Enable multiverse.
sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list

if test ! $(which add-apt-repository)
    then
    apt-get install -y software-properties-common python-software-properties
fi

# Add apt repositories
for repo in "${PPA_REPOSITORIES[@]}"
do
    add-apt-repository -y $repo
done

apt-get update
apt-get install -y ${PKG_DEPENDENCIES[@]}

# Create a temporary 2Gb swap file so that we don't exhaust the virtual
# machine's memory when compiling scipy.
# Note: Not really necessary if the VM has >=2Gb RAM
#if [ ! -f "/tmp/tmp_swap" ]; then
#    dd if=/dev/zero of=/tmp/tmp_swap bs=1024 count=2097152
#    mkswap /tmp/tmp_swap
#    swapon /tmp/tmp_swap
#fi

# Install required python packages.
easy_install pip
pip install -r /vagrant/requirements.txt

# Fix for matplotlib bug #3029.
# See: https://github.com/matplotlib/matplotlib/issues/3029
if [ ! -f "/usr/include/freetype2/ft2build.h" ]; then
    ln -s /usr/include/freetype2/ft2build.h /usr/include/
fi

# Install OpenCV
latest_opencv="$(wget -q -O - http://sourceforge.net/projects/opencvlibrary/files/opencv-unix | egrep -m1 -o '\"[0-9](\.[0-9]+)+(-[-a-zA-Z0-9]+)?' | cut -c2-)"
opencv=$(python -c 'exec("ex = \"not installed\";\ntry: import cv2; ex = cv2.__version__\nexcept: pass;\nprint(ex)")')
if [ $opencv != "not installed" -a $opencv == $latest_opencv ]; then
    echo "Latest OpenCV installed (version $opencv)... skipping!"
else
    echo "OpenCV outdated/not installed ($opencv)... installing!"
    pushd /tmp
        git clone https://github.com/jayrambhia/Install-OpenCV.git
        pushd Install-OpenCV/Ubuntu/
            ./opencv_latest.sh
        popd
    popd
fi
