#!/bin/bash

if [ "$EUID" -eq 0 ]; then 
    echo "Start MA35D env check" 
    echo ""
else 
    echo "please execute in root privilege"
    exit
fi

which virt-host-validate &> /dev/null
if [ $? -ne 0 ]; then 
    sudo apt update -y
    sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y
fi

which dmidecode &> /dev/null
if [ $? -ne 0 ]; then 
    sudo apt-get install dmidecode -y
fi

echo "##### CPU info #####"
echo "$(sudo dmidecode -s processor-manufacturer)"
echo "$(sudo dmidecode -s processor-version)"
echo "Frequency $(sudo dmidecode -s processor-frequency)"
echo ""

echo "##### Memory info #####"
lsmem

sudo dmidecode -t memory | egrep "Type:|Speed:|Width|Manufacturer:|Volatile Size:" | egrep -v "Unknown|None|Configured|Total" | awk 'NR<=5'

echo ""

echo "##### BIOS info #####"
echo "vendor:$(sudo dmidecode -s bios-vendor)"
echo "version:$(sudo dmidecode -s bios-version)"

echo ""

echo "##### Mother board info #####"
echo "manufacturer: $(sudo dmidecode -s baseboard-manufacturer)"
echo "product-name: $(sudo dmidecode -s baseboard-product-name)"

echo ""

echo "##### Operation system info #####"
lsb_release -a
echo ""

echo "##### Kernel info #####"
uname -r

echo ""

lsb_release -d | grep -q "Ubuntu 20.04"
if [ $? -ne 0 ]; then 
    echo "Need Ubuntu 20.04"
    exit
fi

echo "##### device info #####"
lspci -d 10ee:

echo ""

echo "##### PCIE Link status #####"
lspci -vvd 10ee: | grep LnkSta:

echo ""

echo "##### Firmware version #####"
cat /sys/class/misc/ama_transcoder0/version_information

echo ""

echo "##### Check result #####"

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

# which docker &> /dev/null
# if [ $? -eq 0 ]; then 
#     echo "5  Docker installed"
# else
#     echo "6  Need install docker"
#     echo "6  refer https://docs.docker.com/engine/install/ubuntu/"
# fi

echo "All check Complete"

