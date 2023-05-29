#include <stdio.h>
#include <string.h>


unsigned long convert_hex_string(char* hex_string)
{
    unsigned long number = 0;
    int hex_char = 0;
    
    for (hex_char = 0; hex_char < 8; ++hex_char) {
        number <<= 4;
        switch (hex_string[hex_char]) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                number += (unsigned char)hex_string[hex_char] - 0x30;
                break;
            case 'A':
                number += 10;
                break;
           case 'B':
                number += 11;
                break;
           case 'C':
                number += 12;
                break;
           case 'D':
                number += 13;
                break;
           case 'E':
                number += 14;
                break;
           case 'F':
                number += 15;
                break;
        }
     }
    return number;
}
           
            


int main(int argc, char **argv)
{
    if (argc != 2) {
        printf ("Enter HEX parameter\n");
        return 0;
    }
    
    char* hex_string = argv[1];
    if (strlen (hex_string) !=8 ) {
        printf ("HEX string should be 8 characters long\n");
        return 0;
    }
    
    unsigned long hex_number = convert_hex_string(hex_string);
    
    printf("Number : %lu\n", hex_number);
}