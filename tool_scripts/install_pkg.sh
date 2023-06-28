apt -y update
apt install python3 -y
apt install mediainfo -y

apt install pip -y
python3 -m pip install --upgrade pip
pip install xlsxwriter
pip install matplotlib
pip3 install Jupyter
pip install keyboard

# install in outside docker
# sudo apt-get install  libx264-dev -y
# sudo apt-get install  libx265-dev -y