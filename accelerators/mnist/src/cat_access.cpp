
#include "cat_access.h"

// catapult memory access routines


//=====Weight/scratchpad memory==============//

// everything that reads and writes the weight/scratchpad memory should be of the type "cat_memory_type"
// and should use the routines set|get_cat_value() and copy_to|from_cat() as the type will be differnt 
// ac_fixed or native float types at different times
// this keeps all the conversions in one place

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

