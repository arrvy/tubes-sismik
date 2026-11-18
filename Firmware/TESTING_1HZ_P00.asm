
ORG 0H

Start:
    CLR P0.0          ; Kondisi awal LOW

Loop:
    CALL Delay
    SETB P0.0         ; HIGH
    CALL Delay
    CLR P0.0          ; LOW
    SJMP Loop

Delay:
    MOV R0,#100
    MOV TMOD,#00010000B

Load:
    MOV TH1,#0ECh
    MOV TL1,#078h
    SETB TR1

OFlow:
    JNB TF1,OFlow
    CLR TR1
    CLR TF1
    DJNZ R0,Load

    RET

END
x`