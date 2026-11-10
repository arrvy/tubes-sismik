; =================================================================
; BASIC CALCULATOR 8051 (REFINED VERSION)
; Fitur: 
; - Operator langsung tampil setelah angka pertama (Augend)
; - Tombol R4 C1 berfungsi penuh sebagai ON/C (Clear/Reset All)
; =================================================================

; --- DEKLARASI PIN I/O & FLAG ---
RS          EQU P2.1    ; RS pada LCD
EN          EQU P2.2    ; EN pada LCD
NOVONUM     EQU P2.7    ; P2.7 HIGH saat menulis angka kedua
NOVODIG     EQU P2.6    ; P2.6 HIGH saat digit pertama sudah ditulis

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
    JNB P3.0, C1
    JNB P3.1, C2
    JNB P3.2, C3
    JNB P3.3, C4
    SJMP L1

C1: ; SCANNING KOLOM 1
    JNB P3.4, JUMP_TO_7 
    JNB P3.5, JUMP_TO_4 
    JNB P3.6, JUMP_TO_1 
    JNB P3.7, JUMP_RFRESH   ; <-- Tombol R4 C1 (ON/C) untuk RESET
    SETB P3.0
    CLR P3.1
    SJMP L1

C2: ; SCANNING KOLOM 2
    JNB P3.4, JUMP_TO_8 
    JNB P3.5, JUMP_TO_5 
    JNB P3.6, JUMP_TO_2 
    JNB P3.7, JUMP_TO_0 
    SETB P3.1
    CLR P3.2
    SJMP L1

C3: ; SCANNING KOLOM 3
    JNB P3.4, JUMP_TO_9 
    JNB P3.5, JUMP_TO_6 
    JNB P3.6, JUMP_TO_3 
    JNB P3.7, JUMP_EQUAL    
    SETB P3.2
    CLR P3.3
    SJMP L1

C4: ; SCANNING KOLOM 4
    JNB P3.4, JUMP_DIVIDE   
    JNB P3.5, JUMP_MULTI    
    JNB P3.6, JUMP_MINUS    
    JNB P3.7, JUMP_PLUS     
    SETB P3.3
    CLR P3.0
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
    CLR NOVONUM         ; Kembalikan flag ke input angka pertama
    CLR NOVODIG         ; Kembalikan flag digit baru
    LJMP L1

; =================================================================
; INPUT ANGKA (0-9)
; =================================================================
NUM_0: JNB P3.7, NUM_0
       MOV R0, #'0'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_1: JNB P3.6, NUM_1          
       MOV R0, #'1'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_2: JNB P3.6, NUM_2
       MOV R0, #'2'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_3: JNB P3.6, NUM_3
       MOV R0, #'3'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_4: JNB P3.5, NUM_4
       MOV R0, #'4'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_5: JNB P3.5, NUM_5
       MOV R0, #'5'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_6: JNB P3.5, NUM_6
       MOV R0, #'6'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_7: JNB P3.4, NUM_7
       MOV R0, #'7'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_8: JNB P3.4, NUM_8   
       MOV R0, #'8'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_9: JNB P3.4, NUM_9
       MOV R0, #'9'
       ACALL ASCII_2_DEC       
       ACALL DISPLAY
       LJMP L1

; =================================================================
; INPUT OPERATOR & SAMA DENGAN
; =================================================================
EQU_FUNC:
    JNB P3.7, EQU_FUNC
    MOV R0, #'='            
    ACALL DISPLAY
    ACALL RESULT        
    LJMP L1

ADD_FUNC: 
    JNB P3.7, ADD_FUNC
    MOV R0, #'+'
    ACALL OPERATOR      
    ACALL DISPLAY       ; Langsung tampilkan '+' setelah angka 1
    LJMP L1

SUB_FUNC:
    JNB P3.6, SUB_FUNC
    MOV R0, #'-'
    ACALL OPERATOR      
    ACALL DISPLAY       ; Langsung tampilkan '-' setelah angka 1
    LJMP L1

MUL_FUNC:
    JNB P3.5, MUL_FUNC
    MOV R0, #'*'
    ACALL OPERATOR      
    ACALL DISPLAY       ; Langsung tampilkan '*' setelah angka 1
    LJMP L1

DIV_FUNC:
    JNB P3.4, DIV_FUNC
    MOV R0, #'/'
    ACALL OPERATOR      
    ACALL DISPLAY       ; Langsung tampilkan '/' setelah angka 1
    LJMP L1

OPERATOR:
    SETB NOVONUM        ; Aktifkan state untuk menerima Angka Ke-2
    CLR NOVODIG         ; Reset flag digit untuk angka baru
    MOV A, R0           
    MOV R2, A           ; Simpan tipe operator di R2
    RET

; =================================================================
; KONVERSI ASCII KE DECIMAL (PENYIMPANAN NILAI)
; =================================================================
ASCII_2_DEC:
    JB NOVONUM, SECOND_NUMBER   ; Jika state angka ke-2, lompat
    JB NOVODIG, NEW_DIGIT       ; Jika bukan digit pertama angka ke-1, lompat
    
    ; Simpan digit pertama dari angka pertama
    MOV A, R0
    SUBB A, #30H
    MOV R1, A           ; Nilai masuk ke R1
    SETB NOVODIG        ; Tandai digit pertama sudah masuk
    RET

NEW_DIGIT: 
    MOV A, R0
    MOV B, #10D
    SUBB A, #30H
    MOV R7, A
    MOV A, R1
    MUL AB              ; R1 * 10
    MOV R6, B 
    CJNE R6, #00H, JUMP_BURST
    ADD A, R7
    JC JUMP_BURST
    MOV R1, A           ; Update R1 dengan gabungan digit
    SETB NOVODIG
    RET

SECOND_NUMBER:
    JB NOVODIG, NOVODIGITO2
    
    ; Simpan digit pertama dari angka kedua
    MOV A, R0
    SUBB A, #30H
    MOV R3, A           ; Nilai masuk ke R3
    SETB NOVODIG
    RET

NOVODIGITO2:
    MOV A, R0
    MOV B, #10D
    SUBB A, #30H
    MOV R7, A
    MOV A, R3
    MUL AB              ; R3 * 10
    MOV R6, B
    CJNE R6, #00H, JUMP_BURST
    ADD A, R7
    JC JUMP_BURST
    MOV R3, A           ; Update R3 dengan gabungan digit
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
    MOV R4, A           ; R4 menyimpan hasil bagi
    MOV R5, B           ; R5 menyimpan sisa bagi (modulus)
    LJMP TO_PRINT

; =================================================================
; CETAK HASIL KE LCD
; =================================================================
TO_PRINT:
    CJNE R3, #0D, NORMAL
    CJNE R2, #'/', NORMAL
    ; Jika Pembagian dengan 0
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
    ACALL DISPLAY       ; Cetak Ratusan
    MOV R4, B
    MOV A, B
    MOV R7, #10D
    MOV B, R7
    DIV AB
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       ; Cetak Puluhan
    MOV A, B
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       ; Cetak Satuan
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
    ACALL DISPLAY       ; Cetak Puluhan
    MOV A, B
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       ; Cetak Satuan
    CJNE R5, #00H, DECIMAL
    RET

MENOR10:
    MOV A, R4
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       ; Cetak Satuan
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
    ACALL DISPLAY       ; Cetak angka di belakang koma
    RET

; =================================================================
; DRIVER LCD
; =================================================================
DISPLAY:
    MOV P0, R0
    SETB RS
    SETB EN
    ACALL DELAY
    CLR EN
    RET

COMMAND:
    MOV P0, R0
    CLR RS
    SETB EN
    ACALL DELAY
    CLR EN
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
    MOV P0, A
    MOV P1, A
    MOV P2, A
    MOV P3, #0FEH

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
    ACALL COMMAND           ; Bersihkan layar setelah splash screen
    RET

DELAY:  MOV 62, #2          ; APPROX DELAY DE 0.25s
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