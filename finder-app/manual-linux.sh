#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    echo "Building Kernel"

    echo "Building kernel - clean"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper

    echo "Building kernel - configure"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig

    echo "Building kernel - build kernel image"
    make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all

    echo "Building kernel - build kernel modules"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules

    echo "Building kernel - build device tree"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs
fi

echo "Adding the Image in outdir"
cp -r ${OUTDIR}/linux-stable/arch/${ARCH}/boot/* ${OUTDIR}/

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ];
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "Creating base directories"
mkdir "${OUTDIR}/rootfs"
cd "${OUTDIR}/rootfs"
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ];
then
    echo "Cloning busybox"
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "Configuring busybox"
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
echo "Making busybox"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "Add library dependencies to rootfs"
#if [ -d "/home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu" ]; then
    #cp /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 ${OUTDIR}/rootfs/lib/
    #cp /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib/
    #cp /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6 ${OUTDIR}/rootfs/lib/
    #cp /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/
    #cp /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64/
    #cp /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/
    
    
    #cp -r /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/* ${OUTDIR}/rootfs/lib64/
    #cp -r /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/* ${OUTDIR}/rootfs/lib/
    
    cp -r ${FINDER_APP_DIR}/../libs_arm/lib64/* ${OUTDIR}/rootfs/lib64/
    cp -r ${FINDER_APP_DIR}/../libs_arm/lib/* ${OUTDIR}/rootfs/lib/

    #sudo cp -r ${FINDER_APP_DIR}/../libs/* ${OUTDIR}/rootfs/
    #sudo chmod -R 666 ${OUTDIR}/rootfs/lib/*
    #sudo chmod -R 666 ${OUTDIR}/rootfs/lib64/*
    
    #cp -a /home/michal/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/
#fi
    #cp -r /lib/x86_64-linux-gnu/* ${OUTDIR}/rootfs/lib64/
    #cp /lib/x86_64-linux-gnu/libm.so.6 ${OUTDIR}/rootfs/lib64/
    #cp /lib/x86_64-linux-gnu/libresolv.so.2 ${OUTDIR}/rootfs/lib64/
    #cp /lib/x86_64-linux-gnu/libc.so.6 ${OUTDIR}/rootfs/lib64/
    #cp /lib/x86_64-linux-gnu/libm.so.6 ${OUTDIR}/rootfs/lib/
    #cp /lib/x86_64-linux-gnu/libresolv.so.2 ${OUTDIR}/rootfs/lib/
    #cp /lib/x86_64-linux-gnu/libc.so.6 ${OUTDIR}/rootfs/lib/

# TODO: Make device nodes
echo "Making device nodes"
cd "${OUTDIR}/rootfs"
if [ ! -e "dev/null" ]; then
    sudo mknod -m 777 dev/null c 1 3
fi
if [ ! -e "dev/console" ]; then
    sudo mknod -m 777 dev/console c 5 1
fi
if [ ! -e "dev/tty" ]; then
    sudo mknod -m 777 dev/tty c 5 0
fi

# TODO: Clean and build the writer utility
echo "Cleaning and building writer"
cd "$FINDER_APP_DIR"
make clean
make CROSS_COMPILE=aarch64-none-linux-gnu- writer

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
if [ ! -d "${OUTDIR}/rootfs/home" ]; then
    echo "Copying writer to rootfs/home/"
    mkdir ${OUTDIR}/rootfs/home/
    cp finder.sh ${OUTDIR}/rootfs/home/
    cp finder-test.sh ${OUTDIR}/rootfs/home/
    cp writer ${OUTDIR}/rootfs/home/
    cp conf/username.txt ${OUTDIR}/rootfs/home/
    cp autorun-qemu.sh ${OUTDIR}/rootfs/home/
fi

# TODO: Chown the root directory
echo "Chown the root directory"
cd "${OUTDIR}/rootfs"
sudo chown root:root .

# TODO: Create initramfs.cpio.gz
cd "$OUTDIR/rootfs"
sudo find .| cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd "$OUTDIR"
sudo gzip -f initramfs.cpio
