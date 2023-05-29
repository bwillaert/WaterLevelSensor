
_interrupt:
	CLRF       PCLATH+0
	CLRF       STATUS+0

;WLS2.c,42 :: 		void interrupt(void)
;WLS2.c,46 :: 		if (PIR2.C1IF)
	BTFSS      PIR2+0, 5
	GOTO       L_interrupt0
;WLS2.c,48 :: 		actual_nr_pulses++;
	MOVLW      1
	ADDWF      WLS2_actual_nr_pulses+0, 1
	MOVLW      0
	ADDWFC     WLS2_actual_nr_pulses+1, 1
	ADDWFC     WLS2_actual_nr_pulses+2, 1
	ADDWFC     WLS2_actual_nr_pulses+3, 1
;WLS2.c,49 :: 		PIR2.C1IF = FALSE;
	BCF        PIR2+0, 5
;WLS2.c,50 :: 		}
L_interrupt0:
;WLS2.c,52 :: 		}
L_end_interrupt:
L__interrupt11:
	RETFIE     %s
; end of _interrupt

_sendchar:

;WLS2.c,58 :: 		void sendchar( char c)
;WLS2.c,60 :: 		while (!UART1_Tx_Idle())
L_sendchar1:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_sendchar2
;WLS2.c,62 :: 		Delay_us(100);
	MOVLW      66
	MOVWF      R13
L_sendchar3:
	DECFSZ     R13, 1
	GOTO       L_sendchar3
	NOP
;WLS2.c,63 :: 		}
	GOTO       L_sendchar1
L_sendchar2:
;WLS2.c,64 :: 		UART1_Write(c);
	MOVF       FARG_sendchar_c+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;WLS2.c,65 :: 		}
L_end_sendchar:
	RETURN
; end of _sendchar

_sendhex:

;WLS2.c,70 :: 		void sendhex(unsigned long hexnumber)
;WLS2.c,72 :: 		int nibble = 0;
	CLRF       sendhex_nibble_L0+0
	CLRF       sendhex_nibble_L0+1
;WLS2.c,75 :: 		sendchar('\n');
	MOVLW      10
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;WLS2.c,76 :: 		for (nibble = 0; nibble < 8; nibble++)
	CLRF       sendhex_nibble_L0+0
	CLRF       sendhex_nibble_L0+1
L_sendhex4:
	MOVLW      128
	XORWF      sendhex_nibble_L0+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sendhex14
	MOVLW      8
	SUBWF      sendhex_nibble_L0+0, 0
L__sendhex14:
	BTFSC      STATUS+0, 0
	GOTO       L_sendhex5
;WLS2.c,78 :: 		sendchar(hexnr[(hexnumber&0xF0000000)>>28]);
	MOVLW      0
	ANDWF      FARG_sendhex_hexnumber+0, 0
	MOVWF      R5
	MOVLW      0
	ANDWF      FARG_sendhex_hexnumber+1, 0
	MOVWF      R6
	MOVLW      0
	ANDWF      FARG_sendhex_hexnumber+2, 0
	MOVWF      R7
	MOVLW      240
	ANDWF      FARG_sendhex_hexnumber+3, 0
	MOVWF      R8
	MOVLW      28
	MOVWF      R4
	MOVF       R5, 0
	MOVWF      R0
	MOVF       R6, 0
	MOVWF      R1
	MOVF       R7, 0
	MOVWF      R2
	MOVF       R8, 0
	MOVWF      R3
	MOVF       R4, 0
L__sendhex15:
	BTFSC      STATUS+0, 2
	GOTO       L__sendhex16
	LSRF       R3, 1
	RRF        R2, 1
	RRF        R1, 1
	RRF        R0, 1
	ADDLW      255
	GOTO       L__sendhex15
L__sendhex16:
	MOVLW      sendhex_hexnr_L0+0
	ADDWF      R0, 0
	MOVWF      FSR0L
	MOVLW      hi_addr(sendhex_hexnr_L0+0)
	ADDWFC     R1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;WLS2.c,79 :: 		hexnumber<<=4;
	MOVLW      4
	MOVWF      R0
	MOVF       R0, 0
L__sendhex17:
	BTFSC      STATUS+0, 2
	GOTO       L__sendhex18
	LSLF       FARG_sendhex_hexnumber+0, 1
	RLF        FARG_sendhex_hexnumber+1, 1
	RLF        FARG_sendhex_hexnumber+2, 1
	RLF        FARG_sendhex_hexnumber+3, 1
	ADDLW      255
	GOTO       L__sendhex17
L__sendhex18:
;WLS2.c,76 :: 		for (nibble = 0; nibble < 8; nibble++)
	INCF       sendhex_nibble_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       sendhex_nibble_L0+1, 1
;WLS2.c,80 :: 		}
	GOTO       L_sendhex4
L_sendhex5:
;WLS2.c,81 :: 		}
L_end_sendhex:
	RETURN
; end of _sendhex

_measure_frequency:

;WLS2.c,84 :: 		unsigned long measure_frequency()
;WLS2.c,86 :: 		actual_nr_pulses =0;
	CLRF       WLS2_actual_nr_pulses+0
	CLRF       WLS2_actual_nr_pulses+1
	CLRF       WLS2_actual_nr_pulses+2
	CLRF       WLS2_actual_nr_pulses+3
;WLS2.c,87 :: 		Delay_ms(1000);
	MOVLW      11
	MOVWF      R11
	MOVLW      38
	MOVWF      R12
	MOVLW      93
	MOVWF      R13
L_measure_frequency7:
	DECFSZ     R13, 1
	GOTO       L_measure_frequency7
	DECFSZ     R12, 1
	GOTO       L_measure_frequency7
	DECFSZ     R11, 1
	GOTO       L_measure_frequency7
	NOP
	NOP
;WLS2.c,88 :: 		return actual_nr_pulses;
	MOVF       WLS2_actual_nr_pulses+0, 0
	MOVWF      R0
	MOVF       WLS2_actual_nr_pulses+1, 0
	MOVWF      R1
	MOVF       WLS2_actual_nr_pulses+2, 0
	MOVWF      R2
	MOVF       WLS2_actual_nr_pulses+3, 0
	MOVWF      R3
;WLS2.c,89 :: 		}
L_end_measure_frequency:
	RETURN
; end of _measure_frequency

_init:

;WLS2.c,93 :: 		void init()
;WLS2.c,96 :: 		OSCCON = 0xF0;
	MOVLW      240
	MOVWF      OSCCON+0
;WLS2.c,100 :: 		TRISA.TRISA0 = OUT;  // PIN 7
	BCF        TRISA+0, 0
;WLS2.c,101 :: 		PORTA.RA0 = 1;
	BSF        PORTA+0, 0
;WLS2.c,102 :: 		TRISA.TRISA1 = OUT;  // PIN 6
	BCF        TRISA+0, 1
;WLS2.c,103 :: 		PORTA.RA1 = 1;
	BSF        PORTA+0, 1
;WLS2.c,104 :: 		TRISA.TRISA2 = OUT;  // PIN 5
	BCF        TRISA+0, 2
;WLS2.c,105 :: 		PORTA.RA2 = 1;
	BSF        PORTA+0, 2
;WLS2.c,106 :: 		TRISA.TRISA3 = IN;   // PIN 4
	BSF        TRISA+0, 3
;WLS2.c,107 :: 		PORTA.RA3 = 1;
	BSF        PORTA+0, 3
;WLS2.c,108 :: 		TRISA.TRISA4 = IN;   // PIN 3
	BSF        TRISA+0, 4
;WLS2.c,109 :: 		PORTA.RA4 = 1;
	BSF        PORTA+0, 4
;WLS2.c,110 :: 		TRISA.TRISA5 = OUT;  // PIN 2
	BCF        TRISA+0, 5
;WLS2.c,111 :: 		PORTA.RA5 = 1;
	BSF        PORTA+0, 5
;WLS2.c,115 :: 		ANSELA.ANSA4 = 1;     // comparator-
	BSF        ANSELA+0, 4
;WLS2.c,121 :: 		CM1CON0.C1POL = 0;      // comp output polarity is not inverted
	BCF        CM1CON0+0, 4
;WLS2.c,122 :: 		CM1CON0.C1OE = 1;       // comp output enabled
	BSF        CM1CON0+0, 5
;WLS2.c,123 :: 		CM1CON0.C1SP = 1;       // high speed
	BSF        CM1CON0+0, 2
;WLS2.c,124 :: 		CM1CON0.C1ON = 1;       // comp is enabled
	BSF        CM1CON0+0, 7
;WLS2.c,125 :: 		CM1CON0.C1HYS = 1;      // hysteresis enabled
	BSF        CM1CON0+0, 1
;WLS2.c,126 :: 		CM1CON0.C1SYNC = 0;     // comp output synchronous with timer 1
	BCF        CM1CON0+0, 0
;WLS2.c,128 :: 		CM1CON1.C1NCH = 1;      // C1IN1-
	BSF        CM1CON1+0, 0
;WLS2.c,129 :: 		CM1CON1.C1PCH0 = 0;     // comparator + Fixed Voltage Reference
	BCF        CM1CON1+0, 4
;WLS2.c,130 :: 		CM1CON1.C1PCH1 = 1;     // comparator + Fixed Voltage Reference
	BSF        CM1CON1+0, 5
;WLS2.c,131 :: 		CM1CON1.C1INTP = 1;     // comparator interrupt on positive edge
	BSF        CM1CON1+0, 7
;WLS2.c,132 :: 		CM1CON1.C1INTN = 0;
	BCF        CM1CON1+0, 6
;WLS2.c,133 :: 		PIE2.C1IE = 1;          // comparator 1 interrupt enabled
	BSF        PIE2+0, 5
;WLS2.c,136 :: 		FVRCON.FVREN = 1;          // Fixed Voltage Reference Enable bit
	BSF        FVRCON+0, 7
;WLS2.c,137 :: 		FVRCON.CDAFVR0 = 0;        // Fixed Voltage Reference Peripheral output is 2x (2.048V)
	BCF        FVRCON+0, 2
;WLS2.c,138 :: 		FVRCON.CDAFVR1 = 1;        // Fixed Voltage Reference Peripheral output is 2x (2.048V)
	BSF        FVRCON+0, 3
;WLS2.c,142 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;WLS2.c,145 :: 		}
L_end_init:
	RETURN
; end of _init

_main:

;WLS2.c,152 :: 		void main()
;WLS2.c,156 :: 		init();
	CALL       _init+0
;WLS2.c,159 :: 		while(1)
L_main8:
;WLS2.c,162 :: 		frequency = measure_frequency();
	CALL       _measure_frequency+0
	MOVF       R0, 0
	MOVWF      WLS2_frequency+0
	MOVF       R1, 0
	MOVWF      WLS2_frequency+1
	MOVF       R2, 0
	MOVWF      WLS2_frequency+2
	MOVF       R3, 0
	MOVWF      WLS2_frequency+3
;WLS2.c,165 :: 		sendhex(frequency);
	MOVF       R0, 0
	MOVWF      FARG_sendhex_hexnumber+0
	MOVF       R1, 0
	MOVWF      FARG_sendhex_hexnumber+1
	MOVF       R2, 0
	MOVWF      FARG_sendhex_hexnumber+2
	MOVF       R3, 0
	MOVWF      FARG_sendhex_hexnumber+3
	CALL       _sendhex+0
;WLS2.c,166 :: 		}
	GOTO       L_main8
;WLS2.c,167 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
