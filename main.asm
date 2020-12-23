;
; finalProject.asm
;
; Created: 12/6/2020 2:01:27 PM
; Author : pab13
;

; configure interrupt vector table
.org 0x0000 ; reset
rjmp start
.org INT0addr ; External Interrupt Request 0
rjmp ext0_isr

.org INT_VECTORS_SIZE ; end of vector table

start:
    ; initialize stack
              ldi   r16, HIGH(RAMEND)
              out   SPH, r16
              ldi   r16, LOW(RAMEND)
              out   SPL, r16

              cbi   DDRB, DDD2          ; set direction of port-d
                                        ; pin 2 to input
          
              sbi   PORTD, PD2        ; set port-d pin-2 to pull-up

              sbi   DDRB, DDB2          ; make PB2 output
              sbi   DDRB, DDB3          ; make PB3 output
              sbi   DDRB, DDB4          ; make PB4 output

              ; configure interrupt for push button
              ldi   r20, (1<<INT0)      ; enable interrupt 0
              out   EIMSK, r20          
              
              ; configure interrupt sense control bits
              ldi   r20, (1<<ISC01)     ; set falling edge
              sts   EICRA, r20          ; interrupt sense control bits

              ; Enable global interrupts
              sei

traffic_cycle:
              sbi   PORTB, PB2
              call  delay_9seconds
              sbic  PORTB, PB4
              call  return_to_normal
              cbi   PORTB, PB2
              sbi   PORTB, PB3
              call  timer1_3000ms
              cbi   PORTB, PB3
              sbi   PORTB, PB4
              call  delay_6seconds
              cbi   PORTB, PB4

end_main:     rjmp  traffic_cycle

;-------------------------------------------------------
ext0_isr:
; interrupt service routine for external
; interrupt 0 (PD2)
              ldi   r18, 1     

              reti                      ; end ext0_isr
;-------------------------------------------------------
          
return_to_normal:
              sbi   PORTB, PB2
              call  delay_9seconds
              ret

delay_9seconds:
              ldi   r18, 3

delay_9:
              call  timer1_3000ms
              dec   r18
              brne  delay_9
              ret

delay_6seconds:
              ldi   r18, 2

delay_6:
              call  timer1_3000ms
              dec   r18
              brne  delay_6
              ret


;-------------------------------------
timer1_3000ms:
; 3000ms timer called by delay routine
;-------------------------------------

          ; 1) Set count in TCNT1H/L
          ldi       r20,HIGH(18661)     ; set timer clock high byte count
          sts       TCNT1H, r20         ; copy to temp register
          ldi       r20,LOW(18661)      ; set timer clock low byte count
          sts       TCNT1L, r20         ; write to low byte and copy temp to high

          ; 2) Set mode in TCCR1A
          clr       r20
          sts       TCCR1A, r20

          ; 3) Set clock select in TCCR1B
          ldi       r20, (1<<CS12 | 1<<CS10)
          sts       TCCR1B, r20         ; set clk/1024     

          ; 4) Watch for TOV1 in TIFR1
tov1_lp:  sbis      TIFR1, TOV1         ; do{
          rjmp      tov1_lp             ; } while (TOV1 == 0)

          ; 5) Stop Timer in TCCR1B
          clr       r20
          sts       TCCR1B, r20         ; set no clock select

          ; 6) Write 1 to TOV1 in TIFR1
          ldi       r20,(1<<TOV1)
          out       TIFR1, r20          ; clear TOV1 flag


          ret                           ; end timer1_300ms
