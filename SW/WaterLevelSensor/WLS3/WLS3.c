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
      - sensor wire connected to capacitive oscillator
*/
//======================================================================

// I/O pins
// PIN 1 : VDD +5V
// PIN 2 : LED           RA5
// PIN 3 : CPS3          RA4          IN ANA
// PIN 4 : MCLR          RA3          IN DIG
// PIN 5 :               RA2
// PIN 6 :               RA1
// PIN 7 : TX            RA0          OUT DIG
// PIN 8 : VSS GND


// GENERIC
#define TRUE            1
#define FALSE           0
#define ON              1
#define OFF             0
#define IN              1
#define OUT             0
#define STX             2
#define LED             LATA.LATA5


// STATIC VARIABLES
static unsigned long tmr1_overflow;
static unsigned long frequency;
static unsigned long pulse_count = 0;


// ISR
void interrupt(void)
{
    // TMR1 interrupt
    if (PIR1.TMR1IF)
    {
        tmr1_overflow++;
        PIR1.TMR1IF = FALSE;
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

      // Start of transmission
      sendchar(STX);
      // Highest nibble is sent first
      for (nibble = 0; nibble < 8; nibble++)
      {
          sendchar(hexnr[(hexnumber&0xF0000000)>>28]);
          hexnumber<<=4;
      }
 }

// Measure comparator oscillator frequency
unsigned long measure_frequency()
{ 
    T1CON.TMR1ON = 0;
    tmr1_overflow = 0;
    TMR1L = 0;
    TMR1H = 0;
    T1CON.TMR1ON = 1;
    Delay_ms(1000);
    T1CON.TMR1ON = 0;
    pulse_count = (tmr1_overflow << 16) + (TMR1H << 8) + TMR1L;
    return pulse_count;
}

// Initialize all peripherals
void init()
{
    // oscillator
    OSCCON = 0x70;     // 4x PLL disabled

    // GPIO init
    // PORT A
    TRISA.TRISA0 = OUT;  // PIN 7  TX
    PORTA.RA0 = 1;
    TRISA.TRISA1 = OUT;  // PIN 6
    PORTA.RA1 = 1;
    TRISA.TRISA2 = OUT;  // PIN 5
    PORTA.RA2 = 1;
    TRISA.TRISA3 = IN;   // PIN 4  MCLR
    PORTA.RA3 = 1;
    TRISA.TRISA4 = IN;   // PIN 3  CPS3
    PORTA.RA4 = 1;
    TRISA.TRISA5 = OUT;  // PIN 2  LED
    PORTA.RA5 = 0;
    LED = OFF;

    // Analog input pins
    ANSELA.ANSA4 = 1;     // PIN 3 CPS3

    // Capacitive sensor
    CPSCON0.CPSRM = 0;    // Low range - internal voltage reference
    CPSCON0.CPSRNG0 = 0;  // oscillator medium range   [ 12 kHz  dry]
    CPSCON0.CPSRNG1 = 1;  // oscillator medium range
    /*
    CPSCON0.CPSRNG0 = 1;  // oscillator high range   [ 57 kHz  dry]
    CPSCON0.CPSRNG1 = 1;  // oscillator high range
    */
    CPSCON0.CPSON = 1;
    CPSCON1.CPSCH0 = 1;   // Channel 3 = PIN 3
    CPSCON1.CPSCH1 = 1;   // Channel 3 = PIN 3

    // Timer1 - clocked by capacitive sensor oscillator
    T1CON.TMR1CS0 = 1;    // TMR1 clock = capacitive oscillator
    T1CON.TMR1CS1 = 1;    // TMR1 clock = capacitive oscillator
    PIE1.TMR1IE = 1;      // Enable TMR1 interrupt

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
       LED = ON;
       sendhex(frequency);
       LED = OFF;
    }
}