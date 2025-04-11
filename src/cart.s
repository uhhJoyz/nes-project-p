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
    sei                         ; disable interrupts TODO: come back here and enable them later
    cld                         ; disable decimal mode (unsupported by NES architecture)

    ldx #$1000000                ; disable sound irq (load literal value 0x1000000 into index, or index register, X)
    stx $4017                    ; store that value to the address (4017)
    ldx #$00
    stx $4010                   ; disable pcm

    ;; initializing stack register
    ldx #$FF                    ; load the literal 0xFF
    txs                         ; transfer it to the stack register

CLEAR_PPU:   
    ;; clear the PPU (pixel processing unit) registers
    lxd #$00
    stx $2000
    stx $2001

: 
    ;; wait for VBLANK (vertical blank)
    bit $2002
    bpl :-                      ; conditionally loop (branch if the result of the previous operation was positive)
                                ; the :- here means jump to the previous anonymous symbol (defined 3 lines above with :)

    txa
CLEARMEMORY:
    ;; this part is a loop that clears the memory of our device (takes a long time)
    sta $0000, x
    sta $0100, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x

    ;; we set the address 0x0200 to the literal 0xFF because this allows us to control when sprites are displayed
    lda #$FF
    sta $0200, x
    lda #$00

    inx
    cpx #$00
    bne CLEARMEMORY

;; wait for vblank again
:
    bit $2002
    bpl :-

    lda #$02
    sta $4014                   ; tells the PPU where the sprites are stored (8 kb range, so by setting this to 0x02,
                                ; we tell the PPU that sprites are stored in addresses of the form 0x02__)
    nop
    lda #$3F                    ; PPU memory starts at 0x3F00, so we load the left 2 nybbles (most significant byte) into the A register
    sta $2006                   
    lda #$00
    sta $2006
    ;; what's happening here is that the PPU requires 2 writes to set its memory range properly - the first writes the most significant byte
    ;; the second writes the least significant byte. This set of instructions tells the PPU that its memory starts at address 0x3F00

    ldx #$00
LOADPALETTES:
    sta $2007
    inx
    cpx #$20
    bne LOADPALETTES
;; TODO: finish setting up sprite data and palette data


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
