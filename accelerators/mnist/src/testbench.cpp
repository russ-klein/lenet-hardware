#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "weights.h"

#include "test_images.h"

static const char program_name[] = "mnist_inference";


//=====Weight/scratchpad memory==============//

// everything that reads and writes the weight/scratchpad memory should be of the type "cat_memory_type"
// and should use the routines set|get_cat_value() and copy_to|from_cat() as the type will be differnt 
// ac_fixed or native float types at different times
// this keeps all the conversions in one place

typedef float cat_memory_type;

cat_memory_type get_cat_value(cat_memory_type *memory, int offset)
{
    return memory[offset];
}


void set_cat_value(cat_memory_type *memory, int offset, cat_memory_type value)
{
    memory[offset] = value;
}


void copy_to_cat(cat_memory_type *memory, int offset, float *source, int size)
{
    int i;

    for (i=0; i<size; i++) set_cat_value(memory, offset+i, source[i]);
}

void copy_from_cat(cat_memory_type *memory, float *dest, int offset, int size)
{
    int i;

    for (i=0; i<size; i++) dest[i] = get_cat_value(memory, offset + i);
}

//=====Debug routines========================//

void print_image(cat_memory_type *memory, int image_offset, int height, int width, int count)
{
    int r;
    int c;
    int i;

    for (i=0; i<count; i++) {
        for (r=0; r<height; r++) {
            for (c=0; c<width; c++) {
                if (memory[image_offset + i * height * width + r * width + c] > 0.001) {
                    printf("%5.3f, ", memory[image_offset + i * height * width + r * width + c]);
                } else {
                    printf("  -    ");
                }
            }
            printf("\n");
        }
        printf("\n");
    }
}

//=====Keras layer functions=================//

int in_bounds(
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
               cat_memory_type *memory,
               int image_offset,
               int weight_offset,
               int bias_offset,
               int output_image_offset,
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
    int size = height * width;
    int filter_size = filter_height * filter_width;

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
                                weight_index = o * filter_size * num_input_images + i * filter_size + fr * width + fc;
                                image_value = get_cat_value(memory, image_offset + image_index);
                                weight_value = get_cat_value(memory, weight_offset + weight_index);
//#ifdef ARM
                                if (chatty) printf("image_index: %d weight_index: %d image_value: %5.2f weight_value: %5.2f \n",
                                                   image_index, weight_index, image_value, weight_value);
//#else
//                              if (chatty) printf("image_index: %d weight_index: %d image_value: %5.2f weight_value: %5.2f \n",
//                                                 image_index, weight_index, image_value.to_double(), weight_value.to_double());
//#endif
                                sum += image_value * weight_value;
                            }
                        }
                    }
                    output_index = o * image_size + r * image_width + c;
                    if (maxpool) output_index = o * image_size /(stride * stride) + r * image_width + c;
                    if (i==0) n = sum; else n = sum + get_cat_value(memory, output_image_offset + output_index);
                    set_cat_value(memory, output_image_offset + output_index, n);
                }
            }
        }
        if (relu) {
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    output_index = o * size + r * width + c;
                    n = get_cat_value(memory, output_image_offset + output_index);
                    if (n<0) set_cat_value(memory, output_image_offset + output_index, 0.0);
                }
            }
        }
        if (bias) {  // todo: does the bias get calculated before or ater relu???
            for (r=0; r<height; r++) {
                for (c=0; c<width; c++) {
                    image_index = o * size + r * width + c;
                    image_value = get_cat_value(memory, output_image_offset + image_index);
                    bias_value = get_cat_value(memory, bias_offset + o);
                    set_cat_value(memory, output_image_offset + image_index, image_value + bias_value);
                }
            } 
        }
        if (maxpool) {
            for (r=0; r<height/stride; r++) {
                for (c=0; c<width/stride; c++) {
                    output_index = o * size/(stride * stride) + r * width / stride + c;
                    input_index = o * size/(stride * stride) + r * stride * width + c * stride;

                    max = get_cat_value(memory, output_image_offset + input_index);
                    for (r1=0; r1<stride; r1++) {
                        for (c1=0; c1<stride; c1++) {
                            input_index = o * size + (r+r1) * width + (c+c1);
                            n = get_cat_value(memory, output_image_offset + input_index);
                            if (n > max) {
                                max = n;
                            }
                        }
                    }
                    
                    set_cat_value(memory, output_image_offset + output_index, max);
                }
            }
        }
    }
}


void dense_sw(
              cat_memory_type *memory,
              int input_image_offset,
              int weight_offset,
              int bias_offset,
              int output_image_offset,
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
                sum += get_cat_value(memory, input_image_offset + n * unit_count + c) * get_cat_value(memory, weight_offset + (i*num_units*unit_count)+n*unit_count+c);
            }
        }
        if (bias) {
            bias_value = get_cat_value(memory, bias_offset + i);
            set_cat_value(memory, output_image_offset + i, sum + bias_value);
        } else {
            set_cat_value(memory, output_image_offset + i, sum);
        }
    }
}


void softmax(
             float *predictions,
             float *probabilities,
             int count)
{
    int i;
    double sum;
    double f;

    sum = 0.0;

    for (i=0; i<count; i++) {
        f = predictions[i];
        sum += exp(f);
    }

    for (i=0; i<count; i++) {
        probabilities[i] = exp(predictions[i])/sum;
    }
}

//=====Inference functions===================//

void infer(cat_memory_type *memory, int image_offset, float *probabilities)
{
    int layer1_out_offset  = size_of_weights + image_size;
    int layer2_out_offset  = layer1_out_offset + layer1_out_size;
    int layer3_out_offset  = layer2_out_offset + layer2_out_size;
    float host_layer3_out[layer3_out_size];

    const int chatty = 1;

    if (chatty) {
        printf("sw image in: \n");
        print_image(memory, image_offset, image_height, image_width, 1);

        printf("Convolution layer #1 \n");
    }

    conv2d_sw(memory, image_offset, layer1_weight_offset, layer1_bias_offset, layer1_out_offset,
              layer1_input_images, layer1_output_images, image_height, image_width, 5, 5, 1, 1, 0);

    if (chatty) {
        printf("sw image out layer #1: \n");
        print_image(memory, layer1_out_offset, image_height/2, image_width/2, layer1_output_images);

        printf("Dense layer #2 \n");
    }

    dense_sw (memory, layer1_out_offset, layer2_weight_offset, layer2_bias_offset, layer2_out_offset,
              layer2_weights_cols / (image_size/4), image_size/4, layer2_weights_rows, 1);

    if (chatty) printf("Dense layer #3 \n");

    dense_sw (memory, layer2_out_offset, layer3_weight_offset, layer3_bias_offset, layer3_out_offset,
              layer3_weights_cols / (image_size/4), image_size/4, layer3_weights_rows, 1);

    copy_from_cat(memory, host_layer3_out, layer3_out_offset, layer3_weights_rows);

    if (chatty) {
        printf("raw sw scores... \n");
        for (int i=0; i<10; i++) printf("raw scores[%d] = %f \n", i, host_layer3_out[i]);
    }

    softmax(host_layer3_out, probabilities, layer3_weights_rows);
}


void load_memory(cat_memory_type *memory)
{
    int i;
    int r;
    
    // only neccesary when running on the host, when embedded the weights will be loaded into memory

    FILE *weight_database;
    char weight_filename[] = "../../../data/weights_float.bin";

    weight_database = fopen(weight_filename, "r");

    if (weight_database == NULL) {
        fprintf(stderr, "Unable to open file '%s' for reading \n", weight_filename);
        perror(program_name);
        exit(0);
    }

    r = fread(memory, sizeof(float), size_of_weights, weight_database);

    if (r != size_of_weights) {
        fprintf(stderr, "Unable to read in weights from file '%s' \n", weight_filename);
        perror(program_name);
        exit(0);
    }

    fclose(weight_database);
}


void scale(unsigned char *input_image, float *output_image, int count)
{   
    int i;
    
    for (i=0; i<count; i++) {
        output_image[i] = ((float) input_image[i])/255.0;
    }
}


void sw_inference(unsigned char *input_image, cat_memory_type *memory, float *probabilities)
{   
    float image[image_height * image_width];
    int image_offset = size_of_weights;
    int i;
    const int chatty = 1;
    
    scale(input_image, image, image_height * image_width);
    
    load_memory(memory);
    copy_to_cat(memory, image_offset, image, image_height * image_width * layer1_input_images);
    
    infer(memory, image_offset, probabilities);
    
    if (chatty) {
        printf("software probabilities: \n");
        for (i=0; i<10; i++) { 
            printf(" %d: %8.6f \n", i, probabilities[i]);
        }
        printf("\n");
    }
}


int main()
{
    // possible values for *input_image are "zero" through "nine" //
    unsigned char *input_image = (unsigned char *) five;
    float sw_prob[10];
    float hw_prob[10];
    int errors = 0;
    int i;

    static cat_memory_type memory[0x1000000];  // make it static so you do not blow up the stack

    // sweep();

    printf("start sw: \n");
    sw_inference(input_image, memory, sw_prob);

    //printf("start hw: \n");
    //hw_inference(input_image, memory, hw_prob);

    for (i=0; i<10; i++) {
        if (sw_prob[i] != hw_prob[i]) errors++;
    }

    if (errors) {
        printf("Test failed, hw does not match sw! \n");
        return 1;
    } else {
        printf("Test passed! \n");
        return 0;
    }

    return 0;
}

