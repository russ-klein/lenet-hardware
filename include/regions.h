#ifndef REGIONS_H_INCLUDED 
#define REGIONS_H_INCLUDED 


static unsigned int region_map[][2] = { 
  {          0,        500 },  // conv2d weights 
  {        500,         20 },  // conv2d biases 
  {        520,      25000 },  // conv2d_1 weights 
  {      25520,         50 },  // conv2d_1 biases 
  {      25570,    1225000 },  // dense weights 
  {    1250570,        500 },  // dense biases 
  {    1251070,       5000 },  // dense_1 weights 
  {    1256070,         10 },  // dense_1 biases 
  {    1256080,        784 },  // input_image 
  {    1256864,       3920 },  // conv2d outputs 
  {    1260784,       2450 },  // conv2d_1 outputs 
  {    1263234,        500 },  // dense outputs 
  {    1263734,         10 },  // dense_1 outputs 
  {    1263744, 4294967295 }   // out of bounds 
}; 
 
 
static char region_names[][40] = { 
  { "conv2d weights" }, 
  { "conv2d biases " }, 
  { "conv2d_1 weights" }, 
  { "conv2d_1 biases " }, 
  { "dense weights" }, 
  { "dense biases " }, 
  { "dense_1 weights" }, 
  { "dense_1 biases " }, 
  { "input image " }, 
  { "conv2d outputs " }, 
  { "conv2d_1 outputs " }, 
  { "dense outputs " }, 
  { "dense_1 outputs " }, 
  { "out of bounds " } 
}; 

#endif 
