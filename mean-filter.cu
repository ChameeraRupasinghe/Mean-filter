#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <cuda.h>

//Parallel (GPU) function for mean filter
__global__ void meanFilter(int* imageArray, int* filteredArray, int img_height, int img_width, int window_width){
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    int y = blockIdx.y*blockDim.y + threadIdx.y;
 
    if(x >= window_width/2 && x< (img_width- window_width/2) && y >= window_width/2 && y<(img_height-window_width/2)){
       int sum = 0;
          for(int wy = 0 - window_width/2; wy <= window_width/2 ; wy++){
             for(int wx = 0 - window_width/2; wx <= window_width/2 ; wx++){
                sum += imageArray[img_width*(y+wy) + (x+wx)];
             }
          }
          filteredArray[img_width*y + x] = sum / (window_width*window_width);
    }   
 }


int* getImageArrayFromBMP(FILE* fptr, int* height, int* width){
    int * imageArray;
    int offset;
    long n;

    fseek(fptr, 10, SEEK_SET);
    fread(&offset, 1, 4, fptr);
    fseek(fptr, 4, SEEK_CUR);
    fread(height, 1, 4, fptr);
    fread(width, 1, 4, fptr);

    imageArray = (int *) malloc((*height)*(*width)*sizeof(int));
    fseek(fptr, offset, SEEK_SET);
    for(int i=0; i < (*height)*(*width); i++){
       n = fread(&imageArray[i], 1, 1, fptr);
       if (n!=1) {
          printf("File not found");
      }
    }
    return imageArray;
}

//sequential (CPU) function for mean filter
void meanFilter_h(int* sourceArray, int* filteredArray, int height, int width, int window_width){

    for(int y = window_width/2; y < height - (window_width/2); y++){
       for(int x = window_width/2; x < width - (window_width/2); x++){
          int sum = 0;
          for(int wy = 0 - window_width/2; wy <= window_width/2 ; wy++){
             for(int wx = 0 - window_width/2; wx <= window_width/2 ; wx++){
                sum += sourceArray[width*(y+wy) + (x+wx)];
             }
          }
          filteredArray[width*y + x] = sum / (window_width*window_width);
       }
    }
}

int main(int argc,char **argv){

    int *sourceImage, *filteredImage;
    int height,width;
    int window_width = 5;

    printf("Mean filter program\n");
    FILE *fptr;
    fptr = fopen("puppy_1280.bmp", "r");
    if(fptr == NULL)
    {
       printf("Error!");   
       exit(1);             
    }

    sourceImage = getImageArrayFromBMP(fptr, &height, &width);
    fclose(fptr);

    filteredImage = (int *) malloc((height)*(width)*sizeof(int));

    clock_t start_h=clock();
    meanFilter_h(sourceImage, filteredImage, height, width, window_width);
    clock_t end_h = clock();
    double time_h = (double)(end_h - start_h)/CLOCKS_PER_SEC;

    int* d_image;
    int* d_filteredImage;
    int* h_filteredImage;

    h_filteredImage = (int *) malloc(height*width*sizeof(int));
    for(int i = 0; i< height*width; i++){
        h_filteredImage[i] = 0;
    }  

    cudaMalloc((void **)&d_image, height*width*sizeof(int));    
    cudaMalloc((void **)&d_filteredImage, height*width*sizeof(int));
    cudaMemcpy(d_image, sourceImage, height*width*sizeof(int), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(32,32);
    dim3 numBlocks(1 + ((width-1)/threadsPerBlock.x), 1 + ((height-1)/threadsPerBlock.y));

    clock_t start_d=clock();
    meanFilter<<<numBlocks, threadsPerBlock>>>(d_image, d_filteredImage, height, width, window_width);
    cudaThreadSynchronize();
    clock_t end_d = clock();
    double time_d = (double)(end_d - start_d)/CLOCKS_PER_SEC;


    cudaMemcpy(h_filteredImage, d_filteredImage, height*width*sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d_image);
    cudaFree(d_filteredImage);

    printf("For %dx%d image and window size %d, CPU time %f is GPU time %f\n", height, width, window_width, time_h, time_d);

    free(filteredImage);
    free(sourceImage);
    free(h_filteredImage);    
    return 0;
}