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
init:
        mov     ah,00h          ;\
        int     1ah             ; seed random number with timer
        mov     word [seed], dx ;/
        mov     ax, 0003h       ;goto textmode (80x25)
        int     10h             ;
.main:
        call    dice
;        int     20h
        jmp     .main



dice:
        mov     word [total],00h
        mov     ax, 0600h       ;clear screen
        mov     bh, 0ah         ;BG = black(0), FG = B. green(10)
                                ;
                                ; |    |     0  |     1  |     2  |     3  |
                                ; |----|--------|--------|--------|--------|
                                ; | 0+ | 000000 | 800000 | 008000 | 808000 |
                                ; | 4+ | 000080 | 800080 | 008080 | c0c0c0 |
                                ; | 8+ | 808080 | ff0000 | 00ff00 | ffff00 |
                                ; | C+ | 0000ff | ff00ff | 00ffff | ffffff |
                                ;
        mov     cx, 0000h       ;start at 0,0
        mov     dx, 184fh       ;end at 79,24
        int     10h             ;
        mov     ah, 02h         ;move cursor to top of screen
        mov     bh, 00h
        mov     dx, 0000h       ;start at 0,0
        int     10h             ;

        mov     di,menu         ;print menu
        call    writeLine

.getKey:
        mov     ah,00h          ;readin a char
        int     16h

        cmp     al,"q"          ; case "q"
        jne     .notq
        ret                     ;end program
.notq:

        cmp     al,"c"          ; case "c"
        je      dice            ; restart dice

        cmp     al,"t"          ; case "t"
        jne     .nott

        mov     di,dashes       ;print dashes
        call    writeLine

        mov     ax,word [total] ;disp total
        call    writeNum
        jmp     .getKey

.nott:
        sub     al, "1"         ; al = key - '1'
        cmp     al, 7           ; if(key - '1' >= 7) getNextKey()
        jae     .getKey

        xor     bh, bh          ; bx = key - '1'
        mov     bl, al

        mov     bl, byte[die+bx]; bx = die[key-'1']

        mov     ax, MAX_RAND    ; get next random number
        mul     word [seed]
        inc     ax
        mov     word [seed], ax ; seed = (seed * MAX_RAND + 1) & 0xFFFF

        mov     ax, dx          ; rnd = ((seed * MAX_RAND) >> 16) & 0xFFFF
        mul     bx              ; rnd*dice

        mov     bx,MAX_RAND     ; rnd*dice/MAX_RAND
        div     bx
        inc     ax              ; roll = rnd*dice/MAX_RAND+1

        add     word [total],ax
        call    writeNum

        jmp     .getKey

seed:   dw      1
total:  dw      0
dashes: db      "----",CR,LF,NULL
menu:   db      "1-1d4 2-1d6 3-1d8 4-1d10 5-1d12 6-1d20 7-1d100 t-total c-clear q-quit",CR,LF,NULL
die:    db      4,6,8,10,12,20,100

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
