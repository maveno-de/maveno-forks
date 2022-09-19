#!/bin/bash

# Check current HDDcoin SSL version to prevent update on old SSL
if [ -e ../.hddcoin/mainnet/config/ssl/ca/hddcoin_ca.crt ]; then
	HDDCOIN_SSL_SERIAL=$(openssl x509 -noout -in ../.hddcoin/mainnet/config/ssl/ca/hddcoin_ca.crt -serial)
	if [ $HDDCOIN_SSL_SERIAL = "serial=5C8A71239328650EB9FEF85CEC32BF779CA6A0C5" ]; then 
		echo ""
		echo "WARNING:"
		echo "Old version of HDDcoin Blockchain SSL has been detected."
		echo "Please visit https://hddcoin.org/sslupdate/ for further instructions."
		echo ""
		echo "Exiting installer..."
		echo ""
		exit 1
	fi
fi

set -e
UBUNTU=false
DEBIAN=false
if [ "$(uname)" = "Linux" ]; then
	#LINUX=1
	if type apt-get; then
		OS_ID=$(lsb_release -is)
		if [ "$OS_ID" = "Debian" ]; then
			DEBIAN=true
		else
			UBUNTU=true
		fi
	fi
fi

# Check for non 64 bit ARM64/Raspberry Pi installs
if [ "$(uname -m)" = "armv7l" ]; then
  echo ""
	echo "WARNING:"
	echo "The HDDcoin Blockchain requires a 64 bit OS and this is 32 bit armv7l"
	echo "For more information, see"
	echo "https://github.com/HDDcoin-Network/hddcoin-blockchain/wiki/Raspberry-Pi"
	echo "Exiting."
	exit 1
fi
# Get submodules
git submodule update --init mozilla-ca

UBUNTU_PRE_2004=false
if $UBUNTU; then
	LSB_RELEASE=$(lsb_release -rs)
	# In case Ubuntu minimal does not come with bc
	if [ "$(which bc |wc -l)" -eq 0 ]; then sudo apt install bc -y; fi
	# Mint 20.04 repsonds with 20 here so 20 instead of 20.04
	UBUNTU_PRE_2004=$(echo "$LSB_RELEASE<20" | bc)
	UBUNTU_2100=$(echo "$LSB_RELEASE>=21" | bc)
fi

find_python() {
	set +e
	unset BEST_VERSION
	for V in 39 3.9 38 3.8 37 3.7 3; do
		if which python$V >/dev/null; then
			if [ "$BEST_VERSION" = "" ]; then
				BEST_VERSION=$V
			fi
		fi
	done
	echo $BEST_VERSION
	set -e
}

if [ "$INSTALL_PYTHON_VERSION" = "" ]; then
	INSTALL_PYTHON_VERSION=$(find_python)
fi

# This fancy syntax sets INSTALL_PYTHON_PATH to "python3.7", unless
# INSTALL_PYTHON_VERSION is defined.
# If INSTALL_PYTHON_VERSION equals 3.8, then INSTALL_PYTHON_PATH becomes python3.8

INSTALL_PYTHON_PATH=python${INSTALL_PYTHON_VERSION:-3.7}

echo "Python version is $INSTALL_PYTHON_VERSION"
$INSTALL_PYTHON_PATH -m venv venv
if [ ! -f "activate" ]; then
	ln -s venv/bin/activate .
fi

# shellcheck disable=SC1091
. ./activate
# pip 20.x+ supports Linux binary wheels
python -m pip install --upgrade pip
python -m pip install wheel
#if [ "$INSTALL_PYTHON_VERSION" = "3.8" ]; then
# This remains in case there is a diversion of binary wheels
python -m pip install --extra-index-url https://pypi.chia.net/simple/ miniupnpc==2.2.2
python -m pip install -e . --extra-index-url https://pypi.chia.net/simple/

logo_color="
[30;107m[0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [38;5;m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;072m/[38;5;m/[0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [0m [0m 
[0m [0m [0m [0m [0m [0m [0m [38;5;151m,[38;5;151m,[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;071m@[38;5;065m#[0m [0m [0m [0m [0m [0m 
[0m [0m [0m [0m [38;5;252m.[38;5;252m.[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;029m%[38;5;029m%[0m [0m [0m 
[0m [0m [38;5;m*[38;5;151m,[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;029m%[38;5;m&[0m 
[0m [38;5;115m*[38;5;071m@[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;029m%[38;5;023m%
[0m [38;5;115m*[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m&
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;114m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;194m [38;5;193m.[38;5;194m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;115m*[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;157m,[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;254m.[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;152m,[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;255m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;156m,[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;155m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;152m.[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;029m#[38;5;029m%[38;5;029m%[38;5;029m%[38;5;015m [38;5;156m,[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;254m.[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;029m#[38;5;035m#[38;5;029m#[38;5;035m#[38;5;029m#[38;5;072m/[38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;255m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;151m,[38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[38;5;m/[38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;255m [38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;119m*[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%
[0m [38;5;072m/[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;115m*[38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;254m.[38;5;252m.[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;114m*[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;235m&
[0m [38;5;071m@[38;5;071m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;151m,[38;5;015m [38;5;015m [38;5;015m [38;5;071m#[38;5;071m#[38;5;071m#[38;5;071m#[38;5;071m#[38;5;035m#[38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m&[38;5;m&
[0m [0m [38;5;m&[38;5;065m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;234m&[0m [0m 
[0m [0m [0m [0m [38;5;m#[38;5;029m%[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;072m/[38;5;015m [38;5;015m [38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;233m [38;5;m&[0m [0m [0m 
[0m [0m [0m [0m [0m [0m [0m [38;5;m%[38;5;023m%[38;5;029m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;035m#[38;5;022m%[38;5;234m&[38;5;m&[0m [0m [0m [0m [0m [0m 
[0m
"

logo_bw="\
             *////////////////////////////*            
      ,.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     
   %.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#   
  ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@# 
 ,@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@%
./@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@%
*@@@@@@@@@@@@@@       ,,,,,,,,,,,,       @@@@@@@@@@@@@%
*@@@@@@@@@@@@     ,,,,,,,,,,,,,,,,,,,.     @@@@@@@@@@@%
*@@@@@@@@@@     ,,,,,,,,,,,,,,,,,,,,,,,,    /@@@@@@@@@%
*@@@@@@@@@*    ,,,,,,,,,,,    ,,,,,,,,,,,    @@@@@@@@@%
*@@@@@@@@@    ,,,,,,,,,          ,,,,,,,,,    @@@@@@@@%
*@@@@@@@@@    ,,,,,,,,,   @@@@   ,,,,,,,,,    @@@@@@@@%
*@@@@@@@@@    ,,,,,,,,,         ,,,,,,,,,,    @@@@@@@@%
*@@@@@@@@@/    ,,,,,,  #     ,,,,,,,,,,,,    @@@@@@@@@%
*@@@@@@@@@@,    ,  ##### ,,,,,,,,,,,,,,,    @@@@@@@@@@%
*@@@@@@@@@@@@  @@@@@@@ ,,,,,,,,,,,,,,,     @@@@@@@@@@@%
*@@@@@@@@@ @@@@@@@@@ ,,,,,,,,,,,,,,      @@@@@@@@@@@@@%
*/@@@@@  @@@@@@@@@                    @@@@@@@@@@@@@@@@%
 /@@@@@  .@@@@@@, @@@@@*        /@@@@@@@@@@@.  @@@@@@@&
  @@@@@/        @@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@& 
    #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   .@@@&   
      ##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#&&     
"

if [ -x "$(command -v tput)" ]; then
    [ $(tput colors) -ge 256 ] && echo "${logo_color}" || echo "${logo_bw}"
else
    echo "${logo_bw}"
fi


echo "HDDcoin blockchain install.sh complete."															  
echo ""
echo "Visit our Website to learn more about HDDcoin:"
echo "https://hddcoin.org"
echo ""
echo "Try the Quick Start Guide to running hddcoin-blockchain:"
echo "https://github.com/HDDcoin-Network/hddcoin-blockchain/wiki/Quick-Start-Guide"
echo ""
echo "To install the GUI type 'sh install-gui.sh' after '. ./activate'."
echo ""
echo "Type '. ./activate' and then 'hddcoin init' to begin."