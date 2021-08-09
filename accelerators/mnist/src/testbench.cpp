#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "weights.h"
#include "test_images.h"

#include "cat_access.h"

#include "sw_infer.h"
#include "hw_infer.h"

#include "diags.h"

static const char program_name[] = "mnist_inference";

//=====Debug routines========================//

void print_float_image(float *image, int height, int width, int count)
{
    int r;
    int c;
    int i;

    for (i=0; i<count; i++) {
        for (r=0; r<height; r++) {
            for (c=0; c<width; c++) {
                if (image[i * height * width + r * width + c] > 0) {
                    printf("%5.3f, ", image[i * height * width + r * width + c]);
                } else {
                    printf("  -    ");
                }
            }
            printf("\n");
        }
        printf("\n");
    }
}

void print_char_image(unsigned char *image, int height, int width, int count)
{
    int r;
    int c;
    int i;

    for (i=0; i<count; i++) {
        for (r=0; r<height; r++) {
            for (c=0; c<width; c++) {
                if (image[i * height * width + r * width + c] > 0) {
                    printf("%3d, ", image[i * height * width + r * width + c]);
                } else {
                    printf("  -  ");
                }
            }
            printf("\n");
        }
        printf("\n");
    }
}

void print_float_kernel(float *kernel, int kernel_height, int kernel_width, int count)
{
    int r;
    int c;
    int i;

    for (i=0; i<count; i++) {
        for (r=0; r<kernel_height; r++) {
            for (c=0; c<kernel_width; c++) {
                printf("%5.3f, ", kernel[i * kernel_height * kernel_width + r * kernel_width + c]);
            }
            printf("\n");
        }
        printf("\n");
    }
}


void print_cat_image(cat_memory_type *memory, int image_offset, int height, int width, int count)
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

void print_cat_kernel(cat_memory_type *memory, int kernel_offset, int kernel_height, int kernel_width, int count)
{
    int r;
    int c;
    int i;

    for (i=0; i<count; i++) {
        for (r=0; r<kernel_height; r++) {
            for (c=0; c<kernel_width; c++) {
                printf("%5.3f, ", memory[kernel_offset + i * kernel_height * kernel_width + r * kernel_width + c]);
            }
            printf("\n");
        }
        printf("\n");
    }
}

//=====Keras layer functions=================//


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

void load_memory(cat_memory_type *memory)
{
    int i;
    int r;
    
    // only neccesary when running on the host, when embedded the weights will be loaded into memory

    FILE *weight_database;
    char *weight_path; 
    char weight_base_filename[] = "weights_float.bin";
    char weight_filename[10240];

    weight_path = getenv("WEIGHT_PATH");

    if (weight_path) sprintf(weight_filename, "%s/%s", weight_path, weight_base_filename);
    else strcpy(weight_filename, weight_base_filename);

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

#include "auto_infer.c"

void sw_inference(unsigned char *input_image, float *memory, float *probabilities)
{
    float image[image_height * image_width * 1];
    int image_offset = size_of_weights;
    int i;
    const int chatty = 1;

    scale(input_image, image, image_height * image_width);

    load_memory(memory);
    memcpy(memory+image_offset, image, image_height * image_width * 1 * sizeof(float));

    sw_auto_infer(memory, image_offset, probabilities);

    if (chatty) {
        printf("sw prediction: \n");
        for (i=0; i<10; i++) {
           printf("%d = %8.6f \n", i, probabilities[i]);
        }
        printf("\n");
    }
}


void hw_inference(unsigned char *input_image, cat_memory_type *memory, float *probabilities)
{
    float image[image_height * image_width * 1];
    int image_offset = size_of_weights;
    float p[10];
    int i;
    const int chatty = 1;

    scale(input_image, image, image_height * image_width);

    load_memory(memory);

    copy_to_cat(memory, image_offset, image, image_height * image_width * layer1_input_images);

    hw_auto_infer(memory, image_offset, probabilities);

    if (chatty) {
        printf("hw prediction: \n");
        for (i=0; i<10; i++) {
           printf("%d = %8.6f \n", i, probabilities[i]);
        }
        printf("\n");
    }
}


void all_digits(float *memory)
{
    unsigned char *image_list[] = { (unsigned char *) &zero, 
                                    (unsigned char *) &one, 
                                    (unsigned char *) &two, 
                                    (unsigned char *) &three, 
                                    (unsigned char *) &four, 
                                    (unsigned char *) &five, 
                                    (unsigned char *) &six, 
                                    (unsigned char *) &seven, 
                                    (unsigned char *) &eight, 
                                    (unsigned char *) &nine};
    int i, j;
    float image[image_height * image_width];
    float probabilities[10];

    load_memory(memory);

    for (i=0; i<sizeof(image_list)/sizeof(image_list[0]); i++) {
        print_char_image(image_list[i], image_height, image_width, 1);
        scale(image_list[i], image, image_height * image_width);
        memcpy(memory+size_of_weights, image, image_height * image_width * 1 * sizeof(float));

        sw_auto_infer(memory, size_of_weights, probabilities);

        printf("prediction: \n");
        for (j=0; j<10; j++) {
           printf("%d = %8.6f \n", j, probabilities[j]);
        }
        printf("\n");
    }  
}

int main()
{
    // possible values for *input_image are "zero" through "nine" //
    unsigned char *input_image = (unsigned char *) three;
    float sw_prob[10];
    float hw_prob[10];
    int errors = 0;
    int i;

    static cat_memory_type hw_memory[0x1000000];  // make it static so you do not blow up the stack
    static float           sw_memory[0x1000000];

    // sweep();
    // test_conv2d();
    // test_dense();
    // all_digits(sw_memory);

    printf("start sw: \n");
    sw_inference(input_image, sw_memory, sw_prob);

    printf("start hw: \n");
    hw_inference(input_image, hw_memory, hw_prob);

    for (i=0; i<10; i++) {
        if (sw_prob[i] != hw_prob[i]) {
           printf("%d: hw: %f sw: %f \n", i, hw_prob[i], sw_prob[i]);
           errors++;
        }
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

