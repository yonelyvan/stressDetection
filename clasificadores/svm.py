
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np
from sklearn import datasets
import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()


session = tf.Session()

## load data
iris = datasets.load_iris()
#print(">>>>>>>>>>>>>>>>>>")
#for i in range(len(iris.data)):
#    print( iris.data[i], iris.target[i], iris.target_names[iris.target[i]])

x_vals = np.array([[x[0], x[1], x[2]] for x in iris.data])
#x_vals = np.array([[x[0], x[1] ] for x in iris.data])
y_vals = np.array([1 if y == 0 else -1 for y in iris.target])


train_idx = np.random.choice(len(x_vals), round(len(x_vals)*0.8), replace=False)
test_idx = np.array(list(set(range(len(x_vals)))-set(train_idx)))
x_vals_train = x_vals[train_idx]
x_vals_test = x_vals[test_idx]
y_vals_train = y_vals[train_idx]
y_vals_test = y_vals[test_idx]

dim = 3 #2D 3D

batch_size = 1000
# placeholders
x_data = tf.placeholder(shape=[None, dim], dtype=tf.float32)
y_target = tf.placeholder(shape=[None, 1], dtype=tf.float32)
# variable 
A = tf.Variable(tf.random_normal(shape=[dim,1]))
b = tf.Variable(tf.random_normal(shape=[1,1]))


model_output = tf.subtract(tf.matmul(x_data,A), b)# Ax-b


l2_norm = tf.reduce_sum(tf.square(A)) # sqrt(x1^2 + x2^2 + ... + xn^2) | regulacion
alpha = tf.constant([0.05])
classification_term = tf.reduce_mean(tf.maximum(0.0, tf.subtract(1.0, tf.multiply(model_output, y_target))))

# Funcion de perdida
loss = tf.add(classification_term, tf.multiply(alpha, l2_norm))

# Pecision
prediction = tf.sign(model_output)
accuracy = tf.reduce_mean(tf.cast(tf.equal(prediction, y_target), tf.float32))

# Entrenamiento
my_optim = tf.train.GradientDescentOptimizer(0.01)
train_step = my_optim.minimize(loss)

# Inicialización de variables
init = tf.global_variables_initializer()
session.run(init)

# iteraciones
loss_vect = []
train_acc = []
test_acc = []

for i in range(1000):
    rand_idx = np.random.choice(len(x_vals_train), size=batch_size)
    rand_x = x_vals_train[rand_idx]
    rand_y = np.transpose([y_vals_train[rand_idx]])
    session.run(train_step, feed_dict = {x_data: rand_x, y_target: rand_y}) # Entrenamiento
    #vector de perdida por iteracion
    temp_loss = session.run(loss, feed_dict = {x_data: rand_x, y_target: rand_y}) # Perdia
    loss_vect.append(temp_loss)
    
    train_acc_temp = session.run(accuracy, feed_dict = {x_data: x_vals_train, y_target: np.transpose([y_vals_train])}) # Pecisión entrenamiento
    train_acc.append(train_acc_temp)
    
    test_acc_temp = session.run(accuracy, feed_dict= {x_data: x_vals_test, y_target: np.transpose([y_vals_test])}) # Pecisión prueba
    test_acc.append(test_acc_temp)
    
    if(i+1)%50==0:
        print("Paso #"+str(i+1)+", A = "+str(session.run(A))+", b = "+str(session.run(b))+ ", Loss = "+str(temp_loss))


[[a1],[a2],[a3]] = session.run(A)
#[[a1],[a2]] = session.run(A)
[[b]] = session.run(b)


def maxMIn(V):
    max = 0
    min = 1000
    for e in V:
        if e>max:
            max = e
        if e<min:
            min=e
    return [min,max]

def plot_2d():
    setosa_x = [d[0] for i, d in enumerate(x_vals) if y_vals[i]==1]
    setosa_y = [d[1] for i, d in enumerate(x_vals) if y_vals[i]==1]
    no_setosa_x = [d[0] for i, d in enumerate(x_vals) if y_vals[i]==-1]
    no_setosa_y = [d[1] for i, d in enumerate(x_vals) if y_vals[i]==-1]

    x0_vals = [d[0] for d in x_vals]
    best_fit = []
    yy2 =[]
    for x1 in x0_vals:
        best_fit.append(((a1*x1)-b)/(-a2))

    plt.plot(setosa_x, setosa_y, 'o', label = "Setosa")
    plt.plot(no_setosa_x, no_setosa_y, 'x', label="No Setosa")
    plt.plot(x0_vals, best_fit, 'r-', label = "Separador Lineal", linewidth=3)
    plt.ylim([0,10])
    plt.legend(loc="lower right")
    plt.xlabel("Anchura de Pétalo")
    plt.ylabel("Longitud de Sépalo")
    plt.title("Setosa vs No Setosa por medidas")
    plt.show()

def plot_3d():
    setosa_x = [d[0] for i, d in enumerate(x_vals) if y_vals[i]==1]
    setosa_y = [d[1] for i, d in enumerate(x_vals) if y_vals[i]==1]
    setosa_z = [d[2] for i, d in enumerate(x_vals) if y_vals[i]==1]
    no_setosa_x = [d[0] for i, d in enumerate(x_vals) if y_vals[i]==-1]
    no_setosa_y = [d[1] for i, d in enumerate(x_vals) if y_vals[i]==-1]
    no_setosa_z = [d[2] for i, d in enumerate(x_vals) if y_vals[i]==-1]

    fig = plt.figure()
    ax = plt.axes(projection='3d')
    ax.scatter(setosa_x, setosa_y, setosa_z, marker='o')
    ax.scatter(no_setosa_x, no_setosa_y, no_setosa_z, marker='^')

    ax.set_xlabel('X Label')
    ax.set_ylabel('Y Label')
    ax.set_zlabel('Z Label')    

   
    xx_data = [d[0] for d in x_vals]
    yy_data = [d[1] for d in x_vals]
    [x_min, x_max]= maxMIn(xx_data)
    [y_min, y_max]= maxMIn(yy_data)

    X1, X2 = np.meshgrid( np.arange(x_min, x_max, 0.01), np.arange(y_min, y_max, 0.01) ) #range: [0-49]
    X3 = []

    for i in range(len(X1)):
        X3.append((a1*X1[i] + a2*X2[i] - b)/(-a3))
    X3 = np.array(X3)
    ax.plot_wireframe(X1, X2, X3, color='g')

    plt.show()

def plot():
    if dim == 2:
        plot_2d()
    else:
        plot_3d()


plot()


plt.plot(loss_vect, 'k-')
plt.title("Pérdidas por Iteración")
plt.show()



