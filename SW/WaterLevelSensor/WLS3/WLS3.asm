
_interrupt:
	CLRF       PCLATH+0
	CLRF       STATUS+0

;WLS3.c,43 :: 		void interrupt(void)
;WLS3.c,46 :: 		if (PIR1.TMR1IF)
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt0
;WLS3.c,48 :: 		tmr1_overflow++;
	MOVLW      1
	ADDWF      WLS3_tmr1_overflow+0, 1
	MOVLW      0
	ADDWFC     WLS3_tmr1_overflow+1, 1
	ADDWFC     WLS3_tmr1_overflow+2, 1
	ADDWFC     WLS3_tmr1_overflow+3, 1
;WLS3.c,49 :: 		PIR1.TMR1IF = FALSE;
	BCF        PIR1+0, 0
;WLS3.c,50 :: 		}
L_interrupt0:
;WLS3.c,51 :: 		}
L_end_interrupt:
L__interrupt12:
	RETFIE     %s
; end of _interrupt

_sendchar:

;WLS3.c,57 :: 		void sendchar( char c)
;WLS3.c,59 :: 		while (!UART1_Tx_Idle())
L_sendchar1:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_sendchar2
;WLS3.c,61 :: 		Delay_us(100);
	MOVLW      66
	MOVWF      R13
L_sendchar3:
	DECFSZ     R13, 1
	GOTO       L_sendchar3
	NOP
;WLS3.c,62 :: 		}
	GOTO       L_sendchar1
L_sendchar2:
;WLS3.c,63 :: 		UART1_Write(c);
	MOVF       FARG_sendchar_c+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;WLS3.c,64 :: 		}
L_end_sendchar:
	RETURN
; end of _sendchar

_sendhex:

;WLS3.c,69 :: 		void sendhex(unsigned long hexnumber)
;WLS3.c,71 :: 		int nibble = 0;
	CLRF       sendhex_nibble_L0+0
	CLRF       sendhex_nibble_L0+1
;WLS3.c,75 :: 		sendchar(STX);
	MOVLW      2
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;WLS3.c,77 :: 		for (nibble = 0; nibble < 8; nibble++)
	CLRF       sendhex_nibble_L0+0
	CLRF       sendhex_nibble_L0+1
L_sendhex4:
	MOVLW      128
	XORWF      sendhex_nibble_L0+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sendhex15
	MOVLW      8
	SUBWF      sendhex_nibble_L0+0, 0
L__sendhex15:
	BTFSC      STATUS+0, 0
	GOTO       L_sendhex5
;WLS3.c,79 :: 		sendchar(hexnr[(hexnumber&0xF0000000)>>28]);
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
L__sendhex16:
	BTFSC      STATUS+0, 2
	GOTO       L__sendhex17
	LSRF       R3, 1
	RRF        R2, 1
	RRF        R1, 1
	RRF        R0, 1
	ADDLW      255
	GOTO       L__sendhex16
L__sendhex17:
	MOVLW      sendhex_hexnr_L0+0
	ADDWF      R0, 0
	MOVWF      FSR0L
	MOVLW      hi_addr(sendhex_hexnr_L0+0)
	ADDWFC     R1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;WLS3.c,80 :: 		hexnumber<<=4;
	MOVLW      4
	MOVWF      R0
	MOVF       R0, 0
L__sendhex18:
	BTFSC      STATUS+0, 2
	GOTO       L__sendhex19
	LSLF       FARG_sendhex_hexnumber+0, 1
	RLF        FARG_sendhex_hexnumber+1, 1
	RLF        FARG_sendhex_hexnumber+2, 1
	RLF        FARG_sendhex_hexnumber+3, 1
	ADDLW      255
	GOTO       L__sendhex18
L__sendhex19:
;WLS3.c,77 :: 		for (nibble = 0; nibble < 8; nibble++)
	INCF       sendhex_nibble_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       sendhex_nibble_L0+1, 1
;WLS3.c,81 :: 		}
	GOTO       L_sendhex4
L_sendhex5:
;WLS3.c,82 :: 		}
L_end_sendhex:
	RETURN
; end of _sendhex

_measure_frequency:

;WLS3.c,85 :: 		unsigned long measure_frequency()
;WLS3.c,87 :: 		T1CON.TMR1ON = 0;
	BCF        T1CON+0, 0
;WLS3.c,88 :: 		tmr1_overflow = 0;
	CLRF       WLS3_tmr1_overflow+0
	CLRF       WLS3_tmr1_overflow+1
	CLRF       WLS3_tmr1_overflow+2
	CLRF       WLS3_tmr1_overflow+3
;WLS3.c,89 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;WLS3.c,90 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;WLS3.c,91 :: 		T1CON.TMR1ON = 1;
	BSF        T1CON+0, 0
;WLS3.c,92 :: 		Delay_ms(1000);
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
;WLS3.c,93 :: 		T1CON.TMR1ON = 0;
	BCF        T1CON+0, 0
;WLS3.c,94 :: 		pulse_count = (tmr1_overflow << 16) + (TMR1H << 8) + TMR1L;
	MOVF       WLS3_tmr1_overflow+1, 0
	MOVWF      R7
	MOVF       WLS3_tmr1_overflow+0, 0
	MOVWF      R6
	CLRF       R4
	CLRF       R5
	MOVF       TMR1H+0, 0
	MOVWF      R1
	CLRF       R0
	MOVF       R4, 0
	ADDWF      R0, 1
	MOVF       R5, 0
	ADDWFC     R1, 1
	MOVF       R6, 0
	ADDWFC     R2, 1
	MOVF       R7, 0
	ADDWFC     R3, 1
	MOVF       TMR1L+0, 0
	ADDWF      R0, 1
	MOVLW      0
	ADDWFC     R1, 1
	ADDWFC     R2, 1
	ADDWFC     R3, 1
	MOVF       R0, 0
	MOVWF      WLS3_pulse_count+0
	MOVF       R1, 0
	MOVWF      WLS3_pulse_count+1
	MOVF       R2, 0
	MOVWF      WLS3_pulse_count+2
	MOVF       R3, 0
	MOVWF      WLS3_pulse_count+3
;WLS3.c,95 :: 		return pulse_count;
;WLS3.c,96 :: 		}
L_end_measure_frequency:
	RETURN
; end of _measure_frequency

_init:

;WLS3.c,99 :: 		void init()
;WLS3.c,102 :: 		OSCCON = 0x70;     // 4x PLL disabled
	MOVLW      112
	MOVWF      OSCCON+0
;WLS3.c,106 :: 		TRISA.TRISA0 = OUT;  // PIN 7
	BCF        TRISA+0, 0
;WLS3.c,107 :: 		PORTA.RA0 = 1;
	BSF        PORTA+0, 0
;WLS3.c,108 :: 		TRISA.TRISA1 = OUT;  // PIN 6
	BCF        TRISA+0, 1
;WLS3.c,109 :: 		PORTA.RA1 = 1;
	BSF        PORTA+0, 1
;WLS3.c,110 :: 		TRISA.TRISA2 = OUT;  // PIN 5
	BCF        TRISA+0, 2
;WLS3.c,111 :: 		PORTA.RA2 = 1;
	BSF        PORTA+0, 2
;WLS3.c,112 :: 		TRISA.TRISA3 = IN;   // PIN 4
	BSF        TRISA+0, 3
;WLS3.c,113 :: 		PORTA.RA3 = 1;
	BSF        PORTA+0, 3
;WLS3.c,114 :: 		TRISA.TRISA4 = IN;   // PIN 3
	BSF        TRISA+0, 4
;WLS3.c,115 :: 		PORTA.RA4 = 1;
	BSF        PORTA+0, 4
;WLS3.c,116 :: 		TRISA.TRISA5 = OUT;  // PIN 2
	BCF        TRISA+0, 5
;WLS3.c,117 :: 		PORTA.RA5 = 1;
	BSF        PORTA+0, 5
;WLS3.c,120 :: 		ANSELA.ANSA4 = 1;     // PIN 3 CPS3
	BSF        ANSELA+0, 4
;WLS3.c,123 :: 		CPSCON0.CPSRM = 0;    // Low range - internal voltage reference
	BCF        CPSCON0+0, 6
;WLS3.c,124 :: 		CPSCON0.CPSRNG0 = 0;  // oscillator medium range
	BCF        CPSCON0+0, 2
;WLS3.c,125 :: 		CPSCON0.CPSRNG1 = 1;
	BSF        CPSCON0+0, 3
;WLS3.c,126 :: 		CPSCON0.CPSON = 1;
	BSF        CPSCON0+0, 7
;WLS3.c,127 :: 		CPSCON1.CPSCH0 = 1;   // Channel 3 = PIN 3
	BSF        CPSCON1+0, 0
;WLS3.c,128 :: 		CPSCON1.CPSCH1 = 1;
	BSF        CPSCON1+0, 1
;WLS3.c,131 :: 		T1CON.TMR1CS0 = 1;    // TMR1 clock = capacitive oscillator
	BSF        T1CON+0, 6
;WLS3.c,132 :: 		T1CON.TMR1CS1 = 1;    // TMR1 clock = capacitive oscillator
	BSF        T1CON+0, 7
;WLS3.c,133 :: 		PIE1.TMR1IE = 1;      // Enable TMR1 interrupt
	BSF        PIE1+0, 0
;WLS3.c,136 :: 		UART1_Init(9600);
	BSF        BAUDCON+0, 3
	MOVLW      207
	MOVWF      SPBRG+0
	CLRF       SPBRG+1
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;WLS3.c,139 :: 		INTCON.PEIE = 1;
	BSF        INTCON+0, 6
;WLS3.c,140 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;WLS3.c,141 :: 		}
L_end_init:
	RETURN
; end of _init

_main:

;WLS3.c,148 :: 		void main()
;WLS3.c,151 :: 		init();
	CALL       _init+0
;WLS3.c,154 :: 		Delay_ms(1000);
	MOVLW      11
	MOVWF      R11
	MOVLW      38
	MOVWF      R12
	MOVLW      93
	MOVWF      R13
L_main8:
	DECFSZ     R13, 1
	GOTO       L_main8
	DECFSZ     R12, 1
	GOTO       L_main8
	DECFSZ     R11, 1
	GOTO       L_main8
	NOP
	NOP
;WLS3.c,157 :: 		while(1)
L_main9:
;WLS3.c,160 :: 		frequency = measure_frequency();
	CALL       _measure_frequency+0
	MOVF       R0, 0
	MOVWF      WLS3_frequency+0
	MOVF       R1, 0
	MOVWF      WLS3_frequency+1
	MOVF       R2, 0
	MOVWF      WLS3_frequency+2
	MOVF       R3, 0
	MOVWF      WLS3_frequency+3
;WLS3.c,163 :: 		sendhex(frequency);
	MOVF       R0, 0
	MOVWF      FARG_sendhex_hexnumber+0
	MOVF       R1, 0
	MOVWF      FARG_sendhex_hexnumber+1
	MOVF       R2, 0
	MOVWF      FARG_sendhex_hexnumber+2
	MOVF       R3, 0
	MOVWF      FARG_sendhex_hexnumber+3
	CALL       _sendhex+0
;WLS3.c,164 :: 		}
	GOTO       L_main9
;WLS3.c,165 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
