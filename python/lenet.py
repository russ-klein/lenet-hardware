# Baseline MLP for MNIST dataset
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Conv2D, Flatten, MaxPooling2D
from keras.utils import np_utils

def lenet_model_scan(epochs=10, batch_size=100):

    # load data
    (X_train, y_train), (X_test, y_test) = mnist.load_data()

    # flatten 28*28 images to a 784 vector for each image
    num_pixels = X_train.shape[1] * X_train.shape[2]

    X_train = X_train.reshape((X_train.shape[0], X_train.shape[1], X_train.shape[2], 1)).astype('int32');
    X_test = X_test.reshape((X_test.shape[0], X_test.shape[1], X_test.shape[2], 1)).astype('int32');

    # normalize inputs from 0-255 to 0-1
    X_train = X_train / 255
    X_test = X_test / 255

    # one hot encode outputs
    y_train = np_utils.to_categorical(y_train)
    y_test = np_utils.to_categorical(y_test)

    for i in [1,2,3,4,5,6,7,8,9,10,15,20,25,50,100,200,250,300,400,500]:
      # create model
      model = Sequential()
      model.add(Conv2D(20, (5,5), use_bias=True, padding="same", activation=None, input_shape=(28,28,1)))
      model.add(MaxPooling2D(pool_size=(2,2)))
      model.add(Flatten())
      model.add(Dense(500, use_bias=True, kernel_initializer='normal', activation='relu'))
      model.add(Dense(10, use_bias=True, kernel_initializer='normal', activation='softmax'))
      # Compile model
      model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
      model.fit(X_train, y_train, validation_data=(X_test, y_test), epochs=epochs, batch_size=batch_size, verbose=1)
      scores = model.evaluate(X_test, y_test, verbose=0)
      print("Baseline Error: {:d} {:6.2f}".format(i, 100-scores[1]*100))

def lenet_tiny_model():
    # create model
    model = Sequential()
    model.add(Conv2D(2, (5,5), use_bias=True, padding="same", activation=None, input_shape=(28,28,1)))
    model.add(MaxPooling2D(pool_size=(2,2)))
    model.add(Conv2D(5, (5,5), use_bias=True, padding="same", activation=None))
    model.add(MaxPooling2D(pool_size=(2,2)))
    ##model.add(Flatten(input_shape=(28,28,1)))
    model.add(Flatten())
    #model.add(Dense(10, use_bias=True, kernel_initializer='normal'))
    #model.add(Dense(20, use_bias=True, kernel_initializer='normal', activation='relu'))
    model.add(Dense(10, use_bias=True, kernel_initializer='normal', activation='softmax'))
    # Compile model
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model


# define LeNet model
def lenet_model():
    # create model
    model = Sequential()

    model.add(Conv2D(20, (5,5), use_bias=True, padding="same", activation=None, input_shape=(28,28,1)))
    model.add(MaxPooling2D(pool_size=(2,2)))

    model.add(Conv2D(50, (5,5), use_bias=True, padding="same", activation=None))
    model.add(MaxPooling2D(pool_size=(2,2)))

    model.add(Flatten())

    model.add(Dense(500, use_bias=True, kernel_initializer='normal', activation='relu'))

    model.add(Dense(10, use_bias=True, kernel_initializer='normal', activation='softmax'))

    # Compile model
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

def train_network(batch_size=200, epochs=20):
    # load data
    (X_train, y_train), (X_test, y_test) = mnist.load_data()
    
    # flatten 28*28 images to a 784 vector for each image
    num_pixels = X_train.shape[1] * X_train.shape[2]
    
    X_train = X_train.reshape((X_train.shape[0], X_train.shape[1], X_train.shape[2], 1)).astype('int32');
    X_test = X_test.reshape((X_test.shape[0], X_test.shape[1], X_test.shape[2], 1)).astype('int32');
    
    # normalize inputs from 0-255 to 0-1
    X_train = X_train / 255
    X_test = X_test / 255
    
    # one hot encode outputs
    y_train = np_utils.to_categorical(y_train)
    y_test = np_utils.to_categorical(y_test)
    
    model = lenet_model()
    model.fit(X_train, y_train, validation_data=(X_test, y_test), epochs=epochs, batch_size=batch_size, verbose=1)
    scores = model.evaluate(X_test, y_test, verbose=0)
    print("Baseline Error: %.2f%%" % (100-scores[1]*100))
   
    return model
