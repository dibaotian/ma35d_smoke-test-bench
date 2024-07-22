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

### 3 run the test script
#### >cd /demo/test_scripts
#### >./run_base_test.sh
#### NOTE: In the ffmpeg_cmd.sh , you can use EN_CPU=true and EN_MA35=true to decide run the transcode in CPU or MA35D
####       also in the run_base_test.sh you should set the device=cpu or device=ma35 in the test

###