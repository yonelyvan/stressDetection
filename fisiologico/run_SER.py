import neurokit2 as nk
import matplotlib.pyplot as plt
import numpy as np

from io import TextIOWrapper
import csv

#para moverse en directorios
import os, glob, pickle
#for zip files
from zipfile import ZipFile


#frecuencia de muestreo de EDA
f_muestreo = 8 #4hz

def load_file_from_zip(reader):
    #reader = csv.reader(file_from_zip)
    data = []
    i =0
    for line in reader:
        if i!=0:
            value = float(line[0])
            data.append(value)
            data.append(value)
        i+=1

    data_eda = np.array(data)
   
    # Preprocess the data (filter, find peaks, etc.)
    processed_data, info = nk.bio_process(eda=data_eda, sampling_rate=f_muestreo)
    #processed_data, info = nk.bio_process(ecg=data["ECG"], rsp=data["RSP"], eda=data["EDA"], sampling_rate=100)

    # Compute relevant features
    results = nk.bio_analyze(processed_data, sampling_rate=f_muestreo)
    r = [results["SCR_Peaks_N"][0], results["SCR_Peaks_Amplitude_Mean"][0]]
    return r
    #TODO: make sure that SCL and SCR are included as aditional number of picks

def load_dataset():
    X=[]
    Y=[]
    dir = "/media/y/730D-8298/DATASETS/WESAD"
    for file in glob.glob(dir+"/S*/*.zip"):
        print(file)
        with ZipFile(file, 'r') as zip:
            with zip.open('EDA.csv', 'r') as infile:
                reader = csv.reader(TextIOWrapper(infile, 'utf-8'))
                r = load_file_from_zip(reader)
                X.append(r)
    return X


########## on tensorflow #######
#get Xdata and Ydata
print("hello")
X_data = load_dataset()
print(X_data)


#...












