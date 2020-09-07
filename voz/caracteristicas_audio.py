# características que se extraen de las señales de voz

#!/usr/bin/env python
# -*- coding: utf-8 -*-
import librosa 
import librosa.display
import matplotlib.pyplot as plt
import IPython.display as ipd #play sound
import sklearn

def normalize(x, axis=0):
        return sklearn.preprocessing.minmax_scale(x, axis=axis)

class Audio:
    audio_path = ""
    data = []           #matriz unidimencional
    sampling_rate = 0    #frecuencia de muestreo de data

    def __init__(self, audio_path):
        self.audio_path = audio_path
        #self.data, self.sampling_rate = librosa.load(audio_path)
        sr2 = 22050
        self.data, self.sampling_rate = librosa.load(audio_path,sr=sr2, mono= True)

    def plot_audio(self):
        plt.figure(figsize=(10, 5))
        librosa.display.waveplot(self.data, sr=self.sampling_rate) #offset=15.0, duration=5.0
        plt.show()

    def debug_content(self):
        print("Data size: "+str(self.data.size))
        print(self.data)
        print(self.sampling_rate)
    
    def play_sound(self):
        ipd.Audio(self.audio_path)

    def show_spect(self):
        print(self.sampling_rate)
        print(type(self.data), type(self.sampling_rate))
        #display Spectrogram
        X = librosa.stft(self.data) #convierte datos en transformada de Fourier
        Xdb = librosa.amplitude_to_db(abs(X))
        plt.figure(figsize=(9, 16))
        librosa.display.specshow(Xdb, sr=self.sampling_rate, x_axis='time', y_axis='hz') 
        #If to pring log of frequencies  
        #librosa.display.specshow(Xdb, sr=sr, x_axis='time', y_axis='log')
        plt.colorbar()
        plt.show()

    def plot_zero_crosing_rate(self):
        #Plot the signal:
        plt.figure(figsize=(14, 5))
        librosa.display.waveplot(self.data, sr=self.sampling_rate)
        # Zooming in
        tam = int(len(self.data)/3) 
        n0 = tam
        n1 = tam+100
        print(">>>>>>>>>>>>>"+str(n1))
        plt.figure(figsize=(14, 5))
        plt.plot(self.data[n0:n1])
        plt.grid()
        plt.show()
        #
        zero_crossings = librosa.zero_crossings(self.data[n0:n1], pad=False)
        print(sum(zero_crossings))

    #Spectral Centroid and Spectral Rolloff
    def plot_spectral_centroid_and_rolloff(self):
        spectral_centroids = librosa.feature.spectral_centroid(self.data, sr=self.sampling_rate)[0]
        print(spectral_centroids.shape)# Calcular la variable de tiempo para la visualización
        frames = range(len(spectral_centroids))
        t = librosa.frames_to_time(frames)
        #Plotting the Spectral Centroid along the waveform
        librosa.display.waveplot(self.data, sr=self.sampling_rate, alpha=0.4)
        plt.plot(t, normalize(spectral_centroids), color='r')
        plt.show()

        spectral_rolloff = librosa.feature.spectral_rolloff(self.data, sr=self.sampling_rate)[0]
        librosa.display.waveplot(self.data, sr=self.sampling_rate, alpha=0.4)
        plt.plot(t, normalize(spectral_rolloff), color='r')
        plt.show()

    def plot_mfccs(self):
        mfccs = librosa.feature.mfcc(self.data, sr=self.sampling_rate)
        print(mfccs.shape)#Displaying  the MFCCs:
        print(mfccs)
        #print(mfccs[1])
        plt.figure(figsize=(14, 5))
        librosa.display.specshow(mfccs, sr=self.sampling_rate, x_axis='time')
        plt.show()



audio = Audio('audio.wav')
#audio.plot_audio()
#audio.debug_content()

audio.show_spect()
audio.plot_zero_crosing_rate()
audio.plot_spectral_centroid_and_rolloff()
audio.plot_mfccs()



















































