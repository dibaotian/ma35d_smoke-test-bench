#!/bin/bash

# Author: MinXie
# Copyright: 2023 MinXie
# Origin: 2023/4
# Contact: minx@amd.com
# Description: This script is used for the MA35D basic test.

# change here to decied run the codec in CPU or ma35d transcode card
# device=cpu
device=ma35

# defind codec array
codec_dec=(h264dec hevcdec av1dec vp9dec)
codec_enc=(h264enc hevcenc av1enc)
codec_tra=(h264toh264 h264tohevc h264toav1 hevctohevc hevctoh264 hevctoav1 av1toav1 av1toh264 av1tohevc)
codec=(${codec_dec[*]} ${codec_enc[*]} ${codec_tra[*]})

echo " "
# defind codec input and output 
declare -A codec_input
codec_input=([h264dec]="../videos/TheaterSquare_640x360.h264.mp4"  
            [hevcdec]="../videos/video-h265.mkv" 
            [av1dec]="../videos/CityHall_640x360.av1.webm" 
            [vp9dec]="../videos/UshaikaRiverEmb_854x480.vp9.webm" 
            [h264enc]="../videos/akiyo_qcif.y4m" 
            [hevcenc]="../videos/akiyo_qcif.y4m" 
            [av1enc]="../videos/akiyo_qcif.y4m" 
            [h264toh264]="../videos/TheaterSquare_640x360.h264.mp4" 
            [h264tohevc]="../videos/TheaterSquare_640x360.h264.mp4" 
            [h264toav1]="../videos/TheaterSquare_640x360.h264.mp4" 
            [hevctohevc]="../videos/video-h265.mkv" 
            [hevctoh264]="../videos/video-h265.mkv" 
            [hevctoav1]="../videos/video-h265.mkv"
            [av1toav1]="../videos/CityHall_640x360.av1.webm" 
            [av1toh264]="../videos/CityHall_640x360.av1.webm" 
            [av1tohevc]="../videos/CityHall_640x360.av1.webm")

declare -A codec_output
codec_output=([h264dec]="h264dec.out"  
            [hevcdec]="hevcdec.out" 
            [av1dec]="av1dec.out" 
            [vp9dec]="vp9dec.out" 
            [h264enc]="h264enc.out" 
            [hevcenc]="hevcenc.out" 
            [av1enc]="av1enc.out" 
            [h264toh264]="h264toh264.out" 
            [h264tohevc]="h264tohevc.out" 
            [h264toav1]="h264toav1.out" 
            [hevctohevc]="hevctohevc.out" 
            [hevctoh264]="hevctoh264.out" 
            [hevctoav1]="hevctoav1.out"
            [av1toav1]="av1toav1.out" 
            [av1toh264]="av1toh264.out" 
            [av1tohevc]="av1tohevc.out")

# define codec execute result
declare -A codec_result
declare -A codec_fail_reason

echo "###test codec###"
echo ${codec[*]}

echo " "
echo "###codec input file###"
# for key in ${!codec_input[@]}
for key in ${codec[@]}
do 
    echo "$key --- ${codec_input[$key]}"  
done

# for key in ${!codec_input[@]}
for key in ${codec[@]}
do 
    if [ ! -f ${codec_input[$key]} ]; then
        echo " ${codec_input[$key]}  not exist, please check"
        exit
    else
        # type=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 -i ${codec_input[$key]})
       
        # echo $type
        # echo $key
        # # check if the input stream type is correct
        # echo ${key:0:${#type}}
        # echo " "

        # if [[ "${codec_enc[@]}" =~ "$key" ]]; then
        #     # encode input stream could be rawvideo or ...
        #     if [ $type != "rawvideo" ] || [ $type == ${key:0:${#type}} ]; then
        #         echo "$key input type $type error, please check the file ${codec_input[$key]}"
        #         exit
        #     fi
        # else
        #     if [ $type != ${key:0:${#type}} ]; then
        #       echo "$key input type $type error, please check the file ${codec_input[$key]}"
        #       exit
        #     fi
        # fi

        # In case we do not have ffprobe in the docker
        type=$(mediainfo --Inform="Video;%Format%" ${codec_input[$key]})

        if [ $type == "AVC" ];then
            type="h264"
        fi

        if [ $type == "HEVC" ];then
            type="hevc"
        fi

        if [ $type == "VP9" ];then
            type="vp9"
        fi

        if [ $type == "AV1" ];then
            type="av1"
        fi


        # check the input stream type
        if [[ "${codec_enc[@]}" =~ "$key" ]]; then
            # encode input stream could be rawvideo or ...

            if [ $type != "YUV" ] || [ $type == ${key:0:${#type}} ]; then
                echo "$key input type $type error, please check the file ${codec_input[$key]}"
                exit
            fi

        else
            if [ $type != ${key:0:${#type}} ]; then
              echo "$key input type $type error, please check the file ${codec_input[$key]}"
              exit
            fi
        fi

        
    fi
done

# for key in ${!codec_input[@]}
for key in ${codec[@]}
do 
    ./ffmpeg_cmd.sh $key ${codec_input[$key]} ${codec_output[$key]} $device

    # todo find more way to check the transcode video
    # execute sucess and fail check
    if [ $? -eq 0 ];then 
        # size=$(mediainfo trans_out/cpu/${codec_output[$key]}  | grep "File size" | awk '{print $4}')
        size=$(mediainfo trans_out/$device/${codec_output[$key]} | grep "File size" | awk '{print $4}')
        echo "size is $size"
        if [ $size == 0 ] || [  -z $size ];then
            echo "$key failed"
            codec_result[$key]="failed"
            codec_fail_reason[$key]="mediainfo check fail, output size =0 or mediainfo check fail"

            echo ${codec_result[$key]}
        else
            echo "$key succeeded"
            codec_result[$key]="succeed"
            echo ${codec_result[$key]}
        fi
    else
        echo "$key failed"
        codec_result[$key]="failed"
        codec_fail_reason[$key]="ffmpeg return fail"
        echo ${codec_result[$key]}
    fi
done

echo "#####execute result#####"
for key in ${codec[@]}
do 
    # echo "$key result --- ${codec_result[$key]}"  
    printf "%10s" "$key"
    printf "%4s" "----"
    printf "%-20s\n" ${codec_result[$key]}
    
done
echo "#####execute result#####"

# printf "\n "
# printf "###basic function run result###\n"
# printf "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n" "h264dec"                 "hevcdec"                "av1dec "                  "h264enc" "hevcenc" "av1enc " "h264toh264" "h264tohevc" "h264toav1 " "hevctohevc" "hevctoh264" "hevctoav1" "av1toav1" "av1toh264" "av1tohevc" "vp9dec"
# printf "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n" ${codec_result[h264dec]}  ${codec_result[hevcdec]}  ${codec_result[av1dec]}   $h264enc  $hevcenc  $av1enc   $h264toh264  $h264tohevc   $h264toav1   $hevctohevc $hevctoh264  $hevctoav1  $av1toav1  $av1toh264  $av1tohevc  $vp9dec

exit

./ffmpeg_cmd.sh h264dec ../videos/TheaterSquare_640x360.h264.mp4
if [ $? -eq 0 ]
then
    
    #Duration before transcode
    # ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4
    # ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu_h264toh264.mp4

    size=$(mediainfo trans_out/h264dec.out  | grep "File size" | awk '{print $4}')
    if [ $size -eq 0 ] || [  -z $size ];then
        echo "h264dec failed"
        h264dec="failed"
    else
        echo "h264dec succeeded"
        h264dec="succeeded"
    fi

    
else
    echo "h264dec failed"
    h264dec="failed"
fi

./ffmpeg_cmd.sh hevcdec ../videos/video-h265.mkv

if [ $? -eq 0 ]
then
     #Duration before transcode
    # ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/video-h265.mkv
    # ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu_hevcdec.out

    size=$(mediainfo trans_out/h264dec.out  | grep "File size" | awk '{print $4}')
    if [ $size -eq 0  && -z $size ];then
        echo "h264dec failed"
        h264dec="failed"
    else
        echo "h264dec succeeded"
        h264dec="succeeded"
    fi
else
    echo "hevcdec failed"
    hevcdec="failed"
fi

./ffmpeg_cmd.sh av1dec ../videos/CityHall_640x360.av1.webm

if [ $? -eq 0 ]
then
    av1dec="succeeded"
    echo "av1dec succeeded"
else
    av1dec="failed"
    echo "av1dec failed"
fi

./ffmpeg_cmd.sh vp9dec ../videos/UshaikaRiverEmb_854x480.vp9.webm
if [ $? -eq 0 ]
then
    vp9dec="succeeded"
    echo "vp9dec succeeded"
else
    vp9dec="failed"
    echo "vp9dec failed"
fi

./ffmpeg_cmd.sh h264enc ../videos/akiyo_qcif.y4m

if [ $? -eq 0 ]
then
    h264enc="succeeded"
    echo "h264enc succeeded"
else
    h264enc="failed"
    echo "h264enc failed"
fi

./ffmpeg_cmd.sh hevcenc ../videos/akiyo_qcif.y4m

if [ $? -eq 0 ]
then
    hevcenc="succeeded"
    echo "hevcenc succeeded"
else
    hevcenc="failed"
    echo "hevcenc failed"
fi

./ffmpeg_cmd.sh av1enc ../videos/akiyo_qcif.y4m

if [ $? -eq 0 ]
then
    av1enc="succeeded"
    echo "av1enc succeeded"
else
    av1enc="failed"
    echo "av1enc failed"
fi

./ffmpeg_cmd.sh h264toh264 ../videos/TheaterSquare_640x360.h264.mp4
if [ $? -eq 0 ]
then
    h264toh264="succeeded"
    echo "h264toh264 succeeded"
else
    h264toh264="failed"
    echo "h264toh264 failed"
fi

./ffmpeg_cmd.sh h264tohevc ../videos/TheaterSquare_640x360.h264.mp4
if [ $? -eq 0 ]
then
    h264tohevc="succeeded"
    echo "h264toh264 succeeded"
else
    h264tohevc="failed"
    echo "h264toh264 failed"
fi


./ffmpeg_cmd.sh h264toav1 ../videos/TheaterSquare_640x360.h264.mp4
if [ $? -eq 0 ]
then
    h264toav1="succeeded"
    echo "h264toav1 succeeded"
else
    h264toav1="failed"
    echo "h264toav1 failed"
fi


./ffmpeg_cmd.sh hevctohevc ../videos/TheaterSquare_640x360.h264.mp4
if [ $? -eq 0 ]
then
    mediainfo cpu_hevctohevc.out
    if [ $? -eq 0 ];then
        hevctohevc="succeeded"
        echo "hevctohevc succeeded"
    else
        hevctohevc="failed"
        echo "hevctohevc failed"
    fi
else
    hevctohevc="failed"
    echo "hevctohevc failed"
fi


./ffmpeg_cmd.sh hevctohevc ../videos/video-h265.mkv
if [ $? -eq 0 ]
then
    hevctohevc="succeeded"
    echo "hevctohevc succeeded"
else
    hevctohevc="failed"
    echo "hevctohevc failed"
fi

./ffmpeg_cmd.sh hevctoh264 ../videos/video-h265.mkv
if [ $? -eq 0 ]
then
    hevctoh264="succeeded"
    echo "hevctoh264 succeeded"
else
    hevctoh264="failed"
    echo "hevctoh264 failed"
fi

./ffmpeg_cmd.sh hevctoav1 ../videos/video-h265.mkv
if [ $? -eq 0 ]
then
    hevctoav1="succeeded"
    echo "hevctoav1 succeeded"
else
    hevctoav1="failed"
    echo "hevctoav1 failed"
fi

./ffmpeg_cmd.sh  av1toav1 ../videos/CityHall_640x360.av1.webm
if [ $? -eq 0 ]
then
    av1toav1="succeeded"
    echo "av1toav1 succeeded"
else
    av1toav1="failed"
    echo "av1toav1 failed"
fi

./ffmpeg_cmd.sh  av1toh264 ../videos/CityHall_640x360.av1.webm
if [ $? -eq 0 ]
then
    av1toh264="succeeded"
    echo "av1toh264 succeeded"
else
    av1toh264="failed"
    echo "av1toh264 failed"
fi

./ffmpeg_cmd.sh  av1tohevc ../videos/CityHall_640x360.av1.webm
if [ $? -eq 0 ]
then
    av1tohevc="succeeded"
    echo "av1tohevc succeeded"
else
    av1tohevc="failed"
    echo "av1tohevc failed"
fi




printf "\n "
printf "###basic function run result###\n"
printf "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n" "h264dec" "hevcdec" "av1dec " "h264enc" "hevcenc" "av1enc " "h264toh264" "h264tohevc" "h264toav1 " "hevctohevc" "hevctoh264" "hevctoav1" "av1toav1" "av1toh264" "av1tohevc" "vp9dec"
printf "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n" $h264dec  $hevcdec  $av1dec   $h264enc  $hevcenc  $av1enc   $h264toh264  $h264tohevc   $h264toav1   $hevctohevc $hevctoh264  $hevctoav1  $av1toav1  $av1toh264  $av1tohevc  $vp9dec

