#include <stdio.h>

#include "weights.h"
#include "sw_infer.h"

void print_image(float *f, int h, int w, int c);

static int in_bounds(
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
               int bias,
               int relu)
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
    int input_base;
    int output_base;
    const int size = height * width;
    const int filter_size = filter_height * filter_width;

    print_image(image, height, width, num_input_images);
    print_image(weights, filter_height, filter_width, num_input_images);
    printf("num_input_images: %d \n", num_input_images);
    printf("num_output_images: %d \n", num_output_images);
    printf("height: %d \n", height);
    printf("width: %d \n", width);
    printf("filter_height: %d \n", filter_height);
    printf("filter_width: %d \n", filter_width);
    printf("maxpool: %d \n", maxpool);
    printf("bias: %d \n", bias);
    printf("relu: %d \n", relu);

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

                                image_index = i * size + rr * width + cc;
                                weight_index = o * filter_size * num_input_images + i * filter_size + fr * filter_width + fc;

                                image_value = image[image_index];
                                weight_value = weights[weight_index];

                                if (chatty) printf("image_index: %d weight_index: %d image_value: %5.2f weight_value: %5.2f \n",
                                                   image_index, weight_index, image_value, weight_value);
                                sum += image_value * weight_value;
                            }
                        }
                    }
                    output_index = o * size + r * width + c;
                    if (i==0) n = sum; else n = sum + output_image[output_index];
                    output_image[output_index] = n;
                }
            }
        }
        if (relu) {
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    output_index = o * size + r * width + c;
                    n = output_image[output_index];
                    if (n<0) output_image[output_index] = 0.0;
                }
            }
        }
        if (bias) {  // todo: does the bias get calculated before or ater relu???
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    image_index = o * size + r * width + c;
                    image_value = output_image[image_index];
                    bias_value = biases[o];
                    output_image[image_index] = image_value + bias_value;
                }
            }
        }
        if (maxpool) {

            input_base = o * size;
            output_base = o * size / (stride * stride);

            for (r=0; r<height/stride; r++) {
                for (c=0; c<width/stride; c++) {
                    output_index = output_base + r * width / stride + c;
                    input_index = input_base + r * stride * width + c * stride;

                    max = output_image[input_index];
                    for (r1=0; r1<stride; r1++) {
                        for (c1=0; c1<stride; c1++) {
                            input_index = input_base + (r * stride + r1) * width + (c * stride + c1);
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
            }
        }
        if (bias) {
            bias_value = biases[i];
            output_image[i] = sum + bias_value;
        } else {
            output_image[i] = sum;
        }
    }
}

