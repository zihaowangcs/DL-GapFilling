import sys
import os
import pandas as pd
import numpy as np

def write_to_sorted_file(csv_headers,data,path):
    np_data = np.array(data)

    df = pd.DataFrame(data=np_data, columns=csv_headers)
    df.to_csv(path,index=False)

def parse_line(line,split_by = " "):
    line = str(line).replace("\n","")
    line_datas = line.split(split_by)
    return line_datas

def parse_sealer_log(file_path):
    file = open(file_path, 'r')
    names = []
    datas = []
    for line in file:
        if "gaps found" in line:
            total_gaps = int(parse_line(line)[0])
            names.append("total_gaps")
            datas.append(total_gaps)
        elif "run complete" in line:
            k = str(parse_line(line)[0])
            names.append(k)
        elif "Total gaps closed so far" in line:
            k_closed = int(parse_line(line)[len(parse_line(line))-1])
            datas.append(k_closed)
        elif "Gaps closed" in line:
            closed_gap = int(parse_line(line)[len(parse_line(line))-1])
            names.append("closed_gap")
            datas.append(closed_gap)
        elif "%" in line:
            closed_precent = str(line).replace("\n","")
            names.append("closed_precent")
            datas.append(closed_precent)
    if len(names) == len(datas):
        return names,datas
    else:
        return None,None

def main():
    cur_dir = sys.argv[1]
    dir_list = os.listdir(cur_dir)
    target_file_name = "/gene-scaffolds.sealer_log.txt"
    sorted_file_path = cur_dir + "/gene_gap_sorted.csv"
    csv_headers = None
    gap_datas = []
    for dir_name in dir_list:
        full_target_path = dir_name + target_file_name
        if os.path.exists(full_target_path):
            headers,gap_data = parse_sealer_log(full_target_path)
            if headers is not None and csv_headers is None:
                headers.insert(0, "id")
                csv_headers = headers
            if gap_data is not None:
                gap_data.insert(0, dir_name)
                gap_datas.append(gap_data)

    if csv_headers is not None:
        sort_index = len(gap_datas[0])-2
        gap_datas.sort(key=lambda x:x[sort_index],reverse=True)
        write_to_sorted_file(csv_headers,gap_datas,sorted_file_path)

if __name__ == "__main__":
    main()