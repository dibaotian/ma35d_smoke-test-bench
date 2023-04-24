# ma35d_smoke-test-bench

### This test bench is used for MA35D basic transcode function test

###

### 1 install the MA35D SDK (install the driver)

### 2 Run ma35_enc_check.sh chech if basic enviroment is ready(in the host)
#### when you see the following, it means check passed
#### $>sudo ma35_enc_check.sh
#### 1  Found 1 MA35D
#### 2  MA35D driver is installed
#### 3  System virtualization config check passed
#### 4  Huge page configuration check passed
#### 5  Docker installed
#### All check passed

###

### 3 load the ma35d docker image(refer /opt/amd/ma35/doc/README.md)
#### $>docker images
#### REPOSITORY                                               TAG       IMAGE ID       CREATED        SIZE
#### packages.xilinx.com/docker-restricted/ma35/ubuntu_demo   latest    c6a3cfac7478   2 months ago   215MB

###

### 4 Run run.sh start and enter the docker
#### Note: change the path of the DOCKER_EXTRA 
#### DOCKER_EXTRA="-v <your_path>/ma35d_smoke-test-bench/videos:/demo/videos -v <your_path>/ma35d_smoke-test-bench/test_scripts:/demo/test_scripts -v <your_path>/ma35d_smoke-test-bench/tool_scripts:/demo/tool_scripts" \
#### $>./run.sh
#### Adding device /dev/transcoder0
#### >$ ls
#### README.md  ReleaseNotes.md  test_scripts  tool_scripts  videos



###

### 5 In the docker install the package
##### >cd /demo/tool_scripts
##### >./install_pkg.sh

###

### 6 run the test script
#### >cd /demo/test_scripts
#### >./run_base_test.sh
#### NOTE: In the ffmpeg_cmd.sh , you can use EN_CPU=true and EN_MA35=true to decide run the transcode in CPU or MA35D
####       also in the run_base_test.sh you should set the device=cpu or device=ma35 in the test

###


根据网络搜索结果，您可以使用 egrep 命令来过滤出有效的内存信息，例如大小、类型等。例如，您可以使用以下命令¹：

sudo dmidecode -t memory | egrep "Maximum Capacity|Number Of Devices|Size|Type:" | egrep -v "No Module|Unknown|None"

这将显示每个内存设备的最大容量、数量、大小和类型，排除了空的或未知的模块。

根据网络搜索结果，您可以使用 dmidecode 命令来查看 Ubuntu 下的内存插槽数。例如，您可以使用以下命令¹：


这将显示一个整数，表示您的主板支持的内存插槽数。您还可以使用 lshw 命令来查看每个插槽的详细信息，例如大小、类型、速度等²。

Source: Conversation with Bing, 4/24/2023(1) command to check RAM slots in motherboard? - Ask Ubuntu. https://askubuntu.com/questions/673408/command-to-check-ram-slots-in-motherboard Accessed 4/24/2023.
(2) hardware - Number of RAM slots - Ask Ubuntu. https://askubuntu.com/questions/1092815/number-of-ram-slots Accessed 4/24/2023.
(3) How to Check RAM Slots in Linux - Appuals.com. https://appuals.com/check-ram-slots-linux/ Accessed 4/24/2023.
(4) detect number of RAM channels - Unix & Linux Stack Exchange. https://unix.stackexchange.com/questions/215206/detect-number-of-ram-channels Accessed 4/24/2023.






