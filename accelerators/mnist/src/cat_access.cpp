
#include "defines.h"
#include "cat_access.h"

// catapult memory access routines


//=====Weight/scratchpad memory==============//

// everything that reads and writes the weight/scratchpad memory should be of the type "cat_memory_type"
// and should use the routines set|get_cat_value() and copy_to|from_cat() as the type will be differnt 
// ac_fixed or native float types at different times
// this keeps all the conversions in one place

#ifdef FIXED_POINT
#ifdef HOST
hw_cat_type get_cat_value(cat_memory_type *memory, int offset)
{
    hw_cat_type value;
    unsigned long index = offset / STRIDE;

    value.set_slc(0, memory[index].slc<WORD_SIZE>((offset % STRIDE) * WORD_SIZE));
    return value;
}
#else // not HOST (i.e. EMBEDDED)

cat_memory_type get_cat_value(cat_memory_type *memory, int offset)
{
    unsigned int     array_word;
    unsigned int     index = offset / (WORD_SIZE/32);
    unsigned int     mask = (1 << WORD_SIZE) - 1;
    unsigned long    shift = (offset % (WORD_SIZE/32)) * WORD_SIZE;
    cat_memory_type  cat_value;

    array_word = memory[index];
    cat_value = (array_word >> shift) & mask;
    return cat_value;
}

#endif
#else // not FIXED_POINT (i.e. FLOAT)   

cat_memory_type get_cat_value(cat_memory_type *memory, int offset)
{
    return memory[offset];
}

#endif


#ifdef FIXED_POINT
#ifdef HOST
void set_cat_value(cat_memory_type *memory, int offset, hw_cat_type value)
{
    unsigned long index = offset / STRIDE;
    // hw_cat_type rv;
    ac_int <WORD_SIZE, false> temp;

    // rv.set_slc(0, value.slc<WORD_SIZE>(0));
    memory[index].set_slc((offset % STRIDE) * WORD_SIZE, value.slc<WORD_SIZE>(0));
}

#else // not HOST (i.e. EMBEDDED)

void set_cat_value(cat_memory_type *memory, int offset, hw_cat_type value)
{
    unsigned int     array_word;
    unsigned int     index = offset / (WORD_SIZE/32);
    unsigned int     mask = (1 << WORD_SIZE) - 1;
    unsigned long    shift = (offset % (WORD_SIZE/32)) * WORD_SIZE;

    array_word = memory[offset/STRIDE];
    cat_value (bus_line >> shift) & mask;
    return cat_value;
}   
#endif // not HOST
#else // not FIXED_POINT (i.e. FLOAT)

void set_cat_value(cat_memory_type *memory, int offset, cat_memory_type value)
{
    memory[offset] = value;
}

#endif // not FIXED_POINT


void copy_to_cat(cat_memory_type *memory, int offset, float *source, int size)
{
    int i;

    for (i=0; i<size; i++) set_cat_value(memory, offset+i, source[i]);
}

void copy_from_cat(cat_memory_type *memory, float *dest, int offset, int size)
{
    int i;

    for (i=0; i<size; i++) dest[i] = get_cat_value(memory, offset + i).to_double();
}

