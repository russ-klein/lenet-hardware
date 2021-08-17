#include <stdio.h>

#include "defines.h"
#include "hw_infer.h"

void print_image(hw_cat_type *f, int h, int w, int c);

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

static int offset(int row, int col, int image, int height, int width, int images)
{
    int image_offset = (row * width) + col;
    int array_offset = (image_offset * images) + image;
    return array_offset;
}

#define OUT_OFFSET(ROW, COL, IMAGE) offset(ROW, COL, IMAGE, height, width, num_output_images)
#define IN_OFFSET(ROW, COL, IMAGE) offset(ROW, COL, IMAGE, height, width, num_input_images)

static int weight_offset(int row, int col, int input_image, int output_image, int height, int width, int num_input_images, int num_output_images)
{
    return output_image * height * width * num_input_images + input_image * height * width + row * width + col;
}

#define WEIGHT_OFFSET(ROW, COL, IN_IMAGE, OUT_IMAGE) weight_offset(ROW, COL, IN_IMAGE, OUT_IMAGE, filter_height, filter_width, num_input_images, num_output_images)

void conv2d_hw_algorithmic(
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
               int bias)
{
    int  o, i, fr, fc, r, c, rr, cc, r1, c1;
    hw_cat_type sum;
    hw_cat_type max;
    hw_cat_type n;
    hw_cat_type image_value;
    hw_cat_type weight_value;
    hw_cat_type bias_value;
    int image_index;
    int weight_index;
    int output_index;
    int input_index;
    int input_base;
    int output_base;
    const int size = height * width;
    const int filter_size = filter_height * filter_width;

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

                                image_index = IN_OFFSET(rr, cc, i);
                                weight_index = WEIGHT_OFFSET(fr, fc, o, i);

                                image_value = get_cat_value(memory, image + image_index); // image[image_index];
                                weight_value = get_cat_value(memory, weights + weight_index); // weights[weight_index];

                                #ifdef FIXED_POINT
                                  if (chatty) printf("image_index: %d weight_index: %d image_value: %5.3f weight_value: %5.3f = %5.3f \n",
                                                   image_index, weight_index, image_value.to_double(), weight_value.to_double(), 
                                                   image_value.to_double() * weight_value.to_double());
                                #else
                                  if (chatty) printf("image_index: %d weight_index: %d image_value: %5.3f weight_value: %5.3f = %5.3f \n",
                                                   image_index, weight_index, image_value, weight_value, image_value * weight_value);
                                #endif
                                sum += image_value * weight_value;
                            }
                        }
                    }
                    output_index = OUT_OFFSET(r, c, o);
                    if (i==0) n = sum; else n = sum + get_cat_value(memory, output_image + output_index); // output_image[output_index];
                    set_cat_value(memory, output_image + output_index, n); //output_image[output_index] = n;
                    #ifdef FIXED_POINT
                      if (chatty) printf("output[%d] = %5.3f \n", output_index, n.to_double());
                    #else
                      if (chatty) printf("output[%d] = %5.3f \n", output_index, n);
                    #endif
                }
            }
        }
        if (bias) {  
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    // output_index = (r * width + c) * num_output_images + o;
                    output_index = OUT_OFFSET(r, c, o);
                    image_value = get_cat_value(memory, output_image + output_index); // output_image[output_index];
                    bias_value = get_cat_value(memory, biases + o); // biases[o];
                    set_cat_value(memory, output_image + output_index, image_value + bias_value); // output_image[output_index] = image_value + bias_value;
                }
            }
        }
        if (relu) {
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    // output_index = o * size + r * width + c;
                    output_index = OUT_OFFSET(r, c, o);
                    n = get_cat_value(memory, output_image + output_index); // output_image[output_index];
                    if (n<0) set_cat_value(memory, output_image + output_index, 0.0); // output_image[output_index] = 0.0;
                }
            }
        }
        if (maxpool) {

            for (r=0; r<height/stride; r++) {
                for (c=0; c<width/stride; c++) {

                    input_index = offset(r*stride, c*stride, o, height, width, num_output_images);
                    output_index = offset(r, c, o, height/stride, width/stride, num_output_images);

                    max = get_cat_value(memory, output_image + input_index); // output_image[input_index];
                    for (r1=0; r1<stride; r1++) {
                        for (c1=0; c1<stride; c1++) {
                            input_index = offset(r*stride + r1, c*stride + c1, o, height, width, num_output_images);

                            n = get_cat_value(memory, output_image + input_index); // output_image[input_index];
                            if (n > max) {
                                max = n;
                            }
                        }
                    }
                    set_cat_value(memory, output_image + output_index, max); // output_image[output_index] = max;
                }
            }
        }
    }
}



void dense_hw_algorithmic(
              cat_memory_type *memory,
              int input_image,
              int weights,
              int biases,
              int output_image,
              int num_units,
              int unit_count,
              int output_image_elements,
              int relu,
              int bias)
{

    int i, n, c;
    hw_cat_type sum;
    hw_cat_type bias_value;
    int chatty = 0;

    for (i=0; i<output_image_elements; i++) {
        sum = 0.0;
        for (n=0; n<num_units; n++) {
            for (c=0; c<unit_count; c++) {
                sum += get_cat_value(memory, input_image + n * unit_count + c) *
                       get_cat_value(memory, weights + (i*num_units*unit_count)+n*unit_count+c);
                // sum += input_image[n * unit_count + c] * weights[(i*num_units*unit_count)+n*unit_count+c];
                // if (chatty) printf("image_value: %5.3f weight_value: %5.3f product: %5.3f sum: %5.3f \n",
                //       input_image[n * unit_count + c], weights[(i*num_units*unit_count)+n*unit_count+c], 
                //       input_image[n * unit_count + c] * weights[(i*num_units*unit_count)+n*unit_count+c], sum);
            }
        }
        if (bias) {
            bias_value = get_cat_value(memory, biases + i); // biases[i];
            set_cat_value(memory, output_image + i, sum + bias_value); // output_image[i] = sum + bias_value;
        } else {
            set_cat_value(memory, output_image + i, sum); // output_image[i] = sum;
        }
        if (relu) {
            //if (output_image[i] <0) output_image[i] = 0;
            if (get_cat_value(memory, output_image + i) < 0) set_cat_value(memory, output_image + i, 0); // output_image[i] = 0;
        }
    }
}
/*
void new_dense_hw(
              hw_cat_type *input_image,
              hw_cat_type *weights,
              hw_cat_type *biases,
              hw_cat_type *output_image,
              int input_image_elements,
              int output_image_elements,
              int relu,
              int bias)
{

    int i, o;
    hw_cat_type sum;
    hw_cat_type bias_value;
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
*/
