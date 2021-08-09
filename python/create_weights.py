import lenet
import write_weights

model = lenet.train_network()
write_weights.write_header_file(model)

