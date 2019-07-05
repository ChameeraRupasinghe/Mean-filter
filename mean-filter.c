#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int height, width;

//sequential code
void meanFilter_h(int** sourceMat, int** filteredMat, int window_width){
   for(int y = window_width/2; y < height - (window_width/2); y++){
      for(int x = window_width/2; x < width - (window_width/2); x++){
         int sum = 0;
         for(int wy = y-window_width/2; wy <= y+window_width/2; wy++){
            for(int wx = x-window_width/2; wx <= x+window_width/2; wx++){
               sum += sourceMat[wy][wx];
            }
         }
         filteredMat[y][x] = sum / (window_width*window_width);
      }
   }
}

int** getArrayFromBMP(FILE* fptr){
   int** imageArray;
   int offset;
   long n;

   fseek(fptr, 10, SEEK_SET);
   fread(&offset, 1, 4, fptr);
   fseek(fptr, 4, SEEK_CUR);
   fread(&height, 1, 4, fptr);
   fread(&width, 1, 4, fptr);

   printf("offset %d height %d width %d \n", offset, height, width);

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
   return imageArray;
}

int main(int argc,char **argv)
{
   printf("Mean filter sequential program\n");
   FILE *fptr;
   fptr = fopen("p2.bmp", "r");
   if(fptr == NULL)
   {
      printf("Error!");   
      exit(1);             
   }
   int** imageArray = getArrayFromBMP(fptr);
   int** filterArray;
   filterArray = (int**) malloc(height*sizeof(int*));
   for (int i=0; i<height; i++){
      filterArray[i] = (int*) malloc(width*sizeof(int));
   }
   fclose(fptr);
   meanFilter_h(imageArray, filterArray, 3);

   printf("input mat\n");
   for(int i = 0; i<height; i++){
      for(int j = 0; j<width; j++){
         printf("%d ", imageArray[i][j]);
      }
      printf("\n");
   }

   printf("output mat\n");
   for(int i = 0; i<height; i++){
      for(int j = 0; j<width; j++){
         printf("%d ", filterArray[i][j]);
      }
      printf("\n");
   }

   printf("end\n");
   return 0;
}