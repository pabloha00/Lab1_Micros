;******************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de microcontroladores
; Laboratorio1
; Autor: Pablo Herrarte
; Proyecto: Laboratorio1
; Hardware: ATMEGA328P
; Creado: 28/01/2023
; Última modificación: 28/01/2023 
;******************************************************************************

.include "M328PDEF.inc"
.CSEG
.ORG 0x0000

;******************************************************************************
; SACK POINTER
;******************************************************************************

	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17				;Cuneta del sumador 1
	LDI R18, HIGH(RAMEND)
	OUT SPH, R18				;Cuenta del sumador 2
	LDI R19, HIGH(RAMEND)
	OUT SPH, R19				;Cuenta de la suma de contadores

;******************************************************************************
; CONFIGURACIÓN
;******************************************************************************

Setup:

	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16			;Habilita prescaler
	LDI R16, 0b0000_0100
	STS CLKPR, R16			;Reloj 1MHz

	LDI R16, 0b1111_0000	;Pin PD4 a PD7 como entrada con pullup
	OUT PORTD, R16			;Se le asigna el pullup a PD4 a PD7 
	LDI R16, 0b0000_1111	;Pines PD4 a PD7 son in y PD0 a PD3 son out
	OUT DDRD, R16		

	LDI R16, 0b0000_1111	;Pines PB0 a PB3 se asignan como salidas
	OUT DDRB, R16			
	
	LDI R16, 0b0010_0000	;Pin PC5 es asignada con pullup
	OUT PORTC, R16			;Pull up a PC5
	LDI R16, 0b0001_1111	;Asignamos PC5 son in y PC0 a PC4 son out
	OUT DDRC, R16
	
	LDI R17, 0				;Contador 1
	OUT PORTB, R17			;Inicializa el puerto B con el valor en R17

	LDI R18, 0b1111_0000	;Contador 2 se asigna ese valor porque-
	OUT PORTD, R18			;-medio PORTD son in con pullup

	LDI R19, 0b0010_0000	;Suma de contadores
	OUT PORTC, R19			;Valor por la entrada en PORTC
	
;******************************************************************************
; LOOP
;******************************************************************************

LOOP:
	IN R16, PIND		;Escribir PIND en R16 
	SBRS R16, PD4		;Salta instrucción si PD4 está encendido
	RJMP DelayBounce	;Función DelayBounce (Suma del contador 1)

	IN R16, PIND
	SBRS R16, PD5		;Salta instrucción si PD5 está encendido
	RJMP DelayBounce2	;Función DelayBounce2 (Resta del contador 1)

	IN R16, PIND		;Escribir PIND en R16
	SBRS R16, PD6		;Salta instrucción si PD6 está encendido
	RJMP DelayBounce3	;Función DelayBounce3 (Suma del contador 2)

	IN R16, PIND		;Escribir PIND en R16
	SBRS R16, PD7		;Salta instrucción si PD7 está encendido
	RJMP DelayBounce4	;Función DelayBounce4 (Resta del contador 2)

	IN R16, PINC		;Escribir PIND en R16
	SBRS R16, PC5		;Salta instrucción si PD7 está encendido
	RJMP DelayBounce5	;Función DelayBounce4 (Suma de ambos contadores)

	RJMP LOOP			;Regresa al Loop

;******************************************************************************
; DELAY BOUNCE
;******************************************************************************

DelayBounce:			;Antirerebote (Suma del contador 1)
	LDI R16, 100		
	delay:				
		DEC R16			;Cuneta a 100
		BRNE delay		
	SBIS PIND, PD4		;Salta instrucción si PD4 está encendido
	RJMP DelayBounce	;Regresa a DelayBounce
	RJMP Suma
	RJMP LOOP

Suma:

	INC R17				;Suma 1
	CPI R17, 16			;El resultado no debe ser 16
	BREQ LimSup			
	OUT PORTB, R17		;Despliega el resultado en PORTB
	RJMP LOOP

LimSup:
	LDI R17, 15			;Limite superior 15
	OUT PORTB, R17		;Despliega el resultado en PORTB
	RJMP LOOP

DelayBounce2:			;Antirrebote (Resta del contador 1)
	LDI R16, 100		
	delay2:	
		DEC R16			;Cuenta a 100
		BRNE delay2
	SBIS PIND, PD5		;Salta instrucción si PD5 está encendido
	RJMP DelayBounce2	;Regresa a DelayBounce2
	RJMP Resta
	RJMP LOOP

Resta:

	DEC R17				;Resta 1
	CPI R17, -1			;El resultado no debe ser -1
	BREQ LimInf			
	OUT PORTB, R17		;Despliega el resultado en PORTB
	RJMP LOOP

LimInf:
	LDI R17, 0			;Limite inferior 0
	OUT PORTB, R17		;Despliega el resultado en PORTB
	RJMP LOOP


DelayBounce3:			;Antirrebote (Suma del contador 2)
	LDI R16, 100
	delay3:
		DEC R16			;Cuenta a 100
		BRNE delay3
	SBIS PIND, PD6		;Salta instrucción si PD6 está encendido
	RJMP DelayBounce3	;Regresa a DelayBounce3
	RJMP Suma2			
	RJMP LOOP

Suma2:
	
	INC R18				;Suma 1
	CPI R18, 0			;El resultado no debe ser 0
	BREQ LimSup2
	OUT PORTD, R18		;Despliega el resultado en PORTD
	RJMP LOOP

LimSup2:
	LDI R18, 0b1111_1111	;Limite superior
	OUT PORTD, R18		;Despliega el resultado en PORTD
	RJMP LOOP

DelayBounce4:			;Antirrebote (Resta del contador 2)
	LDI R16, 100
	delay4:
		DEC R16			;Cuenta a 100
		BRNE delay4
	SBIS PIND, PD7		;Salta instrucción si PD7 está encendido
	RJMP DelayBounce4	;Regresa a DelayBounce4
	RJMP Resta2			
	RJMP LOOP
	

Resta2:

	DEC R18				;Resta 1
	CPI R18, 239		;El resultado no debe ser 239 por in en PORTD
	BREQ LimInf2
	OUT PORTD, R18		;Despliega el resultado en PORTD
	RJMP LOOP

LimInf2:
	LDI R18, 240		;Limite inferior 240
	OUT PORTD, R18
	RJMP LOOP
	

DelayBounce5:			;Antirrebote (Sumador de contadores
	LDI R16, 100
	delay5:
		DEC R16			;Cuenta a 100
		BRNE delay5
	SBIS PINC, PC5		;Salta instrucción si PC5 está encendido
	RJMP DelayBounce5	;Regresa a DelayBounce5
	RJMP SumaFinal
	RJMP LOOP

SumaFinal:
	LDI R19, 0b0010_0000	;Variable inicial de R19
	ADD R19, R17			;R19 = R19 + Contador 1
	LDI R16, 0b1111_0000	;Variable temporal para modificar contador 2
	SUB R18, R16			;R18 = R18 - R16
	ADD R19, R18			;R19 = R19 + R18
	ADD R18, R16			;Regresamos R18 a su valor original
	OUT PORTC, R19			;Despliega resultado en PORTC
	RJMP LOOP

