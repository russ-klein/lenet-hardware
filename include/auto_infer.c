#include "sw_infer.h"  
  
void sw_auto_infer(float *memory, int image_offset, float *probabilities) 
{ 
 
   conv2d_sw( 
       memory + 1966030,  // offset of input images 
       memory + 0,  // offset of weights      
       memory + 500,  // offset of biases       
       memory + 1966814,  // offset of output images 
       1,           // number of input images  
       20,           // number of output images 
       28,           // height                  
       28,           // width                   
       5,           // kernel height           
       5,           // kernel width            
       1,          // apply max pooling          
       0,          // don't apply relu        
       1);         // apply bias              
 
   dense_sw( 
       memory + 1966814,  // offset of input images 
       memory + 520,  // offset of weights      
       memory + 1960520,  // offset of biases       
       memory + 1970734,  // offset of output images          
       1,           // number of rows in input images   
       3920,           // number of cols in input images   
       500,           // number of output images          
       1,          // apply relu              
       1);         // apply bias              
 
   dense_sw( 
       memory + 1970734,  // offset of input images 
       memory + 1961020,  // offset of weights      
       memory + 1966020,  // offset of biases       
       memory + 1971234,  // offset of output images          
       1,           // number of rows in input images   
       500,           // number of cols in input images   
       10,           // number of output images          
       0,          // don't apply relu        
       1);         // apply bias              
 
   softmax(memory + 1971234, memory + 1971244, 10); 
 
 
   memcpy(probabilities, memory + 1971244, 10 * sizeof(float)); 
} 
 
#include "hw_infer.h"  
  
void hw_auto_infer(float *memory, int image_offset, float *probabilities) 
{ 
 
   conv2d_hw( 
       memory,                                   
       1966030,           // offset of input images 
       0,           // offset of weights      
       500,           // offset of biases       
       1966814,           // offset of output images 
       1,           // number of input images  
       20,           // number of output images 
       28,           // height                  
       28,           // width                   
       5,           // kernel height           
       5,           // kernel width            
       1,          // apply max pooling          
       0,          // don't apply relu        
       1);         // apply bias              
 
   dense_hw( 
       memory,                                   
       1966814,           // offset of input images 
       520,           // offset of weights      
       1960520,           // offset of biases       
       1970734,           // offset of output images          
       1,           // number of rows in input images   
       3920,           // number of cols in input images   
       500,           // number of output images          
       1,          // apply relu              
       1);         // apply bias              
 
   dense_hw( 
       memory,                                   
       1970734,           // offset of input images 
       1961020,           // offset of weights      
       1966020,           // offset of biases       
       1971234,           // offset of output images          
       1,           // number of rows in input images   
       500,           // number of cols in input images   
       10,           // number of output images          
       0,          // don't apply relu        
       1);         // apply bias              
   float softmax_in[10];                        
   float softmax_out[10];                       
 
   copy_from_cat(memory, softmax_in, 1971234, 10); 
 
   softmax(softmax_in, softmax_out, 10);         
 
 
   memcpy(probabilities, softmax_out, 10 * sizeof(float)); 
} 
 
