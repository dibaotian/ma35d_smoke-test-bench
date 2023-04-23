
import os
import json
import subprocess
import xlsxwriter
import time


timegap=1   # mean 1s time.sleep(int(gap_time))

file_sysinfo = 'sysinfo.json'
if os.path.exists(file_sysinfo):
    os.remove(file_sysinfo)

file_powerinfo = 'powerinfo.json'
if os.path.exists(file_powerinfo):
    os.remove(file_powerinfo)

file_powerchart = 'power_chart.xlsx'
if os.path.exists(file_powerchart):
    os.remove(file_powerchart)

# cmd_str = "mautil examine -r host -f JSON -o sysinfo.json"
cmd_str = "mautil examine -r host -f JSON -o sysinfo.json"
subprocess.run(cmd_str, shell=True)
# ret = subprocess.Popen(cmd_str, stdout=subprocess.PIPE, shell=True)

with open(file_sysinfo, 'r') as f:
    data = json.load(f)

device_num = len(data["system"]["host"]["devices"])
device_bdf=data["system"]["host"]["devices"][0]['bdf']
# print(device_bdf)
print("there are {} device, the device id is {}".format(device_num, data["system"]["host"]["devices"]))

cmd_str = "mautil examine -r electrical thermal -d {} -f JSON -o powerinfo.json --force".format(device_bdf)
print(cmd_str)
power_list=[]
#计算一分钟count
count = 20/timegap
while True:
    subprocess.run(cmd_str, shell=True)
    with open(file_powerinfo, 'r') as f:
        data = json.load(f)

    # print(data)
    # print("")
    # print(data["devices"][0]["electrical"]["power"]["sensor0"]["power_mW"])
    power_list.append(data["devices"][0]["electrical"]["power"]["sensor0"]["power_mW"])
    time.sleep(int(timegap))
    count = count - 1
    if count == 0:
        break

print(power_list)

# 创建一个新的 Excel 文件并添加一个工作表
workbook = xlsxwriter.Workbook(file_powerchart)
# workbook = xlsxwriter.Workbook('chart.xlsx')
worksheet = workbook.add_worksheet()
worksheet.write_column('A1', power_list)

# 创建一个图表对象
chart = workbook.add_chart({'type': 'column'})

# 配置图表
chart.add_series({'values': '=Sheet1!$A$1:$A$6'})
chart.set_title({'name': 'power chart'})

# 将图表插入工作表
worksheet.insert_chart('C1', chart)
workbook.close()

