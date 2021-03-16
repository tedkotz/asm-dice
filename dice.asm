;;;
;;; Simply Dice Roller program
;;; Can run from Master Boot Record
;;; written for FASM (ported from a86)
;;;

; Defines
CR = 13
LF = 10
NULL = 0
MAX_RAND = 0fff1h

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
        jne     check2
        mov     word [die],4
check2: cmp     al,32h
        jne     check3
        mov     word [die],6
check3: cmp     al,33h
        jne     check4
        mov     word [die],8
check4: cmp     al,34h
        jne     check5
        mov     word [die],10
check5: cmp     al,35h
        jne     check6
        mov     word [die],12
check6: cmp     al,36h
        jne     check7
        mov     word [die],20
check7: cmp     al,37h
        jne     checkq
        mov     word [die],100
checkq: cmp     al,"q"
        jne     checkt
        jmp     dice            ;end program
checkt: cmp     al,"t"
        jne     checkc

        mov     di,dashes       ;print dashes
        call    writeLine

        mov     ax,word [total]
        call    writeNum        ;disp total
        jmp     lbla
checkc: cmp     al,"c"
        jne     cont
        jmp     dice

cont:   mov     word [seed], 2
        mov     cx, 0
.getNextRand:
        inc     cx
        mov     ax, MAX_RAND     ; get next random number
        mul     word [seed]
        inc     ax
        cmp     ax, 2
        jz      .printResults
        mov     word [seed], ax ; seed = (seed * MAX_RAND + 1) & 0xFFFF
;        call    writeNum

        mov     ax, dx          ; rnd = ((seed * MAX_RAND) >> 16) & 0xFFFF
        mul     word [die]      ; rnd*dice

        mov     bx,MAX_RAND     ; rnd*dice/MAX_RAND
        div     bx


        mov     bx,ax
        shl     bx, 1
        inc     word [counts + bx] ;
        inc     ax              ; roll = rnd*dice/MAX_RAND+1

        add     word [total],ax
        call    writeNum
        jmp     .getNextRand
.printResults:
        mov     di,dashes       ;print dashes
        call    writeLine

        mov     ax,cx
        call    writeNum

        mov     cx, 0
.printNextCount:
        mov     bx,cx
        shl     bx, 1
        mov     ax, word [counts + bx] ;
        call    writeNum
        inc     cx
        cmp     cx, 20
        jnz     .printNextCount




        jmp     lbla

seed:   dw      1
die:    dw      0ffffh
total:  dw      0
dashes: db      "----",CR,LF,NULL
menu:   db      "1-1d4 2-1d6 3-1d8 4-1d10 5-1d12 6-1d20 7-1d100 t-total c-clear q-quit",CR,LF,NULL
counts: dw      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;;; writeNum
;    prints number in AX as base 10
;    @param AX number to print
;
writeNum:
        pusha                   ; save registers
        mov     bx, 10          ; divive by 10 for base 10 printing
        mov     dx, 0
.moreDiv:
        push    dx              ; push 0 or print instruction
        mov     dx, 0
        div     bx              ; ax = num/10, dx = num%10
        add     dx, 0e30h       ; convert to TTY print instruction
        cmp     ax, 0
        jne     .moreDiv
        mov     ax, dx          ; move print instruction to ax for use
.morePrint:
        int     10h             ; print char [ah=0eh, bh=0, al=char]
        pop     ax              ; pop 0 or print instruction
        cmp     ax, 0
        jne     .morePrint
        mov     ax, 0e00h + CR  ; print carriage return
        int     10h             ; print char [ah=0eh, bh=0, al=char]
        mov     al, LF          ; print newline
        int     10h             ; print char [ah=0eh, bh=0, al=char]
exitProc:
        popa                    ; restore registers
        ret                     ; return to caller

;;; writeLine
;    prints string pointed to by DS:DI
;    NOTE: does not handle strings across segment boundary.
;    @param DS:DI pointer to start of zero terminated string
;
writeLine:
        pusha                   ; save registers
        mov     bx, 0h          ; setup for int 10h function selection
        mov     ah, 0eh
.getChar:
        mov     al, [di]        ; get character
        cmp     al, NULL
        je      exitProc
        int     10h             ; print char [ah=0eh, bh=0, al=char]
        inc     di              ; advance pointer to next char
        jmp     .getChar


;; Boot sector magic
times 510-($-$$) db 0   ; pads out 0s until we reach 510th byte
dw 0AA55h               ; BIOS magic number; BOOT magic #
