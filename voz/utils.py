import librosa 
import librosa.display
import matplotlib.pyplot as plt
import numpy as np

def plot_data(data, sr):
    plt.figure(figsize=(10, 5))
    librosa.display.waveplot(data, sr=sr)
    plt.show()
