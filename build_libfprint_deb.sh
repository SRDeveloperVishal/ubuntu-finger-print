#!/bin/bash

# Exit script if any command fails
set -e

# Variables
REPO_URL="https://gitlab.freedesktop.org/Depau/libfprint/"
BRANCH="elanmoc2"
PACKAGE_NAME="libfprint"
VERSION="1.0"

# Update and install required packages
echo "Installing dependencies..."
sudo apt update
sudo apt install -y build-essential devscripts dh-make debhelper fakeroot meson ninja-build \
                    libglib2.0-dev libgusb-dev gobject-introspection libpixman-1-dev libnss3-dev libgudev-1.0-dev gtk-doc-tools

# Clone the repository
echo "Cloning the libfprint repository..."
git clone -b $BRANCH $REPO_URL
cd $PACKAGE_NAME

# Create debian/ folder and metadata files
echo "Setting up Debian package structure..."
dh_make --single --yes -p ${PACKAGE_NAME}_${VERSION}

# Update debian/control
echo "Modifying debian/control file..."
cat > debian/control <<EOL
Source: libfprint
Section: libs
Priority: optional
Maintainer: Your Name <your.email@example.com>
Build-Depends: debhelper-compat (= 12), meson, libglib2.0-dev, libgusb-dev, gobject-introspection, libpixman-1-dev, libnss3-dev, libgudev-1.0-dev, gtk-doc-tools
Standards-Version: 4.5.0
Homepage: https://gitlab.freedesktop.org/libfprint/libfprint

Package: libfprint
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Library for fingerprint reader support.
EOL

# Update debian/rules
echo "Modifying debian/rules file..."
cat > debian/rules <<EOL
#!/usr/bin/make -f

%:
	dh \$@ --buildsystem=meson

override_dh_auto_configure:
	dh_auto_configure --buildsystem=meson -- -Dprefix=/usr

override_dh_auto_build:
	meson compile -C builddir

override_dh_auto_install:
	meson install -C builddir --destdir=\$(CURDIR)/debian/tmp
EOL

# Set executable permission for debian/rules
chmod +x debian/rules

# Build the Debian package
echo "Building the Debian package..."
debuild -us -uc

# Install the package
echo "Installing the package..."
sudo dpkg -i ../${PACKAGE_NAME}_${VERSION}_*.deb

# Finish
echo "Debian package created and installed successfully!"
