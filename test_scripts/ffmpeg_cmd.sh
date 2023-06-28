#!/bin/bash

# Author: MinXie
# Copyright: 2023 MinXie
# Origin: 2023/4
# Contact: minx@amd.com
# Description: This script is used for the MA35D basic test.

# video source
# https://h265.webmfiles.org/
# https://media.xiph.org/video/derf/
# https://www.elecard.com/videos
# https://aomedia.org/


codec_dec=(h264dec hevcdec av1dec ) # vp9dec
codec_enc=(h264enc hevcenc av1enc)
codec_tra=(h264toh264 h264tohevc h264toav1 hevctohevc hevctoh264 hevctoav1 av1toav1 av1toh264 av1tohevc)
codec=(${codec_dec[*]} ${codec_enc[*]} ${codec_tra[*]})


#输入参数检查
if [ $# -ne 4 ];then
    echo "please input correct parameter"
    echo "./ffmpeg_cmd.sh [trans_type] [codec_inputfile] [codec_putputfile] <device_type cpu/ma35>"
    exit
else
    if [[ ! "${codec[@]}" =~ "$1" ]]; then
        echo "the input trans type not supported"
        echo "the support trans type -- ${codec[*]}"
        exit
    fi
fi


if [ $4 == "cpu" ] || [ $4 == "ma35" ];then
    device_type=$4
else
    echo "device type error, should be cpu or ma35"
    exit
fi

echo "### device type is $device_type"

if [ $device_type == "cpu" ]; then
    EN_CPU=true
else
    EN_CPU=false
fi

if [ $device_type == "ma35" ]; then
    EN_MA35=true
else
     EN_MA35=false
fi


# if ffmpeg do not have h264 encoder
# sudo apt-get install  libx264-dev

# if ffmpeg do not have hevc encoder
# sudo apt-get install  libx265-dev
OUT_DIR=trans_out
CPU_OUT_DIR=$OUT_DIR/cpu
MA35_OUT_DIR=$OUT_DIR/ma35

rm -rf $CPU_OUT_DIR
rm -rf $MA35_OUT_DIR

mkdir -p $OUT_DIR
mkdir -p $CPU_OUT_DIR
mkdir -p $MA35_OUT_DIR

DEVICE=0
SLICE=0
FRAMES=1000
SCALER=""

# ffmpeg -formats
output_mp4=mp4
output_raw=rawvideo
output_y4m=y4m
output_mkv=mkv
output_avi=avi

######CODEC########
# type      ma35decode     ma35encode
# h264	    h264_ama	   h264_ama
# hevc	    hevc_ama	   hevc_ama
# av1	    av1_ama	       av1_ama
# vp9	    vp9_ama	       NA                   //alpha version not support 

#MA35D
MA35_H264_DEC=h264_ama
MA35_H264_ENC=h264_ama 

MA35_HEVC_DEC=hevc_ama 
MA35_HEVC_ENC=hevc_ama

MA35_AV1_DEC=av1_ama #snav1dec
# MA35_AV1_DEC=snav1dec
# MA35_AV1_ENC=av1enc_vpe #snav1enc
MA35_AV1_ENC=av1_ama 

MA35_VP9_DEC=vp9_ama

#CPU
CPU_H264_DEC=h264
CPU_H264_ENC=libx264

CPU_HEVC_DEC=hevc
CPU_HEVC_ENC=libx265

# not support yet,ffmpeg need install av1 decoder
# https://trac.ffmpeg.org/wiki/Encode/AV1
# sudo apt install libdav1d-dev

CPU_AV1_DEC=av1 #Alliance for Open Media AV1
CPU_AV1_ENC=libaom-av1 #libaom (libaom-av1)
# CPU_AV1_ENC=av1

CPU_VP9_DEC=vp9

######codec########


# ffmpeg -hide_banner -y -init_hw_device vpe=dev0:/dev/transcoder${DEVICE} -vsync 0 -c:v h264dec_vpe -i ${INPUT} -c:v sn${MA35}enc -xav1-params *slice=${SLICE} -b:v 20M ${FRAMES} -f mp4 ${OUTPUT}

# TRANS_CONFIG="-vsync 0 -c:v mpsoc_vcu_h264 -profile:v high -g ${GOP} -control-rate 0 -bf 0 -threads 1 -r 30 -lookahead_depth 0 -tune-metrics 1"  # -slice-qp ${QP} -expert-options ip-delta=${delta}"
# CONFIG="-hide_banner -y -stream_loop -1 -init_hw_device vpe=dev0:/dev/transcoder${DEVICE} -vsync 0 "
# -hide_banner is an option in FFmpeg that can be used to suppress printing the banner and copyright information when running FFmpeg commands.
# MA35_CONFIG="-hide_banner -y -hwaccel ama  -vsync 0 "
MA35_CONFIG="-hide_banner -y -hwaccel ama  -vsync 0 "
CPU_CONFIG="-hide_banner -y -vsync 0"

if [ -f $2 ]; then
    echo " "
else
    echo "$2 input file not exist"
    exit -1
fi

case $1 in
    h264dec)
        
        echo "############"
        echo "h264 decode"
        echo "############"

        # pure decode fail
        # ffmpeg -hide_banner -y \
        #        -stream_loop -1 \
        #        -init_hw_device vpe=dev0:/dev/transcoder${DEVICE} \
        #        -vsync 0 \
        #        -c:v $MA35_H264_DEC  \
        #        -i  $2 \
        #        -frames:v $FRAMES \
        #        -f output_raw h264_decode.yuv

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";

            # ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i $2

            ffmpeg $CPU_CONFIG \
                    -c:v $CPU_H264_DEC \
                    -i  $2\
                    -f $output_raw $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";
           
            # ffmpeg $MA35_CONFIG \
            #     -stream_loop -1 \
            #     -out_fmt nv12 \
            #     -c:v $MA35_H264_DEC  \
            #     -i  $2 \
            #     -frames:v $FRAMES \
            #     -vf hwdownload,format=nv12 \
            #     -f $output_raw $MA35_OUT_DIR/$3

            ffmpeg $MA35_CONFIG \
                -stream_loop -1 \
                -out_fmt yuv420p \
                -c:v $MA35_H264_DEC  \
                -i  $2 \
                -frames:v $FRAMES \
                -vf hwdownload,format=yuv420p \
                -f $output_raw $MA35_OUT_DIR/$3
        fi
        ;;

    hevcdec)
       
        echo "###########"
        echo "hevc_decode"
        echo "###########"
        echo ""

        # ffmpeg -hide_banner -y \
        #        -stream_loop -1 \
        #        -init_hw_device vpe=dev0:/dev/transcoder${DEVICE} \
        #        -vsync 0 \
        #        -i  $2 \
        #        -c:v $MA35_HEVC_DEC  \
        #        -frames:v $FRAMES \
        #        -f mp4 hevc_decode.yuv

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg $CPU_CONFIG \
                -c:v $CPU_HEVC_DEC  \
                -i $2 \
                -frames:v $FRAMES \
                -f $output_raw $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";
            ffmpeg $MA35_CONFIG \
                -stream_loop -1 \
                -out_fmt nv12 \
                -c:v $MA35_HEVC_DEC  \
                -i $2 \
                -vf hwdownload,format=nv12 \
                -frames:v $FRAMES \
                -f $output_raw $MA35_OUT_DIR/$3
        fi
        ;;

    av1dec)
        echo "##########"
        echo "av1_decode"
        echo "##########"
        echo ""
        
        # ffmpeg -hide_banner -y \
        #        -stream_loop -1 \
        #        -init_hw_device vpe=dev0:/dev/transcoder${DEVICE} \
        #        -vsync 0 \
        #        -i  $2 \
        #        -c:v $MA35_AV1_DEC  \
        #        -frames:v $FRAMES \
        #        -f mp4 av1_decode.yuv

        # current ffmpeg not support av1 decode codec, need install or build ffmpeg
        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg $CPU_CONFIG \
                   -c:v $CPU_AV1_DEC  \
                   -i  $2 \
                   -f $output_raw $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";
            ffmpeg $MA35_CONFIG \
                -stream_loop -1 \
                -out_fmt nv12 \
                -c:v $MA35_AV1_DEC  \
                -i  $2 \
                -frames:v $FRAMES \
                -vf hwdownload,format=nv12 \
                -f $output_raw $MA35_OUT_DIR/$3
        fi
        ;;

    vp9dec)
        echo "##########"
        echo "vp9_decode"
        echo "##########"
        echo ""
        
        # ffmpeg -hide_banner -y \
        #        -stream_loop -1 \
        #        -init_hw_device vpe=dev0:/dev/transcoder${DEVICE} \
        #        -vsync 0 \
        #        -i  $2 \
        #        -c:v $MA35_AV1_DEC  \
        #        -frames:v $FRAMES \
        #        -f mp4 av1_decode.yuv

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg $CPU_CONFIG \
                   -c:v $CPU_VP9_DEC  \
                   -i  $2 \
                   -f $output_raw $CPU_OUT_DIR/$3
        fi
        
        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";
            ffmpeg $MA35_CONFIG \
                -stream_loop -1 \
                -c:v $MA35_VP9_DEC  \
                -i  $2 \
                -frames:v $FRAMES \
                -vf hwdownload,format=nv12 \
                -f $output_raw $MA35_OUT_DIR/$3
        fi
        ;;
    
    h264enc)
        echo "############"
        echo "H264_encode"
        echo "############"
        echo ""
        
        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            # current docker ffmpeg do not have libx264 encoder
            # you can run it in outside of container
            ffmpeg $CPU_CONFIG \
                   -i  $2 \
                   -frames:v $FRAMES \
                   -c:v $CPU_H264_ENC  \
                   -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";
            ffmpeg $MA35_CONFIG \
                    -stream_loop -1 \
                    -i  $2 \
                    -pix_fmt yuv420p \
                    -vf hwupload \
                    -c:v $MA35_H264_ENC  \
                    -frames:v $FRAMES \
                    -f mp4 $MA35_OUT_DIR/$3
                   
        fi
        ;;
    
    hevcenc)
        echo "##########"
        echo "Hevc_encode"
        echo "##########"
        echo ""

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg $CPU_CONFIG \
                   -i  $2 \
                   -c:v $CPU_HEVC_ENC  \
                   -frames:v $FRAMES \
                   -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";
            ffmpeg $MA35_CONFIG \
                -stream_loop -1 \
                -i  $2 \
                -vf hwupload \
                -c:v $MA35_HEVC_ENC  \
                -frames:v $FRAMES \
                -f mp4 $MA35_OUT_DIR/$3
        fi
        ;;

    av1enc)
        echo "##########"
        echo "av1_encode"
        echo "##########"
        echo ""

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            # current docker ffmpeg do not have libaom-av1 encoder
            # you can run it in outside of container
            # cpu process is very slow
            ffmpeg $CPU_CONFIG \
                   -i $2 \
                   -c:v $CPU_AV1_ENC  \
                   -strict experimental \
                   -frames:v 10 \
                   -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";
            ffmpeg $MA35_CONFIG \
                -stream_loop -1 \
                -i  $2 \
                -vf hwupload \
                -c:v $MA35_AV1_ENC  \
                -frames:v $FRAMES \
                -f mp4 $MA35_OUT_DIR/$3
        fi
        ;;

    h264toh264)
        echo "######################"
        echo "h264 to h264 transcode"
        echo "######################"

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_H264_DEC \
                    -i $2 \
                    -c:v $CPU_H264_ENC \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        echo ""

       if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            # bug pre-alpha version , the transcode hang 
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_H264_DEC \
                    -i $2 \
                    -frames:v $FRAMES \
                    -c:v $MA35_H264_ENC \
                    -b:v 20M \
                    -f mp4 $MA35_OUT_DIR/$3
        fi

        ;;

    h264tohevc)
        echo "######################"
        echo "h264 to hevc transcode"
        echo "######################"

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_H264_DEC \
                    -i $2 \
                    -c:v $CPU_H264_ENC \
                    -frames:v $FRAMES \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_H264_DEC \
                    -i $2 \
                    -c:v $MA35_HEVC_ENC \
                    -frames:v $FRAMES \
                    -b:v 10M \
                    -f rawvideo $MA35_OUT_DIR/$3
        fi
        ;;

    h264toav1)
        echo "######################"
        echo "h264 to av1 transcode"
        echo "######################"
      
        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            # fmpeg -hide_banner -y -vsync 0 -c:v h264 -i  ../videos/Basketball_2.1920x1080.I420_20000kbps.h264.mp4 -c:v libaom-av1 -strict  experimental  -f mp4 out.yuv
           taskset -c 0-3 ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_H264_DEC \
                    -i $2 \
                    -c:v $CPU_AV1_ENC \
                    -strict experimental \
                    -frames:v 10 \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                -stream_loop -1 \
                -c:v $MA35_H264_DEC \
                -i $2 \
                -c:v $MA35_AV1_ENC \
                -frames:v $FRAMES \
                -b:v 10M \
                -f rawvideo $MA35_OUT_DIR/$3

        fi
        ;;

    hevctohevc)
        echo "######################"
        echo "hevc to hevc transcode"
        echo "######################"

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_HEVC_DEC \
                    -i $2 \
                    -c:v $CPU_HEVC_ENC \
                    -frames:v $FRAMES \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        # decode fail
        # game-265-1920x1080-30fps-2M.mp4
        # game-265-1920x1080-60fps-2M.mp4

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_HEVC_DEC \
                    -i $2 \
                    -c:v $MA35_HEVC_ENC \
                    -frames:v $FRAMES \
                    -b:v 10M \
                    -f mp4 $MA35_OUT_DIR/$3
        fi
        ;;

    hevctoh264)
        echo "######################"
        echo "hevc to h264 transcode"
        echo "######################"
        # hevc-h264 transcode
        # ffmpeg  -y -init_hw_device vpe=dev0:/dev/transcoder${DEVICE} \
        #         -stream_loop -1 \
        #         -vsync 0 \
        #         -c:v $MA35_HEVC_DEC \
        #         -i $2 \
        #         -c:v $MA35_H264_ENC \
        #         -frames:v $FRAMES \
        #         -b:v 10M \
        #         -f mp4 hevc_to_h264.h264

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_HEVC_DEC \
                    -i $2 \
                    -c:v $CPU_H264_ENC \
                    -frames:v $FRAMES \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_HEVC_DEC \
                    -i $2 \
                    -c:v $MA35_H264_ENC \
                    -frames:v $FRAMES \
                    -b:v 10M \
                    -f mp4 $MA35_OUT_DIR/$3
        fi
        ;;

    hevctoav1)
        echo "######################"
        echo "hevc to av1 transcode"
        echo "######################"

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_HEVC_DEC \
                    -i $2 \
                    -c:v $CPU_AV1_ENC \
                    -strict experimental \
                    -frames:v 3 \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        # hevc-av1 transcode
        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_HEVC_DEC \
                    -i $2 \
                    -c:v $MA35_AV1_ENC \
                    -frames:v $FRAMES \
                    -b:v 10M \
                    -f rawvideo $MA35_OUT_DIR/$3
        fi
        ;;

    av1toav1)
        echo "######################"
        echo "av1 to av1 transcode"
        echo "######################"

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_AV1_DEC \
                    -i $2 \
                    -c:v $CPU_AV1_ENC \
                    -strict experimental \
                    -frames:v 3 \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_AV1_DEC \
                    -i $2 \
                    -c:v $MA35_AV1_ENC \
                    -frames:v $FRAMES \
                    -b:v 10M \
                    -f mp4 $MA35_OUT_DIR/$3
        fi

    ;;

    av1toh264)
        echo "######################"
        echo "av1 to h264 transcode"
        echo "######################"

         if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_AV1_DEC \
                    -i $2 \
                    -c:v $CPU_H264_ENC \
                    -frames:v $FRAMES \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

        if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_AV1_DEC \
                    -i $2 \
                    -c:v $MA35_H264_ENC \
                    -frames:v $FRAMES \
                    -b:v 10M \
                    -f mp4 $MA35_OUT_DIR/$3
        fi

    ;;

    av1tohevc)
        echo "######################"
        echo "av1 to hevc transcode"
        echo "######################"

        if [[ $EN_CPU == true ]];then
            echo "@@@CPU process@@@";
            ffmpeg  $CPU_CONFIG \
                    -c:v $CPU_AV1_DEC \
                    -i $2 \
                    -c:v $CPU_HEVC_ENC \
                    -frames:v $FRAMES \
                    -f mp4 $CPU_OUT_DIR/$3
        fi

         if [[ $EN_MA35 == true ]];then
            echo "&&&MA35 process&&&";    
            ffmpeg  $MA35_CONFIG \
                    -stream_loop -1 \
                    -c:v $MA35_AV1_DEC \
                    -i $2 \
                    -c:v $MA35_HEVC_ENC \
                    -frames:v $FRAMES \
                    -b:v 10M \
                    -f mp4 $MA35_OUT_DIR/$3
        fi

        
    ;;
    *) 
        echo "please input a transcode type"
        echo "For Example"
         echo "./ffmpeg_cmd.sh [trans_type] [codec_inputfile] [codec_putputfile] <device_type default cpu>"
    ;;
esac