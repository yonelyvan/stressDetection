from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt


fig = plt.figure()
#ax = fig.add_subplot(111, projection='3d')
ax = plt.axes(projection='3d')

xx = [25.54708124, 31.17469926, 28.52087138, 27.48382184, 28.54491093,23.29680909, 28.65396255, 28.51391683, 23.74796767, 23.60344609]
yy = [26.85305544, 18.16348247, 85.6486335 , 51.58108876, 93.63792217,58.69935638,  1.04683199, 51.5041098 , 87.1235226 , 30.77285181]
zz = [-43.37465341, -49.51351354, -47.46792579, -43.04604664,-27.55911518, -48.23684023, -39.0832312 , -40.08935293,-42.58495484,-30.88907518]

xx2 = [31.48254822, 28.90642703, 29.60299612, 28.44005967, 27.32555076,31.55480559, 25.76285299, 30.95731992, 27.16640927, 23.1537339 ] 
yy2 = [9.42173974, 90.82874092, 12.41316359, 30.52512606, 66.56705954,2.29892058, 71.35835842, 96.73508724, 39.49493644, 59.97355977]
zz2 = [-7.47625111, -25.74162052, -26.66973133,  -5.90575884,-9.50165733, -15.19461806, -12.99406911, -27.68827667,-17.43089816, -10.62662381]

ax.scatter(xx, yy, zz, marker='o')
ax.scatter(xx2, yy2, zz2, marker='^')

ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')



#plt.show()


import numpy as np
def LoG(x, y, sigma):
    temp = (x ** 2 + y ** 2) / (2 * sigma ** 2)
    return -1 / (np.pi * sigma ** 4) * (1 - temp) * np.exp(-temp)




N = 100
half_N = N // 2
X2, Y2 = np.meshgrid(range(N), range(N)) #range: [0-49]
X2 = X2 - half_N
Y2 = Y2 - half_N

#X2 = X2/10.0
#Y2 = Y2/10.0

Z2 = -LoG(X2, Y2, sigma=10)
#Z2 = X2*np.exp(-X2**2 - Y2**2)


X1 = np.reshape(X2, -1)
Y1 = np.reshape(Y2, -1)
Z1 = np.reshape(Z2, -1)


#ax = plt.axes(projection='3d')
ax.plot_wireframe(X2, Y2, Z2, color='g')


plt.show()
