
hw_cat_type read_cat_memory_as_fixed(int offset);
void write_cat_memory_as_fixed(int offset, hw_cat_type value);
void load_cat_memory(cat_memory_type *memory);
int record_differences(float *sw_memory, cat_memory_type *hw_memory, int size);



void conv2d_hw(
               int image_offset,
               int weight_offset,
               int output_offset,
               int num_input_images,
               int num_output_images,
               int height,
               int width,
               int filter_height,
               int filter_width,
               int relu);

void dense_hw(
              int image_offset,
              int weight_offset,
              int output_offset,
              int num_input_images,
              int num_output_images);
