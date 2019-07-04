#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <cuda.h>

int** getArrayFromBMP(FILE* fptr){
   int** imageArray;
   int height, width, offset;
   long n;

   fseek(fptr, 10, SEEK_SET);
   fread(&offset, 1, 4, fptr);
   fseek(fptr, 4, SEEK_CUR);
   fread(&height, 1, 4, fptr);
   fread(&width, 1, 4, fptr);

   imageArray = (int**) malloc(height*sizeof(int*));
   for (int i=0; i<height; i++){
      imageArray[i] = (int*) malloc(width*sizeof(int));
   }

   fseek(fptr, offset, SEEK_SET);
   for (int y=height-1; y>=0; y--) {
      for (int x=0; x<width; x++) {
          n=fread(&imageArray[y][x], 1, 1, fptr);
          if (n!=1) {
              printf("File not found");
          }
      }
   }

   for(int i=0; i<height; i++){
      for(int j=0; j<width; j++){
         printf("%d ", imageArray[i][j]);
      }
      printf("\n");
   }

   return imageArray;
}

int main(int argc,char **argv)
{
   printf("Mean filter program\n");
   FILE *fptr;
   fptr = fopen("pup.bmp", "r");
   if(fptr == NULL)
   {
      printf("Error!");   
      exit(1);             
   }

   int** imageArray = getArrayFromBMP(fptr);

   fclose(fptr);
   printf("end\n");
   return 0;
}