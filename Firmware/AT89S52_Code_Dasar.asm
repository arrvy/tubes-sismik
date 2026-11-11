; =================================================================
; BASIC CALCULATOR 8051 (REFINED & PIN-MODULAR VERSION)
; Fitur: 
; - Operator langsung tampil setelah angka pertama (Augend)
; - Tombol R4 C1 berfungsi penuh sebagai ON/C (Clear/Reset All)
; - PIN MODULAR: Definisi port/pin I/O terpusat di atas.
; =================================================================

; =================================================================
; MODULAR HARDWARE CONFIGURATION (UBAH PIN DI SINI)
; =================================================================
; --- Konfigurasi LCD ---
LCD_DAT     EQU P0      ; Port Data LCD (D0-D7)
LCD_RS      EQU P2.1    ; Pin RS pada LCD
LCD_EN      EQU P2.2    ; Pin EN pada LCD

; --- Konfigurasi Port Keypad Matriks ---
KEY_PORT    EQU P3      ; Base Port untuk Keypad
COL1        EQU P3.0    ; Keypad Kolom 1
COL2        EQU P3.1    ; Keypad Kolom 2
COL3        EQU P3.2    ; Keypad Kolom 3
COL4        EQU P3.3    ; Keypad Kolom 4
ROW1        EQU P3.4    ; Keypad Baris 1
ROW2        EQU P3.5    ; Keypad Baris 2
ROW3        EQU P3.6    ; Keypad Baris 3
ROW4        EQU P3.7    ; Keypad Baris 4

; --- Flag Internal State (Meminjam pin P2 yang tidak terpakai) ---
NOVONUM     EQU P2.7    ; Flag: HIGH saat menulis angka kedua
NOVODIG     EQU P2.6    ; Flag: HIGH saat digit pertama sudah ditulis
; =================================================================

    ORG 00H
    AJMP START

    ORG 40H 
START:  
    ACALL INITIALYZE
    SJMP L1             ; Langsung mulai scanning keypad

; =================================================================
; KEYPAD SCANNING (4x4 Matrix)
; =================================================================
L1:
    JNB COL1, C1
    JNB COL2, C2
    JNB COL3, C3
    JNB COL4, C4
    SJMP L1

C1: ; SCANNING KOLOM 1
    JNB ROW1, JUMP_TO_7 
    JNB ROW2, JUMP_TO_4 
    JNB ROW3, JUMP_TO_1 
    JNB ROW4, JUMP_RFRESH   ; <-- Tombol R4 C1 (ON/C)
    SETB COL1
    CLR COL2
    SJMP L1

C2: ; SCANNING KOLOM 2
    JNB ROW1, JUMP_TO_8 
    JNB ROW2, JUMP_TO_5 
    JNB ROW3, JUMP_TO_2 
    JNB ROW4, JUMP_TO_0 
    SETB COL2
    CLR COL3
    SJMP L1

C3: ; SCANNING KOLOM 3
    JNB ROW1, JUMP_TO_9 
    JNB ROW2, JUMP_TO_6 
    JNB ROW3, JUMP_TO_3 
    JNB ROW4, JUMP_EQUAL    
    SETB COL3
    CLR COL4
    SJMP L1

C4: ; SCANNING KOLOM 4
    JNB ROW1, JUMP_DIVIDE   
    JNB ROW2, JUMP_MULTI    
    JNB ROW3, JUMP_MINUS    
    JNB ROW4, JUMP_PLUS     
    SETB COL4
    CLR COL1
    LJMP L1

; --- PENGALIHAN JUMP (OUT OF RANGE RELATIVE JUMP FIX) ---
JUMP_TO_0:  LJMP NUM_0
JUMP_TO_1:  LJMP NUM_1
JUMP_TO_2:  LJMP NUM_2
JUMP_TO_3:  LJMP NUM_3
JUMP_TO_4:  LJMP NUM_4
JUMP_TO_5:  LJMP NUM_5
JUMP_TO_6:  LJMP NUM_6
JUMP_TO_7:  LJMP NUM_7
JUMP_TO_8:  LJMP NUM_8
JUMP_TO_9:  LJMP NUM_9

JUMP_PLUS:  LJMP ADD_FUNC
JUMP_MINUS: LJMP SUB_FUNC
JUMP_MULTI: LJMP MUL_FUNC
JUMP_DIVIDE:LJMP DIV_FUNC
JUMP_EQUAL: LJMP EQU_FUNC

; =================================================================
; FUNGSI RESET / CLEAR (ON/C)
; =================================================================
JUMP_RFRESH: 
    MOV R0, #01H        ; Command Clear LCD
    ACALL COMMAND
    
    ; Reset seluruh nilai register dan state
    MOV R1, #00H        ; Reset Angka 1
    MOV R2, #00H        ; Reset Operator
    MOV R3, #00H        ; Reset Angka 2
    MOV R4, #00H        ; Reset Hasil / Temp
    MOV R5, #00H        ; Reset Sisa Bagi
    MOV R6, #00H
    MOV R7, #00H
    CLR NOVONUM         ; Kembalikan flag
    CLR NOVODIG         ; Kembalikan flag
    LJMP L1

; =================================================================
; INPUT ANGKA (0-9)
; =================================================================
NUM_0: JNB ROW4, NUM_0
       MOV R0, #'0'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_1: JNB ROW3, NUM_1          
       MOV R0, #'1'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_2: JNB ROW3, NUM_2
       MOV R0, #'2'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_3: JNB ROW3, NUM_3
       MOV R0, #'3'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_4: JNB ROW2, NUM_4
       MOV R0, #'4'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_5: JNB ROW2, NUM_5
       MOV R0, #'5'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_6: JNB ROW2, NUM_6
       MOV R0, #'6'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_7: JNB ROW1, NUM_7
       MOV R0, #'7'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_8: JNB ROW1, NUM_8   
       MOV R0, #'8'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_9: JNB ROW1, NUM_9
       MOV R0, #'9'
       ACALL ASCII_2_DEC       
       ACALL DISPLAY
       LJMP L1

; =================================================================
; INPUT OPERATOR & SAMA DENGAN
; =================================================================
EQU_FUNC:
    JNB ROW4, EQU_FUNC
    MOV R0, #'='            
    ACALL DISPLAY
    ACALL RESULT        
    LJMP L1

ADD_FUNC: 
    JNB ROW4, ADD_FUNC
    MOV R0, #'+'
    ACALL OPERATOR      
    ACALL DISPLAY
    LJMP L1

SUB_FUNC:
    JNB ROW3, SUB_FUNC
    MOV R0, #'-'
    ACALL OPERATOR      
    ACALL DISPLAY
    LJMP L1

MUL_FUNC:
    JNB ROW2, MUL_FUNC
    MOV R0, #'*'
    ACALL OPERATOR      
    ACALL DISPLAY
    LJMP L1

DIV_FUNC:
    JNB ROW1, DIV_FUNC
    MOV R0, #'/'
    ACALL OPERATOR      
    ACALL DISPLAY
    LJMP L1

OPERATOR:
    SETB NOVONUM        
    CLR NOVODIG         
    MOV A, R0           
    MOV R2, A           
    RET

; =================================================================
; KONVERSI ASCII KE DECIMAL
; =================================================================
ASCII_2_DEC:
    JB NOVONUM, SECOND_NUMBER   
    JB NOVODIG, NEW_DIGIT       
    MOV A, R0
    SUBB A, #30H
    MOV R1, A           
    SETB NOVODIG        
    RET

NEW_DIGIT: 
    MOV A, R0
    MOV B, #10D
    SUBB A, #30H
    MOV R7, A
    MOV A, R1
    MUL AB              
    MOV R6, B 
    CJNE R6, #00H, JUMP_BURST
    ADD A, R7
    JC JUMP_BURST
    MOV R1, A           
    SETB NOVODIG
    RET

SECOND_NUMBER:
    JB NOVODIG, NOVODIGITO2
    MOV A, R0
    SUBB A, #30H
    MOV R3, A           
    SETB NOVODIG
    RET

NOVODIGITO2:
    MOV A, R0
    MOV B, #10D
    SUBB A, #30H
    MOV R7, A
    MOV A, R3
    MUL AB              
    MOV R6, B
    CJNE R6, #00H, JUMP_BURST
    ADD A, R7
    JC JUMP_BURST
    MOV R3, A           
    SETB NOVODIG
    RET

JUMP_BURST: 
    LJMP ERRORS

; =================================================================
; KALKULASI HASIL (RESULT)
; =================================================================
RESULT:
ADD_BYTES:
    CJNE R2, #'+', SUB_BYTES
    MOV A, R1
    CLR C
    ADD A, R3
    JC JUMP_BURST
    MOV R5, #0H
    MOV R4, A
    LJMP TO_PRINT

SUB_BYTES:
    CJNE R2, #'-', MUL_BYTES
    MOV A, R1
    CLR C
    SUBB A, R3
    JC JUMP_BURST
    MOV R5, #0H
    MOV R4, A
    LJMP TO_PRINT

MUL_BYTES:
    CJNE R2, #'*', DIV_BYTES
    MOV A, R1
    MOV B, R3
    MUL AB
    MOV R7, B
    CJNE R7, #0H, ERRORS
    MOV R5, #0H
    MOV R4, A
    LJMP TO_PRINT

DIV_BYTES:
    MOV A, R1
    MOV B, R3
    DIV AB
    MOV R4, A           
    MOV R5, B           
    LJMP TO_PRINT

; =================================================================
; CETAK HASIL KE LCD
; =================================================================
TO_PRINT:
    CJNE R3, #0D, NORMAL
    CJNE R2, #'/', NORMAL
    MOV R0, #0C0H
    ACALL COMMAND
    MOV DPTR, #MSG_ERR_0
    CLR C
    MOV R7, #0D
PROX:   
    MOV A, R7
    MOVC A, @A+DPTR
    MOV R0, A
    ACALL DISPLAY
    INC R7
    JNZ PROX
    RET

ERRORS:
    MOV R0, #0C0H
    ACALL COMMAND
    MOV DPTR, #MSG_ERR_1
    CLR C
    MOV R7, #0D
PROX2:  
    MOV A, R7
    MOVC A, @A+DPTR
    MOV R0, A
    ACALL DISPLAY
    JZ FIM
    INC R7
    SJMP PROX2
FIM:
    RET

NORMAL: 
    MOV R7, #100D
    CLR C
    SUBB A, R7
    JC MENOR100
    MOV A, R4
    MOV B, R7
    DIV AB
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    MOV R4, B
    MOV A, B
    MOV R7, #10D
    MOV B, R7
    DIV AB
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    MOV A, B
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    CJNE R5, #00H, DECIMAL
    RET

MENOR100: 
    MOV R7, #10D
    CLR C
    MOV A, R4
    SUBB A, R7
    JC MENOR10
    MOV A, R4
    MOV B, R7
    DIV AB
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    MOV A, B
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    CJNE R5, #00H, DECIMAL
    RET

MENOR10:
    MOV A, R4
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    CJNE R5, #00H, DECIMAL
    RET

DECIMAL: 
    MOV R0, #'.'
    ACALL DISPLAY
    MOV A, R5
    MOV B, #10D
    MUL AB
    MOV B, R3
    DIV AB
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    RET

; =================================================================
; DRIVER LCD
; =================================================================
DISPLAY:
    MOV LCD_DAT, R0     ; Menggunakan Port LCD Modular
    SETB LCD_RS         ; Menggunakan Pin RS Modular
    SETB LCD_EN         ; Menggunakan Pin EN Modular
    ACALL DELAY
    CLR LCD_EN
    RET

COMMAND:
    MOV LCD_DAT, R0     ; Menggunakan Port LCD Modular
    CLR LCD_RS          ; Menggunakan Pin RS Modular
    SETB LCD_EN         ; Menggunakan Pin EN Modular
    ACALL DELAY
    CLR LCD_EN
    RET

; =================================================================
; INITIALIZATION & DELAY
; =================================================================
INITIALYZE:
    CLR A               
    MOV R0, A
    MOV R1, A
    MOV R2, A
    MOV R3, A
    MOV R4, A
    MOV R5, A
    MOV R6, A
    MOV R7, A
    
    ; Setup Port Modular
    MOV LCD_DAT, A      ; Reset Port Data LCD
    MOV KEY_PORT, #0FEH ; Setup awal Keypad Matrix (Kolom 1 Low)
    
LCD_INIT:
    MOV R0,#38H
    ACALL COMMAND
    MOV R0,#0EH
    ACALL COMMAND
    MOV R0,#01H
    ACALL COMMAND
    MOV A,#06H 
    ACALL COMMAND
    MOV R0,#80H
    ACALL COMMAND
    MOV A,#3CH 
    ACALL COMMAND

STARTUP_MSG:        
    MOV R0, #01H
    ACALL COMMAND
    MOV DPTR, #MSG_START
DO_LOOP1:   
    CLR A
    MOVC A, @A+DPTR
    MOV R0, A
    JZ EXIT1
    ACALL DISPLAY           
    ACALL DELAY             
    INC DPTR
    SJMP DO_LOOP1
EXIT1:
    ACALL DELAY
    ACALL DELAY
    MOV R0, #01H
    ACALL COMMAND           
    RET

DELAY:  MOV 62, #2          
DELAY1: MOV 61, #100
DELAY2: MOV 60, #250
        DJNZ 60, $
        DJNZ 61, DELAY2
        DJNZ 62, DELAY1
        RET

; =================================================================
; DATA STRING MESSAGE
; =================================================================
MSG_START: DB 'BASIC CALCULATOR',0
MSG_ERR_0: DB 'ERROR: DIV BY 0',0
MSG_ERR_1: DB 'OVERFLOW!',0

END