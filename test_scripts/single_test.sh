#!/bin/bash

# ./ffmpeg_cmd.sh h264dec ../videos/TheaterSquare_640x360.h264.mp4 h264dec.out # fail
# ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu/h264dec.out
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4

# ./ffmpeg_cmd.sh hevcdec ../videos/video-h265.mkv hevcdec.out   # fail
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu/hevcdec.out
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/video-h265.mkv


# ./ffmpeg_cmd.sh av1dec ../videos/CityHall_1920x1080.av1.webm   # fail

# ./ffmpeg_cmd.sh vp9dec ../videos/UshaikaRiverEmb_1920x1080.vp9.webm   # fail

# ./ffmpeg_cmd.sh h264enc ../videos/akiyo_qcif.y4m #fail

# ./ffmpeg_cmd.sh hevctohevc ../videos/video-h265.mkv hevcenc.out  # fail
# ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 -i ../videos/video-h265.mkv

# ./ffmpeg_cmd.sh av1enc ../videos/akiyo_qcif.y4m # fail

# ./ffmpeg_cmd.sh  h264toh264 ../videos/TheaterSquare_640x360.h264.mp4 h264toh264.out   # fail, process hang
# echo $?

# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu_h264toh264.mp4

# size=$(mediainfo trans_out/cpu_h264toh.out  | grep "File size" | awk '{print $4}')
# echo $size


# ./ffmpeg_cmd.sh  h264tohevc ../videos/TheaterSquare_640x360.h264.mp4 h264tohevc.out   #fail, process hang

./ffmpeg_cmd.sh  h264toav1 ../videos/TheaterSquare_640x360.h264.mp4 h264toav1.out   #fail, process hang
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/ma35/h264toav1.out

# ./ffmpeg_cmd.sh  hevctohevc ../videos/video-h265.mkv

# ./ffmpeg_cmd.sh  hevctoh264 ../videos/video-h265.mkv

# ./ffmpeg_cmd.sh  hevctoav1 ../videos/video-h265.mkv

# ./ffmpeg_cmd.sh  av1toav1 ../videos/CityHall_1920x1080.av1.webm

# ./ffmpeg_cmd.sh  av1toh264 ../videos/CityHall_640x360.av1.webm av1toh264.out

# ./ffmpeg_cmd.sh  av1tohevc ../videos/CityHall_640x360.av1.webm  av1tohevc.out

# ./ffmpeg_cmd.sh hevctohevc ../videos/TheaterSquare_640x360.h264.mp4

echo $?



