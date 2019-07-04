#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct
{
    unsigned char val;
} PIXEL;

int width, height;

PIXEL **createArray()
{
    PIXEL **array;
    array = (PIXEL **)malloc(height * sizeof(PIXEL *));
    for (int i = 0; i < height; i++)
    {
        array[i] = (PIXEL *)malloc(width * sizeof(PIXEL));
    }
    return array;
}

int setHeightWidth(FILE *fptr)
{
    fseek(fptr, 18, SEEK_SET);
    fread(&height, 1, 4, fptr);
    fread(&width, 1, 4, fptr);
    return 0;
}

int bitmapToArray(FILE *fptr, PIXEL **array)
{
    int offset;
    long n;
    fseek(fptr, 10, SEEK_SET);
    fread(&offset, 1, 4, fptr);
    fseek(fptr, offset, SEEK_SET);

    for (int y = height - 1; y >= 0; y--)
    {
        for (int x = 0; x < width; x++)
        {
            n = fread(&array[y][x], 1, 1, fptr);
            if (n != 1)
            {
                return 1;
            }
        }
    }
    printf("offset is %d \n", offset);
    return 0;
}

int main(int argc, char **argv)
{
    printf("Mean filter program\n");
    FILE *fptr;

    //give the file name
    fptr = fopen("puppy.bmp", "r");    

    if (fptr == NULL)
    {
        printf("Error!");
        exit(1);
    }

    setHeightWidth(fptr);
    PIXEL **imageArray = createArray();
    bitmapToArray(fptr, imageArray);

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            printf("%x ", imageArray[i][j].val);
        }
        printf("\n");
    }

    fclose(fptr);

    printf("end\n");
    return 0;
}