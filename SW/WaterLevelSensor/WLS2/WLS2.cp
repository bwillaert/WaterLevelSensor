#line 1 "C:/Users/berna/Documents/Projects/WaterLevelSensor/WLS2/WLS2.c"
#line 36 "C:/Users/berna/Documents/Projects/WaterLevelSensor/WLS2/WLS2.c"
static unsigned long actual_nr_pulses;
static unsigned long frequency;




void interrupt(void)
{


 if (PIR2.C1IF)
 {
 actual_nr_pulses++;
 PIR2.C1IF =  0 ;
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

 sendchar('\n');
 for (nibble = 0; nibble < 8; nibble++)
 {
 sendchar(hexnr[(hexnumber&0xF0000000)>>28]);
 hexnumber<<=4;
 }
}


unsigned long measure_frequency()
{
 actual_nr_pulses =0;
 Delay_ms(1000);
 return actual_nr_pulses;
}



 void init()
 {

 OSCCON = 0xF0;



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





 CM1CON0.C1POL = 0;
 CM1CON0.C1OE = 1;
 CM1CON0.C1SP = 1;
 CM1CON0.C1ON = 1;
 CM1CON0.C1HYS = 1;
 CM1CON0.C1SYNC = 0;

 CM1CON1.C1NCH = 1;
 CM1CON1.C1PCH0 = 0;
 CM1CON1.C1PCH1 = 1;
 CM1CON1.C1INTP = 1;
 CM1CON1.C1INTN = 0;
 PIE2.C1IE = 1;


 FVRCON.FVREN = 1;
 FVRCON.CDAFVR0 = 0;
 FVRCON.CDAFVR1 = 1;



 INTCON.GIE = 1;


 }






void main()
{


 init();


 while(1)
 {

 frequency = measure_frequency();


 sendhex(frequency);
 }
}
