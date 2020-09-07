#!/usr/bin/env python
# -*- coding: utf-8 -*-
import librosa, librosa.display
import matplotlib.pyplot as plt
import numpy as np

#file = "audio.wav"
file = "blues.wav"
#waveform, sr=Sample Rate
signal, sample_rate =  librosa.load(file, sr=22050)

#librosa.display.waveplot(signal,sr=sample_rate)
#plt.ylabel("Amplitude")
#plt.xlabel("Time")
#plt.show()


fft = np.fft.fft(signal)
magnitude = np.abs(fft)
frequency = np.linspace(0, sample_rate, len(magnitude))
left_frequency = frequency[:int(len(frequency)/2)]
left_magnitude = magnitude[:int(len(frequency)/2)]
#plt.plot(frequency, magnitude)
#plt.plot(left_frequency, left_magnitude)
#plt.ylabel("Frequency")
#plt.xlabel("Magnitude")
#plt.show()


# fft -> spectrum


#stft -> spectrogram
n_fft = 2048
hop_length = 512

stft = librosa.core.stft(signal, hop_length=hop_length, n_fft=n_fft)
spectrogram = np.abs(stft)

log_spectrogram = librosa.amplitude_to_db(spectrogram)

#librosa.display.specshow(log_spectrogram, sr=sr, hop_length = hop_length)
#plt.xlabel("Time")
#plt.ylabel("Frequency")
#plt.colorbar()
#plt.show()


# MFCCs
# MFCCs
# extract 13 MFCCs
MFCCs = librosa.feature.mfcc(signal, sample_rate, n_fft=n_fft, hop_length=hop_length, n_mfcc=13)

# display MFCCs
librosa.display.specshow(MFCCs, sr=sample_rate, hop_length=hop_length)
plt.xlabel("Time")
plt.ylabel("MFCC coefficients")
plt.colorbar()
plt.title("MFCCs")

# show plots
plt.show()
















