
_interrupt:
	CLRF       PCLATH+0
	CLRF       STATUS+0

;WLS.c,103 :: 		void interrupt(void)
;WLS.c,107 :: 		if (INTCON.TMR0IF)
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;WLS.c,111 :: 		if (beepcnt)
	MOVF       WLS_beepcnt+0, 0
	IORWF       WLS_beepcnt+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt1
;WLS.c,113 :: 		beepcnt--;
	MOVLW      1
	SUBWF      WLS_beepcnt+0, 1
	MOVLW      0
	SUBWFB     WLS_beepcnt+1, 1
;WLS.c,115 :: 		if (!beepcnt)
	MOVF       WLS_beepcnt+0, 0
	IORWF       WLS_beepcnt+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt2
;WLS.c,117 :: 		BEEP = !BEEP;
	MOVLW      4
	XORWF      LATA+0, 1
;WLS.c,118 :: 		beepcnt = beepdivider ;
	MOVF       WLS_beepdivider+0, 0
	MOVWF      WLS_beepcnt+0
	MOVF       WLS_beepdivider+1, 0
	MOVWF      WLS_beepcnt+1
;WLS.c,119 :: 		}
L_interrupt2:
;WLS.c,121 :: 		}
	GOTO       L_interrupt3
L_interrupt1:
;WLS.c,124 :: 		beepcnt = beepdivider;
	MOVF       WLS_beepdivider+0, 0
	MOVWF      WLS_beepcnt+0
	MOVF       WLS_beepdivider+1, 0
	MOVWF      WLS_beepcnt+1
;WLS.c,125 :: 		}
L_interrupt3:
;WLS.c,129 :: 		if (pulse_time)
	MOVF       WLS_pulse_time+0, 0
	IORWF       WLS_pulse_time+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt4
;WLS.c,131 :: 		pulse_time--;
	MOVLW      1
	SUBWF      WLS_pulse_time+0, 1
	MOVLW      0
	SUBWFB     WLS_pulse_time+1, 1
;WLS.c,132 :: 		if (!pulse_time)
	MOVF       WLS_pulse_time+0, 0
	IORWF       WLS_pulse_time+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt5
;WLS.c,135 :: 		pulse_time = PULSE_TIME_DIVIDER;
	MOVLW      4
	MOVWF      WLS_pulse_time+0
	MOVLW      0
	MOVWF      WLS_pulse_time+1
;WLS.c,136 :: 		pulse_flag = TRUE;
	MOVLW      1
	MOVWF      WLS_pulse_flag+0
;WLS.c,137 :: 		}
L_interrupt5:
;WLS.c,138 :: 		}
L_interrupt4:
;WLS.c,141 :: 		if (lv_time)
	MOVF       WLS_lv_time+0, 0
	IORWF       WLS_lv_time+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt6
;WLS.c,143 :: 		lv_time--;
	MOVLW      1
	SUBWF      WLS_lv_time+0, 1
	MOVLW      0
	SUBWFB     WLS_lv_time+1, 1
;WLS.c,144 :: 		if (!lv_time)
	MOVF       WLS_lv_time+0, 0
	IORWF       WLS_lv_time+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt7
;WLS.c,147 :: 		lv_time = LV_TIME_DIVIDER;
	MOVLW      80
	MOVWF      WLS_lv_time+0
	MOVLW      195
	MOVWF      WLS_lv_time+1
;WLS.c,148 :: 		lv_flag = TRUE;
	MOVLW      1
	MOVWF      WLS_lv_flag+0
;WLS.c,149 :: 		}
L_interrupt7:
;WLS.c,150 :: 		}
L_interrupt6:
;WLS.c,153 :: 		if (sensitivity_time)
	MOVF       WLS_sensitivity_time+0, 0
	IORWF       WLS_sensitivity_time+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt8
;WLS.c,155 :: 		sensitivity_time--;
	MOVLW      1
	SUBWF      WLS_sensitivity_time+0, 1
	MOVLW      0
	SUBWFB     WLS_sensitivity_time+1, 1
;WLS.c,156 :: 		if (!sensitivity_time)
	MOVF       WLS_sensitivity_time+0, 0
	IORWF       WLS_sensitivity_time+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;WLS.c,159 :: 		sensitivity_time = SENSITIVITY_TIME_DIVIDER;
	MOVLW      208
	MOVWF      WLS_sensitivity_time+0
	MOVLW      7
	MOVWF      WLS_sensitivity_time+1
;WLS.c,160 :: 		sensitivity_flag = TRUE;
	MOVLW      1
	MOVWF      WLS_sensitivity_flag+0
;WLS.c,161 :: 		}
L_interrupt9:
;WLS.c,162 :: 		}
L_interrupt8:
;WLS.c,165 :: 		if (startup_delay)
	MOVF       WLS_startup_delay+0, 0
	IORWF       WLS_startup_delay+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt10
;WLS.c,167 :: 		startup_delay--;
	MOVLW      1
	SUBWF      WLS_startup_delay+0, 1
	MOVLW      0
	SUBWFB     WLS_startup_delay+1, 1
;WLS.c,168 :: 		}
L_interrupt10:
;WLS.c,171 :: 		if (coil_timeout)
	MOVF       WLS_coil_timeout+0, 0
	IORWF       WLS_coil_timeout+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt11
;WLS.c,173 :: 		coil_timeout--;
	MOVLW      1
	SUBWF      WLS_coil_timeout+0, 1
	MOVLW      0
	SUBWFB     WLS_coil_timeout+1, 1
;WLS.c,174 :: 		}
L_interrupt11:
;WLS.c,178 :: 		INTCON.TMR0IF = 0;
	BCF        INTCON+0, 2
;WLS.c,180 :: 		}
L_interrupt0:
;WLS.c,181 :: 		}
L_end_interrupt:
L__interrupt83:
	RETFIE     %s
; end of _interrupt

_sound:

;WLS.c,191 :: 		void sound (unsigned int period, unsigned long duration)
;WLS.c,195 :: 		time_played = 0;
	CLRF       R1+0
	CLRF       R1+1
	CLRF       R1+2
	CLRF       R1+3
;WLS.c,197 :: 		period >>=1 ;
	LSRF       FARG_sound_period+1, 1
	RRF        FARG_sound_period+0, 1
;WLS.c,198 :: 		while (time_played < duration)
L_sound12:
	MOVF       FARG_sound_duration+3, 0
	SUBWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sound85
	MOVF       FARG_sound_duration+2, 0
	SUBWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sound85
	MOVF       FARG_sound_duration+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sound85
	MOVF       FARG_sound_duration+0, 0
	SUBWF      R1+0, 0
L__sound85:
	BTFSC      STATUS+0, 0
	GOTO       L_sound13
;WLS.c,200 :: 		for (i = 0; i < period ; i++)
	CLRF       R5+0
	CLRF       R5+1
L_sound14:
	MOVF       FARG_sound_period+1, 0
	SUBWF      R5+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sound86
	MOVF       FARG_sound_period+0, 0
	SUBWF      R5+0, 0
L__sound86:
	BTFSC      STATUS+0, 0
	GOTO       L_sound15
;WLS.c,202 :: 		Delay_us(100);
	MOVLW      2
	MOVWF      R12
	MOVLW      8
	MOVWF      R13
L_sound17:
	DECFSZ     R13, 1
	GOTO       L_sound17
	DECFSZ     R12, 1
	GOTO       L_sound17
	NOP
;WLS.c,200 :: 		for (i = 0; i < period ; i++)
	INCF       R5+0, 1
	BTFSC      STATUS+0, 2
	INCF       R5+1, 1
;WLS.c,203 :: 		}
	GOTO       L_sound14
L_sound15:
;WLS.c,204 :: 		time_played += period;
	MOVF       FARG_sound_period+0, 0
	ADDWF      R1+0, 1
	MOVF       FARG_sound_period+1, 0
	ADDWFC     R1+1, 1
	MOVLW      0
	ADDWFC     R1+2, 1
	ADDWFC     R1+3, 1
;WLS.c,206 :: 		BEEP = !BEEP;
	MOVLW      4
	XORWF      LATA+0, 1
;WLS.c,207 :: 		}
	GOTO       L_sound12
L_sound13:
;WLS.c,208 :: 		}
L_end_sound:
	RETURN
; end of _sound

_start_sound:

;WLS.c,211 :: 		void start_sound()
;WLS.c,213 :: 		INTCON.GIE = 0;
	BCF        INTCON+0, 7
;WLS.c,214 :: 		sound ( 50, 1000);    // 200 Hz
	MOVLW      50
	MOVWF      FARG_sound_period+0
	MOVLW      0
	MOVWF      FARG_sound_period+1
	MOVLW      232
	MOVWF      FARG_sound_duration+0
	MOVLW      3
	MOVWF      FARG_sound_duration+1
	CLRF       FARG_sound_duration+2
	CLRF       FARG_sound_duration+3
	CALL       _sound+0
;WLS.c,215 :: 		sound ( 20, 1000);    // 500 Hz
	MOVLW      20
	MOVWF      FARG_sound_period+0
	MOVLW      0
	MOVWF      FARG_sound_period+1
	MOVLW      232
	MOVWF      FARG_sound_duration+0
	MOVLW      3
	MOVWF      FARG_sound_duration+1
	CLRF       FARG_sound_duration+2
	CLRF       FARG_sound_duration+3
	CALL       _sound+0
;WLS.c,216 :: 		sound ( 10, 1000);    // 1 KHz
	MOVLW      10
	MOVWF      FARG_sound_period+0
	MOVLW      0
	MOVWF      FARG_sound_period+1
	MOVLW      232
	MOVWF      FARG_sound_duration+0
	MOVLW      3
	MOVWF      FARG_sound_duration+1
	CLRF       FARG_sound_duration+2
	CLRF       FARG_sound_duration+3
	CALL       _sound+0
;WLS.c,218 :: 		TMR0 = 0;
	CLRF       TMR0+0
;WLS.c,219 :: 		INTCON.T0IF = 0;
	BCF        INTCON+0, 2
;WLS.c,220 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;WLS.c,221 :: 		}
L_end_start_sound:
	RETURN
; end of _start_sound

_ready_sound:

;WLS.c,224 :: 		void ready_sound()
;WLS.c,226 :: 		sound ( 10, 300);    // 1 KHz
	MOVLW      10
	MOVWF      FARG_sound_period+0
	MOVLW      0
	MOVWF      FARG_sound_period+1
	MOVLW      44
	MOVWF      FARG_sound_duration+0
	MOVLW      1
	MOVWF      FARG_sound_duration+1
	CLRF       FARG_sound_duration+2
	CLRF       FARG_sound_duration+3
	CALL       _sound+0
;WLS.c,227 :: 		Delay_ms(200);
	MOVLW      9
	MOVWF      R11
	MOVLW      30
	MOVWF      R12
	MOVLW      228
	MOVWF      R13
L_ready_sound18:
	DECFSZ     R13, 1
	GOTO       L_ready_sound18
	DECFSZ     R12, 1
	GOTO       L_ready_sound18
	DECFSZ     R11, 1
	GOTO       L_ready_sound18
	NOP
;WLS.c,228 :: 		sound ( 20, 300);    // 500 Hz
	MOVLW      20
	MOVWF      FARG_sound_period+0
	MOVLW      0
	MOVWF      FARG_sound_period+1
	MOVLW      44
	MOVWF      FARG_sound_duration+0
	MOVLW      1
	MOVWF      FARG_sound_duration+1
	CLRF       FARG_sound_duration+2
	CLRF       FARG_sound_duration+3
	CALL       _sound+0
;WLS.c,229 :: 		Delay_ms(200);
	MOVLW      9
	MOVWF      R11
	MOVLW      30
	MOVWF      R12
	MOVLW      228
	MOVWF      R13
L_ready_sound19:
	DECFSZ     R13, 1
	GOTO       L_ready_sound19
	DECFSZ     R12, 1
	GOTO       L_ready_sound19
	DECFSZ     R11, 1
	GOTO       L_ready_sound19
	NOP
;WLS.c,230 :: 		sound ( 10, 300);    // 1 KHz
	MOVLW      10
	MOVWF      FARG_sound_period+0
	MOVLW      0
	MOVWF      FARG_sound_period+1
	MOVLW      44
	MOVWF      FARG_sound_duration+0
	MOVLW      1
	MOVWF      FARG_sound_duration+1
	CLRF       FARG_sound_duration+2
	CLRF       FARG_sound_duration+3
	CALL       _sound+0
;WLS.c,231 :: 		}
L_end_ready_sound:
	RETURN
; end of _ready_sound

_absvalue:

;WLS.c,235 :: 		unsigned long absvalue(unsigned long a, unsigned long b)
;WLS.c,237 :: 		if (a > b)
	MOVF       FARG_absvalue_a+3, 0
	SUBWF      FARG_absvalue_b+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__absvalue90
	MOVF       FARG_absvalue_a+2, 0
	SUBWF      FARG_absvalue_b+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__absvalue90
	MOVF       FARG_absvalue_a+1, 0
	SUBWF      FARG_absvalue_b+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__absvalue90
	MOVF       FARG_absvalue_a+0, 0
	SUBWF      FARG_absvalue_b+0, 0
L__absvalue90:
	BTFSC      STATUS+0, 0
	GOTO       L_absvalue20
;WLS.c,239 :: 		return (a-b);
	MOVF       FARG_absvalue_a+0, 0
	MOVWF      R0
	MOVF       FARG_absvalue_a+1, 0
	MOVWF      R1
	MOVF       FARG_absvalue_a+2, 0
	MOVWF      R2
	MOVF       FARG_absvalue_a+3, 0
	MOVWF      R3
	MOVF       FARG_absvalue_b+0, 0
	SUBWF      R0, 1
	MOVF       FARG_absvalue_b+1, 0
	SUBWFB     R1, 1
	MOVF       FARG_absvalue_b+2, 0
	SUBWFB     R2, 1
	MOVF       FARG_absvalue_b+3, 0
	SUBWFB     R3, 1
	GOTO       L_end_absvalue
;WLS.c,240 :: 		}
L_absvalue20:
;WLS.c,243 :: 		return (b-a);
	MOVF       FARG_absvalue_b+0, 0
	MOVWF      R0
	MOVF       FARG_absvalue_b+1, 0
	MOVWF      R1
	MOVF       FARG_absvalue_b+2, 0
	MOVWF      R2
	MOVF       FARG_absvalue_b+3, 0
	MOVWF      R3
	MOVF       FARG_absvalue_a+0, 0
	SUBWF      R0, 1
	MOVF       FARG_absvalue_a+1, 0
	SUBWFB     R1, 1
	MOVF       FARG_absvalue_a+2, 0
	SUBWFB     R2, 1
	MOVF       FARG_absvalue_a+3, 0
	SUBWFB     R3, 1
;WLS.c,246 :: 		}
L_end_absvalue:
	RETURN
; end of _absvalue

_calibrate_offset:

;WLS.c,252 :: 		void calibrate_offset()
;WLS.c,255 :: 		char calibration_step = 0;
	CLRF       calibrate_offset_calibration_step_L0+0
;WLS.c,256 :: 		calibration_delay--;
	MOVLW      1
	SUBWF      WLS_calibration_delay+0, 1
	MOVLW      0
	SUBWFB     WLS_calibration_delay+1, 1
;WLS.c,257 :: 		if (!calibration_delay )
	MOVF       WLS_calibration_delay+0, 0
	IORWF       WLS_calibration_delay+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_calibrate_offset22
;WLS.c,260 :: 		calibration_delay = CALIBRATION_DELAY;
	MOVLW      220
	MOVWF      WLS_calibration_delay+0
	MOVLW      5
	MOVWF      WLS_calibration_delay+1
;WLS.c,263 :: 		Delay_us (2 * TX_PULSE_WIDTH);
	MOVLW      3
	MOVWF      R12
	MOVLW      18
	MOVWF      R13
L_calibrate_offset23:
	DECFSZ     R13, 1
	GOTO       L_calibrate_offset23
	DECFSZ     R12, 1
	GOTO       L_calibrate_offset23
	NOP
;WLS.c,264 :: 		DC_offset = ADC_Read(6) ;
	MOVLW      6
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0, 0
	MOVWF      WLS_DC_offset+0
	MOVF       R1, 0
	MOVWF      WLS_DC_offset+1
;WLS.c,267 :: 		if (calibration_steps)
	MOVF       WLS_calibration_steps+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_calibrate_offset24
;WLS.c,269 :: 		if (absvalue(DC_offset, ADC_TARGET) < ADC_TOLERANCE)
	MOVF       WLS_DC_offset+0, 0
	MOVWF      FARG_absvalue_a+0
	MOVF       WLS_DC_offset+1, 0
	MOVWF      FARG_absvalue_a+1
	CLRF       FARG_absvalue_a+2
	CLRF       FARG_absvalue_a+3
	MOVLW      62
	MOVWF      FARG_absvalue_b+0
	MOVLW      3
	MOVWF      FARG_absvalue_b+1
	CLRF       FARG_absvalue_b+2
	CLRF       FARG_absvalue_b+3
	CALL       _absvalue+0
	MOVLW      0
	SUBWF      R3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__calibrate_offset92
	MOVLW      0
	SUBWF      R2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__calibrate_offset92
	MOVLW      0
	SUBWF      R1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__calibrate_offset92
	MOVLW      10
	SUBWF      R0, 0
L__calibrate_offset92:
	BTFSC      STATUS+0, 0
	GOTO       L_calibrate_offset25
;WLS.c,271 :: 		calibration_steps = 0;
	CLRF       WLS_calibration_steps+0
;WLS.c,272 :: 		}
	GOTO       L_calibrate_offset26
L_calibrate_offset25:
;WLS.c,276 :: 		if (DC_offset < ADC_TARGET )
	MOVLW      3
	SUBWF      WLS_DC_offset+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__calibrate_offset93
	MOVLW      62
	SUBWF      WLS_DC_offset+0, 0
L__calibrate_offset93:
	BTFSC      STATUS+0, 0
	GOTO       L_calibrate_offset27
;WLS.c,278 :: 		if (DAC_value > 0)
	MOVF       WLS_DAC_value+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_calibrate_offset28
;WLS.c,280 :: 		calibration_step = -1;
	MOVLW      255
	MOVWF      calibrate_offset_calibration_step_L0+0
;WLS.c,281 :: 		}
L_calibrate_offset28:
;WLS.c,282 :: 		}
	GOTO       L_calibrate_offset29
L_calibrate_offset27:
;WLS.c,285 :: 		if (DAC_value < 31)
	MOVLW      31
	SUBWF      WLS_DAC_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_calibrate_offset30
;WLS.c,287 :: 		calibration_step = 1;
	MOVLW      1
	MOVWF      calibrate_offset_calibration_step_L0+0
;WLS.c,288 :: 		}
L_calibrate_offset30:
;WLS.c,289 :: 		}
L_calibrate_offset29:
;WLS.c,292 :: 		if (calibration_steps && (old_calibration_step != 0) && (old_calibration_step != calibration_step))
	MOVF       WLS_calibration_steps+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_calibrate_offset33
	MOVF       calibrate_offset_old_calibration_step_L0+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_calibrate_offset33
	MOVF       calibrate_offset_old_calibration_step_L0+0, 0
	XORWF      calibrate_offset_calibration_step_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_calibrate_offset33
L__calibrate_offset79:
;WLS.c,295 :: 		calibration_steps = 0;
	CLRF       WLS_calibration_steps+0
;WLS.c,297 :: 		calibration_step = 0;
	CLRF       calibrate_offset_calibration_step_L0+0
;WLS.c,298 :: 		}
L_calibrate_offset33:
;WLS.c,301 :: 		DAC_value += calibration_step;
	MOVF       calibrate_offset_calibration_step_L0+0, 0
	ADDWF      WLS_DAC_value+0, 0
	MOVWF      R0
	MOVF       R0, 0
	MOVWF      WLS_DAC_value+0
;WLS.c,302 :: 		DACCON1 = DAC_value;
	MOVF       R0, 0
	MOVWF      DACCON1+0
;WLS.c,305 :: 		old_calibration_step = calibration_step;
	MOVF       calibrate_offset_calibration_step_L0+0, 0
	MOVWF      calibrate_offset_old_calibration_step_L0+0
;WLS.c,307 :: 		if (calibration_steps)
	MOVF       WLS_calibration_steps+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_calibrate_offset34
;WLS.c,309 :: 		calibration_steps--;
	DECF       WLS_calibration_steps+0, 1
;WLS.c,310 :: 		}
L_calibrate_offset34:
;WLS.c,311 :: 		}
L_calibrate_offset26:
;WLS.c,312 :: 		}
	GOTO       L_calibrate_offset35
L_calibrate_offset24:
;WLS.c,319 :: 		EEPROM_Write(0x00,DAC_value);
	CLRF       FARG_EEPROM_Write_Address+0
	MOVF       WLS_DAC_value+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;WLS.c,324 :: 		DC_offset >>= 2;           // 8 bit : 0-255 : 0-5V
	MOVF       WLS_DC_offset+0, 0
	MOVWF      R0
	MOVF       WLS_DC_offset+1, 0
	MOVWF      R1
	LSRF       R1, 1
	RRF        R0, 1
	LSRF       R1, 1
	RRF        R0, 1
	MOVF       R0, 0
	MOVWF      WLS_DC_offset+0
	MOVF       R1, 0
	MOVWF      WLS_DC_offset+1
;WLS.c,325 :: 		DC_offset = DC_offset - DC_OFFSET_MARGIN; // 1 V lower
	MOVLW      50
	SUBWF      R0, 1
	MOVLW      0
	SUBWFB     R1, 1
	MOVF       R0, 0
	MOVWF      WLS_DC_offset+0
	MOVF       R1, 0
	MOVWF      WLS_DC_offset+1
;WLS.c,326 :: 		PWM2_Set_Duty(DC_offset);
	MOVF       R0, 0
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;WLS.c,329 :: 		calibration_busy = 0;
	CLRF       WLS_calibration_busy+0
;WLS.c,331 :: 		ready_sound();
	CALL       _ready_sound+0
;WLS.c,332 :: 		}
L_calibrate_offset35:
;WLS.c,333 :: 		}
L_calibrate_offset22:
;WLS.c,335 :: 		}
L_end_calibrate_offset:
	RETURN
; end of _calibrate_offset

_tx_pulse_processing:

;WLS.c,341 :: 		void tx_pulse_processing()
;WLS.c,345 :: 		char i = 0;
	CLRF       tx_pulse_processing_i_L0+0
;WLS.c,350 :: 		INTCON.GIE = 0;
	BCF        INTCON+0, 7
;WLS.c,353 :: 		T1CON.TMR1ON = 0;
	BCF        T1CON+0, 0
;WLS.c,354 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;WLS.c,355 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;WLS.c,356 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;WLS.c,359 :: 		PI_TX = 0;
	BCF        LATC+0, 5
;WLS.c,360 :: 		Delay_us(TX_PULSE_WIDTH);
	MOVLW      2
	MOVWF      R12
	MOVLW      8
	MOVWF      R13
L_tx_pulse_processing36:
	DECFSZ     R13, 1
	GOTO       L_tx_pulse_processing36
	DECFSZ     R12, 1
	GOTO       L_tx_pulse_processing36
	NOP
;WLS.c,362 :: 		T1CON.TMR1ON = 1;
	BSF        T1CON+0, 0
;WLS.c,364 :: 		T1CON.TMR1ON = 1;
	BSF        T1CON+0, 0
;WLS.c,366 :: 		PI_TX = 1;
	BSF        LATC+0, 5
;WLS.c,369 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;WLS.c,372 :: 		if (!calibration_busy )
	MOVF       WLS_calibration_busy+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_tx_pulse_processing37
;WLS.c,374 :: 		coil_timeout = COIL_TIMEOUT;
	MOVLW      2
	MOVWF      WLS_coil_timeout+0
	MOVLW      0
	MOVWF      WLS_coil_timeout+1
;WLS.c,375 :: 		while(!CM2CON0.C2OUT && coil_timeout);
L_tx_pulse_processing38:
	BTFSC      CM2CON0+0, 6
	GOTO       L_tx_pulse_processing39
	MOVF       WLS_coil_timeout+0, 0
	IORWF       WLS_coil_timeout+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_tx_pulse_processing39
L__tx_pulse_processing81:
	GOTO       L_tx_pulse_processing38
L_tx_pulse_processing39:
;WLS.c,376 :: 		if (!coil_timeout)
	MOVF       WLS_coil_timeout+0, 0
	IORWF       WLS_coil_timeout+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_tx_pulse_processing42
;WLS.c,378 :: 		alternate_beepdivider_time = 5;
	MOVLW      5
	MOVWF      WLS_alternate_beepdivider_time+0
	MOVLW      0
	MOVWF      WLS_alternate_beepdivider_time+1
;WLS.c,379 :: 		alternate_beepdivider = 8;
	MOVLW      8
	MOVWF      WLS_alternate_beepdivider+0
	MOVLW      0
	MOVWF      WLS_alternate_beepdivider+1
;WLS.c,380 :: 		beepdivider = 8;
	MOVLW      8
	MOVWF      WLS_beepdivider+0
	MOVLW      0
	MOVWF      WLS_beepdivider+1
;WLS.c,381 :: 		return;
	GOTO       L_end_tx_pulse_processing
;WLS.c,382 :: 		}
L_tx_pulse_processing42:
;WLS.c,385 :: 		coil_timeout = COIL_TIMEOUT;
	MOVLW      2
	MOVWF      WLS_coil_timeout+0
	MOVLW      0
	MOVWF      WLS_coil_timeout+1
;WLS.c,386 :: 		while (CM2CON0.C2OUT && coil_timeout);
L_tx_pulse_processing43:
	BTFSS      CM2CON0+0, 6
	GOTO       L_tx_pulse_processing44
	MOVF       WLS_coil_timeout+0, 0
	IORWF       WLS_coil_timeout+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_tx_pulse_processing44
L__tx_pulse_processing80:
	GOTO       L_tx_pulse_processing43
L_tx_pulse_processing44:
;WLS.c,387 :: 		if (!coil_timeout)
	MOVF       WLS_coil_timeout+0, 0
	IORWF       WLS_coil_timeout+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_tx_pulse_processing47
;WLS.c,389 :: 		alternate_beepdivider_time = 5;
	MOVLW      5
	MOVWF      WLS_alternate_beepdivider_time+0
	MOVLW      0
	MOVWF      WLS_alternate_beepdivider_time+1
;WLS.c,390 :: 		alternate_beepdivider = 8;
	MOVLW      8
	MOVWF      WLS_alternate_beepdivider+0
	MOVLW      0
	MOVWF      WLS_alternate_beepdivider+1
;WLS.c,391 :: 		beepdivider = 8;
	MOVLW      8
	MOVWF      WLS_beepdivider+0
	MOVLW      0
	MOVWF      WLS_beepdivider+1
;WLS.c,392 :: 		return;
	GOTO       L_end_tx_pulse_processing
;WLS.c,393 :: 		}
L_tx_pulse_processing47:
;WLS.c,394 :: 		} // if !calibration_busy
	GOTO       L_tx_pulse_processing48
L_tx_pulse_processing37:
;WLS.c,397 :: 		calibrate_offset();
	CALL       _calibrate_offset+0
;WLS.c,398 :: 		return;
	GOTO       L_end_tx_pulse_processing
;WLS.c,399 :: 		}
L_tx_pulse_processing48:
;WLS.c,405 :: 		pulsevalue += ((TMR1H<<8) | TMR1L);
	MOVF       TMR1H+0, 0
	MOVWF      R1
	CLRF       R0
	MOVF       TMR1L+0, 0
	IORWF       R0, 1
	MOVLW      0
	IORWF       R1, 1
	MOVF       R0, 0
	ADDWF      tx_pulse_processing_pulsevalue_L0+0, 1
	MOVF       R1, 0
	ADDWFC     tx_pulse_processing_pulsevalue_L0+1, 1
	MOVLW      0
	ADDWFC     tx_pulse_processing_pulsevalue_L0+2, 1
	ADDWFC     tx_pulse_processing_pulsevalue_L0+3, 1
;WLS.c,407 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;WLS.c,408 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;WLS.c,409 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;WLS.c,410 :: 		T1CON.TMR1ON = 0;
	BCF        T1CON+0, 0
;WLS.c,414 :: 		measurecnt--;
	MOVLW      1
	SUBWF      WLS_measurecnt+0, 1
	MOVLW      0
	SUBWFB     WLS_measurecnt+1, 1
;WLS.c,415 :: 		if (!measurecnt)
	MOVF       WLS_measurecnt+0, 0
	IORWF       WLS_measurecnt+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_tx_pulse_processing49
;WLS.c,418 :: 		if (!startup_delay)
	MOVF       WLS_startup_delay+0, 0
	IORWF       WLS_startup_delay+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_tx_pulse_processing50
;WLS.c,421 :: 		pulse_average = 0;
	CLRF       WLS_pulse_average+0
	CLRF       WLS_pulse_average+1
	CLRF       WLS_pulse_average+2
	CLRF       WLS_pulse_average+3
;WLS.c,422 :: 		for (i = 0; i < pulse_array_size; i++)
	CLRF       tx_pulse_processing_i_L0+0
L_tx_pulse_processing51:
	MOVF       WLS_pulse_array_size+0, 0
	SUBWF      tx_pulse_processing_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_tx_pulse_processing52
;WLS.c,424 :: 		pulse_average += pulse_average_array[i];
	MOVLW      WLS_pulse_average_array+0
	MOVWF      R3
	MOVLW      hi_addr(WLS_pulse_average_array+0)
	MOVWF      R4
	MOVF       tx_pulse_processing_i_L0+0, 0
	MOVWF      R0
	CLRF       R1
	LSLF       R0, 1
	RLF        R1, 1
	LSLF       R0, 1
	RLF        R1, 1
	MOVF       R0, 0
	ADDWF      R3, 0
	MOVWF      FSR0L
	MOVF       R1, 0
	ADDWFC     R4, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	ADDWF      WLS_pulse_average+0, 1
	ADDFSR     0, 1
	MOVF       INDF0+0, 0
	ADDWFC     WLS_pulse_average+1, 1
	ADDFSR     0, 1
	MOVF       INDF0+0, 0
	ADDWFC     WLS_pulse_average+2, 1
	ADDFSR     0, 1
	MOVF       INDF0+0, 0
	ADDWFC     WLS_pulse_average+3, 1
;WLS.c,422 :: 		for (i = 0; i < pulse_array_size; i++)
	INCF       tx_pulse_processing_i_L0+0, 1
;WLS.c,425 :: 		}
	GOTO       L_tx_pulse_processing51
L_tx_pulse_processing52:
;WLS.c,426 :: 		pulse_average >>= pulse_array_shift;  // divide by
	MOVF       WLS_pulse_array_shift+0, 0
	MOVWF      R0
	MOVF       R0, 0
L__tx_pulse_processing95:
	BTFSC      STATUS+0, 2
	GOTO       L__tx_pulse_processing96
	LSRF       WLS_pulse_average+3, 1
	RRF        WLS_pulse_average+2, 1
	RRF        WLS_pulse_average+1, 1
	RRF        WLS_pulse_average+0, 1
	ADDLW      255
	GOTO       L__tx_pulse_processing95
L__tx_pulse_processing96:
;WLS.c,431 :: 		if (!PP_BUTTON)
	BTFSC      PORTA+0, 3
	GOTO       L_tx_pulse_processing54
;WLS.c,433 :: 		pulse_average += (accumulate_measure_cnt<<1);
	MOVF       WLS_accumulate_measure_cnt+0, 0
	MOVWF      R0
	MOVF       WLS_accumulate_measure_cnt+1, 0
	MOVWF      R1
	LSLF       R0, 1
	RLF        R1, 1
	MOVF       R0, 0
	ADDWF      WLS_pulse_average+0, 1
	MOVF       R1, 0
	ADDWFC     WLS_pulse_average+1, 1
	MOVLW      0
	ADDWFC     WLS_pulse_average+2, 1
	ADDWFC     WLS_pulse_average+3, 1
;WLS.c,434 :: 		}
L_tx_pulse_processing54:
;WLS.c,440 :: 		if (pulsevalue > pulse_average)
	MOVF       tx_pulse_processing_pulsevalue_L0+3, 0
	SUBWF      WLS_pulse_average+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__tx_pulse_processing97
	MOVF       tx_pulse_processing_pulsevalue_L0+2, 0
	SUBWF      WLS_pulse_average+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__tx_pulse_processing97
	MOVF       tx_pulse_processing_pulsevalue_L0+1, 0
	SUBWF      WLS_pulse_average+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__tx_pulse_processing97
	MOVF       tx_pulse_processing_pulsevalue_L0+0, 0
	SUBWF      WLS_pulse_average+0, 0
L__tx_pulse_processing97:
	BTFSC      STATUS+0, 0
	GOTO       L_tx_pulse_processing55
;WLS.c,442 :: 		pulsediff = pulsevalue - pulse_average;
	MOVF       tx_pulse_processing_pulsevalue_L0+0, 0
	MOVWF      tx_pulse_processing_pulsediff_L0+0
	MOVF       tx_pulse_processing_pulsevalue_L0+1, 0
	MOVWF      tx_pulse_processing_pulsediff_L0+1
	MOVF       tx_pulse_processing_pulsevalue_L0+2, 0
	MOVWF      tx_pulse_processing_pulsediff_L0+2
	MOVF       tx_pulse_processing_pulsevalue_L0+3, 0
	MOVWF      tx_pulse_processing_pulsediff_L0+3
	MOVF       WLS_pulse_average+0, 0
	SUBWF      tx_pulse_processing_pulsediff_L0+0, 1
	MOVF       WLS_pulse_average+1, 0
	SUBWFB     tx_pulse_processing_pulsediff_L0+1, 1
	MOVF       WLS_pulse_average+2, 0
	SUBWFB     tx_pulse_processing_pulsediff_L0+2, 1
	MOVF       WLS_pulse_average+3, 0
	SUBWFB     tx_pulse_processing_pulsediff_L0+3, 1
;WLS.c,443 :: 		}
	GOTO       L_tx_pulse_processing56
L_tx_pulse_processing55:
;WLS.c,446 :: 		pulsediff  = 0;
	CLRF       tx_pulse_processing_pulsediff_L0+0
	CLRF       tx_pulse_processing_pulsediff_L0+1
	CLRF       tx_pulse_processing_pulsediff_L0+2
	CLRF       tx_pulse_processing_pulsediff_L0+3
;WLS.c,447 :: 		}
L_tx_pulse_processing56:
;WLS.c,451 :: 		if (pulsediff > MAX_PULSEDIFF)
	MOVF       tx_pulse_processing_pulsediff_L0+3, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__tx_pulse_processing98
	MOVF       tx_pulse_processing_pulsediff_L0+2, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__tx_pulse_processing98
	MOVF       tx_pulse_processing_pulsediff_L0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__tx_pulse_processing98
	MOVF       tx_pulse_processing_pulsediff_L0+0, 0
	SUBLW      64
L__tx_pulse_processing98:
	BTFSC      STATUS+0, 0
	GOTO       L_tx_pulse_processing57
;WLS.c,453 :: 		pulsediff = MAX_PULSEDIFF;
	MOVLW      64
	MOVWF      tx_pulse_processing_pulsediff_L0+0
	CLRF       tx_pulse_processing_pulsediff_L0+1
	CLRF       tx_pulse_processing_pulsediff_L0+2
	CLRF       tx_pulse_processing_pulsediff_L0+3
;WLS.c,454 :: 		DETECTION_PIN = 1;
	BSF        LATC+0, 3
;WLS.c,455 :: 		}
	GOTO       L_tx_pulse_processing58
L_tx_pulse_processing57:
;WLS.c,458 :: 		DETECTION_PIN = 0;
	BCF        LATC+0, 3
;WLS.c,459 :: 		}
L_tx_pulse_processing58:
;WLS.c,464 :: 		if (!alternate_beepdivider_time)
	MOVF       WLS_alternate_beepdivider_time+0, 0
	IORWF       WLS_alternate_beepdivider_time+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_tx_pulse_processing59
;WLS.c,466 :: 		beepdivider = (2048 - (pulsediff << 5)) + 1;
	MOVLW      5
	MOVWF      R2
	MOVF       tx_pulse_processing_pulsediff_L0+0, 0
	MOVWF      R0
	MOVF       tx_pulse_processing_pulsediff_L0+1, 0
	MOVWF      R1
	MOVF       R2, 0
L__tx_pulse_processing99:
	BTFSC      STATUS+0, 2
	GOTO       L__tx_pulse_processing100
	LSLF       R0, 1
	RLF        R1, 1
	ADDLW      255
	GOTO       L__tx_pulse_processing99
L__tx_pulse_processing100:
	MOVF       R0, 0
	SUBLW      0
	MOVWF      WLS_beepdivider+0
	MOVF       R1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      8
	MOVWF      WLS_beepdivider+1
	INCF       WLS_beepdivider+0, 1
	BTFSC      STATUS+0, 2
	INCF       WLS_beepdivider+1, 1
;WLS.c,467 :: 		}
	GOTO       L_tx_pulse_processing60
L_tx_pulse_processing59:
;WLS.c,470 :: 		alternate_beepdivider_time--;
	MOVLW      1
	SUBWF      WLS_alternate_beepdivider_time+0, 1
	MOVLW      0
	SUBWFB     WLS_alternate_beepdivider_time+1, 1
;WLS.c,471 :: 		beepdivider = alternate_beepdivider;
	MOVF       WLS_alternate_beepdivider+0, 0
	MOVWF      WLS_beepdivider+0
	MOVF       WLS_alternate_beepdivider+1, 0
	MOVWF      WLS_beepdivider+1
;WLS.c,472 :: 		}
L_tx_pulse_processing60:
;WLS.c,475 :: 		if (beepdivider < beepcnt)
	MOVF       WLS_beepcnt+1, 0
	SUBWF      WLS_beepdivider+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__tx_pulse_processing101
	MOVF       WLS_beepcnt+0, 0
	SUBWF      WLS_beepdivider+0, 0
L__tx_pulse_processing101:
	BTFSC      STATUS+0, 0
	GOTO       L_tx_pulse_processing61
;WLS.c,477 :: 		beepcnt = beepdivider;
	MOVF       WLS_beepdivider+0, 0
	MOVWF      WLS_beepcnt+0
	MOVF       WLS_beepdivider+1, 0
	MOVWF      WLS_beepcnt+1
;WLS.c,478 :: 		}
L_tx_pulse_processing61:
;WLS.c,479 :: 		} // if (!startup_delay)
L_tx_pulse_processing50:
;WLS.c,482 :: 		if (PP_BUTTON)
	BTFSS      PORTA+0, 3
	GOTO       L_tx_pulse_processing62
;WLS.c,484 :: 		pulse_average_array[pulse_average_cnt%pulse_array_size] = pulsevalue;
	MOVF       WLS_pulse_array_size+0, 0
	MOVWF      R4
	MOVF       WLS_pulse_average_cnt+0, 0
	MOVWF      R0
	CALL       _Div_8x8_U+0
	MOVF       R8, 0
	MOVWF      R0
	MOVLW      WLS_pulse_average_array+0
	MOVWF      R4
	MOVLW      hi_addr(WLS_pulse_average_array+0)
	MOVWF      R5
	MOVF       R0, 0
	MOVWF      R1
	CLRF       R2
	LSLF       R1, 1
	RLF        R2, 1
	LSLF       R1, 1
	RLF        R2, 1
	MOVF       R1, 0
	ADDWF      R4, 0
	MOVWF      FSR1L
	MOVF       R2, 0
	ADDWFC     R5, 0
	MOVWF      FSR1H
	MOVF       tx_pulse_processing_pulsevalue_L0+0, 0
	MOVWF      INDF1+0
	MOVF       tx_pulse_processing_pulsevalue_L0+1, 0
	ADDFSR     1, 1
	MOVWF      INDF1+0
	MOVF       tx_pulse_processing_pulsevalue_L0+2, 0
	ADDFSR     1, 1
	MOVWF      INDF1+0
	MOVF       tx_pulse_processing_pulsevalue_L0+3, 0
	ADDFSR     1, 1
	MOVWF      INDF1+0
;WLS.c,485 :: 		}
L_tx_pulse_processing62:
;WLS.c,490 :: 		pulsevalue  = 0;
	CLRF       tx_pulse_processing_pulsevalue_L0+0
	CLRF       tx_pulse_processing_pulsevalue_L0+1
	CLRF       tx_pulse_processing_pulsevalue_L0+2
	CLRF       tx_pulse_processing_pulsevalue_L0+3
;WLS.c,491 :: 		pulse_average_cnt++;
	INCF       WLS_pulse_average_cnt+0, 1
;WLS.c,492 :: 		measurecnt = accumulate_measure_cnt;
	MOVF       WLS_accumulate_measure_cnt+0, 0
	MOVWF      WLS_measurecnt+0
	MOVF       WLS_accumulate_measure_cnt+1, 0
	MOVWF      WLS_measurecnt+1
;WLS.c,493 :: 		} // if (!measurecnt
L_tx_pulse_processing49:
;WLS.c,496 :: 		}
L_end_tx_pulse_processing:
	RETURN
; end of _tx_pulse_processing

_main:

;WLS.c,502 :: 		void main()
;WLS.c,505 :: 		unsigned int new_sensitivity, old_sensitivity = 1;
	MOVLW      1
	MOVWF      main_old_sensitivity_L0+0
	MOVLW      0
	MOVWF      main_old_sensitivity_L0+1
;WLS.c,506 :: 		accumulate_measure_cnt = ACCUMULATE_MEASURE_CNT;
	MOVLW      5
	MOVWF      WLS_accumulate_measure_cnt+0
	MOVLW      0
	MOVWF      WLS_accumulate_measure_cnt+1
;WLS.c,507 :: 		measurecnt = accumulate_measure_cnt;
	MOVLW      5
	MOVWF      WLS_measurecnt+0
	MOVLW      0
	MOVWF      WLS_measurecnt+1
;WLS.c,508 :: 		sensitivity_flag = TRUE;
	MOVLW      1
	MOVWF      WLS_sensitivity_flag+0
;WLS.c,509 :: 		pulse_flag = FALSE;
	CLRF       WLS_pulse_flag+0
;WLS.c,510 :: 		beepdivider = 2048;
	MOVLW      0
	MOVWF      WLS_beepdivider+0
	MOVLW      8
	MOVWF      WLS_beepdivider+1
;WLS.c,511 :: 		beepcnt = 2048;
	MOVLW      0
	MOVWF      WLS_beepcnt+0
	MOVLW      8
	MOVWF      WLS_beepcnt+1
;WLS.c,512 :: 		lv_time = LV_TIME_DIVIDER;
	MOVLW      80
	MOVWF      WLS_lv_time+0
	MOVLW      195
	MOVWF      WLS_lv_time+1
;WLS.c,513 :: 		lv_flag = FALSE;
	CLRF       WLS_lv_flag+0
;WLS.c,514 :: 		startup_delay = STARTUP_DELAY;
	MOVLW      136
	MOVWF      WLS_startup_delay+0
	MOVLW      19
	MOVWF      WLS_startup_delay+1
;WLS.c,515 :: 		sensitivity_time = SENSITIVITY_TIME_DIVIDER;
	MOVLW      208
	MOVWF      WLS_sensitivity_time+0
	MOVLW      7
	MOVWF      WLS_sensitivity_time+1
;WLS.c,516 :: 		pulse_time = PULSE_TIME_DIVIDER;
	MOVLW      4
	MOVWF      WLS_pulse_time+0
	MOVLW      0
	MOVWF      WLS_pulse_time+1
;WLS.c,517 :: 		DAC_value = 16;
	MOVLW      16
	MOVWF      WLS_DAC_value+0
;WLS.c,518 :: 		calibration_delay = CALIBRATION_DELAY;
	MOVLW      220
	MOVWF      WLS_calibration_delay+0
	MOVLW      5
	MOVWF      WLS_calibration_delay+1
;WLS.c,519 :: 		calibration_steps = 31;
	MOVLW      31
	MOVWF      WLS_calibration_steps+0
;WLS.c,520 :: 		calibration_busy = 1;
	MOVLW      1
	MOVWF      WLS_calibration_busy+0
;WLS.c,521 :: 		PWM_duty = 0;  // 0...127
	CLRF       WLS_PWM_duty+0
;WLS.c,522 :: 		pulse_average_cnt = 0;
	CLRF       WLS_pulse_average_cnt+0
;WLS.c,523 :: 		pulse_array_size = PULSE_ARRAY_SIZE;
	MOVLW      32
	MOVWF      WLS_pulse_array_size+0
;WLS.c,524 :: 		pulse_array_shift = 5;
	MOVLW      5
	MOVWF      WLS_pulse_array_shift+0
;WLS.c,525 :: 		alternate_beepdivider_time = 0;
	CLRF       WLS_alternate_beepdivider_time+0
	CLRF       WLS_alternate_beepdivider_time+1
;WLS.c,528 :: 		OSCCON= 0xF0;
	MOVLW      240
	MOVWF      OSCCON+0
;WLS.c,532 :: 		TRISA.TRISA0 = OUT;  // PIN 13DAC out
	BCF        TRISA+0, 0
;WLS.c,533 :: 		PORTA.RA0 = 1;
	BSF        PORTA+0, 0
;WLS.c,534 :: 		WPUA.WPUA0 = 0;     // disable pullup R for DAC out !!
	BCF        WPUA+0, 0
;WLS.c,535 :: 		TRISA.TRISA1 = IN;   // PIN 12 - low battery detection
	BSF        TRISA+0, 1
;WLS.c,536 :: 		PORTA.RA1 = 1;
	BSF        PORTA+0, 1
;WLS.c,537 :: 		TRISA.TRISA2 = OUT;  // PIN 11  - COMP1 out
	BCF        TRISA+0, 2
;WLS.c,538 :: 		PORTA.RA2 = 1;
	BSF        PORTA+0, 2
;WLS.c,539 :: 		TRISA.TRISA3 = OUT;  // PIN 4
	BCF        TRISA+0, 3
;WLS.c,540 :: 		PORTA.RA3 = 1;
	BSF        PORTA+0, 3
;WLS.c,541 :: 		TRISA.TRISA4 = IN;   // PIN 3 sensitivity potmeter in
	BSF        TRISA+0, 4
;WLS.c,542 :: 		PORTA.RA4 = 1;
	BSF        PORTA+0, 4
;WLS.c,543 :: 		TRISA.TRISA5 = OUT;  // PIN 2 PWM2 out
	BCF        TRISA+0, 5
;WLS.c,544 :: 		PORTA.RA5 = 1;
	BSF        PORTA+0, 5
;WLS.c,547 :: 		TRISC.TRISC0 = IN;  // PIN 10 comparator2 + in
	BSF        TRISC+0, 0
;WLS.c,548 :: 		PORTC.RC0 = 1;
	BSF        PORTC+0, 0
;WLS.c,549 :: 		TRISC.TRISC1 = IN;  // PIN 9 = comparator in
	BSF        TRISC+0, 1
;WLS.c,550 :: 		PORTC.RC1 = 1;
	BSF        PORTC+0, 1
;WLS.c,551 :: 		TRISC.TRISC2 = IN;  // PIN 8 = ADC6 in
	BSF        TRISC+0, 2
;WLS.c,552 :: 		PORTC.RC2 = 1;
	BSF        PORTC+0, 2
;WLS.c,553 :: 		TRISC.TRISC3 = OUT;  // PIN 7 = RS232 out
	BCF        TRISC+0, 3
;WLS.c,554 :: 		PORTC.RC3 = 1;
	BSF        PORTC+0, 3
;WLS.c,555 :: 		TRISC.TRISC4 = OUT; // PIN 6 comparator 2 out
	BCF        TRISC+0, 4
;WLS.c,556 :: 		PORTC.RC4 = 1;
	BSF        PORTC+0, 4
;WLS.c,557 :: 		TRISC.TRISC5 = OUT; // PIN 5 pulse out
	BCF        TRISC+0, 5
;WLS.c,558 :: 		PORTC.RC5 = 1;
	BSF        PORTC+0, 5
;WLS.c,561 :: 		ANSELA.ANSA0 = 1;     // DAC out
	BSF        ANSELA+0, 0
;WLS.c,562 :: 		ANSELA.ANSA1 = 1;     // low battery detection
	BSF        ANSELA+0, 1
;WLS.c,563 :: 		ANSELA.ANSA4 = 1;     // sensititity potmeter in
	BSF        ANSELA+0, 4
;WLS.c,564 :: 		ANSELC.ANSC0 = 1;     // comparator 2 + in
	BSF        ANSELC+0, 0
;WLS.c,565 :: 		ANSELC.ANSC1 = 1;     // pulse in
	BSF        ANSELC+0, 1
;WLS.c,566 :: 		ANSELC.ANSC2 = 1;     // pulse in
	BSF        ANSELC+0, 2
;WLS.c,569 :: 		T1GCON.TMR1GE = 1;
	BSF        T1GCON+0, 7
;WLS.c,570 :: 		T1GCON.T1GPOL = 1; // timer 1 gate active high
	BSF        T1GCON+0, 6
;WLS.c,571 :: 		T1GCON.T1GTM = 0;
	BCF        T1GCON+0, 5
;WLS.c,572 :: 		T1GCON.T1GSPM = 0;
	BCF        T1GCON+0, 4
;WLS.c,573 :: 		T1GCON.T1GSS1 = 1;  // comparator 2
	BSF        T1GCON+0, 1
;WLS.c,574 :: 		T1GCON.T1GSS0 = 1;  // comparator 2
	BSF        T1GCON+0, 0
;WLS.c,575 :: 		T1CON.T1CKPS0 = 0;
	BCF        T1CON+0, 4
;WLS.c,576 :: 		T1CON.T1CKPS1 = 0;                // timer 1 prescaler = 0
	BCF        T1CON+0, 5
;WLS.c,577 :: 		T1CON.TMR1CS0 = 1;                // timer 1 clock = Fosc
	BSF        T1CON+0, 6
;WLS.c,578 :: 		T1CON.TMR1CS1 = 0;                // timer 1 clock = Fosc
	BCF        T1CON+0, 7
;WLS.c,579 :: 		T1CON.T1OSCEN = 0;                // timer 1 internal oscillator
	BCF        T1CON+0, 3
;WLS.c,580 :: 		T1CON.TMR1ON = 1;                // timer 1 active
	BSF        T1CON+0, 0
;WLS.c,581 :: 		TMR1H = 0;          // initial timer values
	CLRF       TMR1H+0
;WLS.c,582 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;WLS.c,583 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;WLS.c,587 :: 		DACCON0.DACEN = 1;          // DAC enable
	BSF        DACCON0+0, 7
;WLS.c,588 :: 		DACCON0.DACLPS = 0;         // Negative reference
	BCF        DACCON0+0, 6
;WLS.c,589 :: 		DACCON0.DACOE = 1;          // DAC output enable
	BSF        DACCON0+0, 5
;WLS.c,590 :: 		DACCON0.DACPSS0 = 0;        // VDD
	BCF        DACCON0+0, 2
;WLS.c,591 :: 		DACCON0.DACPSS1 = 0;        // VDD
	BCF        DACCON0+0, 3
;WLS.c,592 :: 		DACCON0.DACNSS = 0;         // GND
	BCF        DACCON0+0, 0
;WLS.c,595 :: 		DAC_value = EEPROM_Read(0x00);
	CLRF       FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0, 0
	MOVWF      WLS_DAC_value+0
;WLS.c,596 :: 		if (DAC_value > 32)
	MOVF       R0, 0
	SUBLW      32
	BTFSC      STATUS+0, 0
	GOTO       L_main63
;WLS.c,599 :: 		DAC_value = 16;
	MOVLW      16
	MOVWF      WLS_DAC_value+0
;WLS.c,600 :: 		}
L_main63:
;WLS.c,604 :: 		DACCON1 = DAC_value;
	MOVF       WLS_DAC_value+0, 0
	MOVWF      DACCON1+0
;WLS.c,607 :: 		ADCON0.ADON = 1;            //  ADC on
	BSF        ADCON0+0, 0
;WLS.c,608 :: 		ADCON1.ADFM = 1;            // right justified
	BSF        ADCON1+0, 7
;WLS.c,609 :: 		ADCON1.ADCS0 = 0;           // Fosc / 64
	BCF        ADCON1+0, 4
;WLS.c,610 :: 		ADCON1.ADCS1 = 1;           // Fosc / 64
	BSF        ADCON1+0, 5
;WLS.c,611 :: 		ADCON1.ADCS2 = 1;           // Fosc / 64
	BSF        ADCON1+0, 6
;WLS.c,612 :: 		ADCON1.ADNREF = 0;          // Vref- = VSS
	BCF        ADCON1+0, 2
;WLS.c,613 :: 		ADCON1.ADPREF0 = 0;         // Vref+ = VDD
	BCF        ADCON1+0, 0
;WLS.c,614 :: 		ADCON1.ADPREF1 = 0;         // Vref+ = VDD
	BCF        ADCON1+0, 1
;WLS.c,617 :: 		CM2CON0.C2POL = 0;      // comp output polarity is not inverted
	BCF        CM2CON0+0, 4
;WLS.c,618 :: 		CM2CON0.C2OE = 1;       // comp output enabled
	BSF        CM2CON0+0, 5
;WLS.c,619 :: 		CM2CON0.C2SP = 1;       // high speed
	BSF        CM2CON0+0, 2
;WLS.c,620 :: 		CM2CON0.C2ON = 1;       // comp is enabled
	BSF        CM2CON0+0, 7
;WLS.c,621 :: 		CM2CON0.C2HYS = 1;      // hysteresis enabled
	BSF        CM2CON0+0, 1
;WLS.c,622 :: 		CM2CON0.C2SYNC = 1;     // comp output synchronous with timer 1
	BSF        CM2CON0+0, 0
;WLS.c,624 :: 		CM2CON1.C2NCH0 = 1;     // C12IN1-
	BSF        CM2CON1+0, 0
;WLS.c,625 :: 		CM2CON1.C2NCH1 = 0;     // C12IN1-
	BCF        CM2CON1+0, 1
;WLS.c,626 :: 		CM2CON1.C2PCH0 = 0;     // comparator + input pin
	BCF        CM2CON1+0, 4
;WLS.c,627 :: 		CM2CON1.C2PCH1 = 0;     // comparator + input pin
	BCF        CM2CON1+0, 5
;WLS.c,630 :: 		OPTION_REG.PS0 = 1;
	BSF        OPTION_REG+0, 0
;WLS.c,631 :: 		OPTION_REG.PS1 = 1;
	BSF        OPTION_REG+0, 1
;WLS.c,632 :: 		OPTION_REG.PS2 = 0;      //prescaler / 16
	BCF        OPTION_REG+0, 2
;WLS.c,633 :: 		OPTION_REG.PSA = 0;
	BCF        OPTION_REG+0, 3
;WLS.c,634 :: 		OPTION_REG.TMR0CS = 0;  // FOSC / 4   --> 8 MHz
	BCF        OPTION_REG+0, 5
;WLS.c,635 :: 		INTCON.TMR0IE = 1;          // timer0 interrupt enable
	BSF        INTCON+0, 5
;WLS.c,640 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;WLS.c,645 :: 		APFCON1.CCP2SEL = 1;
	BSF        APFCON1+0, 0
;WLS.c,647 :: 		PWM2_Init(250000);          // 250 kHz
	BCF        T2CON+0, 0
	BCF        T2CON+0, 1
	MOVLW      31
	MOVWF      PR2+0
	CALL       _PWM2_Init+0
;WLS.c,648 :: 		PWM2_Set_Duty(127);
	MOVLW      127
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;WLS.c,649 :: 		PWM2_Start();
	CALL       _PWM2_Start+0
;WLS.c,652 :: 		start_sound();
	CALL       _start_sound+0
;WLS.c,655 :: 		while(1)
L_main64:
;WLS.c,658 :: 		if (pulse_flag)
	MOVF       WLS_pulse_flag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main66
;WLS.c,661 :: 		tx_pulse_processing();
	CALL       _tx_pulse_processing+0
;WLS.c,662 :: 		pulse_flag = FALSE;
	CLRF       WLS_pulse_flag+0
;WLS.c,663 :: 		}
L_main66:
;WLS.c,667 :: 		if (lv_flag)
	MOVF       WLS_lv_flag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main67
;WLS.c,669 :: 		lv_flag = FALSE;
	CLRF       WLS_lv_flag+0
;WLS.c,671 :: 		batt_voltage =  ADC_Read(1);
	MOVLW      1
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
;WLS.c,673 :: 		if (batt_voltage < LOW_BATT_LIMIT )
	MOVLW      2
	SUBWF      R1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main103
	MOVLW      0
	SUBWF      R0, 0
L__main103:
	BTFSC      STATUS+0, 0
	GOTO       L_main68
;WLS.c,675 :: 		alternate_beepdivider_time = 250;
	MOVLW      250
	MOVWF      WLS_alternate_beepdivider_time+0
	CLRF       WLS_alternate_beepdivider_time+1
;WLS.c,676 :: 		alternate_beepdivider_time = 4;
	MOVLW      4
	MOVWF      WLS_alternate_beepdivider_time+0
	MOVLW      0
	MOVWF      WLS_alternate_beepdivider_time+1
;WLS.c,677 :: 		}
L_main68:
;WLS.c,678 :: 		}
L_main67:
;WLS.c,682 :: 		if (sensitivity_flag)
	MOVF       WLS_sensitivity_flag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main69
;WLS.c,686 :: 		new_sensitivity = (ADC_Read(3) >> 4);
	MOVLW      3
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0, 0
	MOVWF      R2
	MOVF       R1, 0
	MOVWF      R3
	LSRF       R3, 1
	RRF        R2, 1
	LSRF       R3, 1
	RRF        R2, 1
	LSRF       R3, 1
	RRF        R2, 1
	LSRF       R3, 1
	RRF        R2, 1
	MOVF       R2, 0
	MOVWF      main_new_sensitivity_L0+0
	MOVF       R3, 0
	MOVWF      main_new_sensitivity_L0+1
;WLS.c,687 :: 		if (new_sensitivity < 4)
	MOVLW      0
	SUBWF      R3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main104
	MOVLW      4
	SUBWF      R2, 0
L__main104:
	BTFSC      STATUS+0, 0
	GOTO       L_main70
;WLS.c,689 :: 		new_sensitivity = 4;
	MOVLW      4
	MOVWF      main_new_sensitivity_L0+0
	MOVLW      0
	MOVWF      main_new_sensitivity_L0+1
;WLS.c,690 :: 		}
L_main70:
;WLS.c,691 :: 		if ( new_sensitivity > 63)
	MOVF       main_new_sensitivity_L0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main105
	MOVF       main_new_sensitivity_L0+0, 0
	SUBLW      63
L__main105:
	BTFSC      STATUS+0, 0
	GOTO       L_main71
;WLS.c,693 :: 		new_sensitivity = 63;
	MOVLW      63
	MOVWF      main_new_sensitivity_L0+0
	MOVLW      0
	MOVWF      main_new_sensitivity_L0+1
;WLS.c,694 :: 		}
L_main71:
;WLS.c,696 :: 		if (absvalue(old_sensitivity, new_sensitivity) > 1)
	MOVF       main_old_sensitivity_L0+0, 0
	MOVWF      FARG_absvalue_a+0
	MOVF       main_old_sensitivity_L0+1, 0
	MOVWF      FARG_absvalue_a+1
	CLRF       FARG_absvalue_a+2
	CLRF       FARG_absvalue_a+3
	MOVF       main_new_sensitivity_L0+0, 0
	MOVWF      FARG_absvalue_b+0
	MOVF       main_new_sensitivity_L0+1, 0
	MOVWF      FARG_absvalue_b+1
	CLRF       FARG_absvalue_b+2
	CLRF       FARG_absvalue_b+3
	CALL       _absvalue+0
	MOVF       R3, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main106
	MOVF       R2, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main106
	MOVF       R1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main106
	MOVF       R0, 0
	SUBLW      1
L__main106:
	BTFSC      STATUS+0, 0
	GOTO       L_main72
;WLS.c,698 :: 		accumulate_measure_cnt = new_sensitivity;
	MOVF       main_new_sensitivity_L0+0, 0
	MOVWF      WLS_accumulate_measure_cnt+0
	MOVF       main_new_sensitivity_L0+1, 0
	MOVWF      WLS_accumulate_measure_cnt+1
;WLS.c,699 :: 		}
L_main72:
;WLS.c,702 :: 		old_sensitivity = new_sensitivity;
	MOVF       main_new_sensitivity_L0+0, 0
	MOVWF      main_old_sensitivity_L0+0
	MOVF       main_new_sensitivity_L0+1, 0
	MOVWF      main_old_sensitivity_L0+1
;WLS.c,703 :: 		sensitivity_flag = FALSE;
	CLRF       WLS_sensitivity_flag+0
;WLS.c,707 :: 		if (new_sensitivity < 15)
	MOVLW      0
	SUBWF      main_new_sensitivity_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main107
	MOVLW      15
	SUBWF      main_new_sensitivity_L0+0, 0
L__main107:
	BTFSC      STATUS+0, 0
	GOTO       L_main73
;WLS.c,709 :: 		pulse_array_size = 32;
	MOVLW      32
	MOVWF      WLS_pulse_array_size+0
;WLS.c,710 :: 		pulse_array_shift = 5;
	MOVLW      5
	MOVWF      WLS_pulse_array_shift+0
;WLS.c,711 :: 		PWM2_Set_Duty(DC_offset - 10);
	MOVLW      10
	SUBWF      WLS_DC_offset+0, 0
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;WLS.c,712 :: 		}
	GOTO       L_main74
L_main73:
;WLS.c,713 :: 		else if (new_sensitivity < 30)
	MOVLW      0
	SUBWF      main_new_sensitivity_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main108
	MOVLW      30
	SUBWF      main_new_sensitivity_L0+0, 0
L__main108:
	BTFSC      STATUS+0, 0
	GOTO       L_main75
;WLS.c,715 :: 		pulse_array_size = 16;
	MOVLW      16
	MOVWF      WLS_pulse_array_size+0
;WLS.c,716 :: 		pulse_array_shift = 4;
	MOVLW      4
	MOVWF      WLS_pulse_array_shift+0
;WLS.c,717 :: 		PWM2_Set_Duty(DC_offset - 5);
	MOVLW      5
	SUBWF      WLS_DC_offset+0, 0
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;WLS.c,718 :: 		}
	GOTO       L_main76
L_main75:
;WLS.c,719 :: 		else if (new_sensitivity < 40)
	MOVLW      0
	SUBWF      main_new_sensitivity_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main109
	MOVLW      40
	SUBWF      main_new_sensitivity_L0+0, 0
L__main109:
	BTFSC      STATUS+0, 0
	GOTO       L_main77
;WLS.c,721 :: 		pulse_array_size = 8;
	MOVLW      8
	MOVWF      WLS_pulse_array_size+0
;WLS.c,722 :: 		pulse_array_shift = 3;
	MOVLW      3
	MOVWF      WLS_pulse_array_shift+0
;WLS.c,723 :: 		PWM2_Set_Duty(DC_offset);
	MOVF       WLS_DC_offset+0, 0
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;WLS.c,724 :: 		}
	GOTO       L_main78
L_main77:
;WLS.c,727 :: 		pulse_array_size = 4;
	MOVLW      4
	MOVWF      WLS_pulse_array_size+0
;WLS.c,728 :: 		pulse_array_shift = 2;
	MOVLW      2
	MOVWF      WLS_pulse_array_shift+0
;WLS.c,729 :: 		PWM2_Set_Duty(DC_offset);
	MOVF       WLS_DC_offset+0, 0
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;WLS.c,730 :: 		}
L_main78:
L_main76:
L_main74:
;WLS.c,732 :: 		} // if sensitivity flag
L_main69:
;WLS.c,734 :: 		}  // while(1)
	GOTO       L_main64
;WLS.c,736 :: 		} //~!
L_end_main:
	GOTO       $+0
; end of _main
