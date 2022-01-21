# name,  bitwidth, type, connection (wire|channel)

#debug_signal,       32, unsigned, output, wire
go,                   1, unsigned, input,  channel
done,                 1, unsigned, output, channel
relu,                 1, unsigned, input, wire
convolve,             1, unsigned, input, wire
fully_connected,      1, unsigned, input, wire
image_offset,        18, unsigned, input, wire
weight_offset,       18, unsigned, input, wire
# bias_offset,       20, unsigned, input, wire
output_offset,       18, unsigned, input, wire
num_input_images,    18, unsigned, input, wire
num_output_images,   18, unsigned, input, wire
memory,              20, unsigned, input, master

