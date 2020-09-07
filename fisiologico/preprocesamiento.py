import neurokit2 as nk
import matplotlib.pyplot as plt
import numpy as np
import csv
###info
#https://neurokit2.readthedocs.io/en/latest/examples/eda.html

#frecuencia de muestreo de EDA
f_muestreo = 8 #4hz

def generarDataSintetica():
    #generando datos
    # Generate 10 seconds of EDA signal (recorded at 250 samples / second) with 2 SCR peaks
    eda = nk.eda_simulate(duration=20, sampling_rate=250, scr_number=3, drift=0.01)

    # Process
    signals, info = nk.eda_process(eda, sampling_rate=250)

    # Visualise the processing
    nk.eda_plot(signals, sampling_rate=250)

#generarDataSintetica()


#load and plot real rdata
def loadRealdata():
    # Download example data
    data = nk.data("bio_eventrelated_100hz")

    # Preprocess the data (filter, find peaks, etc.)
    processed_data, info = nk.bio_process(ecg=data["ECG"], rsp=data["RSP"], eda=data["EDA"], sampling_rate=100)

    # Compute relevant features
    results = nk.bio_analyze(processed_data, sampling_rate=100)


#loadrealdata()


# preprocesamiento, caracteristicas y calsificacion


#TODO: revisar si la primera linea es un numero valido...
def load_csv_file():
    file = open( "EDA3.csv", "r")
    reader = csv.reader(file)
    data = []
    i =0
    for line in reader:
        if i!=0:
            value = float(line[0])
            data.append(value) #TODO: se podria usar el promedio (D[i-1] + D[i])/2.0
            data.append(value)
        i+=1

    data_eda = np.array(data)
   
    # Preprocess the data (filter, find peaks, etc.)
    #signals, info = nk.bio_process(eda=data_eda, sampling_rate=f_muestreo)
    signals, info = nk.eda_process(data_eda, sampling_rate=f_muestreo)
    #signals, info = nk.bio_process(ecg=data["ECG"], rsp=data["RSP"], eda=data["EDA"], sampling_rate=100)

    # Compute relevant features
    #results = nk.bio_analyze(signals, sampling_rate=f_muestreo)
    #print(results)
    # Extract clean EDA and SCR features
    cleaned = signals["EDA_Clean"]
    features = [info["SCR_Onsets"], info["SCR_Peaks"], info["SCR_Recovery"]]
    #print(features)
    #print(cleaned[0])
    plt.plot(cleaned)
    plt.ylabel('some numbers')
    plt.show()

    # Visualise the processing
    nk.eda_plot(signals, sampling_rate=f_muestreo)
    
    
load_csv_file()

