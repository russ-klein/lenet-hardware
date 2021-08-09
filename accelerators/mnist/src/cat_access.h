
#ifndef CAT_ACCESS_INCLUDED
#define CAT_ACCESS_INCLUDED

typedef float cat_memory_type;

cat_memory_type get_cat_value(cat_memory_type *memory, int offset);
void set_cat_value(cat_memory_type *memory, int offset, cat_memory_type value);
void copy_to_cat(cat_memory_type *memory, int offset, float *source, int size);
void copy_from_cat(cat_memory_type *memory, float *dest, int offset, int size);

#endif
