import os
import json
import subprocess

import multiprocessing
import time

import keyboard

filepath='ma35.json'
cmd="/opt/amd/ma35/bin/mautil examine -d 0000:09:00.0 --report electrical --format JSON -o " + filepath 
def get_data():
    while True:

        # 检查文件是否存在
        if os.path.exists(filepath):
            # 如果文件存在，删除它
            os.remove(filepath)

        # 调用ma35的工具读取板卡数据
        p0 = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
        output = p0.stdout.read()
        # print(output)

        # 打开并读取文件
        with open('./' + filepath, 'r') as f:
            data = json.load(f)

        # 打印json数据
        # print(json.dumps(data, indent=4))

        # print(json.dumps(data['devices'][0]['electrical']['power']['board']['board_power']['power_mW'], indent=4))
        pwr=json.dumps(data['devices'][0]['electrical']['power']['board']['board_power']['power_mW'], indent=4)

        # card_pwr = json.loads(output)
        # print(card_pwr)
        print("current power... ", pwr, "mw")
        time.sleep(1)  # 暂停一秒钟

# 创建一个新的进程，目标函数是read_data
p = multiprocessing.Process(target=get_data)

def exit_program():
    print( "$$$$$$$")
    print('Ctrl+C pressed, exiting...')
    p.terminate()
    raise SystemExit

# print("keyboard.on_press_key")
# keyboard.on_press_key("space", exit_program , suppress=True)

# 启动新的进程
p.start()
