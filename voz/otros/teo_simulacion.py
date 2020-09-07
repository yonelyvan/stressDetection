from utils import *

import librosa
import soundfile
import os, glob, pickle
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score

filename = "blues.wav"

def extract_feature(file_name, mfcc):
    with soundfile.SoundFile(file_name) as sound_file:
        X = sound_file.read(dtype="float32")
        sample_rate=sound_file.samplerate #TODO 16000Hz
        result = np.array([])
        # Mel Frequency Cepstral Coefficient (MFCC)
        if mfcc:
            mfccs = np.mean(librosa.feature.mfcc(y=X, sr=sample_rate, n_mfcc=40).T, axis=0)
            result = np.hstack((result, mfccs)) 
    return result


# feature = extract_feature(filename, mfcc=True)
# print(feature)




def teo():
    signal, sr = librosa.load(filename, sr=48000, mono=True) #16000
    plot_data(signal,sr)

    tkeo = []
    for i in range(0, len(signal)):
        if i == 0 or i == len(signal) - 1:
            tkeo.append(signal[i])
        else:
            tkeo.append(pow(signal[i], 2) - (signal[i + 1] * signal[i - 1]))
    tkeo_np = np.array(tkeo)
    plot_data(np.array(tkeo_np), sr)
    librosa.output.write_wav('salida_teo.wav', tkeo_np, sr) #save file, energia que genera el sistema de sonido




teo()

    