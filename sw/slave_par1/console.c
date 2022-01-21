#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>

#define UART_CHAR_PORT ((volatile unsigned char *)(0x80000000))
#define UART_CHAR_READY ((volatile unsigned char *)(0x80000018))

#define ESC (27)

char check_for_escape(void)
{
    int flags;
    char key_pressed;

    flags = *UART_CHAR_READY;
    if (flags & 0x10) return 0;

    key_pressed = *UART_CHAR_PORT;

    if (key_pressed == ESC) return 1;
    else return 0;
}


char get_char(void)
{
    int flags;
    char key_pressed;

    do {
        flags = *UART_CHAR_READY;
    } while (flags & 0x10);

    key_pressed = *UART_CHAR_PORT;

    return key_pressed;
}


int itoa(int n, char *s, int fmt_len)
{
   char t[10];
   int neg = 0;
   int i;
   int len;
   int d;

   if (n == 0) {
      i = 0;

      t[i++] = '0';
    
      while (i<fmt_len) {
         t[i++] = ' ';
      }
   
   } else {

      if (n < 0) {
         neg = 1;
         n = -n;
      }
   
      for (i=0; n; i++) {
         t[i] = '0' + (n % 10);
         n = n / 10;
      }
   
      if (neg) t[i++] = '-';
      
      while (i<fmt_len) {
         t[i++] = ' ';
      }
   
      t[i] = 0;
   }

   len = i;

   for (i=1; i<=len; i++) {
      s[len - i] = t[i-1];
   }

   s[len] = 0;

   return len;
}


int fitoa(int n, char *s, int fmt_len, int neg)
{
   char t[10];
   int i;
   int len;
   int d;

   if (n == 0) {
      i = 0;

      t[i++] = '0';
    
      if (neg) t[i++] = '-';

      while (i<fmt_len) {
         t[i++] = ' ';
      }   

   } else {

      if (n < 0) {
         neg = 1;
         n = -n;
      }
   
      for (i=0; n; i++) {
         t[i] = '0' + (n % 10);
         n = n / 10;
      }
   
      if (neg) t[i++] = '-';
      
      while (i<fmt_len) {
         t[i++] = ' ';
      }
   
      t[i] = 0;
   }

   len = i;

   for (i=1; i<=len; i++) {
      s[len - i] = t[i-1];
   }

   s[len] = 0;

   return len;
}

int ftoa(float f, char *s, int fmt_i, int fmt_f)
{
   //char t[20];
   int i;
   int dp = 0;
   int neg = 0;

   i = f;
   f = f - i;
   if (f<0) {
      f = f * -1.0;
      neg = 1;
   }

   dp = fitoa(i, s+dp, fmt_i - fmt_f - 1, neg);

   s[dp++] = '.';
   s[dp+1] = 0;

   if (fmt_f <= 0) fmt_f = 6;

   for (i=0; i<fmt_f; i++) {
      f=f*10;
      s[dp++] = '0' + (((int)f) % 10);
   }

   s[dp++] = 0;

   return dp;
}

void console_out(char *s, ...)
{
   va_list args;
   int count;
   char number[20];
   int i;
   int n;
   float f;
   char *cp;
   char c;
   int fmt_i;
   int fmt_f;

   va_start(args, s);
   while (*s) {
      if (*s == '\n') *UART_CHAR_PORT = '\r';
      if ((s[0] == '%') && (s[1] == 'd')) {
         n = va_arg(args, int);
         itoa(n, number, 0);
         for (i=0; number[i]; i++) {
            *UART_CHAR_PORT = number[i];
         }
         s += 2;
      } 
      else if ((s[0] == '%') && (isdigit(s[1])) && (s[2] == 'd')) {
         n = va_arg(args, int);
         itoa(n, number, s[1] - '0');
         for (i=0; number[i]; i++) {
            *UART_CHAR_PORT = number[i];
         }
         s += 3;
      }
      if ((s[0] == '%') && (s[1] == 'f')) {
         f = va_arg(args, double);
         ftoa(f, number, 0, 0);
         for (i=0; number[i]; i++) {
            *UART_CHAR_PORT = number[i];
         }
         s += 2;
      } 
      if ((s[0] == '%') && (isdigit(s[1])) && (s[2] == '.') && (isdigit(s[3])) && (s[4] == 'f')) {
         f = va_arg(args, double);
         fmt_i = s[1] - '0';
         fmt_f = s[3] - '0';
         ftoa(f, number, fmt_i, fmt_f);
         for (i=0; number[i]; i++) {
            *UART_CHAR_PORT = number[i];
         }
         s += 5;
      } 
      if ((s[0] == '%') && (isdigit(s[1])) && (isdigit(s[2])) && (s[3] == '.') && (isdigit(s[4])) && (s[5] == 'f')) {
         f = va_arg(args, double);
         fmt_i = (s[1] - '0') * 10 + (s[2] - '0');
         fmt_f = s[4] - '0';
         ftoa(f, number, fmt_i, fmt_f);
         for (i=0; number[i]; i++) {
            *UART_CHAR_PORT = number[i];
         }
         s += 6;
      } 
      else if ((s[0] == '%') && (s[1] == 's')) {
         cp = va_arg(args, char *);
         while (*cp) {
            *UART_CHAR_PORT = *cp++;
         }
         s += 2;
      }        
      else if ((s[0] == '%') && (s[1] == 'c')) {
         c = (char) va_arg(args, int);
         *UART_CHAR_PORT = c;
         s += 2;
      }        
      else {
          *UART_CHAR_PORT = *s;
          s++;
      }
   }
}

