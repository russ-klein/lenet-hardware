#include <stdio.h>

#define DONE (* (unsigned long *) 0xFF000000)
#define UART_CHAR_PORT (* (volatile unsigned char *)(0x80000000))
#define UART_CHAR_READY (* (volatile unsigned char *)(0x80000018))


void _exit(int n)
{
   DONE = 1;
   while(1);
}

int _sbrk(void *addr)
{
   return -1;
}

int _write(int file, char *s, int len)
{
   int n=0;

   while (n<len) {
      UART_CHAR_PORT = *s++;
      n++;
   }
   return len;
}

int _read(int file, char *s, int len)
{
   int n;
   int ready;

   while (n<len) { 
      do {
         ready = UART_CHAR_READY;
      } while (ready == 0);
      *s++ = UART_CHAR_PORT;
      n++;
   }
}
   
int _close(int fd)
{
   return 0;
}

int _lseek(int fd, int off, int whence)
{
   return -1;
}


int _fstat(int fd, void *buf)
{
   return(1);
}

int _isatty(int fd)
{
   return(0);
}

int SystemInit()
{
   return(0);
}

void _interrupt_handler()
{
    return;
}

void _fast_interrupt_handler()
{
    return;
}
