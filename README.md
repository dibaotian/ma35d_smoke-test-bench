# ma35d_smoke-test-bench

### install the MA35D SDK and run the ma35_enc_check.sh chech if basic enviroment is ready
#### >sudo ma35_enc_check.sh
#### 1  Found 1 MA35D
#### 2  MA35D driver is installed
#### 3  System virtualization config check passed
#### 4  Huge page configuration check passed
#### 5  Docker installed

### load the ma35d docker image(refer /opt/amd/ma35/doc/README.md)
#### REPOSITORY                                               TAG       IMAGE ID       CREATED        SIZE
#### packages.xilinx.com/docker-restricted/ma35/ubuntu_demo   latest    c6a3cfac7478   2 months ago   215MB

### run the run.sh start and enter the docker
#### before run remember change the path of the DOCKER_EXTRA 

### In the docker install the package
##### >cd /demo/tool_scripts
##### >./install_pkg.sh

### run the test script
#### >cd /demo/test_scripts
#### >./run_base_test.sh




