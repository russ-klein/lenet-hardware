# lenet-hardware
Implementation of LeNet to be compiled into a hardware accelerator

The project will create a hardware and software implementation of Yan LeCun's LeNet mnist inferencing algorithm.  We will ultimately compare power, performance, and area of the software against various hardware accelerator implementations.  The goal of this project is to explore the feasability of deploying hardware accelerators for high performance, low power inferencing for edge systems. 

The original python implementation of LeNet is defined in python/lenet.py.  Various python scripts are used to perform training, extract the weights, and create C header files that will used for later implementaitons.
