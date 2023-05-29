//=====================================================================
/*
 * Project name:  Watersensor
    Capacitive water level sensor
 * Copyright:
     (c) BW, 2022.
 * Configuration:
     MCU:             PIC12F1840
     Oscillator:      Internal, 8.0000 MHz
   * NOTES:
     180pF sensor wire + 100kOhm ==> 400 kHz
*/
//======================================================================

// I/O pins
// PIN 1 : VDD +5V
// PIN 2 :
// PIN 3 : C1IN1-        RA4          IN ANA
// PIN 4 : MCLR          RA3          IN DIG
// PIN 5 : C1OUT         RA2          OUT DIG
// PIN 6 :
// PIN 7 : TX            RA0          OUT DIG
// PIN 8 : VSS GND


// GENERIC
#define TRUE            1
#define FALSE           0
#define ON              1
#define OFF             0
#define IN              1
#define OUT             0


// STATIC VARIABLES
static unsigned long actual_nr_pulses;
static unsigned long frequency;


// ISR
void interrupt(void)
{
    // SENSOR PULSE COMPARATOR
    if (PIR2.C1IF)
    {
        actual_nr_pulses++;
        PIR2.C1IF = FALSE;
    }
}


//======================================================================
// Send a single character over RS232
//
void sendchar( char c)
{
      while (!UART1_Tx_Idle())
      {
         Delay_us(100);
      }
      UART1_Write(c);
}

//======================================================================
// Send a 16 bit number over RS232
//
void sendhex(unsigned long hexnumber)
{
      int nibble = 0;
      const char hexnr[]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

      // Highest nibble is sent first
      for (nibble = 0; nibble < 8; nibble++)
      {
          sendchar(hexnr[(hexnumber&0xF0000000)>>28]);
          hexnumber<<=4;
      }
      sendchar('\n');
}

// Measure comparator oscillator frequency
unsigned long measure_frequency()
{ 
    actual_nr_pulses = 0;
    Delay_ms(1000);
    return actual_nr_pulses;
}

// Initialize all peripherals
void init()
{
    // oscillator
    OSCCON = 0x70;     // 4x PLL disabled

    // GPIO init
    // PORT A
    TRISA.TRISA0 = OUT;  // PIN 7
    PORTA.RA0 = 1;
    TRISA.TRISA1 = OUT;  // PIN 6
    PORTA.RA1 = 1;
    TRISA.TRISA2 = OUT;  // PIN 5
    PORTA.RA2 = 1;
    TRISA.TRISA3 = IN;   // PIN 4
    PORTA.RA3 = 1;
    TRISA.TRISA4 = IN;   // PIN 3
    PORTA.RA4 = 1;
    TRISA.TRISA5 = OUT;  // PIN 2
    PORTA.RA5 = 1;

    // Analog input pins
    ANSELA.ANSA4 = 1;     // PIN 3 C1IN1-

    // Fixed Voltage Reference
    FVRCON.FVREN = 1;          // Fixed Voltage Reference Enable bit
    FVRCON.CDAFVR0 = 0;        // Fixed Voltage Reference Peripheral output is 2x (2.048V)
    FVRCON.CDAFVR1 = 1;        // Fixed Voltage Reference Peripheral output is 2x (2.048V)

    // Comparator 1 init
    CM1CON0.C1POL = 0;      // comp output polarity is not inverted
    CM1CON0.C1OE = 1;       // comp output enabled
    CM1CON0.C1SP = 1;       // high speed
    CM1CON0.C1ON = 1;       // comp is enabled
    CM1CON0.C1HYS = 1;      // hysteresis enabled
    CM1CON0.C1SYNC = 0;     // comp output synchronous with timer 1

    CM1CON1.C1NCH = 1;      // C1IN1-
    CM1CON1.C1PCH0 = 0;     // comparator + Fixed Voltage Reference
    CM1CON1.C1PCH1 = 1;     // comparator + Fixed Voltage Reference
    CM1CON1.C1INTP = 1;     // comparator interrupt on positive edge
    CM1CON1.C1INTN = 0;
    PIE2.C1IE = 1;          // comparator 1 interrupt enabled

    // Initialize UART
    UART1_Init(9600);

    // Global Interrupt Enable
    INTCON.PEIE = 1;
    INTCON.GIE = 1;
 }


//===================================
//
// MAIN
//
void main()
{
    // Initialize everything
    init();
    
    // Startup delay
    Delay_ms(1000);
    
    // Idle loop
    while(1)
    {
       // Measure oscillator frequency
       frequency = measure_frequency();

       // Send measured frequency
       sendhex(frequency);
    }
}