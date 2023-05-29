// C library headers
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

// Linux headers
#include <fcntl.h> // Contains file controls like O_RDWR
#include <errno.h> // Error integer and strerror() function
#include <termios.h> // Contains POSIX terminal control definitions
#include <unistd.h> // write(), read(), close()
#include <curses.h>


#define SERIAL_PORT_DEV "/dev/ttyUSB0"
#define CHAR_ESC	27
#define CHAR_W		87
#define CHAR_D		68
#define STX		2
#define TTY_TIMEOUT	20  	// deciseconds
#define CAL_WET_FILE	"cal_wet"
#define CAL_DRY_FILE	"cal_dry"

const int LUT[256] = {100,99,98,96,95,94,93,91,90,89,88,87,86,85,84,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65,64,63,63,62,61,60,59,58,57,56,56,55,54,53,52,52,51,50,49,49,48,47,46,46,45,44,44,43,42,42,41,40,40,39,38,38,37,36,36,35,35,34,34,33,32,32,31,31,30,30,29,29,28,28,27,27,26,26,25,25,24,24,24,23,23,22,22,21,21,21,20,20,20,19,19,18,18,18,17,17,17,16,16,16,15,15,15,14,14,14,14,13,13,13,12,12,12,12,11,11,11,11,10,10,10,10,10,9,9,9,9,8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,6,6,5,5,5,5,5,5,5,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

unsigned long read_cal(bool wet)
{
    char* filename = "";
    FILE *fptr;
    unsigned long cal_value;
    if (wet) filename = "CAL_WET_FILE";
    else filename = "CAL_DRY_FILE";
    
    if ((fptr = fopen(filename,"r")) == NULL){
       printf("Error! opening file");
       return 0;
 
   }

   fscanf(fptr,"%lu", &cal_value);
   fclose(fptr); 
   return cal_value; 
}


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
           
            



int main() {
  	// Open the serial port. Change device path as needed (currently set to an standard FTDI USB-UART cable type device)
  	int serial_port = open(SERIAL_PORT_DEV, O_RDWR);
  	if (serial_port < 0) {
  		printf("Error opening serial port %s\n", SERIAL_PORT_DEV);
  		return 1;
  	}

  	// Create new termios struct, we call it 'tty' for convention
  	struct termios tty;

  	// Read in existing settings, and handle any error
  	if(tcgetattr(serial_port, &tty) != 0) {
      		printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
      		return 1;
  	}

  	tty.c_cflag &= ~PARENB; // Clear parity bit, disabling parity (most common)
  	tty.c_cflag &= ~CSTOPB; // Clear stop field, only one stop bit used in communication (most common)
  	tty.c_cflag &= ~CSIZE; // Clear all bits that set the data size 
  	tty.c_cflag |= CS8; // 8 bits per byte (most common)
  	tty.c_cflag &= ~CRTSCTS; // Disable RTS/CTS hardware flow control (most common)
  	tty.c_cflag |= CREAD | CLOCAL; // Turn on READ & ignore ctrl lines (CLOCAL = 1)

  	tty.c_lflag &= ~ICANON;
  	tty.c_lflag &= ~ECHO; 	// Disable echo
  	tty.c_lflag &= ~ECHOE; 	// Disable erasure
  	tty.c_lflag &= ~ECHONL; // Disable new-line echo
  	tty.c_lflag &= ~ISIG; 	// Disable interpretation of INTR, QUIT and SUSP
  	tty.c_iflag &= ~(IXON | IXOFF | IXANY); // Turn off s/w flow ctrl
  	tty.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL); // Disable any special handling of received bytes

  	tty.c_oflag &= ~OPOST; // Prevent special interpretation of output bytes (e.g. newline chars)
  	tty.c_oflag &= ~ONLCR; // Prevent conversion of newline to carriage return/line feed
  	// tty.c_oflag &= ~OXTABS; // Prevent conversion of tabs to spaces (NOT PRESENT ON LINUX)
  	// tty.c_oflag &= ~ONOEOT; // Prevent removal of C-d chars (0x004) in output (NOT PRESENT ON LINUX)

  	tty.c_cc[VTIME] = TTY_TIMEOUT;    // Wait for up to TTY_TIMEOUT deciseconds
  	tty.c_cc[VMIN] = 0;

  	// Set baud rate to 9600
  	cfsetispeed(&tty, B9600);
  	cfsetospeed(&tty, B9600);

  	// Save tty settings, also checking for error
  	if (tcsetattr(serial_port, TCSANOW, &tty) != 0) {
      		printf("Error %i from tcsetattr: %s\n", errno, strerror(errno));
      		//return 1;
  	}
  	
  	printf("Serial port %s OK. Reading data...\n", SERIAL_PORT_DEV);
 
	uint32_t frequency = 0;
	// Allocate memory for read buffer, set size according to your needs
	char RXchar;
	char RXbuffer[9];
	unsigned char RXbuffer_index = 0;

/*	
	// Fetch calibration data
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
    	printf("cal-wet = %lu - cal_dry = %lu\n", cal_wet, cal_dry);

*/
 
	while(true) {

	  // Normally you wouldn't do this memset() call, but since we will just receive
	  // ASCII data for this example, we'll set everything to 0 so we can
	  // call printf() easily.
	  memset(&RXbuffer, '\0', sizeof(RXbuffer));
	  RXbuffer_index = 0;

	  do {
		  // Read 1 bytes
		  int num_bytes = read(serial_port, &RXchar, sizeof(RXchar));

		  // n is the number of bytes read. n may be 0 if no bytes were received, and can also be -1 to signal an error.
		  if (num_bytes < 0) {
		      printf("Error reading: %s", strerror(errno));
		      return 1;
		  }
		  	  
		  if (num_bytes == 1){
		  	if (RXchar == STX){
		  		RXbuffer_index = 0;
		  	} else {
		  	   	RXbuffer[RXbuffer_index++] = RXchar;
		  	}		  
		  } else {
		  	printf("Received not just 1 character !!\n");
		  	RXbuffer_index = 0;
		  }
		  
	  }
	  while (RXbuffer_index < 8);

	  // Print raw ASCII data
	  printf("Read %i bytes. Received message: [%s]\n", RXbuffer_index, RXbuffer);
	  
	  // Process read buffer
	  frequency = convert_hex_string(RXbuffer);	  

	  printf("Frequency: %u\n", frequency);

	  /*
   	  // Frequency limits
    	  if (frequency > cal_dry) frequency = cal_dry;
          if (frequency < cal_wet) frequency = cal_wet;
    
    
	  unsigned long freq_step = (cal_dry - cal_wet) >> 8;
	  int LUT_index = 0;
	  for (LUT_index = 0; LUT_index < 255; ++LUT_index){
	  	cal_wet += freq_step;
		if (frequency < cal_wet){
		    break;
		}
	  }
    
    
    	  printf("LUT_index = %d Percentage = %d\n", LUT_index, LUT[LUT_index]);
*/
	  
	  
/*  
	  // Check keyboard input
	  char c=getchar();
	  if (c==CHAR_ESC) {
	  	break;
	  } else if (c==CHAR_W) {
	  	printf ("Storing wet frequency \n");
	  	store_wet(frequency);
	  } else if (c==CHAR_D) {
	  	store_dry(frequency);
	  	printf ("Storing dry frequency \n");
	  }
*/
	}

  close(serial_port);
  return 0; // success
};
