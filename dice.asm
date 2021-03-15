;;;
;;; Simply Dice Roller program
;;; Can run from Master Boot Record
;;; written for FASM (ported from a86)
;;;
;        org     0100h           ;Setting causes fasm to generate a com file
        org 7C00h               ; 'origin' of Boot code
                                ; helps make sure addresses don't change

        mov     ah,00h          ;\
        int     1ah             ; seed random number with timer
        mov     word [seed], dx ;/

dice:
        mov     word [total],00h
        mov     ax, 0003h       ;clear screen
        int     10h             ;

        mov     di,menu         ;print menu
        call    writeLine

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
        jmp     dice            ;end program
checkt: cmp     al,74h
        jnz     checkc

        mov     di,dashes       ;print dashes
        call    writeLine

        mov     ax,word [total]
        call    writeNum        ;disp total
        jmp     lbla
checkc: cmp     al,63h
        jnz     cont
        jmp     dice

cont:   mov     ax,0fee9h       ;get next random number
        mul     word [seed]
        mov     word [seed], ax

        mul     word [die]           ;rnd*dice

        mov     bx,0ffffh       ;rnd*dice/max_rnd
        div     bx

        inc     ax              ;rnd*dice/max_rnd+1

        add     word [total],ax
        call    writeNum
        jmp     lbla

seed:   dw      1
die:    dw      0ffffh
total:  dw      0
dashes: db      "----",10,13,0
menu:   db      "1-1d4 2-1d6 3-1d8 4-1d10 5-1d12 6-1d20 7-1d100 t-total c-clear q-quit",10,13,0

;;; writeLine
;    prints number in AX
;
writeNum:
        pusha                   ; save registers
        mov     bx, 10          ; divive by 10 for base 10 printing
        mov     dx, 0
moreDiv:
        push    dx
        mov     dx, 0
        div     bx              ; ax = num/10, dx = num%10
        add     dx, 0e30h       ; convert to TTY print instruction
        cmp     ax, 0
        jnz     moreDiv
        mov     ax, dx
morePrint:
        int     10h
        pop     ax
        cmp     ax, 0
        jnz     morePrint
        mov     ax, 0e0ah       ; print newline
        int     10h
        mov     al, 0dh         ; print carriage return
        int     10h
        popa                    ; restore registers
        ret

;;; writeLine
;    prints string pointed to by DS:DI
;
writeLine:
        pusha                   ; save registers
        mov     bx, 0h          ; setup for int 10h function selection
        mov     ah, 0eh
getChar:
        mov     al, [di]   ; get character
        cmp     al, 0
        jnz     displayChar
        popa                    ; restore registers
        ret
displayChar:
        int     10h
        inc     di
        jmp     getChar


;; Boot sector magic
times 510-($-$$) db 0   ; pads out 0s until we reach 510th byte
dw 0AA55h               ; BIOS magic number; BOOT magic #
