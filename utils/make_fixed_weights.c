#include <stdlib.h>
#include <stdio.h>


unsigned long float_to_fixed(float f[], int par)
{
   // packs 'par' floating point values into a 32 bit array as fixed point numbers

   unsigned long bits;
   int shift;
   unsigned long mask;
   long value;
   int p;

   shift = 16/par;

   if (par == 1) mask = 0xFFFFFFFF;
   else mask = (1 << (shift * 2)) - 1;

   bits = 0;

   for (p=0; p<par; p++) {
      value = f[p] * (1 << shift);
      value &= mask;
      bits |= value << (shift * 2 * p);
   }

   return bits;
} 


int main(int argument_count, char *arguments[])
{
   int r;
   int w;
   int p;
   int par;
   int width;
   int count;
   unsigned long bits;
   float f[32];
   FILE *binary_floats;
   
   if (argument_count != 4) {
      fprintf(stderr, "Usage: make_fixed_weights <binary_floats> <words_per_32_bits> <bus_width> \n");
      return 1;
   }

   binary_floats = fopen(arguments[1], "r");

   if (NULL == binary_floats) {
      fprintf(stderr, "Unable to open file '%s' for reading \n", arguments[1]);
      perror("make_fixed_weights");
      return 1;
   }

   par = atoi(arguments[2]);

   if ((par<1) || (32<par)) {
      fprintf(stderr, "words_per_32_bits must be between 1 and 32.  Value found was: %d \n", par);
      return 1;
   }
  
   width = atoi(arguments[3]);

   if ((width<1) || (16<width)) {
      fprintf(stderr, "width must be between 1 and 16.  Value found was: %d \n", width);
      return 1;
   }

   count = 0;
   while (!feof(binary_floats)) {
      for (w=0; w<width; w++) { 
         r = fread(f, 4, par, binary_floats);
         if ((r==0) && (w==0)) break;
         count += r;
         for (p=r; p<par; p++) f[p] = 0.0;
         bits = float_to_fixed(f, par);
         printf("%08lx", bits);
      }
      if (w>0) printf("\n");
   }
   fclose(binary_floats);

   fprintf(stderr, "Processed %d values \n", count);
   return 0; 
}

