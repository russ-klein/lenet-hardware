import numpy as np
import struct

class Layer_rec:
   name = ''
   input_address = 0
   input_size = 0
   input_shape = ()
   weight_shape = ()
   weight_size = 0
   weight_address = 0
   bias_size = 0
   bias_address = 0
   out_shape = ()
   out_size = 0
   out_address = 0

def floatToBits(f):
   return np.fromstring(np.float32(f).tostring(), dtype='<u4')[0]


def uint(n):
  n = int(n + 0.5)
  if n>=0:
     return n
  return 0xFFFFFFFF + n + 1

#===== print software inference function calls =====

def print_inference_prolog(source_file):
   source_file.write('#include "sw_infer.h"  \n');
   source_file.write('  \n');
   source_file.write('void sw_auto_infer(float *memory, int image_offset, float *probabilities) \n')
   source_file.write('{ \n');


def print_convolution_call(source_file, layer, weight_ptr, input_ptr, max_pool):

   in_shape = layer.input_shape
   in_size = in_shape[1] * in_shape[2] * in_shape[3]
   weight_size = layer.kernel.shape[0] * layer.kernel.shape[1] * layer.kernel.shape[2] * layer.kernel.shape[3];

   source_file.write(' \n')
   source_file.write('   conv2d_sw( \n');
   source_file.write('       memory + {:d},  // offset of input images \n'.format(input_ptr))
   source_file.write('       memory + {:d},  // offset of weights      \n'.format(weight_ptr))
   if layer.use_bias:
      source_file.write('       memory + {:d},  // offset of biases       \n'.format(weight_ptr+weight_size))
   else:
      source_file.write('       memory + 0,     // biases are not used    \n')
   source_file.write('       memory + {:d},  // offset of output images \n'.format(input_ptr+in_size))
   source_file.write('       {:d},           // number of input images  \n'.format(layer.input_shape[3]))
   source_file.write('       {:d},           // number of output images \n'.format(layer.output_shape[3]))
   source_file.write('       {:d},           // height                  \n'.format(layer.input_shape[1]))
   source_file.write('       {:d},           // width                   \n'.format(layer.input_shape[2]))
   source_file.write('       {:d},           // kernel height           \n'.format(layer.kernel.shape[0]))
   source_file.write('       {:d},           // kernel width            \n'.format(layer.kernel.shape[1]))
   if max_pool:
      source_file.write('       1,          // apply max pooling          \n')
   else:
      source_file.write('       0,          // don\'t apply max pooling \n')
   if layer.activation.__name__ == 'relu':
      source_file.write('       1,          // apply relu              \n')
   else:
      source_file.write('       0,          // don\'t apply relu        \n')
   if layer.use_bias:
      source_file.write('       1);         // apply bias              \n')
   else:
      source_file.write('       0);         // don\'t apply bias        \n')
 

def print_dense_call(source_file, layer, weight_ptr, input_ptr):

   print('input shape: ', layer.input_shape)
   print('output shape: ', layer.output_shape)

   in_shape = layer.input_shape;
   in_size = in_shape[1]
   weight_size = layer.kernel.shape[0] * layer.kernel.shape[1]

   source_file.write(' \n');
   source_file.write('   dense_sw( \n');
   source_file.write('       memory + {:d},  // offset of input images \n'.format(input_ptr))
   source_file.write('       memory + {:d},  // offset of weights      \n'.format(weight_ptr))
   if layer.use_bias:
      source_file.write('       memory + {:d},  // offset of biases       \n'.format(weight_ptr+weight_size))
   else:
      source_file.write('       memory + 0,     // biases are not used    \n')
   source_file.write('       memory + {:d},  // offset of output images          \n'.format(input_ptr+in_size))
   source_file.write('       {:d},           // number of rows in input images   \n'.format(1))
   source_file.write('       {:d},           // number of cols in input images   \n'.format(layer.kernel.shape[0]))
   source_file.write('       {:d},           // number of output images          \n'.format(layer.kernel.shape[1]))
   if layer.activation.__name__ == 'relu':
      source_file.write('       1,          // apply relu              \n')
   else:
      source_file.write('       0,          // don\'t apply relu        \n')
   if layer.use_bias:
      source_file.write('       1);         // apply bias              \n')
   else:
      source_file.write('       0);         // don\'t apply_bias        \n')


def print_softmax_call(source_file, layer, input_ptr):

   if layer.name[:5] == 'dense':
      size = layer.compute_output_shape(layer.input_shape)[1]
   else:
      print('not yet implemened! ')

   source_file.write(' \n')
   source_file.write('   softmax(memory + {:d}, memory + {:d}, {:d}); \n'.format(input_ptr, input_ptr + size, size))


def print_inference_epilog(source_file, output_offset, output_size):
   source_file.write(' \n')
   source_file.write('   memcpy(probabilities, memory + {:d}, {:d} * sizeof(float)); \n'.format(output_offset, output_size));
   source_file.write('} \n')
   source_file.write(' \n')


def print_sw_inference(model, source_file):

   print_inference_prolog(source_file)

   height = model.input_shape[1]
   width = model.input_shape[2]
   input_images = model.input_shape[3]

   input_size = height * width * input_images

   weight_ptr = 0
   input_ptr = sum_of_all_weights(model)
   output_ptr = input_ptr + input_size

   for i in range(len(model.layers)):
      layer = model.layers[i]

      print('layer: ', i)
      print('weight_ptr: ', weight_ptr)
      print('input_ptr: ', input_ptr)
      print('output_ptr: ', output_ptr)

      if layer.name[:6] == 'conv2d':
         max_pool = False
         out_shape = layer.compute_output_shape(layer.input_shape)
         if (i + 1 < len(model.layers)):
            if model.layers[i+1].name[:8] == 'max_pool':
               max_pool = True;
               out_shape = model.layers[i+1].output_shape
               print('max pool output_shape: ', out_shape)

         print_convolution_call(source_file, layer, weight_ptr, input_ptr, max_pool)

         weight_size = layer.kernel.shape[0] * layer.kernel.shape[1] * layer.kernel.shape[2] * layer.kernel.shape[3]
         out_size = out_shape[1] * out_shape[2] * out_shape[3]
         in_size = layer.input_shape[1] * layer.input_shape[2] * layer.input_shape[3]
         print('out size: ', out_size)

         if layer.use_bias:
            weight_size += layer.bias.shape[0]

         weight_ptr += weight_size
         input_ptr += in_size
         output_ptr += out_size

      if layer.name[:5] == 'dense':
         print_dense_call(source_file, layer, weight_ptr, input_ptr)

         weight_size = layer.kernel.shape[0] * layer.kernel.shape[1];
         out_size = layer.compute_output_shape(layer.input_shape)[1];
         in_size = layer.input_shape[1]

         if layer.use_bias:
            weight_size += layer.bias.shape[0]

         weight_ptr += weight_size
         input_ptr += in_size
         output_ptr += out_size
      
         if layer.activation.__name__ == 'softmax':
             print_softmax_call(source_file, layer, input_ptr)
             input_ptr += out_size

   print_inference_epilog(source_file, input_ptr, out_size)


#===== Print hw infernce function calls =====

def hw_print_inference_prolog(source_file):
   source_file.write('#include "hw_infer.h"  \n');
   source_file.write('  \n');
   source_file.write('void hw_auto_infer(cat_memory_type *memory, int image_offset, float *probabilities) \n')
   source_file.write('{ \n');


def hw_print_convolution_call(source_file, layer, weight_ptr, input_ptr, max_pool):

   in_shape = layer.input_shape
   in_size = in_shape[1] * in_shape[2] * in_shape[3]
   weight_size = layer.kernel.shape[0] * layer.kernel.shape[1] * layer.kernel.shape[2] * layer.kernel.shape[3];

   source_file.write(' \n')
   source_file.write('   conv2d_hw( \n');
   source_file.write('       memory,                                   \n')
   source_file.write('       {:d},           // offset of input images \n'.format(input_ptr))
   source_file.write('       {:d},           // offset of weights      \n'.format(weight_ptr))
   if layer.use_bias:
      source_file.write('       {:d},           // offset of biases       \n'.format(weight_ptr+weight_size))
   else:
      source_file.write('       0,              // biases are not used    \n')
   source_file.write('       {:d},           // offset of output images \n'.format(input_ptr+in_size))
   source_file.write('       {:d},           // number of input images  \n'.format(layer.input_shape[3]))
   source_file.write('       {:d},           // number of output images \n'.format(layer.output_shape[3]))
   source_file.write('       {:d},           // height                  \n'.format(layer.input_shape[1]))
   source_file.write('       {:d},           // width                   \n'.format(layer.input_shape[2]))
   source_file.write('       {:d},           // kernel height           \n'.format(layer.kernel.shape[0]))
   source_file.write('       {:d},           // kernel width            \n'.format(layer.kernel.shape[1]))
   if max_pool:
      source_file.write('       1,          // apply max pooling          \n')
   else:
      source_file.write('       0,          // don\'t apply max pooling \n')
   if layer.activation.__name__ == 'relu':
      source_file.write('       1,          // apply relu              \n')
   else:
      source_file.write('       0,          // don\'t apply relu        \n')
   if layer.use_bias:
      source_file.write('       1);         // apply bias              \n')
   else:
      source_file.write('       0);         // don\'t apply bias        \n')
 

def hw_print_dense_call(source_file, layer, weight_ptr, input_ptr):

   in_shape = layer.input_shape;
   in_size = in_shape[1]
   weight_size = layer.kernel.shape[0] * layer.kernel.shape[1]

   source_file.write(' \n');
   source_file.write('   dense_hw( \n');
   source_file.write('       memory,                                   \n')
   source_file.write('       {:d},           // offset of input images \n'.format(input_ptr))
   source_file.write('       {:d},           // offset of weights      \n'.format(weight_ptr))
   if layer.use_bias:
      source_file.write('       {:d},           // offset of biases       \n'.format(weight_ptr+weight_size))
   else:
      source_file.write('       0,              // biases are not used    \n')
   source_file.write('       {:d},           // offset of output images          \n'.format(input_ptr+in_size))
   source_file.write('       {:d},           // number of rows in input images   \n'.format(1))
   source_file.write('       {:d},           // number of cols in input images   \n'.format(layer.kernel.shape[0]))
   source_file.write('       {:d},           // number of output images          \n'.format(layer.kernel.shape[1]))
   if layer.activation.__name__ == 'relu':
      source_file.write('       1,          // apply relu              \n')
   else:
      source_file.write('       0,          // don\'t apply relu        \n')
   if layer.use_bias:
      source_file.write('       1);         // apply bias              \n')
   else:
      source_file.write('       0);         // don\'t apply_bias        \n')


def hw_print_softmax_call(source_file, layer, input_ptr):

   if layer.name[:5] == 'dense':
      size = layer.compute_output_shape(layer.input_shape)[1]
   else:
      print('not yet implemened! ')

   source_file.write(' \n')
   source_file.write('   float softmax_in[{:d}];                        \n'.format(size))
   source_file.write('   float softmax_out[{:d}];                       \n'.format(size))
   source_file.write(' \n')
   source_file.write('   copy_from_cat(memory, softmax_in, {:d}, {:d}); \n'.format(input_ptr, size))
   source_file.write(' \n')
   source_file.write('   softmax(softmax_in, softmax_out, {:d});         \n'.format(size))


def hw_print_inference_epilog(source_file, output_offset, output_size, softmax):
   source_file.write(' \n')
   if softmax:
      source_file.write('   memcpy(probabilities, softmax_out, {:d} * sizeof(float)); \n'.format(output_size))
   else:
      source_file.write('   copy_from_cat(memory, probabilities, {:d}, {:d});  \n'.format(output_offset, output_size))
   source_file.write('} \n')
   source_file.write(' \n')


def print_hw_inference(model, source_file):

   hw_print_inference_prolog(source_file)

   height = model.input_shape[1]
   width = model.input_shape[2]
   input_images = model.input_shape[3]

   input_size = height * width * input_images

   weight_ptr = 0
   input_ptr = sum_of_all_weights(model)
   output_ptr = input_ptr + input_size

   softmax = False

   for i in range(len(model.layers)):
      layer = model.layers[i]

      print('layer: ', i)
      print('weight_ptr: ', weight_ptr)
      print('input_ptr: ', input_ptr)
      print('output_ptr: ', output_ptr)

      if layer.name[:6] == 'conv2d':
         max_pool = False
         out_shape = layer.compute_output_shape(layer.input_shape)
         if (i + 1 < len(model.layers)):
            if model.layers[i+1].name[:8] == 'max_pool':
               max_pool = True;
               out_shape = model.layers[i+1].output_shape
               print('max pool output_shape: ', out_shape)

         hw_print_convolution_call(source_file, layer, weight_ptr, input_ptr, max_pool)

         weight_size = layer.kernel.shape[0] * layer.kernel.shape[1] * layer.kernel.shape[2] * layer.kernel.shape[3]
         out_size = out_shape[1] * out_shape[2] * out_shape[3]
         in_size = layer.input_shape[1] * layer.input_shape[2] * layer.input_shape[3]
         print('out size: ', out_size)

         if layer.use_bias:
            weight_size += layer.bias.shape[0]

         weight_ptr += weight_size
         input_ptr += in_size
         output_ptr += out_size

      if layer.name[:5] == 'dense':
         hw_print_dense_call(source_file, layer, weight_ptr, input_ptr)

         weight_size = layer.kernel.shape[0] * layer.kernel.shape[1];
         out_size = layer.compute_output_shape(layer.input_shape)[1];
         in_size = layer.input_shape[1]

         if layer.use_bias:
            weight_size += layer.bias.shape[0]

         weight_ptr += weight_size
         input_ptr += in_size
         output_ptr += out_size
      
         if layer.activation.__name__ == 'softmax':
             hw_print_softmax_call(source_file, layer, input_ptr)
             input_ptr += out_size
             softmax = True

   hw_print_inference_epilog(source_file, input_ptr, out_size, softmax)



#===== Write header file for offsets into memory =====


def write_convolution_weights(layer, n, header, data, source, weight_ptr, input_ptr, max_pool, max_pool_shape):

   image_height = layer.input_shape[1]
   image_width  = layer.input_shape[2]

   if max_pool:
      out_shape = max_pool_shape
   else:
      out_shape = layer.compute_output_shape(layer.input_shape)

   out_size = out_shape[1] * out_shape[2] * out_shape[3]

   count = 0
   for out_image in range(layer.kernel.shape[3]):
      for in_image in range(layer.kernel.shape[2]): 
         for r in range(layer.kernel.shape[1]):
            for c in range(layer.kernel.shape[0]):
               data.write(struct.pack('<f', layer.kernel[r][c][in_image][out_image].numpy()))
               count += 1

   weight_size = layer.kernel.shape[0] * layer.kernel.shape[1] * layer.kernel.shape[2] * layer.kernel.shape[3];

   header.write('      \n')
   header.write('   //=======layer {:d} - convolution===============================   \n'.format(n))
   header.write('      \n')
   header.write('   static const int layer{:d}_input_images       = {:d};  \n'.format(n, layer.kernel.shape[2]))
   header.write('   static const int layer{:d}_output_images      = {:d};  \n'.format(n, layer.kernel.shape[3]))
   header.write('   static const int layer{:d}_weights_rows       = {:d};  \n'.format(n, layer.kernel.shape[1]))
   header.write('   static const int layer{:d}_weights_cols       = {:d};  \n'.format(n, layer.kernel.shape[0]))
   header.write('      \n');
   header.write('   static const int layer{:d}_num_weights        = {:d};  \n'.format(n, weight_size))
   header.write('      \n')
   header.write('   static const int layer{:d}_weight_offset      = {:d};  \n'.format(n, weight_ptr))
   header.write('   static const int layer{:d}_out_size           = {:d};  \n'.format(n, out_size))
   header.write('      \n')

   return weight_size, out_size;


def write_dense_weights(layer, n, header, data, source, weight_ptr, input_ptr, images):

   count = 0
   out_shape = layer.compute_output_shape(layer.input_shape);
   out_size = out_shape[1]
   weight_size = layer.kernel.shape[0] * layer.kernel.shape[1];

   image_size = int(layer.kernel.shape[0]/images)
   for i in range(layer.kernel.shape[1]):
      for img in range(images):
         for c in range(image_size):
            idx = c * images + img
            #print('dense[',idx,'][',i,'] = ', layer.kernel[idx][i].numpy())
            data.write(struct.pack('<f', layer.kernel[idx][i].numpy()))
            count += 1

   header.write('      \n')
   header.write('   //=======layer {:d} - dense=====================================   \n'.format(n))
   header.write('      \n');
   header.write('   static const int layer{:d}_weights_rows       = {:d}; \n'.format(n, layer.kernel.shape[1]));
   header.write('   static const int layer{:d}_weights_cols       = {:d}; \n'.format(n, layer.kernel.shape[0]));
   header.write('      \n');
   header.write('   static const int layer{:d}_num_weights        = {:d};  \n'.format(n, layer.kernel.shape[0]*layer.kernel.shape[1]))
   header.write('      \n')
   header.write('   static const int layer{:d}_weight_offset      = {:d};  \n'.format(n, weight_ptr))
   header.write('   static const int layer{:d}_out_size           = {:d};  \n'.format(n, layer.kernel.shape[1]));
   header.write('      \n')
   header.write('      \n')

   return weight_size, out_size

def write_biases(layer, n, header, data, base):

   num_values = layer.bias.shape[0]

   header.write('      \n');
   header.write('   static const int layer{:d}_num_bias_values    = {:d};  \n'.format(n, num_values))
   header.write('   static const int layer{:d}_bias_offset        = {:d};  \n'.format(n, base))
   header.write('      \n')
   header.write('      \n')

   for i in range(num_values):
      data.write(struct.pack('<f', layer.bias[i].numpy()))

   return num_values;

def sum_of_all_weights(model):
   
   sum = 0;

   for layer in model.layers:
      if layer.name[:6] == 'conv2d':
         dims = layer.get_weights()[0].shape;
         size = dims[0] * dims[1] * dims [2] * dims [3]
         if layer.use_bias:
            size += len(layer.get_weights()[1])
         sum += size;
      if layer.name[:5] == 'dense':
         dims = layer.get_weights()[0].shape;
         size = dims[0] * dims[1]
         if layer.use_bias:
            size += len(layer.get_weights()[1])
         sum += size;
   return sum

def print_layer_map(layer_list):

   print(' ')
   print(' Weight map: ')
   print(' ')
   for layer_rec in layer_list:
      print('    {:16s}'.format(layer_rec.name), end='')

      print(' {:18s}'.format(str(layer_rec.weight_shape)),end='')
      print(' {:8d}'.format(layer_rec.weight_size), end='')
      print(' {:10d}'.format(layer_rec.weight_address), end='')
      weight_end = layer_rec.weight_address + layer_rec.weight_size - 1
      if weight_end < 0: weight_end = 0
      print(' {:10d}'.format(weight_end), end='')

      if layer_rec.bias_size > 0:
         print(' ')
         print('    {:16s}'.format('  bias'), end='')
         print(' {:18s}'.format('('+str(layer_rec.bias_size)+')'),end='')
         print(' {:8d}'.format(layer_rec.bias_size), end='')
         print(' {:10d}'.format(layer_rec.bias_address), end='')
         print(' {:10d}'.format(layer_rec.bias_address + layer_rec.bias_size -1), end='')

      print(' ')
   print(' ')

def print_input_map(input_shape, start_addr):
   print(' ')
   print(' Input map: ')
   print(' ')

   print('    input image     ', end='')

   size = input_shape[1] * input_shape[2] * input_shape[3]

   print(' {:18s}'.format(str(input_shape)),end='')
   print(' {:8d}'.format(size), end='')
   print(' {:10d}'.format(start_addr), end='')
   print(' {:10d}'.format(start_addr + size -1), end='')
   print(' ')
   print(' ')

def print_output_map(layer_list):
 
   print(' ')
   print(' Output map: ')
   print(' ')
   
   for layer_rec in layer_list:
      print('    {:16s}'.format(layer_rec.name), end='')

      print(' {:18s}'.format(str(layer_rec.out_shape)),end='')
      print(' {:8d}'.format(layer_rec.out_size), end='')
      print(' {:10d}'.format(layer_rec.out_address), end='')
      out_end = layer_rec.out_address + layer_rec.out_size - 1
      if out_end < 0: out_end = 0
      print(' {:10d}'.format(out_end), end='')
      print(' ')

   print(' ')


def print_memory_map(layer_list, model, input_image_address):
   print(' ')
   print('    Layer            Shape                  Size      Start        End')
   print_layer_map(layer_list)
   print_input_map(model.layers[0].input_shape, input_image_address)
   print_output_map(layer_list)


def print_region_header(layer_list, model, input_image_address):
   region_header = open('regions.h', 'w')

   region_header.write('#ifndef REGIONS_H_INCLUDED \n')
   region_header.write('#define REGIONS_H_INCLUDED \n')
   region_header.write('\n')
   region_header.write('\n')
   region_header.write('static unsigned int region_map[][2] = { \n')
   size = 0
   for layer in layer_list:
      if layer.weight_size > 0:
         region_header.write('  {{ {:10d}, {:10d} }},  // {:s} weights \n'.format(layer.weight_address, layer.weight_size, layer.name))
         size += layer.weight_size
      if layer.bias_size > 0:
         region_header.write('  {{ {:10d}, {:10d} }},  // {:s} biases \n'.format(layer.bias_address, layer.bias_size, layer.name))
         size += layer.bias_size
   input_size = model.layers[0].input_shape[1] * model.layers[0].input_shape[2] * model.layers[0].input_shape[3]
   region_header.write('  {{ {:10d}, {:10d} }},  // input_image \n'.format(input_image_address, input_size))
   size += input_size
   for layer in layer_list:
      if layer.out_size > 0:
         region_header.write('  {{ {:10d}, {:10d} }},  // {:s} outputs \n'.format(layer.out_address, layer.out_size, layer.name))
         size += layer.out_size
   region_header.write('  {{ {:10d}, {:10d} }}   // out of bounds \n'.format(size, 0xFFFFFFFF))
   region_header.write('}; \n')
   region_header.write(' \n');

   region_header.write(' \n')
   region_header.write('static char region_names[][40] = { \n')
   size = 0
   for layer in layer_list:
      if layer.weight_size > 0:
         region_header.write('  {{ "{:s} weights" }}, \n'.format(layer.name))
      if layer.bias_size > 0:
         region_header.write('  {{ "{:s} biases " }}, \n'.format(layer.name))
   region_header.write('  { "input image " }, \n')
   for layer in layer_list:
      if layer.out_size > 0:
         region_header.write('  {{ "{:s} outputs " }}, \n'.format(layer.name))
   region_header.write('  { "out of bounds " } \n');
   region_header.write('}; \n')
   region_header.write('\n');
   region_header.write('#endif \n');

   region_header.close()

def write_header_file(model):

   header_file = open('weights.h', 'w')
   data_file   = open('weights_float.bin', 'w+b')
   source_file = open('auto_infer.c', 'w')


   header_file.write('#ifndef WEIGHTS_H_INCLUDED \n')
   header_file.write('#define WEIGHTS_H_INCLUDED \n')
   header_file.write('\n')
   header_file.write('\n')

   height = model.input_shape[1]
   width = model.input_shape[2]
   input_images = model.input_shape[3]

   input_size = height * width * input_images

   weight_ptr = 0
   input_ptr = sum_of_all_weights(model)
   input_image_address = input_ptr
   output_ptr = input_ptr + input_size
   n = 1

   layer_num = 1

   layer_list = []

   for n in range(len(model.layers)):

      layer_list.append(Layer_rec())

      layer = model.layers[n]

      layer_list[n].name = layer.name

      if layer.name[:6] == 'conv2d':
          if (n + 1) < len(model.layers):
             if (model.layers[n+1].name[:8] == 'max_pool'):
                max_pool = True
                max_pool_shape = model.layers[n+1].output_shape
             else:
                max_pool = False
                max_pool_shape = ()

          weight_size, out_size = write_convolution_weights(layer, layer_num, header_file, data_file, source_file, weight_ptr, input_ptr, max_pool, max_pool_shape)

          in_size = layer.input_shape[1] * layer.input_shape[2] * layer.input_shape[3]
          output_ptr = input_ptr + in_size

          layer_list[n].weight_address = weight_ptr
          layer_list[n].weight_size = weight_size
          layer_list[n].weight_shape = layer.kernel.shape

          layer_list[n].out_address = output_ptr
          layer_list[n].out_size = out_size

          if max_pool:
             layer_list[n].out_shape = max_pool_shape
          else:
             layer_list[n].out_shape = layer.output_shape[1:]

          input_ptr += in_size
          weight_ptr += weight_size
          if layer.use_bias:
              weight_size = write_biases (layer, layer_num, header_file, data_file, weight_ptr)

              layer_list[n].bias_address = weight_ptr
              layer_list[n].bias_size = layer.bias.shape[0]
 
              weight_ptr += weight_size
          layer_num += 1
          if layer.activation.__name__ == 'softmax':
              input_pointer += out_size

      if layer.name[:5] == 'dense':
          print('Layer #', layer_num, ' dense')
          images = 1
          if n>0:
              if model.layers[n-1].name[:7] == 'flatten':
                  images = model.layers[n-1].input_shape[3]

          weight_size, out_size = write_dense_weights(layer, layer_num, header_file, data_file, source_file, weight_ptr, input_ptr, images)

          in_size = layer.input_shape[1] 
          output_ptr = input_ptr + in_size
          layer_list[n].weight_address = weight_ptr
          layer_list[n].weight_size = weight_size
          layer_list[n].weight_shape = layer.kernel.shape

          layer_list[n].out_address = output_ptr
          layer_list[n].out_size = out_size
          layer_list[n].out_shape = layer.output_shape[1:]

          input_ptr += in_size
          weight_ptr += weight_size
          if layer.use_bias:
              weight_size = write_biases (layer, layer_num, header_file, data_file, weight_ptr)

              layer_list[n].bias_address = weight_ptr
              layer_list[n].bias_size = layer.bias.shape[0]
 
              weight_ptr += weight_size

          layer_num += 1
          if layer.activation.__name__ == 'softmax':
              input_ptr += out_size


   header_file.write(' \n');
   header_file.write('   //=======End of layers==========================================   \n'.format(layer))
   header_file.write(' \n');
   header_file.write(' \n');
   header_file.write('   static int const image_height              = {:d}; \n'.format(height))
   header_file.write('   static int const image_width               = {:d}; \n'.format(width))
   header_file.write('   static int const image_size                = {:d}; \n'.format(height*width))
   header_file.write('   static int const num_images                = {:d}; \n'.format(input_images))
   header_file.write(' \n');

   header_file.write('   static int const size_of_weights           = {:d}; \n'.format(weight_ptr))
   header_file.write('   static int const size_of_outputs           = {:d}; \n'.format(input_ptr))
   header_file.write(' \n');

   header_file.write(' \n')
   header_file.write('#endif \n')
   header_file.write(' \n')

   print_sw_inference(model, source_file)
   print_hw_inference(model, source_file)

   header_file.close()
   data_file.close()
   source_file.close()
   
   print_memory_map(layer_list, model, input_image_address)
   print_region_header(layer_list, model, input_image_address)

   return layer_list
