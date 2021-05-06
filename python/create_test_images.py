from keras.datasets import mnist
import write_weights

(X_train, y_train), (X_test, y_test) = mnist.load_data()

write_weights.write_test_images(X_train, y_train)

