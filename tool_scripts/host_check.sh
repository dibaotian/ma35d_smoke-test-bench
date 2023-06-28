if [ $# -ne 1 ];then
    echo "please input BDF "
    echo "./host_check.sh [BDF] "
    echo "example: ./host_check.sh 09:00.0 "
    exit
fi

mautil examine -r host 

mautil examine -r host -f JSON -o sysinfo.json

mautil examine -r thermal -d 0000:$1

mautil examine -r electrical -d 0000:$1

mautil examine -r electrical thermal -d 0000:$1

mautil examine -r electrical -d 0000:09:00.0 | grep board_power


