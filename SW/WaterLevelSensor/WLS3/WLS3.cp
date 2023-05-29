#line 1 "C:/Users/berna/Documents/Projects/WaterLevelSensor/WLS3/WLS3.c"
#line 37 "C:/Users/berna/Documents/Projects/WaterLevelSensor/WLS3/WLS3.c"
static unsigned long tmr1_overflow;
static unsigned long frequency;
static unsigned long pulse_count = 0;



void interrupt(void)
{

 if (PIR1.TMR1IF)
 {
 tmr1_overflow++;
 PIR1.TMR1IF =  0 ;
 }
}





void sendchar( char c)
{
 while (!UART1_Tx_Idle())
 {
 Delay_us(100);
 }
 UART1_Write(c);
}




void sendhex(unsigned long hexnumber)
{
 int nibble = 0;
 const char hexnr[]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};


 sendchar( 2 );

 for (nibble = 0; nibble < 8; nibble++)
 {
 sendchar(hexnr[(hexnumber&0xF0000000)>>28]);
 hexnumber<<=4;
 }
 }


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


void init()
{

 OSCCON = 0x70;



 TRISA.TRISA0 =  0 ;
 PORTA.RA0 = 1;
 TRISA.TRISA1 =  0 ;
 PORTA.RA1 = 1;
 TRISA.TRISA2 =  0 ;
 PORTA.RA2 = 1;
 TRISA.TRISA3 =  1 ;
 PORTA.RA3 = 1;
 TRISA.TRISA4 =  1 ;
 PORTA.RA4 = 1;
 TRISA.TRISA5 =  0 ;
 PORTA.RA5 = 1;


 ANSELA.ANSA4 = 1;


 CPSCON0.CPSRM = 0;
 CPSCON0.CPSRNG0 = 0;
 CPSCON0.CPSRNG1 = 1;
 CPSCON0.CPSON = 1;
 CPSCON1.CPSCH0 = 1;
 CPSCON1.CPSCH1 = 1;


 T1CON.TMR1CS0 = 1;
 T1CON.TMR1CS1 = 1;
 PIE1.TMR1IE = 1;


 UART1_Init(9600);


 INTCON.PEIE = 1;
 INTCON.GIE = 1;
 }






void main()
{

 init();


 Delay_ms(1000);


 while(1)
 {

 frequency = measure_frequency();


 sendhex(frequency);
 }
}
