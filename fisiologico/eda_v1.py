#detector v1 replicacion
import math
import numpy as np
import matplotlib.pyplot as plt

from io import TextIOWrapper
import neurokit2 as nk
import os, glob, pickle
from zipfile import ZipFile
import csv

#0) Load data : S8_E4_Data.zip 

#frecuencia de muestreo de EDA 4Hz

def load_file_from_zip(reader):
    d = []
    i =0
    for line in reader:
        if i!=0:
            value = float(line[0])
            d.append(value)
            d.append(value)
        i+=1
    data_eda = np.array(d)
    return data_eda

def load_dataset():
    #dir = "/Users/y/theproject/emociones/project/fisiologico" # mac
    dir = "/home/y/theproject/emociones/project/fisiologico" # ubuntu
    for file in glob.glob(dir+"/*.zip"):
        print(file)
        with ZipFile(file, 'r') as zip:
            with zip.open('EDA.csv', 'r') as infile:
                reader = csv.reader(TextIOWrapper(infile, 'utf-8'))
                r = load_file_from_zip(reader)
                return r #retornamos solo el primero, solo para pruebas

data = load_dataset() 

# plot data: 4Hz
minutos = 10
minutos_muestra = 4*60*minutos
x = [] #milliseconds
y = data 
#y = data[0:minutos_muestra] #TODO: cambiar y usar toda la muestra
mi = 0 #minutos

for e in y:
    mi += 0.0041667 # 240 muestras X segundo
    x.append(mi)

plt.plot(x,y,'k-', color='red', label="RAW")
plt.title("Señal EDA (RAW)")
plt.xlabel("Tiempo (Minutos)")
plt.ylabel("µS")
plt.legend(loc="upper right")
#plt.show()


#1) Preprocessing (eliminacion de ruido)
def filtro_media(signal,tam=100):
    suavizado = []
    filtro = np.ones(tam)
    len_data = len(signal)
    mitad = tam/2
    for i in range(len_data):
        if(i>=mitad and (len_data-i)>=mitad ):
            it = int(i-mitad)
            s=0
            for j in range(tam):
                value = signal[it+j] 
                s += value*filtro[j]
            media = s/tam
            suavizado.append(media)
        else:
            suavizado.append(signal[i])
    return suavizado

eda_suvizado = filtro_media(y,tam=100)

plt.plot(x,eda_suvizado,'k-',color='green', label="Filtro media")
plt.title("Señal EDA  (fitro ruido)")
plt.xlabel("Tiempo (Minutos)")
plt.ylabel("µS")
plt.legend(loc="upper right")
#plt.show()


#2) Agregacion
print("len: data y:",len(y),"len data suavzado:",len(eda_suvizado))

def agregacion(v):
    y2 = []
    m = 240 # 1 minuto de muestreo
    it = 0  
    while it < (len(v)-m):
        maximo = -9999
        for i in range(m):
            if (it+i) < len(v): ##revisar limites validos de indices
                maximo = max(maximo,v[ it+i ])
                it+=1
            else :
                break
        y2.append(maximo)
    return y2
    

eda_agregado = agregacion(eda_suvizado)
print("len eda_agregado:", len(eda_agregado))

plt.plot(eda_agregado,'k-',color='orange', label="Agregacion")
plt.title("Señal EDA  (agregación)")
plt.xlabel("Tiempo (Minutos)")
plt.legend(loc="upper right")
#plt.show()


#3) Discretizacion
# ref: https://github.com/seninp/saxpy
from saxpy.alphabet import cuts_for_asize
from saxpy.znorm import znorm
from saxpy.sax import ts_to_string
from saxpy.paa import paa

def PAA_aggregation(v):
    dat_znorm = znorm(v)
    r = paa(dat_znorm, len(v))
    #r = znorm(v)
    print("MIN MAX",min(r),max(r))
    return r

ppa_result = PAA_aggregation(eda_agregado)
plt.plot(ppa_result,'k-',color='cyan', label="PAA")
plt.legend(loc="upper right")
#plt.show()


def discretizar(v):
    alphabet_values = {'a':1,'b':2,'c':3,'d':4,'e':5}
    abc = ts_to_string(v, cuts_for_asize(5))  # abc : (cadena de String)
    r = []
    for i in range(len(abc)):
        val = alphabet_values[ abc[i] ]
        r.append(val)
    return r




eda_discretizado = discretizar(ppa_result)

plt.plot(eda_discretizado,'k-',color='blue', label="Discretizado (SAX)")
plt.title("Señal EDA  (Discretizado)")
plt.xlabel("Tiempo (Minutos)")
plt.ylabel("µS")
plt.legend(loc="upper right")
#plt.show()

#4) Deteccion de cambio (clasificacion)
from skmultiflow.drift_detection.adwin import ADWIN
adwin = ADWIN(delta = 0.01)
cambios_detectados_x = []
cambios_detectados_y = []
for i in range(len(eda_discretizado)):
    adwin.add_element(eda_discretizado[i])
    if adwin.detected_change():
        print('Change detected in data: ' + str(eda_discretizado[i]) + ' - at index: ' + str(i))
        cambios_detectados_x.append(i)
        cambios_detectados_y.append(eda_discretizado[i])


plt.plot(cambios_detectados_x,cambios_detectados_y, 'x', label="Cambio detectado" )
plt.legend(loc="upper right")
plt.show()


