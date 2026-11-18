; =================================================================
; BASIC CALCULATOR 8051 (MODULAR + "ANS" CHAINING FEATURE)
; Konfigurasi PINOUT TERBARU:
; LCD Data = P1, LCD Ctrl = P3, Keypad = P2
; =================================================================

; =================================================================
; MODULAR HARDWARE CONFIGURATION
; =================================================================
; --- Konfigurasi LCD ---
LCD_DAT     EQU P1      ; Port Data LCD (D0-D7)
LCD_RS      EQU P3.2    ; Pin RS pada LCD
LCD_EN      EQU P3.3    ; Pin EN pada LCD

; --- Konfigurasi Port Keypad Matriks ---
KEY_PORT    EQU P2      ; Base Port untuk Keypad
COL1        EQU P2.0    ; Keypad Kolom 1
COL2        EQU P2.1    ; Keypad Kolom 2
COL3        EQU P2.2    ; Keypad Kolom 3
COL4        EQU P2.3    ; Keypad Kolom 4
ROW1        EQU P2.4    ; Keypad Baris 1
ROW2        EQU P2.5    ; Keypad Baris 2
ROW3        EQU P2.6    ; Keypad Baris 3
ROW4        EQU P2.7    ; Keypad Baris 4

; --- Flag Internal State ---
NOVONUM     EQU 20H.0   ; Flag: HIGH saat menulis angka kedua (Bit RAM Internal)
NOVODIG     EQU 20H.1   ; Flag: HIGH saat digit pertama sudah ditulis (Bit RAM Internal)
ANS_FLAG    EQU 20H.2   ; Flag: HIGH jika hasil hitungan sedang tampil di layar (Bit RAM Internal)

; --- Alokasi RAM 16-Bit (Max 1024) ---
NUM1_H      EQU 30H     ; Angka 1 High Byte
NUM1_L      EQU 31H     ; Angka 1 Low Byte
NUM2_H      EQU 32H     ; Angka 2 High Byte
NUM2_L      EQU 33H     ; Angka 2 Low Byte
RES_H       EQU 34H     ; Hasil High Byte
RES_L       EQU 35H     ; Hasil Low Byte
REM_H       EQU 36H     ; Sisa Bagi High Byte
REM_L       EQU 37H     ; Sisa Bagi Low Byte
; =================================================================

ORG 00H
    AJMP START

    ORG 40H 
START:  
    ACALL INITIALYZE
    SJMP L1

; =================================================================
; KEYPAD SCANNING (4x4 Matrix)
; =================================================================
L1:
    JNB COL1, C1
    JNB COL2, C2
    JNB COL3, C3
    JNB COL4, C4
    SJMP L1

C1: JNB ROW1, JUMP_TO_7 
    JNB ROW2, JUMP_TO_4 
    JNB ROW3, JUMP_TO_1 
    JNB ROW4, JUMP_RFRESH   ; <-- Tombol ON/C
    SETB COL1
    CLR COL2
    SJMP L1

C2: JNB ROW1, JUMP_TO_8 
    JNB ROW2, JUMP_TO_5 
    JNB ROW3, JUMP_TO_2 
    JNB ROW4, JUMP_TO_0 
    SETB COL2
    CLR COL3
    SJMP L1

C3: JNB ROW1, JUMP_TO_9 
    JNB ROW2, JUMP_TO_6 
    JNB ROW3, JUMP_TO_3 
    JNB ROW4, JUMP_EQUAL    
    SETB COL3
    CLR COL4
    SJMP L1

C4: JNB ROW1, JUMP_DIVIDE   
    JNB ROW2, JUMP_MULTI    
    JNB ROW3, JUMP_MINUS    
    JNB ROW4, JUMP_PLUS     
    SETB COL4
    CLR COL1
    LJMP L1

; --- PENGALIHAN JUMP ---
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
    MOV R0, #01H        
    ACALL COMMAND
    MOV R1, #00H        
    MOV R2, #00H        
    MOV R3, #00H        
    MOV R4, #00H        
    MOV R5, #00H        
    MOV R6, #00H
    MOV R7, #00H
    MOV NUM1_H, #00H
    MOV NUM1_L, #00H
    MOV NUM2_H, #00H
    MOV NUM2_L, #00H
    MOV RES_H, #00H
    MOV RES_L, #00H
    MOV REM_H, #00H
    MOV REM_L, #00H
    CLR NOVONUM         
    CLR NOVODIG 
    CLR ANS_FLAG        ; Reset status ANS
    LJMP L1

; =================================================================
; INPUT ANGKA (0-9)
; =================================================================
NUM_0: JNB ROW4, NUM_0
       ACALL CHECK_NEW_CALC
       MOV R0, #'0'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_1: JNB ROW3, NUM_1          
       ACALL CHECK_NEW_CALC
       MOV R0, #'7'             ; Diubah dari '1' menjadi '7'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_2: JNB ROW3, NUM_2
       ACALL CHECK_NEW_CALC
       MOV R0, #'8'             ; Diubah dari '2' menjadi '8'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_3: JNB ROW3, NUM_3
       ACALL CHECK_NEW_CALC
       MOV R0, #'9'             ; Diubah dari '3' menjadi '9'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_4: JNB ROW2, NUM_4
       ACALL CHECK_NEW_CALC
       MOV R0, #'4'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_5: JNB ROW2, NUM_5
       ACALL CHECK_NEW_CALC
       MOV R0, #'5'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_6: JNB ROW2, NUM_6
       ACALL CHECK_NEW_CALC
       MOV R0, #'6'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_7: JNB ROW1, NUM_7
       ACALL CHECK_NEW_CALC
       MOV R0, #'1'             ; Diubah dari '7' menjadi '1'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_8: JNB ROW1, NUM_8   
       ACALL CHECK_NEW_CALC
       MOV R0, #'2'             ; Diubah dari '8' menjadi '2'
       ACALL ASCII_2_DEC
       ACALL DISPLAY
       LJMP L1

NUM_9: JNB ROW1, NUM_9
       ACALL CHECK_NEW_CALC
       MOV R0, #'3'             ; Diubah dari '9' menjadi '3'
       ACALL ASCII_2_DEC       
       ACALL DISPLAY
       LJMP L1
       
; =================================================================
; CEK JIKA MEMULAI PERHITUNGAN BARU SETELAH HASIL KELUAR
; =================================================================
CHECK_NEW_CALC:
    JNB ANS_FLAG, CHECK_END
    MOV R0, #01H
    ACALL COMMAND
    MOV R1, #00H
    MOV R2, #00H
    MOV R3, #00H
    MOV R4, #00H
    MOV R5, #00H
    MOV NUM1_H, #00H
    MOV NUM1_L, #00H
    MOV NUM2_H, #00H
    MOV NUM2_L, #00H
    MOV RES_H, #00H
    MOV RES_L, #00H
    MOV REM_H, #00H
    MOV REM_L, #00H
    CLR NOVONUM
    CLR NOVODIG
    CLR ANS_FLAG
CHECK_END:
    RET

; =================================================================
; INPUT OPERATOR & SAMA DENGAN
; =================================================================
EQU_FUNC:
    JNB ROW4, EQU_FUNC
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
    MOV A, R0           
    JNB NOVONUM, SKIP_AUTO_EQ   ; Jika belum masuk angka kedua, lompat biasa
    JNB NOVODIG, SKIP_AUTO_EQ   ; Jika angka kedua belum diketik, lompat biasa

    ; --- AUTO-CALCULATE SEBELUM CHAINING OPERATOR BARU ---
    PUSH ACC                    ; Simpan sementara operator baru di Stack (aman 100%)
    ACALL RESULT                ; Hitung operasi sebelumnya (hasil masuk RES_H:RES_L & ANS_FLAG=1)
    POP ACC                     ; Ambil kembali operator baru dari Stack

SKIP_AUTO_EQ:
    MOV R2, A           
    
    JNB ANS_FLAG, NORMAL_OP     
    
    ; --- LOGIKA CHAINING (BERSIHKAN BARIS 1 & CETAK "ANS") ---
    MOV NUM1_H, RES_H
    MOV NUM1_L, RES_L
    MOV NUM2_H, #00H
    MOV NUM2_L, #00H
    CLR ANS_FLAG        
    
    MOV R0, #80H        ; Pindah ke awal baris 1
    ACALL COMMAND
    
    MOV R0, #'A'
    ACALL DISPLAY
    MOV R0, #'N'
    ACALL DISPLAY
    MOV R0, #'S'
    ACALL DISPLAY
    
    MOV A, R2           ; Cetak operator langsung setelah 'S'
    MOV R0, A
    ACALL DISPLAY
    
    MOV R7, #12D        ; Bersihkan sisa 12 kolom di kanan baris 1
CLEAR_REST_LINE1:
    MOV R0, #' '
    ACALL DISPLAY
    DJNZ R7, CLEAR_REST_LINE1
    
    MOV R0, #84H        ; Kembalikan kursor tepat setelah "ANS+" (kolom ke-5 baris 1)
    ACALL COMMAND
    
    POP ACC             ; Hapus alamat return ke ADD_FUNC/SUB_FUNC/MUL_FUNC/DIV_FUNC
    POP ACC             ; agar tidak mencetak operator dua kali
    SETB NOVONUM        
    CLR NOVODIG         
    LJMP L1             ; Langsung kembali ke loop utama scanning keypad

NORMAL_OP:
    SETB NOVONUM        
    CLR NOVODIG         
    RET
    
; =================================================================
; KONVERSI ASCII KE DECIMAL (Fix: Menggunakan ANL bukan SUBB)
; =================================================================
ASCII_2_DEC:
    JB NOVONUM, SECOND_NUMBER   
    JB NOVODIG, NEW_DIGIT       
    MOV A, R0
    ANL A, #0FH         ; Lebih stabil dari SUBB A, #30H
    MOV NUM1_H, #00H
    MOV NUM1_L, A           
    SETB NOVODIG        
    RET

NEW_DIGIT: 
    MOV A, R0
    ANL A, #0FH
    MOV R7, A
    MOV A, NUM1_L
    MOV B, #10D
    MUL AB              
    ADD A, R7
    MOV NUM1_L, A
    CLR A
    ADDC A, B
    MOV R6, A
    MOV A, NUM1_H
    MOV B, #10D
    MUL AB
    MOV R5, B
    CJNE R5, #00H, JUMP_BURST_WRAPPER
    ADD A, R6
    JC JUMP_BURST_WRAPPER
    MOV NUM1_H, A
    MOV R4, NUM1_H
    MOV R5, NUM1_L
    ACALL CHECK_MAX_1024
    SETB NOVODIG
    RET

SECOND_NUMBER:
    JB NOVODIG, NOVODIGITO2
    MOV A, R0
    ANL A, #0FH
    MOV NUM2_H, #00H
    MOV NUM2_L, A           
    SETB NOVODIG
    RET

NOVODIGITO2:
    MOV A, R0
    ANL A, #0FH
    MOV R7, A
    MOV A, NUM2_L
    MOV B, #10D
    MUL AB              
    ADD A, R7
    MOV NUM2_L, A
    CLR A
    ADDC A, B
    MOV R6, A
    MOV A, NUM2_H
    MOV B, #10D
    MUL AB
    MOV R5, B
    CJNE R5, #00H, JUMP_BURST_WRAPPER
    ADD A, R6
    JC JUMP_BURST_WRAPPER
    MOV NUM2_H, A
    MOV R4, NUM2_H
    MOV R5, NUM2_L
    ACALL CHECK_MAX_1024
    SETB NOVODIG
    RET

CHECK_MAX_1024:
    CJNE R4, #04H, CHK_1024_HIGH
    MOV A, R5
    JNZ JUMP_BURST_WRAPPER
    RET
CHK_1024_HIGH:
    JNC JUMP_BURST_WRAPPER
    RET

JUMP_BURST_WRAPPER:
    LJMP ERRORS

; =================================================================
; KALKULASI HASIL (RESULT)
; =================================================================
RESULT:
    MOV REM_H, #00H
    MOV REM_L, #00H
    CJNE R2, #00H, ADD_BYTES
    MOV RES_H, NUM1_H
    MOV RES_L, NUM1_L
    LJMP NORMAL

ADD_BYTES:
    CJNE R2, #'+', SUB_BYTES
    CLR C
    MOV A, NUM1_L
    ADD A, NUM2_L
    MOV RES_L, A
    MOV A, NUM1_H
    ADDC A, NUM2_H
    JC JUMP_BURST_WRAPPER
    MOV RES_H, A
    MOV R4, RES_H
    MOV R5, RES_L
    ACALL CHECK_MAX_1024
    LJMP TO_PRINT

SUB_BYTES:
    CJNE R2, #'-', MUL_BYTES
    CLR C
    MOV A, NUM1_L
    SUBB A, NUM2_L
    MOV RES_L, A
    MOV A, NUM1_H
    SUBB A, NUM2_H
    JC JUMP_BURST_WRAPPER
    MOV RES_H, A
    LJMP TO_PRINT

MUL_BYTES:
    CJNE R2, #'*', DIV_BYTES
    MOV RES_H, #00H
    MOV RES_L, #00H
    MOV A, NUM2_H
    ORL A, NUM2_L
    JZ MUL_DONE
    MOV R6, NUM2_H
    MOV R7, NUM2_L
MUL_LOOP:
    CLR C
    MOV A, RES_L
    ADD A, NUM1_L
    MOV RES_L, A
    MOV A, RES_H
    ADDC A, NUM1_H
    JC JUMP_BURST_WRAPPER
    MOV RES_H, A
    MOV R4, RES_H
    MOV R5, RES_L
    ACALL CHECK_MAX_1024
    MOV A, R7
    JNZ DEC_MUL_LOW
    DEC R6
DEC_MUL_LOW:
    DEC R7
    MOV A, R6
    ORL A, R7
    JNZ MUL_LOOP
MUL_DONE:
    LJMP TO_PRINT

DIV_BYTES:
    MOV A, NUM2_H
    ORL A, NUM2_L
    JZ JUMP_DIV_ZERO
    MOV RES_H, #00H
    MOV RES_L, #00H
    MOV REM_H, NUM1_H
    MOV REM_L, NUM1_L
DIV_LOOP:
    CLR C
    MOV A, REM_L
    SUBB A, NUM2_L
    MOV R5, A
    MOV A, REM_H
    SUBB A, NUM2_H
    JC DIV_DONE
    MOV REM_H, A
    MOV REM_L, R5
    INC RES_L
    MOV A, RES_L
    JNZ DIV_LOOP
    INC RES_H
    SJMP DIV_LOOP
DIV_DONE:
    LJMP TO_PRINT

JUMP_DIV_ZERO:
    LJMP DIV_ZERO_ERR

; =================================================================
; CETAK HASIL KE LCD
; =================================================================
TO_PRINT:
    CJNE R2, #'/', NORMAL
    MOV A, NUM2_H
    ORL A, NUM2_L
    JNZ NORMAL

DIV_ZERO_ERR:
    ; Pengecekan Error Dibagi 0
    MOV R0, #0C0H
    ACALL COMMAND
    MOV DPTR, #MSG_ERR_0
    MOV R7, #0D
PROX:   
    MOV A, R7
    MOVC A, @A+DPTR
    JZ FIM_ERR          ; Fix BUG: Pengecekan dilakukan sebelum display!
    MOV R0, A
    ACALL DISPLAY
    INC R7
    SJMP PROX

ERRORS:
    MOV R0, #0C0H
    ACALL COMMAND
    MOV DPTR, #MSG_ERR_1
    MOV R7, #0D
PROX2:  
    MOV A, R7
    MOVC A, @A+DPTR
    JZ FIM_ERR          ; Fix BUG: Pengecekan dilakukan sebelum display!
    MOV R0, A
    ACALL DISPLAY
    INC R7
    SJMP PROX2
    
FIM_ERR:
    SETB ANS_FLAG       ; Set agar kalau user tekan angka baru, layar me-refresh
    RET

NORMAL: 
    SETB ANS_FLAG       
    
    ; --- BERSIHKAN BARIS 2 AGAR SISA DIGIT LAMA HILANG ---
    MOV R0, #0C0H       ; Pindah ke awal baris 2
    ACALL COMMAND
    MOV R7, #16D        ; 16 karakter dalam 1 baris
CLEAR_LINE2:
    MOV R0, #' '
    ACALL DISPLAY
    DJNZ R7, CLEAR_LINE2

    MOV R0, #0CAH       ; Posisi C0 + 10 = Menaruh tepat hingga 4 digit & desimal di pojok kanan 
    ACALL COMMAND
    
    MOV R4, RES_H
    MOV R5, RES_L
    MOV R3, #00H        ; Flag penanda digit non-nol pertama sudah tercetak
    
    MOV R6, #03H        ; 1000 = 03E8H
    MOV R7, #0E8H
    ACALL GET_DIGIT
    
    MOV R6, #00H        ; 100 = 0064H
    MOV R7, #64H
    ACALL GET_DIGIT
    
    MOV R6, #00H        ; 10 = 000AH
    MOV R7, #0AH
    ACALL GET_DIGIT
    
    MOV A, R5           ; Sisa satuan
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY
    
    MOV A, REM_H
    ORL A, REM_L
    JNZ DECIMAL
    RET

GET_DIGIT:
    MOV R1, #00H
DIGIT_LOOP:
    CLR C
    MOV A, R5
    SUBB A, R7
    MOV 38H, A
    MOV A, R4
    SUBB A, R6
    JC DIGIT_PRINT
    MOV R4, A
    MOV R5, 38H
    INC R1
    SJMP DIGIT_LOOP

DIGIT_PRINT:
    MOV A, R1
    JNZ PRINT_NOW
    CJNE R3, #00H, PRINT_NOW
    RET
PRINT_NOW:
    MOV R3, #01H
    MOV A, R1
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY
    RET

DECIMAL: 
    MOV R0, #'.'
    ACALL DISPLAY
    MOV A, REM_L
    MOV B, #10D
    MUL AB
    MOV R5, A
    MOV R6, B
    MOV A, REM_H
    MOV B, #10D
    MUL AB
    ADD A, R6
    MOV R4, A
    MOV R1, #00H
DEC_LOOP:
    CLR C
    MOV A, R5
    SUBB A, NUM2_L
    MOV 38H, A
    MOV A, R4
    SUBB A, NUM2_H
    JC DEC_PRINT
    MOV R4, A
    MOV R5, 38H
    INC R1
    SJMP DEC_LOOP
DEC_PRINT:
    MOV A, R1
    ADD A, #30H
    MOV R0, A
    ACALL DISPLAY       
    RET
; =================================================================
; RUTIN PEMBALIK BIT (BIT REVERSAL) 
; Memutar urutan bit (D0 jadi D7, D1 jadi D6, dst)
; =================================================================
REVERSE_BITS:
    MOV 3EH, R7         ; Backup R7 ke RAM agar tidak merusak loop teks (OVERFLOW)
    MOV 3FH, R6         ; Backup R6 ke RAM
    
    MOV R7, #8          ; Lakukan pergeseran sebanyak 8 kali (8-bit)
    MOV R6, #0          ; R6 sebagai penampung data yang sudah dibalik
REV_LOOP:
    RRC A               ; Geser bit paling kanan (LSB) dari A ke Carry Flag
    XCH A, R6           ; Tukar nilai A dengan R6 sementara
    RLC A               ; Masukkan Carry Flag tadi ke bit kanan (R6) sambil digeser ke kiri
    XCH A, R6           ; Tukar kembali
    DJNZ R7, REV_LOOP   ; Ulangi sampai 8 bit selesai dipindah
    
    MOV A, R6           ; Pindahkan hasil akhir (yang sudah terbalik) ke Akumulator
    MOV R7, 3EH         ; Kembalikan nilai asli R7
    MOV R6, 3FH         ; Kembalikan nilai asli R6
    RET

; =================================================================
; DRIVER LCD (Updated dengan Pembalik Bit)
; =================================================================
DISPLAY:
    MOV A, R0           ; 1. Ambil data asli dari R0
    ACALL REVERSE_BITS  ; 2. Panggil rutin pembalik bit
    MOV LCD_DAT, A      ; 3. Kirim data yang SUDAH DIBALIK ke Port 1
    SETB LCD_RS         
    SETB LCD_EN         
    ACALL DELAY
    CLR LCD_EN
    RET

COMMAND:
    MOV A, R0           ; 1. Ambil instruksi (command) asli dari R0
    ACALL REVERSE_BITS  ; 2. Panggil rutin pembalik bit
    MOV LCD_DAT, A      ; 3. Kirim instruksi yang SUDAH DIBALIK ke Port 1
    CLR LCD_RS          
    SETB LCD_EN         
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
    MOV NUM1_H, A
    MOV NUM1_L, A
    MOV NUM2_H, A
    MOV NUM2_L, A
    MOV RES_H, A
    MOV RES_L, A
    MOV REM_H, A
    MOV REM_L, A
    
    MOV LCD_DAT, A      
    MOV KEY_PORT, #0FEH 
    CLR NOVONUM
    CLR NOVODIG
    CLR ANS_FLAG
    
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
    JZ EXIT1
    MOV R0, A
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