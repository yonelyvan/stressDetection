## preprocesamiento de señal de voz

from utils import *
import librosa 
import librosa.display
import matplotlib.pyplot as plt
import numpy as np
filename = "audio.wav"

# 1) audio: mono 
# 2) frecuencia de muestreo(SR): 16000Hz
y, sr = librosa.load(filename, sr=16000, mono=True)

# 3) normalizacion
MIN = min(y)
MAX = max(y)
media = sum(y)/len(y)
normalizado = y 
for i in range(len(y)):
    #normalizado[i] =  (y[i]-media)/abs(MAX-MIN)
    normalizado[i] =  2.0*(y[i]-MIN)/(MAX-MIN)-1 #(y[i]-media)/abs(MAX-MIN)

plot_data(normalizado, sr)

# 4) TODO: reduccion de ruido
# 5) TODO: detectar momentos de silencio, Voice Activity Detector (VAD)









