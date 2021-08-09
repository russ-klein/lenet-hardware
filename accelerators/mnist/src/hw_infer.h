
#ifndef HW_INFER_INCLUDED
#define HW_INFER_INCLUDED

#include "cat_access.h"

void conv2d_hw(
               cat_memory_type *memory,
               int image,
               int weights,
               int biases,
               int output_image,
               int num_input_images,
               int num_output_images,
               int height,
               int width,
               int filter_height,
               int filter_width,
               int maxpool,
               int relu,
               int bias);

void dense_hw(
              cat_memory_type *memory,
              int input_image,
              int weights,
              int biases,
              int output_image,
              int num_units,
              int unit_count,
              int output_image_elements,
              int relu,
              int bias);

#endif
