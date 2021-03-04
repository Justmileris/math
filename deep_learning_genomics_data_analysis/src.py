from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D, BatchNormalization, Flatten, Dense, Dropout
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from keras.utils import plot_model
from keras.models import load_model
from keras import optimizers
from keras import regularizers
import h5py

X = np.load('X.npy')
Y = np.load('Y.npy')

########################################################################

X = np.reshape(X, (len(X), 8, 301, 1))

# X = np.expand_dims(X, axis=3)
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.3, random_state=42)

image_shape = (8, 301, 1)
batch_size = 32

model = Sequential()
model.add(Conv2D(32, kernel_size=(3,3), activation='relu', padding='same', input_shape=image_shape))
model.add(Conv2D(64, kernel_size=(3,3), activation='relu', padding='same'))
model.add(MaxPooling2D(pool_size=(2, 2)))

# model.add(Conv2D(64, kernel_size=(3,3), activation='relu', padding='same'))
# model.add(MaxPooling2D(pool_size=(2, 2)))

model.add(BatchNormalization())
model.add(Flatten())
model.add(Dense(units=512, activation='relu', kernel_regularizer=regularizers.l2(0.01), activity_regularizer=regularizers.l1(0.01)))
model.add(Dropout(0.5))
model.add(Dense(units=1, activation='linear'))
# model.compile(loss='mse', optimizer='adam')

adam = optimizers.Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=None, decay=0.0, amsgrad=False)
# sgd = optimizers.SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
model.compile(loss='mean_squared_error', optimizer=adam)

model.fit(X_train, Y_train, epochs=15, verbose=1, batch_size=batch_size, validation_data=(X_test, Y_test))

model.summary()
# plot_model(model, to_file='model.png')
model.save('model.h5')
# model = load_model('model.h5')
# model.predict(x)
