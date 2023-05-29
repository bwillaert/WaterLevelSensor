#include <stdio.h>
#include <stdlib.h>

typedef int bool;
#define TRUE 1
#define FALSE 0

const int LUT[256] = {100,99,98,96,95,94,93,91,90,89,88,87,86,85,84,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65,64,63,63,62,61,60,59,58,57,56,56,55,54,53,52,52,51,50,49,49,48,47,46,46,45,44,44,43,42,42,41,40,40,39,38,38,37,36,36,35,35,34,34,33,32,32,31,31,30,30,29,29,28,28,27,27,26,26,25,25,24,24,24,23,23,22,22,21,21,21,20,20,20,19,19,18,18,18,17,17,17,16,16,16,15,15,15,14,14,14,14,13,13,13,12,12,12,12,11,11,11,11,10,10,10,10,10,9,9,9,9,8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,6,6,5,5,5,5,5,5,5,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};


unsigned long read_cal(bool wet)
{
    char* filename = "";
    FILE *fptr;
    unsigned long cal_value;
    if (wet) filename = "cal_wet";
    else filename = "cal_dry";
    
    if ((fptr = fopen(filename,"r")) == NULL){
       printf("Error! opening file");
       return 0;
 
   }

   fscanf(fptr,"%lu", &cal_value);
   fclose(fptr); 
   return cal_value;
    
}



int main(int argc, char **argv)
{
    if (argc != 2) {
        printf ("Enter frequency parameter\n");
        return 0;
    }
   int frequency = atoi(argv[1]);
   printf("input frequency: %d\n", frequency);
        
    unsigned long cal_wet = read_cal (TRUE);
    unsigned long cal_dry = read_cal (FALSE);
    
    // Sanity checks
    if (!cal_wet || !cal_dry){
        printf("Calibration not OK\n");
        return 0;
    }
    if (cal_wet >= cal_dry){
         printf("Calibration not OK\n");
        return 0;
    }
    if (frequency > cal_dry) frequency = cal_dry;
    if (frequency < cal_wet) frequency = cal_wet;
    
    printf("cal-wet = %lu - cal_dry = %lu\n", cal_wet, cal_dry);
    
  
    unsigned long freq_step = (cal_dry - cal_wet) >> 8;
    int LUT_index = 0;
    for (LUT_index = 0; LUT_index < 255; ++LUT_index){
        cal_wet += freq_step;
        if (frequency < cal_wet){
            break;
        }
    }
    
    
    printf("LUT_index = %d Percentage = %d\n", LUT_index, LUT[LUT_index]);
    
    
    
  
}