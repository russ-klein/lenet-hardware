import numpy as np
import struct

def floatToBits(f):
   return np.fromstring(np.float32(f).tostring(), dtype='<u4')[0]


def uint(n):
  n = int(n + 0.5)
  if n>=0:
     return n
  return 0xFFFFFFFF + n + 1


def write_image(name, a):
   header_file = open(name + ".h", "w")
   header_file.write("  unsigned char " + name + "[28][28] = { \n")
   for row in range(a.shape[0]):
     header_file.write("         { ");
     for col in range(a.shape[1]):
        if (a[row][col]>0):
           header_file.write("0x{:02x}".format(a[row][col]))
        else :
           header_file.write("   0");
        if (col < a.shape[1]-1):
           header_file.write(", ")
     if (row < a.shape[0]-1):
        header_file.write(" }, \n");
     else:
        header_file.write(" }  \n");
   header_file.write("     }; \n")
   header_file.close()

def number_string(i):
   if (i == 0): 
      return "zero"
   if (i == 1): 
      return "one"
   if (i == 2):
      return "two"
   if (i== 3):
      return "three"
   if (i == 4):
      return "four"
   if (i == 5):
      return "five"
   if (i == 6):
      return "six"
   if (i == 7):
      return "seven"
   if (i == 8):
      return "eight"
   if (i == 9):
      return "nine"
   return None


def write_all(xtest, ytest):
   for num in range(10):
      i = 0
      while (ytest[i] != num) :
         i = i + 1
      write_image(number_string(ytest[i]), xtest[i])

def write_convolution_weights(w, layer, header, data, packing_factor=1):

   '''
   header.write("   static const weight_t layer{:d}_weights[{:d}][{:d}][{:d}][{:d}] = \n".format(layer, w.shape[3], w.shape[2], w.shape[0], w.shape[1]))
   header.write("   { \n")
   for out_image in range(w.shape[3]):
      header.write("      { \n")
      for in_image in range(w.shape[2]):
         header.write("          { \n")
         for r in range(w.shape[1]):
            header.write("             { ")
            for c in range(w.shape[0]):
               header.write(" {:9.6f}".format(w[r][c][in_image][out_image]))
               if (c<w.shape[1]-1):
                  header.write(", ")
               else:
                  header.write("}")
            if (r<w.shape[0]-1):
               header.write(", \n")
            else:
               header.write("\n          }")
         if (in_image<w.shape[2]-1):
            header.write(", \n")
         else:
            header.write("  \n")
      header.write("      }")
      if (out_image < w.shape[3]-1):
         header.write(", \n")
      else:
         header.write("  \n")
   '''

   count = 0
   for out_image in range(w.shape[3]):
      for in_image in range(w.shape[2]): 
         for r in range(w.shape[1]):
            for c in range(w.shape[0]):
               data.write(struct.pack('>f', w[r][c][in_image][out_image].numpy()))
               count += 1
   print('wrote: ', count, ' words')

   unit_offset_factor  = int(((w.shape[0] *w.shape[1]) + (packing_factor-1))/packing_factor)
   layer_offset_factor = unit_offset_factor * (w.shape[2] * w.shape[3])

   header.write("   }; \n")
   header.write("      \n")
   header.write("   static const int layer{:d}_input_images       = {:d};  \n".format(layer, w.shape[2]))
   header.write("   static const int layer{:d}_output_images      = {:d};  \n".format(layer, w.shape[3]))
   header.write("   static const int layer{:d}_weights_rows       = {:d};  \n".format(layer, w.shape[1]))
   header.write("   static const int layer{:d}_weights_cols       = {:d};  \n".format(layer, w.shape[0]))
   header.write("      \n");
   header.write("   static const int layer{:d}_num_weights        = {:d};  \n".format(layer, w.shape[0]*w.shape[1]*w.shape[2]*w.shape[3]))
   header.write("   static const int layer{:d}_unit_size          = {:d};  \n".format(layer, w.shape[0]*w.shape[1]))
   header.write("   static const int layer{:d}_unit_offset_factor = {:d};  \n".format(layer, unit_offset_factor))
   header.write("   static const int later{:d}_unit_count         = {:d};  \n".format(layer, w.shape[2]*w.shape[3]))
   header.write("      \n")
   if (layer==1):
      header.write("   static const int layer1_weight_offset         = 0;  \n")
   header.write("   static const int layer{:d}_weight_offset      = layer{:d}_weight_offset + {:d};  \n".format(layer+1, layer, layer_offset_factor))
   header.write("      \n")
   header.write("      \n")

   return w.shape[0] * w.shape[1] * w.shape[2] * w.shape[3];


def write_dense_weights(w, layer, header, data, packing_factor=1):
   '''
   header.write("   static const weight_t layer{:d}_weights[{:d}][{:d}] = \n".format(layer, w.shape[1], w.shape[0]))
   header.write("   { \n");
   for i in range(w.shape[1]):
      header.write("      {  ")
      for c in range(count):
         for j in range(int(w.shape[0]/count)):
            header.write(" {:9.6f}".format(w[j*count+c][i]));
            if ((j*count+c)<w.shape[0]-1):
               header.write(", ")
            if (((j+1)%10==0) or (j==w.shape[0]-1)):
               header.write(" \n");
            if (((j+1)%10==0) and (j<w.shape[0]-1)):
               header.write("         ");
      if (i<w.shape[1]-1):
         header.write("      }, \n");
      else:
         header.write("      }  \n");
   '''

   for i in range(w.shape[1]):
      for c in range(w.shape[0]):
         data.write(struct.pack('>f', w[c][i].numpy()))
               
   unit_offset_factor  = int((w.shape[0] + (packing_factor-1))/packing_factor)
   layer_offset_factor = unit_offset_factor * w.shape[1]

   header.write("   }; \n");
   header.write("      \n");
   header.write("   static const int layer{:d}_weights_rows = {:d}; \n".format(layer, w.shape[1]));
   header.write("   static const int layer{:d}_weights_cols = {:d}; \n".format(layer, w.shape[0]));
   header.write("      \n");
   header.write("   static const int layer{:d}_num_weights        = {:d};  \n".format(layer, w.shape[0]*w.shape[1]))
   header.write("   static const int layer{:d}_unit_size          = {:d};  \n".format(layer, w.shape[0]))
   header.write("   static const int layer{:d}_unit_offset_factor = {:d};  \n".format(layer, unit_offset_factor))
   header.write("   static const int later{:d}_unit_count         = {:d};  \n".format(layer, w.shape[1]))
   header.write("      \n")
   if (layer==1):
      header.write("   static const int layer1_weight_offset         = 0;  \n")
   header.write("   static const int layer{:d}_weight_offset      = layer{:d}_weight_offset + {:d};  \n".format(layer+1, layer, layer_offset_factor))
   header.write("      \n")
   header.write("      \n")

   return w.shape[0] * w.shape[1];

def write_biases(b, layer, data):
   '''
   header.write("   static const weight_t layer{:d}_biases[{:d}]     = \n".format(layer, b.shape[0]))
   header.write("   { \n");
   for i in range(b.shape[0]):
      print(b[i])
      header.write("      {:9.6f}".format(b[i]))
      if (i<b.shape[0]-1):
         header.write(", \n")
      else:
         header.write("  \n")
   header.write("   }; \n");
   header.write("      \n"); 
   '''

   for i in range(b.shape[0]):
      data.write(struct.pack('>f', b[i].numpy()))

   return b.shape[0];

def memimg_convolution_weights(header, memimg, fixed_file, w, layer, address, packing_factor=1, word_size=0, integer_bits=0):
   if word_size == 0:
      word_size = int(32/packing_factor)
      if integer_bits==0:
          integer_bits = int(word_size/2)
      fractional_bits = word_size - integer_bits

   # header.write("   static const int   layer{:d}_weight_offset      = {:d}; \n".format(layer, address))

   for out_image in range(w.shape[3]):
      for in_image in range(w.shape[2]):
         for r in range(w.shape[1]):
            for c in range(w.shape[0]):
               memimg.write("{:08x} \n".format(floatToBits(w[r][c][in_image][out_image])))

   for out_image in range(w.shape[3]):
      for in_image in range(w.shape[2]):
         values = []
         for r in range(w.shape[1]):
            for c in range(w.shape[0]):
               values.append(w[r][c][in_image][out_image].numpy());
         for i in range(int(((w.shape[0]*w.shape[1])+(packing_factor-1))/packing_factor)):
            value = 0
            for p in range(packing_factor):
               index = i * packing_factor + p
               shift_factor = 1 << (word_size * p)
               factor =  1 << fractional_bits
               mask = (1 << word_size) - 1
               if index<len(values):
                  new_bits = values[index] * factor
                  new_bits = uint(new_bits)
                  new_bits = new_bits & mask
                  new_bits = new_bits * shift_factor
                  value = value + new_bits

            fixed_file.write("{:08x} \n".format(uint(value)))

   unit_offset_factor  = int(((w.shape[0] *w.shape[1]) + (packing_factor-1))/packing_factor)
   layer_offset_factor = unit_offset_factor * (w.shape[2] * w.shape[3])

   header.write("      \n")
   header.write("   static const int layer{:d}_input_images         = {:d};  \n".format(layer, w.shape[2]))
   header.write("   static const int layer{:d}_output_images        = {:d};  \n".format(layer, w.shape[3]))
   header.write("   static const int layer{:d}_weights_rows         = {:d};  \n".format(layer, w.shape[1]))
   header.write("   static const int layer{:d}_weights_cols         = {:d};  \n".format(layer, w.shape[0]))
   header.write("      \n")
   header.write("   static const int layer{:d}_num_weights          = {:d};  \n".format(layer, w.shape[0]*w.shape[1]*w.shape[2]*w.shape[3]))
   header.write("   static const int layer{:d}_unit_size            = {:d};  \n".format(layer, w.shape[0]*w.shape[1]))
   header.write("   static const int layer{:d}_unit_offset_factor   = {:d};  \n".format(layer, unit_offset_factor))
   header.write("   static const int later{:d}_unit_count           = {:d};  \n".format(layer, w.shape[2]*w.shape[3]))
   header.write("      \n")
   if (layer==1):   
      header.write("   static const int layer1_weight_offset           = 0;  \n")
   header.write("   static const int layer{:d}_weight_offset        = layer{:d}_weight_offset + {:d};  \n".format(layer+1, layer, layer_offset_factor))
   header.write("      \n")
   header.write("      \n")
   
   return layer_offset_factor
   return w.shape[0] * w.shape[1] * w.shape[2] * w.shape[3];
   
def memimg_dense_weights(header, memimg, fixed_file, w, layer, count, address, packing_factor=1, word_size=0, integer_bits=0):
   if word_size == 0:
      word_size = int(32/packing_factor)
      if integer_bits==0:
          integer_bits = int(word_size/2)
      fractional_bits = word_size - integer_bits

   print('word_size: ', word_size, ' int_bits: ', integer_bits, ' frac_bits: ', fractional_bits)
   # header.write("   static const int   layer{:d}_weight_offset      = {:d}; \n".format(layer, address))
   
   for i in range(w.shape[1]):
      for c in range(count):
         for j in range(int(w.shape[0]/count)):
            memimg.write("{:08x} \n".format(floatToBits(w[j*count+c][i])));

   for i in range(w.shape[1]):
      values = []
      for c in range(count):
         for j in range(int(w.shape[0]/count)):
            values.append(w[j*count+c][i].numpy());

      for j in range(int((w.shape[0] + (packing_factor-1))/packing_factor)):
         value = 0;
         for p in range(packing_factor):
            index = j * packing_factor + p
            shift_factor = 1 << (word_size * p)
            factor =  1 << fractional_bits
            mask = (1 << word_size) - 1
            if index<len(values):
               new_bits = values[index] * factor
               new_bits = uint(new_bits)
               new_bits = new_bits & mask
               print('original: ', values[index], ' bits: ', new_bits, ' factor: ', factor)
               new_bits = new_bits * shift_factor
               value = value + new_bits

         fixed_file.write("{:08x} \n".format(uint(value)))

   unit_offset_factor  = int((w.shape[0] + (packing_factor-1))/packing_factor)
   layer_offset_factor = unit_offset_factor * w.shape[1]

   header.write("      \n");
   header.write("   static const int layer{:d}_weights_rows = {:d}; \n".format(layer, w.shape[1]));
   header.write("   static const int layer{:d}_weights_cols = {:d}; \n".format(layer, w.shape[0]));
   header.write("      \n");
   header.write("   static const int layer{:d}_num_weights        = {:d};  \n".format(layer, w.shape[0]*w.shape[1]))
   header.write("   static const int layer{:d}_unit_size          = {:d};  \n".format(layer, w.shape[0]))
   header.write("   static const int layer{:d}_unit_offset_factor = {:d};  \n".format(layer, unit_offset_factor))
   header.write("   static const int later{:d}_unit_count         = {:d};  \n".format(layer, w.shape[1]))
   header.write("      \n")
   if (layer==1):   
      header.write("   static const int layer1_weight_offset         = 0;  \n")
   header.write("   static const int layer{:d}_weight_offset      = layer{:d}_weight_offset + {:d};  \n".format(layer+1, layer, layer_offset_factor))
   header.write("      \n")
   header.write("      \n")

   return layer_offset_factor
   return w.shape[0] * w.shape[1]


def memimg_biases(header, memimg, fixed_file, b, layer, address):
   header.write("   static const int   layer{:d}_biase_offset       = {:d}; \n".format(layer, address))
   for i in range(b.shape[0]):
      memimg.write("{:08x} \n".format(floatToBits(b[i])));
      fixed_file.write("{:08x} \n".format(uint(0x10000 * b[i])));

   return b.shape[0];


def write_header_file(weights, height, width, include_bias=False):
   header_file = open("weights.h", "w")
   data_file   = open("../data/weight_float.bin", "w+b")

   weight_size = 1 # keeps C pointer arithmetic happy

   current_address = 0
   layer = 1
   weight_index = 0

   print("Layer #1")
   size = write_convolution_weights (weights[weight_index], layer, header_file, data_file)
   current_address += size * weight_size
   weight_index += 1
   if include_bias:
      size = write_biases              (weights[weight_index], layer, data_file)
      current_address += size * weight_size
      weight_index += 1
   layer += 1

   print("Layer #2")
   size = write_dense_weights (weights[weight_index], layer, header_file, data_file)
   current_address += size * weight_size
   weight_index += 1
   if include_bias:
      size = write_biases              (weights[weight_index], layer, data_file)
      current_address += size * weight_size
      weight_index += 1
   layer += 1

   print("Layer #3")
   size = write_dense_weights       (weights[weight_index], layer, header_file, data_file)
   current_address += size * weight_size
   weight_index += 1
   if include_bias:
      size = write_biases              (weights[weight_index], layer, data_file)
      current_address += size * weight_size
      weight_index += 1
   layer += 1

   header_file.write(" \n");
   header_file.write("   static int const image_height = {:d}; \n".format(height))
   header_file.write("   static int const image_width  = {:d}; \n".format(width))
   header_file.write(" \n");

   header_file.write("   static void     *top_of_weights        = (void *) 0x{:x}; \n".format(current_address))
   header_file.write(" \n");

   header_file.close()
   data_file.close()


def write_memory_image_file(weights, height, width, include_bias=False, base_address=0x40000000):

   packing_factor=1

   header_file = open("weights_embedded.h", "w")
   memory_image_file = open("weights.mem", "w")
   fixed_memory_file = open("fixed_weights.mem", "w")
   weight_size = 1;

   layer = 1
   weight_index = 0

   current_address = 0

   header_file.write(" \n");
   header_file.write("   static const int   base_address              = 0x{:x}; \n".format(base_address))
   header_file.write(" \n");

   print("layer #1")
   size = memimg_convolution_weights(header_file, memory_image_file, fixed_memory_file, weights[weight_index], layer, current_address, packing_factor=packing_factor)
   weight_index += 1
   current_address += size * weight_size
   print("Convolution weights: ", size)
   if include_bias:
      size = memimg_biases(header_file, memory_image_file, fixed_memory_file, weights[weight_index], layer, current_address)
      weight_index += 1
      current_address += size * weight_size
      print("Bias weights: ", size)
   layer += 1

   print("layer #2")
   size = memimg_convolution_weights(header_file, memory_image_file, fixed_memory_file, weights[weight_index], layer, current_address, packing_factor=packing_factor)
   weight_index += 1
   current_address += size * weight_size
   print("Convolution weights: ", size)
   if include_bias:
      size = memimg_biases(header_file, memory_image_file, fixed_memory_file, weights[weight_index], layer, current_address)
      weight_index += 1
      current_address += size * weight_size
      print("Bias weights: ", size)
   layer += 1

   if include_bias:
      input_size = weights[weight_index-2].shape[3]
   else:
      input_size = weights[weight_index-1].shape[3]

   print("layer #3")
   size = memimg_dense_weights(header_file, memory_image_file, fixed_memory_file, weights[weight_index], layer, input_size, current_address, packing_factor=packing_factor)
   weight_index += 1
   current_address += size * weight_size
   print("Dense weights: ", size)
   if include_bias:
      size = memimg_biases(header_file, memory_image_file, fixed_memory_file, weights[weight_index], layer, current_address)
      weight_index += 1
      current_address += size * weight_size
      print("Bias weights: ", size)
   layer += 1

   print("end_address: ", current_address);

   header_file.write(" \n");
   header_file.write("   static const int   image_height              = {:d}; \n".format(height))
   header_file.write("   static const int   image_width               = {:d}; \n".format(width))
   header_file.write(" \n");

   header_file.write("   static const int   top_of_weights            = {:d}; \n".format(current_address))
   header_file.write(" \n");
   header_file.close()
   memory_image_file.close()
   fixed_memory_file.close()

