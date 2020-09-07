from utils import *
import librosa 
import librosa.display
import soundfile
import os, glob, pickle
import matplotlib.pyplot as plt

import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score

#filename = "audio.wav"

############### preprocessing ###############
def preprocessing(filename):
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
    
    #plot_data(normalizado, sr)
    #TODO: otros: farming, windowing, Voice Activity Detector (VAD), noise reduction,
    return [normalizado, sr]


############### features extraction ############### #TODO: unconected

def extract_feature(file_name, mfcc):
    with soundfile.SoundFile(file_name) as sound_file:
        #X = sound_file.read(dtype="float32")
        X, sample_rate = preprocessing(file_name)#preprocessing
        #sample_rate=sound_file.samplerate #TODO 16000Hz
        result = np.array([])
        # Mel Frequency Cepstral Coefficient (MFCC)
        if mfcc:
            mfccs = np.mean(librosa.feature.mfcc(y=X, sr=sample_rate, n_mfcc=40).T, axis=0)
            result = np.hstack((result, mfccs)) 
        #TODO: Teager Energy Operator(TEO)
        #TODO: jitter & shimmer
    return result



'''
for file in glob.glob("/home/y/Documents/ravdess_test/Actor_*/*.wav"):
    file_name=os.path.basename(file)
    emotion=emotions[file_name.split("-")[2]]
    print(file_name,emotion)
    f = extract_feature(file, mfcc=True)
    print(f)
    break
'''

############### Classify ###############

#Emociones del conjunto de datos de RAVDESS
emotions={
    '01':'neutral',
    '02':'calm',
    '03':'happy',
    '04':'sad',
    '05':'angry',
    '06':'fearful',
    '07':'disgust',
    '08':'surprised'
}
#Emociones para observar
observed_emotions=['neutral','angry']



#Cargar data y extraer caracteristicas
def load_data(test_size=0.2):
    x,y=[],[]
    for file in glob.glob("/media/y/730D-8298/DATASETS/ravdess_test/Actor_*/*.wav"): #* PC
        file_name=os.path.basename(file)
        emotion=emotions[file_name.split("-")[2]]
        if emotion not in observed_emotions:
            continue
        feature=extract_feature(file, mfcc=True) #TODO: add more features
        x.append(feature)
        y.append(emotion)
    return train_test_split(np.array(x), y, test_size=test_size, random_state=9)


#Dividir el conjunto de datos
x_train,x_test,y_train,y_test=load_data(test_size=0.20)


#Conjuntos de datos de entrenamiento y prueba
print((x_train.shape[0], x_test.shape[0]))
print("Caracteristicas extraidas:", {x_train.shape[1]})

#Inicialisacion del clasificador: Multi Layer Perceptron
model=MLPClassifier(alpha=0.01, batch_size=64, epsilon=1e-08, hidden_layer_sizes=(300,), learning_rate='adaptive', max_iter=500)

#Entrenar modelo
model.fit(x_train,y_train)


#Prediccion para el conjunto de prueba
y_pred = model.predict(x_test)


#Calculo de la precisión de nuestro modelo
accuracy=accuracy_score(y_true=y_test, y_pred=y_pred)
#Imprimir la precisión
print("Accuracy: {:.2f}%".format(accuracy*100))


print("OK")



