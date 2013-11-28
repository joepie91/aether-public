#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "This script will attempt to compile and install SIP and PyQt5, for use with Aether."
echo "Please note the following:"
echo "  1. You need to have the Qt5 core development libraries installed. These can likely be found in the repositories for your distribution (the package name on openSUSE is 'libqt5-qtbase-devel')."
echo "  2. Not all distributions will include the WebKitWidgets component. Ensure this is installed as well (the package name on openSUSE is 'libQt5WebKitWidgets-devel')."
echo "  3. This is NOT an unattended installation. During the PyQt5 installation process, you will be asked to accept a license."
echo "  4. You will be asked some configuration questions after you hit Enter."
read -p "Ensure that you have read the above, and have installed all dependencies, then hit Enter to continue."

echo "How many threads do you want to use for compiling? A safe value is your total amount of CPU cores, minus one. Enter '1' if you are unsure."
read -p "Number of threads: " THREADS

re='^[0-9]+$'
if ! [[ $THREADS =~ $re ]] ; then
	echo "error: You must enter a number." >&2; exit 1
fi

echo "Where's your qmake for Qt5 located? Leave empty to use the default (/usr/bin/qmake-qt5)."
read -p "Path for qmake-qt5: " QMAKE_PATH

if [[ -z "$QMAKE_PATH" ]]; then
	QMAKE_PATH="/usr/bin/qmake-qt5"
fi

if [ ! -f $QMAKE_PATH ]; then
	echo "error: The path you specified does not exist." >&2; exit 1
fi

mkdir pyqt5-build
cd pyqt5-build

wget http://sourceforge.net/projects/pyqt/files/sip/sip-4.15.3/sip-4.15.3.tar.gz
wget http://sourceforge.net/projects/pyqt/files/PyQt5/PyQt-5.1.1/PyQt-gpl-5.1.1.tar.gz

tar -xzf sip-4.15.3.tar.gz
tar -xzf PyQt-gpl-5.1.1.tar.gz

cd sip-4.15.3/
python2 configure.py 
make -j $THREADS
make install
cd ..

cd PyQt-gpl-5.1.1/
python2 configure.py --qmake $QMAKE_PATH
make -j $THREADS
make install
cd ../..

rm -rf mkdir pyqt5-build
