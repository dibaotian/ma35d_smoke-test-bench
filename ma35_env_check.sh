#!/bin/bash



if [ "$EUID" -eq 0 ]; then 
    echo "Start MA35D env check" 
else 
    echo "please execute in root privilege"
    exit
fi

sudo apt update -y

which virt-host-validate &> /dev/null
if [ $? -ne 0 ]; then 
    sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y
fi

lscpu
echo ""

lsb_release -a
echo ""

uname -a

echo ""

lsb_release -d | grep -q "Ubuntu 20.04"
if [ $? -eq 0 ]; then 
    echo "OS is Ubuntu 20.04"
    echo ""
else
    echo "need Ubuntu 20.04"
    exit
fi

lspci -vvd 10ee:

echo ""

lspci -vvd 10ee: | grep LnkSta:

echo ""


# lspci -d 10ee: | grep -q "Xilinx Corporation Device 5070"
DEV_NUM=$(lspci -d 10ee: | wc -l)

if [ $DEV_NUM -ne 0 ]; then 
    echo "1  Found $DEV_NUM MA35D"
else
    echo "1 Did not find MA35D in the system"
    exit 
fi 

lspci -vd 10ee: | grep -q "Kernel driver in use: transcoder"
if [ $? -eq 0 ]; then 
    echo "2  MA35D driver is installed"
else
    echo "2  MA35D driver is not installed"
fi



virt-host-validate | grep -q "FAIL"
if [ $? -eq 1 ]; then 
    echo "3  System virtualization config check passed"
else
    echo "3  System virtualization config check fail"
    echo "   Please Enable Virtualization Technology in BIOS/UEFI,  Intel VT/VT-d or  AMD AMD-Vi"
    echo "   Please Enable IOMMU Support, In /etc/default/grub GRUB_CMDLINE_LINUX_DEFAULT config amd_iommu=on or intel_iommu=on and iommu=pt"
fi

cat /etc/sysctl.conf | grep -q "vm.nr_hugepages="
if [ $? -eq 0 ]; then 
    echo "4  Huge page configuration check passed"
else
    echo "4  Huge page configuration check fail"
    echo "   In the /etc/sysctl.conf add vm.nr_hugepages=4096"
fi

which docker &> /dev/null
if [ $? -eq 0 ]; then 
    echo "5  Docker installed"
else
    echo "6  Need install docker"
    echo "6  refer https://docs.docker.com/engine/install/ubuntu/"
fi

echo "All check passed"