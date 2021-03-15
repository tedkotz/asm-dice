        org     0100h           ;Setting causes fasm to generate a com file

;;;
;;; Simply Dice Roller program
;;; Can run from Master Boot Record
;;; written for FASM (ported from a86)
;;;
        mov     ah,00h          ;\
        int     1ah             ; seed random number with timer
        mov     word [seed], dx ;/

dice:   mov     ax, 0003h       ;clear screen
        int     10h             ;

        mov     dx,menu         ;print menu
        mov     ah,09h
        int     21h

lbla:   mov     ah,00h          ;readin a char
        int     16h

        cmp     al,31h          ;check for 1
        jnz     check2
        mov     word [die],4
check2: cmp     al,32h
        jnz     check3
        mov     word [die],6
check3: cmp     al,33h
        jnz     check4
        mov     word [die],8
check4: cmp     al,34h
        jnz     check5
        mov     word [die],10
check5: cmp     al,35h
        jnz     check6
        mov     word [die],12
check6: cmp     al,36h
        jnz     check7
        mov     word [die],20
check7: cmp     al,37h
        jnz     checkq
        mov     word [die],100
checkq: cmp     al,71h
        jnz     checkt
        int     20h             ;end program
checkt: cmp     al,74h
        jnz     checkc

        mov     dx,dashes       ;print dashes
        mov     ah,09h
        int     21h

        mov     cx,word [total]
        call    writeNum        ;disp total
        jmp     lbla
checkc: cmp     al,63h
        jnz     cont
        mov     word [total],00h
        jmp     dice

cont:   mov     ax,0fee9h       ;get next random number
        mul     word [seed]
        mov     word [seed], ax

        mul     word [die]           ;rnd*dice

        mov     bx,0ffffh       ;rnd*dice/max_rnd
        div     bx

        inc     ax              ;rnd*dice/max_rnd+1

        add     word [total],ax
        mov     cx,ax
        call    writeNum
        jmp     lbla

seed:   dw      1
die:    dw      0ffffh
total:  dw      0
dashes: db      "----",10,13,"$"
menu:   db      "1-1d4 2-1d6 3-1d8 4-1d10 5-1d12 6-1d20 7-1d100 t-total c-clear q-quit",10,13,"$"

writeNum:
        ret
