#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <cuda.h>

int width, height;

int main(int argc,char **argv)
{
   printf("Mean filter program\n");
   FILE *fptr;
   fptr = fopen("puppy.bmp", "r");
   if(fptr == NULL)
   {
      printf("Error!");   
      exit(1);             
   }   
   printf("end\n");
   return 0;
}