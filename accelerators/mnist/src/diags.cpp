#include <stdio.h>

#include "sw_infer.h"
#include "diags.h"


#define IMAGES_IN     1
#define IMAGES_OUT    2
#define IMAGE_HEIGHT 10
#define IMAGE_WIDTH  10
#define FILTER_HEIGHT 5
#define FILTER_WIDTH  5
#define STRIDE        2
#define MAXPOOL       1
#define RELU          0
#define BIAS          0

#define IMAGE_SIZE (IMAGE_HEIGHT * IMAGE_WIDTH)
#define FILTER_SIZE (FILTER_HEIGHT * FILTER_WIDTH)

float abs(float f)
{
    return (f>0.0) ? f : -1.0 * f;
}

void print_image(float *image, int height, int width, int count)
{
    int r;
    int c;
    int i;

    for (i=0; i<count; i++) {
        for (r=0; r<height; r++) {
            for (c=0; c<width; c++) {
                if (abs(image[i * height * width + r * width + c]) > 0.001) {
                    printf("%7.2f, ", image[i * height * width + r * width + c]);
                } else {
                    printf("    -    ");
                }
            }
            printf("\n");
        }
        printf("\n");
    }
}


void max_pool(float *f, int height, int width, int stride, int num_images)
{
    int r;
    int c;
    int r1;
    int c1;
    int n;
    float max;

    for (n=0; n<num_images; n++) {
        for (r=0; r<height; r+=stride) {
            for (c=0; c<width; c+=stride) {
                max = f[n*height*width+r*width+c];
                for (r1=r; r1<r+stride; r1++) {
                    for (c1=c; c1<c+stride; c1++) {
                        if (max < f[n*height*width+r1*width+c1]) max = f[n*height*width+r1*width+c1];
                    }
                }
                f[(n*height*width)/(stride*stride) + (r/stride)*(width/stride)+(c/stride)] = max;
            }
        }
    }
} 

void relu(float *f, int height, int width)
{
    int r;
    int c;

    for (r=0; r<height; r++) {
        for (c=0; c<width; c++) {
            if  (f[r*width+c] < 0.0) f[r*width+c] = 0.0;
        }
    }
} 


int test_conv2d()
{
    float image[IMAGE_SIZE * IMAGES_IN];
    float filter[FILTER_SIZE * IMAGES_OUT];
    float biases[1];
    float output[IMAGE_SIZE * IMAGES_OUT];
    int i;
    int errors = 0;
    int size = IMAGE_SIZE;
    
    for (i=0; i<IMAGE_SIZE * IMAGES_IN; i++) image[i] = (i<50) ? (float) i : -1.0 * i;

    for (i=0; i<FILTER_SIZE * IMAGES_IN * IMAGES_OUT; i++) filter[i] = 0.0;

    for (i=0; i<IMAGES_OUT; i++) {
       filter[i * FILTER_SIZE + FILTER_SIZE/2] = (float) i+1;
    }
  

    print_image(image, IMAGE_HEIGHT, IMAGE_WIDTH, IMAGES_IN);
    print_image(filter, FILTER_HEIGHT, FILTER_WIDTH, IMAGES_IN * IMAGES_OUT);

    conv2d_sw(image, filter, biases, output, IMAGES_IN, IMAGES_OUT, IMAGE_HEIGHT, IMAGE_WIDTH, FILTER_HEIGHT, FILTER_WIDTH, MAXPOOL, BIAS, RELU);

    if (RELU) {
        for (i=0; i<IMAGES_OUT; i++) relu(image + IMAGE_HEIGHT * IMAGE_WIDTH, IMAGE_HEIGHT, IMAGE_WIDTH);
    }

    if (MAXPOOL) {
        max_pool(image, IMAGE_HEIGHT, IMAGE_WIDTH, STRIDE, IMAGES_OUT);
        print_image(output, IMAGE_HEIGHT/2, IMAGE_WIDTH/2, IMAGES_OUT);
        size = size / (STRIDE * STRIDE);
    } else {
        print_image(output, IMAGE_HEIGHT, IMAGE_WIDTH, IMAGES_OUT);
    }

    for (i=0; i<size; i++) {
        if ((image[i] * 1 + (i / IMAGE_SIZE)) != output[i]) {
            printf("mismatch: index:%d expected:%5.2f received:%5.2f \n", i, image[i], output[i]); 
            errors++;
        }
    }

    if (errors == 0) printf(">>> convolution check passed \n");
    else             printf(">>> convolution check failed \n");

    return errors;
}


void dense_sw_exp(
              float *input_images,
              float *weights,
              float *output_images,
              int input_image_elements,
              int output_image_elements)
{
    int i, n;
    float sum;

    for (i=0; i<output_image_elements; i++) {
        sum = 0.0;
        for (n=0; n<input_image_elements; n++) {
            //printf("sum = %8.3f  image_data = %8.3f  weights = %8.3f \n", sum, input_images[n], weights[(i*input_image_elements)+n]);
            sum += input_images[n] * weights[(i*input_image_elements)+n];
        }
        output_images[i] = sum;
    }
}



#define A_HEIGHT    7  /* must be size of input_layers */
#define A_WIDTH     1  /* must be 1 */
#define B_HEIGHT    5  /* must be size of  output_layers */
#define B_WIDTH     7  /* must == A_HEIGHT */

void dense_sw(
              float *input_image,
              float *weights,
              float *biases,
              float *output_image,
              int num_units,
              int unit_count,
              int output_image_elements,
              int bias);


int test_dense()
{
    float a[A_HEIGHT * A_WIDTH];
    float b[B_HEIGHT * B_WIDTH];
    float r[A_WIDTH * B_HEIGHT];
    float r_exp[A_WIDTH * B_HEIGHT];
    float biases[1];

    int i;
    int j;
    int errors = 0;

    for (i=0; i<A_HEIGHT * A_WIDTH; i++) a[i] = (float) i;
    for (i=0; i<B_HEIGHT * B_WIDTH; i++) b[i] = (float) (B_WIDTH * B_HEIGHT - 1 - i);

    printf("a: "); for (i=0; i<A_HEIGHT; i++) printf("%5.2f ", a[i]); printf("\n");
    printf("b: "); 
    for (j=0; j<B_HEIGHT; j++) {
        for (i=0; i<B_WIDTH; i++) {
            printf("%5.2f ", b[j*B_WIDTH+i]); 
        }
        printf("\n   ");
    }
    printf("\n");

    dense_sw_exp(a, b, r_exp, A_HEIGHT, B_HEIGHT);
    dense_sw(a, b, biases, r, A_HEIGHT, A_WIDTH, B_HEIGHT, 0, 0);

    printf("r: "); for (i=0; i<B_HEIGHT; i++) printf("%5.2f ", r[i]); printf("\n");

    for (i=0; i<B_HEIGHT; i++) if (r[i] != r_exp[i]) errors++;

    if (errors == 0) printf(">>> dense check passed \n");
    else             printf(">>> dense check failed \n");

    return errors;

}
