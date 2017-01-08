;****************************************************************************
;**************PROYECTO: TIMMER DE LAVARROPAS *******************************
;**************MICRO: MC68908JL3*********************************************
;**************TALLER DE MICROCONTROLADORES 2005*****************************
;**************UNIVERSIDAD NACIONAL DE LA MATANZA****************************
;**************PROFESOR: CARLOS MAIDANA**************************************
;**************ALUMNO: DAVID CAO*********************************************
;****************************************************************************

portd                    equ     $0003
ddrd                     equ     $0007
ddrb                     equ     $0005
portb                    equ     $0001
config1                  equ     $001f
digito                   equ     6

boton_un                 equ     4
boton_down               equ	 5
boton_enter              equ     6
valvula 		         equ     7
carga1/2		         equ     7
carga1/1		         equ     7
tres_seg			     equ	 150 ;// interrupciones del clock
relés_1_2		         equ     7
drain                    equ     7

A			             equ	$77
B                        equ	$7c
C                        equ	$39
D                        equ	$5e
E                        equ	$79
F                        equ	$71
G                        equ	$7d
H                        equ	$76
I                        equ	$06
J                        equ	$1e


;Ahora defino las variables para el uso del Timer

tsc                      equ     $0020
tsc0                     equ     $0025
tch0h                    equ     $0026
Tch0l                    equ     $0027
tsc1                     equ     $0028
tch1h                    equ     $0029
Tch1l                    equ     $002A

;Variables en RAM
                        ORG $0080

;digito                  rmb       1     
aux                      rmb       1
delay                    rmb       1
interrup_counter         rmb       1
m35_counter		         rmb	   1
min_counter              rmb       1
var_time		         rmb	   1 ;//variable de tiempo em minutos

.base 10t

                         ORG $EC00

start
                         rsp ;carga el SP al tope de RAM ($00ff)
                         mov #$00,portd
                         mov #$ff,ddrd
                         mov #$00,ddrb
                         bclr         2,portd
                         bset         0,config1 ;disable WATCH DOG
                         clr         digito
                         clr          aux
			             clr	     var_time
                         clra
                         clrx

                         jsr init_timer
                         clr digit_counter
                         clr delay
                         cli                 ; Habilita Int.

main_loop


boton_up?
                         brclr   boton_up,portb,check_boton_up?
boton_down?
                         brclr   boton_down,portb,check_boton_down?          boton_enter?
                         brclr   boton_enter,portb,check_boton_enter?
                         bra     main_loop

check_boton_up
                         lda    #20                  ;delay 20 mseg
                         jsr    sw_delay_mseg         ;reviso que no searuido
                         brset  boton_up,portb,boton_down?
                         jsr    inc_counter
fix_boton_up
			             jsr    sw_tycoon_delay
                         brset  boton_up,portb,boton_down?
                         jsr    inc_counter
			             brclr  boton_up,portb,fix_boton_up
                         bra    main_loop


check_boton_down         lda    #20    ;delay 20 mseg
                         jsr    sw_delay_mseg
                         brset  boton_up,port,boton_up?
                         jsr    dec_counter
fix_boton_down
     			         jsr    sw_tycoon_delay
                         brset  boton_up,port,boton_up?
                         jsr    dec_counter
			             brclr  boton_up,port,fix_boton_down
                         bra    main_loop

check_boton_enter
                         lda    #20    ;delay_boton20 milisegundos de delay
                         jsr    sw_delay_mseg
                         brset  boton_enter,portb,main_loop
flash_light

                         bclr  6,portd
                         jsr   doble_delay_mseg
                         bset  6,portd
                         jsr   doble_delay_mseg
                         bra   parpadeo


selector(digito):

case'A':

;// lavado, enjuague y centrifugado X 3.
;// segun el programa, varian los tiempos decada modulo.
;// nadie utiliza mas de 3 programas de lavado, los demas quedan no ;//implementados

         lda	digito ;// lavado ropa blanca
         cmpa	#A
         bne	case'B' ;// salida al proximo case

		 jsr	carga_completa
		 mov	#10,var_time  ;//variable de tiempo en minutos
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
         mov	#10,var_time
		 jsr	lavado_horario     ;// el ciclo enjuague = lavado
		 mov	#5,var_time
		 jsr	centrifugado


         jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
         mov	#7,var_time
		 jsr	lavado_horario
		 mov	#5,var_time
		 jsr	centrifugado

         jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
         mov	#7,var_time
		 jsr	lavado_horario
		 mov	#10,var_time ;//el centrifugado final es + largo
		 jsr	centrifugado


case'B':
         lda	digito    ;// ropa color
         cmp	#B
         bne	case'C'

		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
         mov	#10,var_time
		 jsr	lavado_horario
		 mov	#10,var_time
		 jsr	centrifugado


         jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
         mov	#10,var_time
		 jsr	lavado_horario
		 mov	#9,var_time
		 jsr	centrifugado

         jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
         mov	#10,var_time
		 jsr	lavado_horario
		 mov	#9,var_time
		 jsr	centrifugado
case'C':
         lda	digito     ;/ lavado liviano ( poco sucia)
         cmp	#C
         bne	case'D'

		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
                 mov	#10,var_time
		 jsr	lavado_horario
		 mov	#9,var_time
		 jsr	centrifugado


         jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
                 mov	#10,var_time
		 jsr	lavado_horario
		 mov	#9,var_time
		 jsr	centrifugado

         jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_horario
		 jsr	carga_completa
		 mov	#10,var_time
		 jsr	lavado_antihorario
                 mov	#10,var_time
		 jsr	lavado_horario
		 mov	#10,var_time
		 jsr	centrifugado


;/ no implementado
;case'D':
	         ;lda	digito
                 ;cmp	# D
                 ;bne	case'E'
;case'E':
	         ;lda	digito
                 ;cmp	# E
                 ;bne	case'F'
;case'F':
	         ;lda	digito
                 ;cmp	# F
                 ;bne	case'G'
;case'G':
	         ;lda	digito
                 ;cmp    # G
                 ;bne	case'H'
;case'H':
	         ;lda	digito
                 ;cmp	# H
                 ;bne	case'I'
;case'I':
	         ;lda	digito
                 ;cmp	# I
                 ;bne	case'J'
;case'J':
	         ;lda	digito
                 ;cmp	# J
default:
                 bra	main_loop ;



;/***********************    Start Rutinas de lavado    ********************/

carga_media:

open1/2:
			bset  valvula,port
carga_media_full?:
            brset carga1/2,port,carga_media_full?
close1/2:
			bclr  valvula,port

			rts
;/************************************************************************
carga_entera:

open1/1:
			bset  valvula,port
carga_entera_full?:
			brset carga1/1,port,carga_entera_full?
close1/1:
			bclr  valvula,port

			rts
;/************************************************************************
carga_vacia:

carga_empty_done?:      lda	port
			and	%MASCARA
			bne	carga_empty_done?

			rts

;/************************************************************************

lavado_antihorario:
			jsr     clr_counters

			jsr	relay_B

washa_time_out?:	lda	var_time
                        cmp XXXXXX
			bne	washa_time_out?
			bclr	wash,port
			bset	drain,port
			jsr	carga_vacia ; /*revisar
			bclr	drain,port

			rts
;/************************************************************************
lavado_horario:
			jsr     clr_counters
			bclr	wash,port
			jsr	relay_A

washh_time_out?:	lda	var_time
                        cmp XXXXXX
			bne	washh_time_out?
			bclr	wash,port
			bset	drain,port
			jsr	carga_vacia
			bclr	drain,port
;/************************************************************************
			rts
relay_A:

off_B:			bclr	relé_B,port
relé_A_on:		bset	relé_A,port

			rts


;/************************************************************************
relay_B:

off_A:			bclr	relé_A,port
relé_B_on:		bset	relé_A,port

			rts
;/************************************************************************

off_relés_1_2:
			bclr    relés_1_2,port

			rts
;/************************************************************************
on_relés_1_2:
			bset    relés_1_2,port ;

			rts

;/************************************************************************

centrifugado:
			jsr     clr_counters
			bset	spin,port
			jsr     off_relés_A_B
espera_time_out?:       lda	interrup_counter
                        cmp	# tres_seg        ;// espero 3seg para darle
                        bne	espera_time_out?  ;// línea                        			
                        jsr     relay_B
activo_desagote:	    bset	drain,port
spin_time_out?:	        lda	min_counter
			            cmp     var_time
			            bne	spin_time_out?
desactivo_desagote:	    bclr	drain,port							
                        jsr     off_rotation
                        rts


;/**************************************************************************/
off_rotation:
		        bclr	relé_A,port
			    bclr	relé_B,port
                rts

;/**************************************************************************/
jabonera:
                        brset   octo1,rot_horario
                        brset   octo2,rot_anihor
rot_horario:
                        bset	motor_pin1,port;// contactos del motor de
			bclr	motor_pin2,port;//continua
                        bra     END
rot_anihor:
			bset	motor_pin2,port
			bclr	motor_pin1,port

END:                    rts
;/**************************************************************************/
clr_counters:
			clr interrup_counter
			clr min_counter
			clr m35_counter

			rts
;/**************************************************************************/

tim_clock:
			 pshh                     ;tiro H al stack
             pshx                     ;tiro X al stack
             psha                     ;Salvo el acum en el stack

			 inc	interrup_counter
			 bcc    siguiente	 ;/overf incrementa a 35_c
			 inc	m35_counter
			 lda	m35_counter	;256 int * 35 = 1 minuto
			 cmp 	#35
			 bne    siguiente
			 clr    m35_counter
			 inc	minut_counter

siguiente:


                         lda   tsc0
                         and   #$7f
                         sta   tsc0               ;Limpio el flag de Output Compare
                         ldhx  tch0h              ;Cargo HX (16 bits) con el contenido de TCH0H
                         aix   #ff                ;Le sumo ff(decimal) ( ms)
                         sthx  tch0h              ;Le indico el proximo valor de INT
                         clrh
                         clrx




Stack_recovery :
                         pula
                         pulx
                         pulh                   ;
                         rti


;/**************************************************************************/


tim_display:
                         pshh                     ;tiro H al stack
                         pshx                     ;tiro X al stack
                         psha                     ;Salvo el acumulador en el Stack

                         lda   tsc1
                         and   #$7f
                         sta   tsc1               ;Limpio el flag de Output Compare
                         ldhx  tch1h              ;Cargo HX (16 bits) con el contenido de TCH0H
                         aix   #77                ;Le sumo 77 (decimal) (2 ms)
                         sthx  tch1h              ;Le indico el proximo valor de INT
                         clrh                     ;Ahora muestro el digito que corresponde.
                         clrx




digito:

                         ldx  digito
                         bclr  digito,portd
                         jsr   send_7_seg
                         bset  digito,portd
                         bra   done_tisr

done_tisr:
                         pula                   ;recupero el acumulador del Stack
                         pulx
                         pulh                   ;recupero H del stack
                         inc   delay
                         rti


;/*********************** Start Rutinas del display ***********************/
send_7_seg
                         lda    tabladisplay,x

out_byte
                         clrx
shiftbyte
                         lsla
                         bcs    setuno
                         bcc    setcero
setuno
                         bset   3,portd
                         bra    point1
setcero
                         bclr   3,portd
point1
                         bset   2,portd
                         bclr   2,portd
                         incx
                         cmpx   #$08
                         bne    shiftbyte
                         rts


inc_counter
                        inc     digito
                        lda     digito
                        cmp     #10
                        bne     exit_1

                        clr     digito
exit_1
                        rts

dec_counter
                        dec    digito
                        lda    digito
                        cmp    #$ff
                        bne    exit_2

                        mov #9,digito
exit_2
                        rts
;/**************************************************************************/


sw_delay_mseg 				;/ delay por software......
                        clrx
seguimos                incx
                        cmpx    #$ff
                        nop
                        nop
                        nop
                        nop
                        bne     seguimos
                        deca
                        cmpa    #$00
                        bne     delay_mseg
                        clra
                        clrx
                        rts
;/**************************************************************************/

sw_tycoon_delay:
			    lda    #ff         ;/ llama 2 veces a delay con #ff
                jsr    delay_mseg  ;/no valía la pena hacer un ciclo
		        lda    #ff
                jsr    delay_mseg
                rts
;/**************************************************************************/


init_timer:
                        mov   #$36,tsc


                        mov   #$0,tch0h
                        mov   #ff,tch0l

		        mov   #$0,tch1h
                        mov   #$77,tch1l

                        mov   #$50,tsc0    ; Pág 132 Manual
                        mov   #$50,tsc1                   ; Channel 0 Enable
                                           ; Seteo para la operación de Output Compare

                        mov   #$06,tsc     ; Arranco el timer

                        rts

;/****************** defino los vectores de interrupción ******************/

                        ;Timer vector
                        org     $fff4       ;/TIM Channel 1 lowest priority
                        dw      tim_display ;/ interrupción de display


			;Timer vector
                       ; org     $fff6 	    ;/TIM Channel 0 highest priority
                        ;dw      tim_clock  ;/ interrupción de reloj

                        ;Reset vector
                        org     $fffe
                        dw      start
;/*********************** defino la tabla del display **********************/


tabladisplay    db      A,B,C,D,E,F,G,H,I,J





