#include <stdio.h>

#include "weights.h"
#include "sw_infer.h"

void print_image(float *f, int h, int w, int c);

static inline int in_bounds(
              int r,
              int c,
              int height,
              int width)
{
    if (r < 0)        return 0;
    if (r >= height)  return 0;
    if (c < 0)        return 0;
    if (c >= width)   return 0;
    return 1;
}

static inline int offset(int row, int col, int image, int height, int width, int images)
{
    // int image_offset = (row * width) + col;
    // int array_offset = (image_offset * images) + image;
    // return array_offset;

    int start_of_array = image * height * width;
    int pixel_offset = (row * width) + col;
     
    return start_of_array + pixel_offset;
}

#define OUT_OFFSET(ROW, COL, IMAGE) offset(ROW, COL, IMAGE, height, width, num_output_images)
#define IN_OFFSET(ROW, COL, IMAGE) offset(ROW, COL, IMAGE, height, width, num_input_images)

static inline int weight_offset(int row, int col, int input_image, int output_image, int height, int width, int num_input_images, int num_output_images)
{
    return output_image * height * width * num_input_images + input_image * height * width + row * width + col;
}

#define WEIGHT_OFFSET(ROW, COL, IN_IMAGE, OUT_IMAGE) weight_offset(ROW, COL, IN_IMAGE, OUT_IMAGE, filter_height, filter_width, num_input_images, num_output_images)

void print_float_image(float *image, int height, int width, int count);
void print_float_kernel(float *kernel, int kernel_height, int kernel_width, int count);

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
               int bias)
{
    int  o, i, fr, fc, r, c, rr, cc, r1, c1;
    float sum;
    float max;
    float n;
    float image_value;
    float weight_value;
    float bias_value;
    int image_index;
    int weight_index;
    int output_index;
    int input_index;

    const int stride = 2;
    const int chatty = 0;
    
    for (o=0; o<num_output_images; o++) {
        for (i=0; i<num_input_images; i++) {
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    sum = 0.0;
                    for (fr=0; fr<filter_height; fr++) {
                        for (fc=0; fc<filter_width; fc++) {
                            rr = r + fr - (filter_height -1)/2;
                            cc = c + fc - (filter_width -1)/2;
                            if (in_bounds(rr, cc, height, width)) {

                                // image_index = i * size + rr * width + cc;
                                // weight_index = o * filter_size * num_input_images + i * filter_size + fr * filter_width + fc;

                                image_index = IN_OFFSET(rr, cc, i);
                                weight_index = WEIGHT_OFFSET(fr, fc, i, o);

                                image_value = image[image_index];
                                weight_value = weights[weight_index];

                                if (chatty) printf("SW image_index: %d weight_index: %d image_value[%d][%d]: %5.3f weight_value: %5.3f = %5.3f \n",
                                                   image_index, weight_index, rr, cc, image_value, weight_value, image_value * weight_value);
                                sum += image_value * weight_value;
                            }
                        }
                    }
                    // output_index = (r * width + c) * num_output_images + o;
                    output_index = OUT_OFFSET(r, c, o);
                    if (i==0) n = sum; else n = sum + output_image[output_index];
                    output_image[output_index] = n;
                    if (chatty) printf("output[%d] = %5.3f \n", output_index, output_image[output_index]);
                }
            }
        }
        if (bias) {  
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    // output_index = (r * width + c) * num_output_images + o;
                    output_index = OUT_OFFSET(r, c, o);
                    image_value = output_image[output_index];
                    bias_value = biases[o];
                    output_image[output_index] = image_value + bias_value;
                }
            }
        }
        if (relu) {
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    // output_index = o * size + r * width + c;
                    output_index = OUT_OFFSET(r, c, o);
                    n = output_image[output_index];
                    if (n<0) output_image[output_index] = 0.0;
                }
            }
        }
        if (maxpool) {

            for (r=0; r<height/stride; r++) {
                for (c=0; c<width/stride; c++) {

                    input_index = offset(r*stride, c*stride, o, height, width, num_output_images);
                    output_index = offset(r, c, o, height/stride, width/stride, num_output_images);

                    max = output_image[input_index];
                    for (r1=0; r1<stride; r1++) {
                        for (c1=0; c1<stride; c1++) {
                            input_index = offset(r*stride + r1, c*stride + c1, o, height, width, num_output_images);

                            n = output_image[input_index];
                            if (n > max) {
                                max = n;
                            }
                        }
                    }
                    output_image[output_index] = max;
                }
            }
        }
    }
}



void dense_sw(
              float *input_image,
              float *weights,
              float *biases,
              float *output_image,
              int num_units,
              int unit_count,
              int output_image_elements,
              int relu,
              int bias)
{

    int i, n, c;
    float sum;
    float bias_value;
    int chatty = 0;

    for (i=0; i<output_image_elements; i++) {
        sum = 0.0;
        for (n=0; n<num_units; n++) {
            for (c=0; c<unit_count; c++) {
                sum += input_image[n * unit_count + c] * weights[(i*num_units*unit_count)+n*unit_count+c];
                if (chatty) printf("image_value: %5.3f weight_value: %5.3f product: %5.3f sum: %5.3f \n",
                       input_image[n * unit_count + c], weights[(i*num_units*unit_count)+n*unit_count+c], 
                       input_image[n * unit_count + c] * weights[(i*num_units*unit_count)+n*unit_count+c], sum);
            }
        }
        if (bias) {
            bias_value = biases[i];
            output_image[i] = sum + bias_value;
        } else {
            output_image[i] = sum;
        }
        if (relu) {
            if (output_image[i] <0) output_image[i] = 0;
        }
    }
}

void new_dense_sw(
              float *input_image,
              float *weights,
              float *biases,
              float *output_image,
              int input_image_elements,
              int output_image_elements,
              int relu,
              int bias)
{

    int i, o;
    float sum;
    float bias_value;
    int chatty = 0;

    for (o=0; o<output_image_elements; o++) {
        sum = 0.0;
        for (i=0; i<input_image_elements; i++) {
            sum += input_image[i] * weights[(o*input_image_elements)+i];
            if (chatty) printf("image_value: %5.3f weight_value: %5.3f product: %5.3f sum: %5.3f \n",
                input_image[i], weights[(o*input_image_elements)+i], 
                input_image[i] * weights[(o*input_image_elements)+i], sum);
        }
        if (bias) {
            bias_value = biases[o];
            output_image[o] = sum + bias_value;
        } else {
            output_image[o] = sum;
        }
        if (relu) {
            if (output_image[o] <0) output_image[o] = 0;
        }
    }
}

