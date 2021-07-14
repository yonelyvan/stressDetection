# python3 file.py 

from flask import Flask
from flask import request
import json


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


model = tf.keras.models.load_model("nn_voice.h5")

##sound
def voice_classify(vec_feature):
    # load model
    ### model = tf.keras.models.load_model('/Users/yonel/dockerprojects/rest-api-example-node/src/routes/nn_voice.h5')
    predictions = model.predict(vec_feature)
    #print(predictions)

    # Generate arg maxes for predictions
    #classes = np.argmax(predictions, axis = 1)
    #print(classes)
    ###return np.argmax(predictions[0])
    r = np.argmax(predictions, axis = 1)
    return r[0]


def run( audio_path):
    # 1) get voice stress prediction
    file_name = audio_path #"/Users/yonel/dockerprojects/rest-api-example-node/src/routes/stress.wav" #sys.argv[1] #"stress.wav"
    #print(file_name)
    
    voice_fatures = get_sound_features(file_name)
    #min_max_scaler = preprocessing.MinMaxScaler()
    X = voice_fatures  #min_max_scaler.fit_transform(voice_fatures)
    
    #print( "X_data:", X.shape )
    voice_stress_level = voice_classify(X)

    if voice_stress_level>=1:
        voice_stress_level = 3.0
    else:
        voice_stress_level = 1.0

    return voice_stress_level



#-------------------- run flask app --------------------


app = Flask(__name__)



## test functions

@app.route('/test')
def test():
    path = "/home/yonel/dockerprojects/rest-api-example-node/src/routes/stress.wav"
    stress_level = run(path)
    data = {'path': path, "stress_level" : stress_level}
    return json.dumps(data), 200, {'ContentType':'application/json'}


@app.route("/saludo",  methods = ['POST'])
def hello():
    path = request.get_json()["path"]
    stress_level = run(path)
    print(path)
    data = {'path': path, "stress_level" : stress_level}
    return json.dumps(data), 200, {'ContentType':'application/json'}

@app.route("/hola",  methods = ['POST'])
def hola():
    nombre = request.get_json()["nombre"]
    data = {'resultado': "hola "+nombre}
    return json.dumps(data), 200, {'ContentType':'application/json'}


@app.route('/flask', methods=['GET'])
def helloflask():
    data = {"sms" : "Hello Flask >>>"}
    return json.dumps(data), 200, {'ContentType':'application/json'}



## to detect stress level
@app.route("/flask_voice_stress_level",  methods = ['POST'])
def get_voice_stress_level():
    audio_path = request.get_json()["audio_path"]
    stress_level = run(audio_path)    
    data = {'audio_path': audio_path, "stress_level" : stress_level}
    return json.dumps(data), 200, {'ContentType':'application/json'}



#@app.route('/')
#def index():
#    return 'Web App with Python Flask!'

app.run(host='0.0.0.0', port=5000, debug = True)




