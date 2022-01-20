#include "sw_infer.h"  
  
void sw_auto_infer(float *memory, int image_offset, float *probabilities) 
{ 
 
   conv2d_sw( 
       memory + 1256080,  // offset of input images 
       memory + 0,  // offset of weights      
       memory + 500,  // offset of biases       
       memory + 1256864,  // offset of output images 
       1,           // number of input images  
       20,           // number of output images 
       28,           // height                  
       28,           // width                   
       5,           // kernel height           
       5,           // kernel width            
       1,          // apply max pooling          
       0,          // don't apply relu        
       1);         // apply bias              
 
   conv2d_sw( 
       memory + 1256864,  // offset of input images 
       memory + 520,  // offset of weights      
       memory + 25520,  // offset of biases       
       memory + 1260784,  // offset of output images 
       20,           // number of input images  
       50,           // number of output images 
       14,           // height                  
       14,           // width                   
       5,           // kernel height           
       5,           // kernel width            
       1,          // apply max pooling          
       0,          // don't apply relu        
       1);         // apply bias              
 
   dense_sw( 
       memory + 1260784,  // offset of input images 
       memory + 25570,  // offset of weights      
       memory + 1250570,  // offset of biases       
       memory + 1263234,  // offset of output images          
       1,           // number of rows in input images   
       2450,           // number of cols in input images   
       500,           // number of output images          
       1,          // apply relu              
       1);         // apply bias              
 
   dense_sw( 
       memory + 1263234,  // offset of input images 
       memory + 1251070,  // offset of weights      
       memory + 1256070,  // offset of biases       
       memory + 1263734,  // offset of output images          
       1,           // number of rows in input images   
       500,           // number of cols in input images   
       10,           // number of output images          
       0,          // don't apply relu        
       1);         // apply bias              
 
   softmax(memory + 1263734, memory + 1263744, 10); 
 
   memcpy(probabilities, memory + 1263744, 10 * sizeof(float)); 
} 
 
#include "hw_infer.h"  
  
void hw_auto_infer(cat_memory_type *memory, int image_offset, float *probabilities) 
{ 
 
   conv2d_hw( 
       memory,                                   
       1256080,           // offset of input images 
       0,           // offset of weights      
       500,           // offset of biases       
       1256864,           // offset of output images 
       1,           // number of input images  
       20,           // number of output images 
       28,           // height                  
       28,           // width                   
       5,           // kernel height           
       5,           // kernel width            
       1,          // apply max pooling          
       0,          // don't apply relu        
       1);         // apply bias              
 
   conv2d_hw( 
       memory,                                   
       1256864,           // offset of input images 
       520,           // offset of weights      
       25520,           // offset of biases       
       1260784,           // offset of output images 
       20,           // number of input images  
       50,           // number of output images 
       14,           // height                  
       14,           // width                   
       5,           // kernel height           
       5,           // kernel width            
       1,          // apply max pooling          
       0,          // don't apply relu        
       1);         // apply bias              
 
   dense_hw( 
       memory,                                   
       1260784,           // offset of input images 
       25570,           // offset of weights      
       1250570,           // offset of biases       
       1263234,           // offset of output images          
       1,           // number of rows in input images   
       2450,           // number of cols in input images   
       500,           // number of output images          
       1,          // apply relu              
       1);         // apply bias              
 
   dense_hw( 
       memory,                                   
       1263234,           // offset of input images 
       1251070,           // offset of weights      
       1256070,           // offset of biases       
       1263734,           // offset of output images          
       1,           // number of rows in input images   
       500,           // number of cols in input images   
       10,           // number of output images          
       0,          // don't apply relu        
       1);         // apply bias              
 
   float softmax_in[10];                        
   float softmax_out[10];                       
 
   copy_from_cat(memory, softmax_in, 1263734, 10); 
 
   softmax(softmax_in, softmax_out, 10);         
 
   memcpy(probabilities, softmax_out, 10 * sizeof(float)); 
} 
 
