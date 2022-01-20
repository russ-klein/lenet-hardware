#ifndef WEIGHTS_H_INCLUDED 
#define WEIGHTS_H_INCLUDED 


      
   //=======layer 1 - convolution===============================   
      
   static const int layer1_input_images       = 1;  
   static const int layer1_output_images      = 20;  
   static const int layer1_weights_rows       = 5;  
   static const int layer1_weights_cols       = 5;  
      
   static const int layer1_num_weights        = 500;  
      
   static const int layer1_weight_offset      = 0;  
   static const int layer1_out_size           = 3920;  
      
      
   static const int layer1_num_bias_values    = 20;  
   static const int layer1_bias_offset        = 500;  
      
      
      
   //=======layer 2 - convolution===============================   
      
   static const int layer2_input_images       = 20;  
   static const int layer2_output_images      = 50;  
   static const int layer2_weights_rows       = 5;  
   static const int layer2_weights_cols       = 5;  
      
   static const int layer2_num_weights        = 25000;  
      
   static const int layer2_weight_offset      = 520;  
   static const int layer2_out_size           = 2450;  
      
      
   static const int layer2_num_bias_values    = 50;  
   static const int layer2_bias_offset        = 25520;  
      
      
      
   //=======layer 3 - dense=====================================   
      
   static const int layer3_weights_rows       = 500; 
   static const int layer3_weights_cols       = 2450; 
      
   static const int layer3_num_weights        = 1225000;  
      
   static const int layer3_weight_offset      = 25570;  
   static const int layer3_out_size           = 500;  
      
      
      
   static const int layer3_num_bias_values    = 500;  
   static const int layer3_bias_offset        = 1250570;  
      
      
      
   //=======layer 4 - dense=====================================   
      
   static const int layer4_weights_rows       = 10; 
   static const int layer4_weights_cols       = 500; 
      
   static const int layer4_num_weights        = 5000;  
      
   static const int layer4_weight_offset      = 1251070;  
   static const int layer4_out_size           = 10;  
      
      
      
   static const int layer4_num_bias_values    = 10;  
   static const int layer4_bias_offset        = 1256070;  
      
      
 
   //=======End of layers==========================================   
 
 
   static int const image_height              = 28; 
   static int const image_width               = 28; 
   static int const image_size                = 784; 
   static int const num_images                = 1; 
 
   static int const size_of_weights           = 1256080; 
   static int const size_of_outputs           = 1263744; 
 
 
#endif 
 
