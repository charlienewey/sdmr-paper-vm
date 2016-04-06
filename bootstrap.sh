#!/bin/bash

PPA_REPOSITORIES=(
    "ppa:mc3man/trusty-media"
)

PKG_DEPENDENCIES=(
    "build-essential"
    "g++"
    "gfortran"
    "git"
    "libfreetype6-dev"
    "libjpeg-dev"
    "liblapack-dev"
    "libopenblas-dev"
    "libpng12-0"
    "libpng12-dev"
    "python-cairo"
    "python-cairo-dev"
    "python-dev"
    "python-gobject-2"
    "python-gtk2"
    "python-matplotlib"
    "python-numpy"
    "python-scipy"
    "python-setuptools"
    "python-skimage"
    "python-sklearn"
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
for package in $(cat /vagrant/requirements.txt); do
    pip install $package
done

# Fix for matplotlib bug #3029.
# See: https://github.com/matplotlib/matplotlib/issues/3029
if [ ! -f "/usr/include/freetype2/ft2build.h" ]; then
    ln -s /usr/include/freetype2/ft2build.h /usr/include/
fi

# Install OpCV
function install_opencv() {
    pushd /tmp
        rm -rf Install-OpenCV
        git clone https://github.com/jayrambhia/Install-OpenCV.git
        pushd Install-OpenCV/Ubuntu/
            ./opencv_latest.sh
        popd
    popd
}

latest_opencv="$(wget -q -O - http://sourceforge.net/projects/opencvlibrary/files/opencv-unix | egrep -m1 -o '\"[0-9](\.[0-9]+)+(-[-a-zA-Z0-9]+)?' | cut -c2-)"
opencv=$(python -c 'exec("ex = \"not installed\";\ntry: import cv2; ex = cv2.__version__\nexcept: pass;\nprint(ex)")')
if [ $opencv = $latest_opencv ]; then
    echo "Latest OpenCV installed (version $opencv)... skipping!"
elif [ $opencv = "not installed" ]; then
    echo "OpenCV not installed... installing!"
    install_opencv
else
    echo "OpenCV outdated... upgrading! ($opencv ==> $latest_opencv)"
    install_opencv
fi
