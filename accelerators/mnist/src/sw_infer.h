
#ifndef SW_INFER_INCLUDED
#define SW_INFER_INCLUDED

void conv2d_sw(
               float *image,
               float *weights,
               float *biases,
               float *output_image,
               int num_input_images,
               int num_output_images,
               int height,
               int width,
               int filter_height,
               int filter_width,
               int maxpool,
               int relu,
               int bias);

void dense_sw(
              float *input_image,
              float *weights,
              float *biases,
              float *output_image,
              int num_units,
              int unit_count,
              int output_image_elements,
              int relu,
              int bias);

#endif
