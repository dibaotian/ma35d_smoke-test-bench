#!/bin/bash
# device_type=cpu
device_type=ma35

# decode
./ffmpeg_cmd.sh h264dec ../videos/TheaterSquare_640x360.h264.mp4 h264dec.out $device_type  #pass
# ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu/h264dec.out
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4

# ./ffmpeg_cmd.sh hevcdec ../videos/video-h265.mkv hevcdec.out $device_type   # pass
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu/hevcdec.out
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/video-h265.mkv


# ./ffmpeg_cmd.sh av1dec ../videos/CityHall_640x360.av1.webm av1dec.out $device_type   # will support in next SDK version

# ./ffmpeg_cmd.sh vp9dec ../videos/UshaikaRiverEmb_854x480.vp9.webm vp9dec.out $device_type   # will support in next SDK version

# encode
# ./ffmpeg_cmd.sh h264enc ../videos/akiyo_qcif.y4m h264enc.out $device_type #pass

# ./ffmpeg_cmd.sh hevcenc ../videos/akiyo_qcif.y4m hevcenc.out $device_type #pass

# ./ffmpeg_cmd.sh av1enc ../videos/akiyo_qcif.y4m av1enc.out $device_type # pass

# transcode 
# ./ffmpeg_cmd.sh  h264toh264 ../videos/TheaterSquare_640x360.h264.mp4 h264toh264.out $device_type   # pass
# ./ffmpeg_cmd.sh  h264tohevc ../videos/TheaterSquare_640x360.h264.mp4 h264tohevc.out $device_type   # pass
# ./ffmpeg_cmd.sh  h264toav1 ../videos/TheaterSquare_640x360.h264.mp4 h264tohevc.out $device_type   # pass

# ./ffmpeg_cmd.sh  hevctohevc ../videos/video-h265.mkv hevctohevc.out $device_type #pass
# ./ffmpeg_cmd.sh  hevctoh264 ../videos/video-h265.mkv hevctohevc.out $device_type #pass
# ./ffmpeg_cmd.sh  hevctoav1 ../videos/video-h265.mkv hevctoav1.out $device_type #pass

# ./ffmpeg_cmd.sh  av1toav1 ../videos/CityHall_640x360.av1.webm av1toav1.out $device_type

# ./ffmpeg_cmd.sh  av1toh264 ../videos/CityHall_640x360.av1.webm av1toh264.out $device_type

# ./ffmpeg_cmd.sh  av1tohevc ../videos/CityHall_640x360.av1.webm  av1tohevc.out $device_type






# ./ffmpeg_cmd.sh  h264tohevc ../videos/TheaterSquare_640x360.h264.mp4 h264tohevc.out $device_type   #fail, process hang

# ./ffmpeg_cmd.sh hevctohevc ../videos/video-h265.mkv hevcenc.out $device_type  # fail
# ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 -i ../videos/video-h265.mkv




# echo $?

# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/cpu_h264toh264.mp4

# size=$(mediainfo trans_out/cpu_h264toh.out  | grep "File size" | awk '{print $4}')
# echo $size




# ./ffmpeg_cmd.sh  h264toav1 ../videos/TheaterSquare_640x360.h264.mp4 h264toav1.out $device_type   
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i ../videos/TheaterSquare_640x360.h264.mp4
# ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i trans_out/ma35/h264toav1.out

# ./ffmpeg_cmd.sh  hevctohevc ../videos/video-h265.mkv $device_type

# ./ffmpeg_cmd.sh  hevctoh264 ../videos/video-h265.mkv $device_type

# ./ffmpeg_cmd.sh  hevctoav1 ../videos/video-h265.mkv $device_type


# ./ffmpeg_cmd.sh hevctohevc ../videos/TheaterSquare_640x360.h264.mp4 $device_type

echo $?



