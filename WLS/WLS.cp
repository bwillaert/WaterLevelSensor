#line 1 "C:/Users/b/Documents/GitHub/WaterLevelSensor/WLS/WLS.c"
#line 65 "C:/Users/b/Documents/GitHub/WaterLevelSensor/WLS/WLS.c"
static unsigned int measurecnt;
static unsigned int accumulate_measure_cnt;
static unsigned int pulse_time;
static unsigned char pulse_flag;
static unsigned int beepdivider;
static unsigned int alternate_beepdivider;
static unsigned int alternate_beepdivider_time;
static unsigned int beepcnt;
static unsigned int lv_time;
static unsigned char lv_flag;
static unsigned char sensitivity_flag;
static unsigned int sensitivity_time;
static unsigned int startup_delay;
static unsigned int coil_timeout;
static unsigned char DAC_value;
static unsigned int calibration_delay;
static unsigned char calibration_steps;
static unsigned char calibration_busy;
static unsigned char PWM_duty;
static unsigned char pulse_average_cnt;
static unsigned long pulse_average_array[ 32 ];
static unsigned long pulse_average;
static unsigned char motion_cal_cnt ;
static unsigned int measure_cal;
static unsigned char pulse_array_size;
static unsigned char pulse_array_shift;
static unsigned int DC_offset;
#line 103 "C:/Users/b/Documents/GitHub/WaterLevelSensor/WLS/WLS.c"
void interrupt(void)
{


 if (INTCON.TMR0IF)
 {


 if (beepcnt)
 {
 beepcnt--;
 {
 if (!beepcnt)
 {
  LATA.LATA2  = ! LATA.LATA2 ;
 beepcnt = beepdivider ;
 }
 }
 }
 else
 {
 beepcnt = beepdivider;
 }



 if (pulse_time)
 {
 pulse_time--;
 if (!pulse_time)
 {

 pulse_time =  4 ;
 pulse_flag =  1 ;
 }
 }


 if (lv_time)
 {
 lv_time--;
 if (!lv_time)
 {

 lv_time =  50000 ;
 lv_flag =  1 ;
 }
 }


 if (sensitivity_time)
 {
 sensitivity_time--;
 if (!sensitivity_time)
 {

 sensitivity_time =  2000 ;
 sensitivity_flag =  1 ;
 }
 }


 if (startup_delay)
 {
 startup_delay--;
 }


 if (coil_timeout)
 {
 coil_timeout--;
 }



 INTCON.TMR0IF = 0;

 }
}









void sound (unsigned int period, unsigned long duration)
{
 unsigned long time_played;
 int i;
 time_played = 0;

 period >>=1 ;
 while (time_played < duration)
 {
 for (i = 0; i < period ; i++)
 {
 Delay_us(100);
 }
 time_played += period;

  LATA.LATA2  = ! LATA.LATA2 ;
 }
}


void start_sound()
{
 INTCON.GIE = 0;
 sound ( 50, 1000);
 sound ( 20, 1000);
 sound ( 10, 1000);

 TMR0 = 0;
 INTCON.T0IF = 0;
 INTCON.GIE = 1;
}


void ready_sound()
{
 sound ( 10, 300);
 Delay_ms(200);
 sound ( 20, 300);
 Delay_ms(200);
 sound ( 10, 300);
}



unsigned long absvalue(unsigned long a, unsigned long b)
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





void calibrate_offset()
{
 static char old_calibration_step = 0;
 char calibration_step = 0;
 calibration_delay--;
 if (!calibration_delay )
 {

 calibration_delay =  1500 ;


 Delay_us (2 *  100 );
 DC_offset = ADC_Read(6) ;


 if (calibration_steps)
 {
 if (absvalue(DC_offset,  830 ) <  10 )
 {
 calibration_steps = 0;
 }
 else
 {

 if (DC_offset <  830  )
 {
 if (DAC_value > 0)
 {
 calibration_step = -1;
 }
 }
 else
 {
 if (DAC_value < 31)
 {
 calibration_step = 1;
 }
 }


 if (calibration_steps && (old_calibration_step != 0) && (old_calibration_step != calibration_step))
 {

 calibration_steps = 0;

 calibration_step = 0;
 }


 DAC_value += calibration_step;
 DACCON1 = DAC_value;


 old_calibration_step = calibration_step;

 if (calibration_steps)
 {
 calibration_steps--;
 }
 }
 }

 else
 {



 EEPROM_Write(0x00,DAC_value);




 DC_offset >>= 2;
 DC_offset = DC_offset -  50 ;
 PWM2_Set_Duty(DC_offset);


 calibration_busy = 0;

 ready_sound();
 }
 }

}





void tx_pulse_processing()
{
 static unsigned long pulsediff = 0;
 static unsigned long pulsevalue = 0;
 char i = 0;




 INTCON.GIE = 0;


 T1CON.TMR1ON = 0;
 TMR1H = 0;
 TMR1L = 0;
 PIR1.TMR1IF = 0;


  LATC.LATC5  = 0;
 Delay_us( 100 );

 T1CON.TMR1ON = 1;

 T1CON.TMR1ON = 1;

  LATC.LATC5  = 1;


 INTCON.GIE = 1;


 if (!calibration_busy )
 {
 coil_timeout =  2 ;
 while(!CM2CON0.C2OUT && coil_timeout);
 if (!coil_timeout)
 {
 alternate_beepdivider_time = 5;
 alternate_beepdivider = 8;
 beepdivider = 8;
 return;
 }


 coil_timeout =  2 ;
 while (CM2CON0.C2OUT && coil_timeout);
 if (!coil_timeout)
 {
 alternate_beepdivider_time = 5;
 alternate_beepdivider = 8;
 beepdivider = 8;
 return;
 }
 }
 else
 {
 calibrate_offset();
 return;
 }





 pulsevalue += ((TMR1H<<8) | TMR1L);

 TMR1H = 0;
 TMR1L = 0;
 PIR1.TMR1IF = 0;
 T1CON.TMR1ON = 0;



 measurecnt--;
 if (!measurecnt)
 {

 if (!startup_delay)
 {

 pulse_average = 0;
 for (i = 0; i < pulse_array_size; i++)
 {
 pulse_average += pulse_average_array[i];
 }
 pulse_average >>= pulse_array_shift;




 if (! PORTA.RA3 )
 {
 pulse_average += (accumulate_measure_cnt<<1);
 }





 if (pulsevalue > pulse_average)
 {
 pulsediff = pulsevalue - pulse_average;
 }
 else
 {
 pulsediff = 0;
 }



 if (pulsediff >  64 )
 {
 pulsediff =  64 ;
  LATC.LATC3  = 1;
 }
 else
 {
  LATC.LATC3  = 0;
 }




 if (!alternate_beepdivider_time)
 {
 beepdivider = (2048 - (pulsediff << 5)) + 1;
 }
 else
 {
 alternate_beepdivider_time--;
 beepdivider = alternate_beepdivider;
 }


 if (beepdivider < beepcnt)
 {
 beepcnt = beepdivider;
 }
 }


 if ( PORTA.RA3 )
 {
 pulse_average_array[pulse_average_cnt%pulse_array_size] = pulsevalue;
 }




 pulsevalue = 0;
 pulse_average_cnt++;
 measurecnt = accumulate_measure_cnt;
 }


}





void main()
{
 unsigned int batt_voltage;
 unsigned int new_sensitivity, old_sensitivity = 1;
 accumulate_measure_cnt =  5 ;
 measurecnt = accumulate_measure_cnt;
 sensitivity_flag =  1 ;
 pulse_flag =  0 ;
 beepdivider = 2048;
 beepcnt = 2048;
 lv_time =  50000 ;
 lv_flag =  0 ;
 startup_delay =  5000 ;
 sensitivity_time =  2000 ;
 pulse_time =  4 ;
 DAC_value = 16;
 calibration_delay =  1500 ;
 calibration_steps = 31;
 calibration_busy = 1;
 PWM_duty = 0;
 pulse_average_cnt = 0;
 pulse_array_size =  32 ;
 pulse_array_shift = 5;
 alternate_beepdivider_time = 0;


 OSCCON= 0xF0;



 TRISA.TRISA0 =  0 ;
 PORTA.RA0 = 1;
 WPUA.WPUA0 = 0;
 TRISA.TRISA1 =  1 ;
 PORTA.RA1 = 1;
 TRISA.TRISA2 =  0 ;
 PORTA.RA2 = 1;
 TRISA.TRISA3 =  0 ;
 PORTA.RA3 = 1;
 TRISA.TRISA4 =  1 ;
 PORTA.RA4 = 1;
 TRISA.TRISA5 =  0 ;
 PORTA.RA5 = 1;


 TRISC.TRISC0 =  1 ;
 PORTC.RC0 = 1;
 TRISC.TRISC1 =  1 ;
 PORTC.RC1 = 1;
 TRISC.TRISC2 =  1 ;
 PORTC.RC2 = 1;
 TRISC.TRISC3 =  0 ;
 PORTC.RC3 = 1;
 TRISC.TRISC4 =  0 ;
 PORTC.RC4 = 1;
 TRISC.TRISC5 =  0 ;
 PORTC.RC5 = 1;


 ANSELA.ANSA0 = 1;
 ANSELA.ANSA1 = 1;
 ANSELA.ANSA4 = 1;
 ANSELC.ANSC0 = 1;
 ANSELC.ANSC1 = 1;
 ANSELC.ANSC2 = 1;


 T1GCON.TMR1GE = 1;
 T1GCON.T1GPOL = 1;
 T1GCON.T1GTM = 0;
 T1GCON.T1GSPM = 0;
 T1GCON.T1GSS1 = 1;
 T1GCON.T1GSS0 = 1;
 T1CON.T1CKPS0 = 0;
 T1CON.T1CKPS1 = 0;
 T1CON.TMR1CS0 = 1;
 T1CON.TMR1CS1 = 0;
 T1CON.T1OSCEN = 0;
 T1CON.TMR1ON = 1;
 TMR1H = 0;
 TMR1L = 0;
 PIR1.TMR1IF = 0;



 DACCON0.DACEN = 1;
 DACCON0.DACLPS = 0;
 DACCON0.DACOE = 1;
 DACCON0.DACPSS0 = 0;
 DACCON0.DACPSS1 = 0;
 DACCON0.DACNSS = 0;


 DAC_value = EEPROM_Read(0x00);
 if (DAC_value > 32)
 {

 DAC_value = 16;
 }



 DACCON1 = DAC_value;


 ADCON0.ADON = 1;
 ADCON1.ADFM = 1;
 ADCON1.ADCS0 = 0;
 ADCON1.ADCS1 = 1;
 ADCON1.ADCS2 = 1;
 ADCON1.ADNREF = 0;
 ADCON1.ADPREF0 = 0;
 ADCON1.ADPREF1 = 0;


 CM2CON0.C2POL = 0;
 CM2CON0.C2OE = 1;
 CM2CON0.C2SP = 1;
 CM2CON0.C2ON = 1;
 CM2CON0.C2HYS = 1;
 CM2CON0.C2SYNC = 1;

 CM2CON1.C2NCH0 = 1;
 CM2CON1.C2NCH1 = 0;
 CM2CON1.C2PCH0 = 0;
 CM2CON1.C2PCH1 = 0;


 OPTION_REG.PS0 = 1;
 OPTION_REG.PS1 = 1;
 OPTION_REG.PS2 = 0;
 OPTION_REG.PSA = 0;
 OPTION_REG.TMR0CS = 0;
 INTCON.TMR0IE = 1;




 INTCON.GIE = 1;




 APFCON1.CCP2SEL = 1;

 PWM2_Init(250000);
 PWM2_Set_Duty(127);
 PWM2_Start();


 start_sound();


 while(1)
 {

 if (pulse_flag)
 {

 tx_pulse_processing();
 pulse_flag =  0 ;
 }



 if (lv_flag)
 {
 lv_flag =  0 ;

 batt_voltage = ADC_Read(1);

 if (batt_voltage <  0x200  )
 {
 alternate_beepdivider_time = 250;
 alternate_beepdivider_time = 4;
 }
 }



 if (sensitivity_flag)
 {


 new_sensitivity = (ADC_Read(3) >> 4);
 if (new_sensitivity < 4)
 {
 new_sensitivity = 4;
 }
 if ( new_sensitivity > 63)
 {
 new_sensitivity = 63;
 }

 if (absvalue(old_sensitivity, new_sensitivity) > 1)
 {
 accumulate_measure_cnt = new_sensitivity;
 }


 old_sensitivity = new_sensitivity;
 sensitivity_flag =  0 ;



 if (new_sensitivity < 15)
 {
 pulse_array_size = 32;
 pulse_array_shift = 5;
 PWM2_Set_Duty(DC_offset - 10);
 }
 else if (new_sensitivity < 30)
 {
 pulse_array_size = 16;
 pulse_array_shift = 4;
 PWM2_Set_Duty(DC_offset - 5);
 }
 else if (new_sensitivity < 40)
 {
 pulse_array_size = 8;
 pulse_array_shift = 3;
 PWM2_Set_Duty(DC_offset);
 }
 else
 {
 pulse_array_size = 4;
 pulse_array_shift = 2;
 PWM2_Set_Duty(DC_offset);
 }

 }

 }

}
