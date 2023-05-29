//=====================================================================
/*
 * Project name:  Watersensor
    Capacitive water level sensor
 * Copyright:
     (c) BW, 2022.
 * Configuration:
     MCU:             PIC16F1824
     Oscillator:      Internal, 32.0000 MHz
   * NOTES:
*/
//======================================================================

/* IOs

    // INPUT    ===> The PORTA pins can be configured to operate as Interrupt-on-Change (IOC) pins.
    // p 141 datasheet  --- 13.2   Individual Pin Configuration  --> PORT A falling edge = PB press
    PB_METER_WATER          RA3 = pin 4
    PB_CAL_WET                     RA5 = pin 2
    PB_CAL_DRY                     RA4 = pin 3
    SENSOR_IN                       RC1 = pin 9           // IN AN comparator 2
    BATTERY_IN                      RC0 = pin 10        // ADC4 
  
    // OUTPUT
    SENSOR_POWER_OUT                      -------------- >LATA.LATA2
    METER_PWM_OUT           RC5 = pin 5  PWM1
    LED_CAL_OUT
    LED_RED_OUT   
    LED_GREEN_OUT
    DEBUG_RS_OUT                RA0 = pin 13
    
    COMP2_OUT                       RC4 = pin 6
*/

// INPUTS
#define PB_METER_WATER              PORTA.RA3   // pin 4
#define PB_CAL_DRY                  PORTA.RA5   // pin 2
#define PB_CAL_WET                  PORTA.RA4   // pin 3
#define ADC_BATTERY                 1           // RA1 ADC1 pin 12
#define SENSOR_IN                   PORTC.RC1   // pin 9

// OUTPUTS
#define DEBUG_RS_OUT               PORTA.RA0    // pin 13
#define LED_RED_OUT                LATA.LATA2   // pin 11
#define LED_GREEN_OUT              LATC.LATC3   // pin 7
#define LED_CAL_OUT                LATC.LATC2   // pin 8
#define SENSOR_POWER_OUT           LATC.LATC4   // pin 6
#define METER_PWM_OUT              PORTC.RC5    // pin 5  PWM1

// EEPROM locations
#define CURRENT_WATER_VALUE      0x00
#define CAL_DRY_VALUE            0x04
#define CAL_WET_VALUE            0x08


// TIMEOUTS
#define LED_ERROR_BLINK_INTERVAL           1000  // * 512 micros
#define TIMEOUT_3_SECONDS                  6000 // * 512 micros
#define TIMEOUT_5_SECONDS                 10000 // * 512 micros


// BATTERY VOLTAGE
// 78L05 min 7.2V input 
// 9V  ---> diode ---> 8.4V ---47K---ADC----68K---- Gnd 
// 7.2 V / (68+47) * 68 =  4.26V  with ADC 0..255 = 0...5V : 4.43V = 217.
#define BATTERY_CRITICAL_VALUE  217

/* 
STATUS LED:
    - GREEN STEADY              all OK
    - RED STEADY                low battery
    - RED BLINKING              sensor error
    - YELLOW BLINKING           calibration error
*/

// GENERIC
#define TRUE            1
#define FALSE           0
#define ON              1
#define OFF             0
#define IN              1
#define OUT             0

#define GREEN           4
#define RED             5
#define YELLOW          6

// STATIC VARIABLES
static unsigned long actual_nr_pulses;
static unsigned long new_nr_pulses;
static unsigned long  cal_wet_pulses;
static unsigned long cal_dry_pulses;
static unsigned long current_nr_pulses;
static unsigned long cal_average;
static unsigned int LED_error_blink_cnt;
static unsigned int sleep_timeout;
static unsigned char sleep_flag;
static unsigned long old_water_value;
static unsigned long new_water_value;
static unsigned int pb_cal_timeout;
static unsigned char battery_value;
static unsigned char LED_COLOR;
static unsigned char pb_cal_flag;
static unsigned long old_EEPROM_value;
static unsigned char cal_cnt;


// ISR
void interrupt(void)
{
    // TIMER0 interrupt
    if (INTCON.TMR0IF)
    {
        if (sleep_timeout)
        {
            sleep_timeout--;
            sleep_flag = FALSE;
            if (!sleep_timeout)
            {
                sleep_flag = TRUE;
            }
        }
        
        if (pb_cal_timeout)
        {
            pb_cal_timeout--;
            pb_cal_flag = FALSE;
            if (! pb_cal_timeout)
            {
                pb_cal_flag = TRUE;
            }
        }
        
        if (LED_error_blink_cnt)
        {
            LED_error_blink_cnt--;
            if (!LED_error_blink_cnt)
            {
                if (LED_COLOR == RED)
                {
                    LED_RED_OUT = !LED_RED_OUT;
                    LED_GREEN_OUT = OFF;
                }
                else if (LED_COLOR == GREEN)
                {
                    LED_RED_OUT = OFF;
                    LED_GREEN_OUT = !LED_GREEN_OUT;
                }
                else if (LED_COLOR == YELLOW)
                {
                    LED_RED_OUT = !LED_RED_OUT;
                    LED_GREEN_OUT = LED_RED_OUT;
                }
                LED_error_blink_cnt = LED_ERROR_BLINK_INTERVAL;
            }
        }
       // reset TIMER0 interrupt flag
        INTCON.TMR0IF = FALSE;
    }
    
    // SENSOR PULSE COMPARATOR
    if (PIR2.C2IF)
    {
        actual_nr_pulses++;
        PIR2.C2IF = FALSE;
    }
    
    // Interrupt On Change PORTA pins
    if (IOCAF.IOCAF3) { IOCAF.IOCAF3 = FALSE;}
    if (IOCAF.IOCAF4) { IOCAF.IOCAF4 = FALSE;}
    if (IOCAF.IOCAF5) { IOCAF.IOCAF5 = FALSE;}
    
 }
 
// Shoz meter value
void show_meter(unsigned char value)
{
     PWM1_Set_Duty(value);
}

 // De-activate ERROR LED
 void NO_ERROR()
 {
     LED_error_blink_cnt = 0;
     LED_RED_OUT = OFF;
     LED_GREEN_OUT = OFF;
 }

// ERROR LED status GREEN / RED / YELLOW
 void ERROR_LED(unsigned char color, unsigned char blink)
 {
     if (color == GREEN)
     {
         LED_GREEN_OUT = ON;
         LED_RED_OUT = OFF;
     }
     else if (color == RED)
     {
         LED_GREEN_OUT = OFF;
         LED_RED_OUT = ON;
     }
     else if (color == YELLOW)
     {
          LED_GREEN_OUT = ON;
          LED_RED_OUT = ON;
    }
    else
    {
          LED_GREEN_OUT = OFF;
          LED_RED_OUT = OFF;
    }
    LED_COLOR = COLOR;
    if (blink && !LED_error_blink_cnt)
    {
        LED_error_blink_cnt = LED_ERROR_BLINK_INTERVAL;
    }
 }

 
// EEPROM access  ---> unsigned long ?
void EEPROM_set(unsigned char address, unsigned long new_EEPROM_value)
{
    old_EEPROM_value = EEPROM_read(address);
    if (new_EEPROM_value != old_EEPROM_value)
    {
        EEPROM_Write(address, new_EEPROM_value & 0x000000FF); 
        EEPROM_Write(address+1, (new_EEPROM_value & 0x0000FF00) >> 8); 
        EEPROM_Write(address+2, (new_EEPROM_value & 0x00FF0000) >> 16); 
        EEPROM_Write(address+3, (new_EEPROM_value & 0xFF000000) >> 24); 
    }
}

unsigned long EEPROM_get(unsigned char address)
{
    return EEPROM_Read(address) | ( EEPROM_Read(address+1) << 8) | ( EEPROM_Read(address+2) << 16) |( EEPROM_Read(address+3) << 24);
}

// Abs value
unsigned long abs_value(unsigned long a, unsigned long b)
{
    if (a > b)
    {
      return (a-b);
    }
    else
    {
      return (b-a);
    }
}


// Sensor measurement
unsigned long measure_sensor()
{
    // Return 10 bit PWM result for meter
    actual_nr_pulses = 0;
    Delay_ms(1000);
    new_nr_pulses = actual_nr_pulses;
    cal_wet_pulses = EEPROM_Read(CAL_WET_VALUE);
    cal_dry_pulses = EEPROM_Read(CAL_DRY_VALUE);
    if (cal_dry_pulses == 0xFFFFFFFF) { ERROR_LED(YELLOW, TRUE); return 0; }
    if (cal_wet_pulses == 0xFFFFFFFF) { ERROR_LED(YELLOW, TRUE); return 0; }
    if (abs_value(cal_dry_pulses, cal_wet_pulses) < 100) {ERROR_LED(YELLOW, TRUE); return 0; }
    if (cal_dry_pulses < cal_wet_pulses) {ERROR_LED(YELLOW, TRUE); return 0; }
    // Convert nr_pulses to 0...1024
    if (!new_nr_pulses) { ERROR_LED(RED, TRUE); return 0; } 
    NO_ERROR();
    if (new_nr_pulses < cal_wet_pulses) new_nr_pulses = cal_wet_pulses;
    if (new_nr_pulses > cal_dry_pulses) new_nr_pulses = cal_dry_pulses;
    
    current_nr_pulses = ((new_nr_pulses - cal_wet_pulses) << 10) / (cal_dry_pulses - cal_wet_pulses);
    
    // Invert current value ... ??? Higher freq = smaller C = dry 
    
    return current_nr_pulses;
}
   
 
 // Reset sleep timeout counter
 void reset_sleep()
 {
    sleep_timeout = TIMEOUT_3_SECONDS;
    sleep_flag = FALSE;
 }
 
 // Prepare for sleep
 void sleep_entry()
 {
     SENSOR_POWER_OUT = OFF;
     NO_ERROR();
     sleep_timeout = 0;
     pb_cal_timeout = 0;
     LED_error_blink_cnt = 0;
 }
 
 // Exit from sleep
 void sleep_exit()
 {
     SENSOR_POWER_OUT = ON;
     NO_ERROR();
 }
 

 // Initialize all peripherals
 void init()
 {
    // oscillator
    OSCCON = 0xF0;
    
    // GPIO init
    // PORT A
    TRISA.TRISA0 = OUT;  // PIN 13
    PORTA.RA0 = 1;
    TRISA.TRISA1 = OUT;   // PIN 12
    PORTA.RA1 = 1;
    TRISA.TRISA2 = OUT;  // PIN 11
    PORTA.RA2 = 1;
    TRISA.TRISA3 = OUT;  // PIN 4
    PORTA.RA3 = 1;
    TRISA.TRISA4 = IN;   // PIN 3
    PORTA.RA4 = 1;
    TRISA.TRISA5 = OUT;  // PIN 2
    PORTA.RA5 = 1;

    // PORT C
    TRISC.TRISC0 = IN;  // PIN 10 battery in
    PORTC.RC0 = 1;
    TRISC.TRISC1 = IN;  // PIN 9 = comparator in
    PORTC.RC1 = 1;
    TRISC.TRISC2 = OUT;  // PIN 8 
    PORTC.RC2 = 1;
    TRISC.TRISC3 = OUT;  // PIN 7
    PORTC.RC3 = 1;
    TRISC.TRISC4 = OUT; // PIN 6 
    PORTC.RC4 = 1;
    TRISC.TRISC5 = OUT; // PIN 5  PWM1
    PORTC.RC5 = 1;

    // Analog input pins
    ANSELC.ANSC0 = 1;     // battery in
    ANSELC.ANSC1 = 1;     // comparator in

    
    // PORTA Interrupt On Change
    INTCON. IOCIE = 1;
    IOCAN.IOCAN3 = 1;                 // Falling edge PORTA.3
    IOCAN.IOCAN4 = 1;                 // Falling edge PORTA.4
    IOCAN.IOCAN5 = 1;                 // Falling edge PORTA.5
 
     // ADC input
    ADCON0.ADON = 1;            //  ADC on
    ADCON1.ADFM = 1;            // right justified
    ADCON1.ADCS0 = 0;           // Fosc / 64
    ADCON1.ADCS1 = 1;           // Fosc / 64
    ADCON1.ADCS2 = 1;           // Fosc / 64
    ADCON1.ADNREF = 0;          // Vref- = VSS
    ADCON1.ADPREF0 = 0;         // Vref+ = VDD
    ADCON1.ADPREF1 = 0;         // Vref+ = VDD

    // Comparator 2 init
    CM2CON0.C2POL = 0;      // comp output polarity is not inverted
    CM2CON0.C2OE = 1;       // comp output enabled
    CM2CON0.C2SP = 1;       // high speed
    CM2CON0.C2ON = 1;       // comp is enabled
    CM2CON0.C2HYS = 1;      // hysteresis enabled
    CM2CON0.C2SYNC = 0;     // comp output synchronous with timer 1

    CM2CON1.C2NCH0 = 1;     // C12IN1-
    CM2CON1.C2NCH1 = 0;     // C12IN1-
    CM2CON1.C2PCH0 = 0;     // comparator + Fixed Voltage Reference
    CM2CON1.C2PCH1 = 1;     // comparator + Fixed Voltage Reference
    CM2CON1.C2INTP = 1;       // comparator interrupt on positive edge 
    CM2CON1.C2INTN = 0;
    PIE2.C2IE = 1;                      // comparator 2 interrupt enabled
    
    // Fixed Voltage Reference
    FVRCON.FVREN = 1;          // Fixed Voltage Reference Enable bit
    FVRCON.CDAFVR0 = 0;        // Fixed Voltage Reference Peripheral output is 2x (2.048V)
    FVRCON.CDAFVR1 = 1;        // Fixed Voltage Reference Peripheral output is 2x (2.048V)

    // Timer0 timebase  32 MHz/4 --> PS/16 --> overflow/256 = 2 kHz  ==> 512 micros
    OPTION_REG.PS0 = 1;
    OPTION_REG.PS1 = 1;
    OPTION_REG.PS2 = 0;          // Prescaler / 16
    OPTION_REG.PSA = 0;
    OPTION_REG.TMR0CS = 0;       // FOSC / 4   --> 8 MHz
    INTCON.TMR0IE = 1;           // timer0 interrupt enable

    // PWM1 - RC5 - pin5
    PWM1_Init(250000);           // 250 kHz
    PWM1_Set_Duty(0);
    PWM1_Start();

    // Global Interrupt Enable
    INTCON.GIE = 1;
    
    // Variables
    reset_sleep();
 }
 
 
//===================================
//
// MAIN
//
void main()
{

    // Initialize everything
    init();

    // Idle loop
    while(1)
    {
        //
        // ======= PUSHBUTTONS
        //
        // PB_METER_WATER
        if (!PB_METER_WATER && PB_CAL_DRY && PB_CAL_WET)
        {
            reset_sleep();
            
            old_water_value = EEPROM_get (CURRENT_WATER_VALUE);
            show_meter (old_water_value);
            
            battery_value = ADC_Read((ADC_BATTERY) >> 2);
            if (battery_value < BATTERY_CRITICAL_VALUE)  ERROR_LED(RED, FALSE);
            else ERROR_LED (GREEN, FALSE);
         
            // Measure during  1 second while the previous value is shown
            new_water_value = measure_sensor();  
            EEPROM_set (CURRENT_WATER_VALUE, new_water_value);
            show_meter (new_water_value);
        }

         
        // PB_CAL_DRY / PB_CAL_WET
        if ( (PB_METER_WATER &&  !PB_CAL_DRY && PB_CAL_WET) || 
             (PB_METER_WATER && PB_CAL_DRY && !PB_CAL_WET))
        {
            reset_sleep();
            
            if  (pb_cal_flag)
            {
                // Press CAL button during 5 seconds
                // After 5 seconds: CAL_LED ON during 4 seconds calibration
                // measure 4 times and average
                // store in EEPROM
                // CAL_LED OFF ==> calibration finished
                LED_CAL_OUT = ON;
                cal_average = 0;
                for (cal_cnt = 0; cal_cnt < 4; cal_cnt++)
                {
                    cal_average +=  measure_sensor(); 
                }
                cal_average >>= 2;

                 if (!PB_CAL_DRY)  EEPROM_write (CAL_DRY_VALUE, cal_average);
                 else if (!PB_CAL_WET)  EEPROM_write (CAL_WET_VALUE, cal_average);
                 LED_CAL_OUT = OFF;
                 pb_cal_timeout = TIMEOUT_5_SECONDS;
                 pb_cal_flag = FALSE;
           }
        }
        else
        {
            pb_cal_timeout = TIMEOUT_5_SECONDS;
            pb_cal_flag = FALSE;
        }


        //
        // SLEEP
        //
        if (sleep_flag)
        {
            sleep_entry();
            asm SLEEP;
            sleep_exit();
         }
    }
}