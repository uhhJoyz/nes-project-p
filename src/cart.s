;; The following code was hand-written following along with this tutorial
;; https://www.youtube.com/watch?v=V5uWqdK92i0&t=611s
;; The cartridge file containing text and sprites was obatined from the author of this video
.segment "HEADER"
    .byte "NES"                 ; identification string, allows the cartridge to be loaded on an NES
    .byte $1A
    .byte $02                   ; amount of PRG (program) ROM in 16 kb units
    .byte $01                   ; amount of CHR (characters) ROM in 8 kb units
    .byte $00                   ; mapper and mirroring (see NES dev wiki when we want to get more advanced)
    .byte $00, $00, $00, $00    ; these are necessary, but not sure why. also see NES dev wiki
    .byte $00, $00, $00, $00, $00 

;; this is for defining variables we need in our program
.segment "ZEROPAGE"
VAR:    .RES 1                  ; reserves 1 byte of memory in our "zero page" for a variable

.segment "STARTUP"
RESET:
INFLOOP:
    jmp INFLOOP

NMI:
    rti                         ; "return to interrupt" - basically if we get an NMI interrupt,
                                ; ignore it and go back to doing what we were doing

;; this is a list of "handlers" for certain hardware events. it is essentially
;; all of the names for the "functions" we have written above
.segment "VECTORS"
    ;; declare the non-maskable interrupt so that we can tell when the monitor
    ;; is in vertical blank state (when it is done being written to)
    .word NMI                   
    ;; allows us to control what happens when someone hits the reset button
    ;; on the NES
    .word RESET
    ;; can add irq word for specialized hardware interrupts, but we won't need them

.segment "CHARS"
    .incbin "rom.chr"           ; include the binary file "rom.chr," which contains text and a few sprites
    ;; note that this file is exactly 8kb in size because that is the declared size above, if we want to change that,
    ;; we will have to redefine the size variable
