    #include "p16f877a.inc"

; __config 0xFFBA
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CP_OFF

 ;Bancos
    #define BANCO1	bsf STATUS, RP0
    #define BANCO0	bcf STATUS, RP0

;Entradas
    #define sp      PORTA, RA2
    #define n2      PORTD, RD0
    #define n5      PORTD, RD1
;Saidas
    #define rn
    #define ac      PORTE, RE2
    #define sm      PORTC, RC3
    #define lm      PORTC, RC4
    #define la      PORTB, RB0
    #define LED1    PORTB, 0

 CBLOCK 20h
    valor_entrada
    valor_salvo
    valor_restante
    valor_veiculo
    peso_veiculo
    qtd_troco
    valor_teste
    contador
    contador2
    valor_vazio
    valor_moto
    valor_carro
    valor_truck
    valor_caminhao
    peso_salvo
    peso
 endc

 org 0 
        
 ;Inicializacoes
 BANCO0
    movlw 0
    movwf valor_entrada
    movwf valor_salvo
    movwf valor_restante
    movwf valor_veiculo
    movwf valor_teste
    movwf qtd_troco
    
    movlw .184
    movwf valor_vazio
    movlw .191
    movwf valor_moto
    movlw .197
    movwf valor_carro
    movlw .195
    movwf valor_truck
    movlw .203
    movwf valor_caminhao
 
 ;DEFINIR SAIDAS
  BANCO1
    movlw b'11111110'
    movwf TRISB
    movlw b'11100000'
    movwf TRISE
    movlw b'00000000'
    movwf TRISC
    movlw b'00000000'
    movwf TRISD
    
;DEFINIR ENTRADAS
    movlw b'11111111'
    movwf TRISA
    movlw b'00000010'
    movwf ADCON1

;CONFIGURACAO PRESCALER
    movlw b'00000111'
    movwf OPTION_REG
 
  BANCO0 
    movlw b'00110001'
    movwf T1CON
 
    call inicia_lcd
    call msg_bem_vindo
;    call espera_4s
    bcf ac
    bcf lm
    bcf sm
    bcf la
    
inicio
    movlw b'01010001'
    movwf ADCON0
    call atraso_limpa_lcd
    
    bsf ADCON0, GO_DONE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;LOOP INICIAL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SENSORES_DESATIVADOS ;3,7v ~ 3,8v = 3,7 = 189
    BANCO0

    bsf ADCON0, GO_DONE
VOLTA_SENSORES_DESATIVADOS
    btfsc ADCON0, GO_DONE
    goto VOLTA_SENSORES_DESATIVADOS

    movfw ADRESH
    movwf peso
       
VERIFICA_VEICULOS
    movlw .180
    subwf peso, W
    call espera_1s
    btfss STATUS, C
    goto SENSORES_DESATIVADOS

 ;compara moto
    movlw .184
    subwf peso, W
    btfss STATUS, C
    goto abrir_cancela
 ;compara carro
    movlw .191
    subwf peso, W
    btfss STATUS, C
    goto seta_valor5
 ;compara carro3eixos
    movlw .195
    subwf peso, W
    btfss STATUS, C
    goto seta_valor7
 ;compara carro4eixos
    movlw .203
    subwf peso, W
    btfss STATUS, C
    goto seta_valor10
    goto SENSORES_DESATIVADOS


    
seta_valor10
    call limpa_lcd
    call valor_10
    movlw 10
    movwf valor_veiculo
    goto ler_valor_entrada
    
seta_valor7
    call limpa_lcd
    call valor_7
    movlw 7
    movwf valor_veiculo
    goto ler_valor_entrada
    
seta_valor5
    call limpa_lcd
    call valor_5
    movlw 5
    movwf valor_veiculo
    goto ler_valor_entrada
    
ler_valor_entrada
    btfsc n2
    goto valor_entrada_2
    goto ler_n5
    
ler_n5      
    btfsc n5
    goto valor_entrada_5
    goto ler_valor_entrada    
 
valor_entrada_2
    movlw 2
    movwf valor_entrada
    call espera_2s 
    goto verifica_valor_entrada
    
valor_entrada_5
    movlw 5
    movwf valor_entrada
    call espera_2s 
    goto verifica_valor_entrada
 
verifica_valor_entrada
    movlw valor_entrada
    addwf valor_salvo
    subwf valor_veiculo
    movwf valor_restante
    movlw 0
    movwf valor_entrada
    movwf valor_restante
    btfsc STATUS, C
    goto devolve_moedas
    goto verifa_faltou_ou_abrir_cancela		    ; =0 ele vai para abrir cancela 
   
verifa_faltou_ou_abrir_cancela
    btfss STATUS, C
    goto ler_valor_entrada
    goto abrir_cancela
   
valor_isento
    movlw 'M'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw 'T'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'S'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'N'
    call escreve_dado_lcd
    movlw 'T'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    return

valor_5
    movlw 'V'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    movlw '5'
    call escreve_dado_lcd
    return 

valor_7
    movlw 'V'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    movlw '7'
    call escreve_dado_lcd
    return

valor_10
    movlw 'V'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    movlw '1'
    call escreve_dado_lcd
    movlw '0'
    call escreve_dado_lcd
    return

msg_bem_vindo
    movlw ' '
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'B'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'M'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'V'
    call escreve_dado_lcd
    movlw 'I'
    call escreve_dado_lcd
    movlw 'N'
    call escreve_dado_lcd
    movlw 'D'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    return

valor_falta
    movlw 'F'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw 'T'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    return

msg_troco
    movlw 'T'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw 'C'
    call escreve_dado_lcd
    movlw 'O'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw '$'
    call escreve_dado_lcd
    return

msg_cancela_aberta
    movlw 'C'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'N'
    call escreve_dado_lcd
    movlw 'C'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'L'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw ' '
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    movlw 'B'
    call escreve_dado_lcd
    movlw 'E'
    call escreve_dado_lcd
    movlw 'R'
    call escreve_dado_lcd
    movlw 'T'
    call escreve_dado_lcd
    movlw 'A'
    call escreve_dado_lcd
    return
 
 ;------ 1 segundo------
espera_1s
 movlw 20
 movwf contador
 movlw 60		; valor para 196 contagens (50ms)
 movwf TMR0		; 256  -  196  = 60

aguarda_estouro 
 btfss INTCON, TMR0IF	; espera timer0 estourar
 goto aguarda_estouro
 movlw 60		; reprograma para 196 contagens (50ms)
 movwf TMR0		; 256  -  196  = 60
 bcf INTCON, TMR0IF	; limpa flag de estouro
 decfsz contador	; aguarda 20 ocorrencias ( 20 x 50ms = 1s)
 goto aguarda_estouro
 return
 
  ;------ 2 segundo pisca led------
espera_2s
 movlw 40
 movwf contador
 movlw 60		; valor para 196 contagens (50ms)
 movwf TMR0		; 256  -  196  = 60

aguarda_estouro_2s 
 btfss INTCON, TMR0IF	; espera timer0 estourar
 goto aguarda_estouro_2s
 movlw 60		; reprograma para 196 contagens (50ms)
 movwf TMR0		; 256  -  196  = 60
 bcf INTCON, TMR0IF	; limpa flag de estouro
 decfsz contador	; aguarda 20 ocorrencias ( 20 x 50ms = 1s)
 goto aguarda_estouro_2s
 return
 
  ;------ 4 segundo ------
espera_4s
 movlw 80
 movwf contador
 movlw 60		; valor para 196 contagens (50ms)
 movwf TMR0		; 256  -  196  = 60

aguarda_estouro_4s 
 btfss INTCON, TMR0IF
 goto aguarda_estouro_4s
 movlw 60		; reprograma para 196 contagens (50ms)
 movwf TMR0		; 256  -  196  = 60
 bcf INTCON, TMR0IF
 decfsz contador
 goto aguarda_estouro_4s
 return
 
;------------| PROCESSAMENTO DE TROCO |------------

devolve_moedas
    bsf sm
    call espera_1s
    bcf sm
    call espera_1s
    bsf lm
    call espera_1s
    bcf lm
    incfsz valor_restante
    goto devolve_moedas
    call limpa_lcd
    call msg_cancela_aberta
    goto abrir_cancela
 
 ;------------| ABRIR/FECHAR CANCELA |------------
abrir_cancela
    bsf ac
    call limpa_lcd
    call msg_cancela_aberta
    call espera_4s
	
fechar_cancela
    bcf ac
    call limpa_lcd
    call msg_bem_vindo
    goto inicio
    
;-------------| Pisca LED |--------------------
pisca_led
    bsf LED1
    call espera_2s
    bcf LED1
    call espera_2s
    return
 
inicia_lcd
;    movlw 38h
;    call escreve_comando_lcd
    movlw 38h
    call escreve_comando_lcd
    movlw 38h
    call escreve_comando_lcd
    movlw 0Ch
    call escreve_comando_lcd
    movlw 06h
    call escreve_comando_lcd
 
limpa_lcd
    movlw 01h
    call escreve_comando_lcd
    call atraso_limpa_lcd
    return
 
escreve_comando_lcd
    bcf PORTE, RE0
    movwf PORTD
    bsf PORTE, RE1
    bcf PORTE, RE1
    call atraso_lcd
    return
 
escreve_dado_lcd
    bsf PORTE, RE0
    movwf PORTD
    bsf PORTE, RE1
    bcf PORTE, RE1
    call atraso_lcd
    return
 
atraso_lcd
    movlw 26
    movwf contador
ret_atraso_lcd
    decfsz contador
    goto ret_atraso_lcd
    return
 
atraso_limpa_lcd
    movlw 40
    movwf contador2
ret_atraso_limpa_lcd
    call atraso_lcd
    decfsz contador2	
    goto ret_atraso_limpa_lcd	
    return
 
 end