### imput: muesta de audio y muestra de GRS
### outut: Stess level
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 

import numpy as np
import librosa 
from librosa import feature
import soundfile
from sklearn import preprocessing

import tensorflow as tf

#load svm model
#from joblib import dump, load

import pandas as pd
import wfdb
import matplotlib.pyplot as plt
import math
import seaborn as sns

import sys 
import json




def extract_feature(file_name, **kwargs):
    mfcc = kwargs.get("mfcc")
    chroma = kwargs.get("chroma")
    mel = kwargs.get("mel")
    contrast = kwargs.get("contrast")
    tonnetz = kwargs.get("tonnetz")
    with soundfile.SoundFile(file_name) as sound_file:
        X_file_data = sound_file.read(dtype="float32")
        sample_rate = sound_file.samplerate
        if chroma or contrast:
            stft = np.abs(librosa.stft(X_file_data))
        result = np.array([])
        if mfcc:
            mfccs = np.mean(librosa.feature.mfcc(y=X_file_data, sr=sample_rate, n_mfcc=40).T, axis=0)
            result = np.hstack((result, mfccs))#concatena ([1,2][3,4]) => [1,2,3,4]
            
            mfccs_var = np.var(librosa.feature.mfcc(y=X_file_data, sr=sample_rate, n_mfcc=40).T, axis=0)
            result = np.hstack((result, mfccs_var))
            
            mfccs_std = np.std(librosa.feature.mfcc(y=X_file_data, sr=sample_rate, n_mfcc=40).T, axis=0)
            result = np.hstack((result, mfccs_std))
    
        if chroma:
            chroma = np.mean(librosa.feature.chroma_stft(S=stft, sr=sample_rate).T,axis=0)
            result = np.hstack((result, chroma))
        if mel:
            mel = np.mean(librosa.feature.melspectrogram(X_file_data, sr=sample_rate).T,axis=0)
            result = np.hstack((result, mel))
        if contrast:
            contrast = np.mean(librosa.feature.spectral_contrast(S=stft, sr=sample_rate).T,axis=0)
            result = np.hstack((result, contrast))
        if tonnetz:
            tonnetz = np.mean(librosa.feature.tonnetz(y=librosa.effects.harmonic(X_file_data), sr=sample_rate).T,axis=0)
            result = np.hstack((result, tonnetz))
    return np.array([result])


def get_sound_features(file_name):
    f = extract_feature(file_name, chroma=True, mfcc=True, mel=True, contrast=True, tonnetz=True)
    return f


##sound
def voice_classify(vec_feature):
    # load model
    model = tf.keras.models.load_model('/home/yonel/dockerprojects/rest-api-example-node/src/routes/nn_voice.h5')
    predictions = model.predict(vec_feature)
    #print(predictions)

    # Generate arg maxes for predictions
    #classes = np.argmax(predictions, axis = 1)
    #print(classes)
    ###return np.argmax(predictions[0])
    r = np.argmax(predictions, axis = 1)
    return r[0]

def run():
    # 1) get voice stress prediction
    file_name = sys.argv[1]  #"/home/yonel/dockerprojects/rest-api-example-node/src/routes/stress.wav" #sys.argv[1] #"/home/yonel/dockerprojects/rest-api-example-node/src/routes/stress.wav" #sys.argv[1] #"stress.wav"
    #print(file_name)
    
    voice_fatures = get_sound_features(file_name)
    #min_max_scaler = preprocessing.MinMaxScaler()
    X = voice_fatures  #min_max_scaler.fit_transform(voice_fatures)
    
    #print( "X_data:", X.shape )
    voice_result = voice_classify(X)

    if voice_result>=1:
        voice_result = 3.0
    else:
        voice_result = 1.0
    
    r = {
        "clasificacion": voice_result
    }
    print(json.dumps(r))


run()
