INCLUDE "hardware.inc"

SECTION "Timer interrupt", ROM0[$50]
	ret

SECTION "After switch", ROM0[$65]
	jp afterSwitch

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR


SECTION "Game code", ROM0

Start:
.waitVBlank
	ld a, [rLY]
	cp 144
	jr c, .waitVBlank

	xor a
	ld [rLCDC], a

	ld hl, $9000
	ld de, TileData
	ld bc, TileDataEnd - TileData
.copyFont
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copyFont

	; Because this is CGB only, the RGB palette #1 needs to be written

	xor a
	ld c, a
	ldh [rBCPS], a
	ld a, $ff
	ldh [rBCPD], a
	inc c
	ld a, c
	ldh [rBCPS], a
	ld a, $3f
	ldh [rBCPD], a
	
	inc c
	ld a, c
	ldh [rBCPS], a
	ld a, %11110111
	ldh [rBCPD], a
	inc c
	ld a, c
	ldh [rBCPS], a
	ld a, %01011110
	ldh [rBCPD], a

	inc c
	ld a, c
	ldh [rBCPS], a
	ld a, %11101111
	ldh [rBCPD], a
	inc c
	ld a, c
	ldh [rBCPS], a
	ld a, %00111110
	ldh [rBCPD], a

	inc c
	ld a, c
	ldh [rBCPS], a
	ld a, %11100111
	ldh [rBCPD], a
	inc c
	ld a, c
	ldh [rBCPS], a
	ld a, %00011100
	ldh [rBCPD], a

	xor a
	ld [rSCY], a
	ld [rSCX], a

	ldh [rNR52], a

	ld a, $80
	ldh [rLCDC], a

	; Now for the fun part- do an illegal speed switch! :D
	; But first, record the initial register values in WRAM
	; Use the default ones, and not 0, as we'll know if they're changed if they get set to 0
	; AF, BC, DE, HL = $C012 (2 times each)

	ld sp, $c012
	push hl
	push de
	push bc
	push af

	; Okay, NOW do the illegal speed switch
	; First, make sure that JOYP is enabled, and IE and IF are non-zero
	; In this case, use the timer to interrupt the speed switch before it ends while a button is pressed
	
	ld a, %11010000
	ldh [rP1], a
	ld a, %00000100
	ldh [rIE], a
	xor a
	ldh [rIF], a
	ldh [rTAC], a
	ld a, $fe
	ldh [rTMA], a
	ldh [rTIMA], a
	ei
	ld a, %00000101 ; CPU clock / 16 (512KiHz, once every 4 machine cycles)
	ldh [rTAC], a

	; This ROM does 'stop stop', except with 'dw $10, $10' to make ultra sure it works

	ld a, $01
	ldh [rKEY1], a
	db $10,$10
	; This takes about 6 machine cycles, so only a few timer ticks are needed before the interrupt

	; Now, stall a little bit, and try to push the current register values onto the stack :p
	
afterSwitch:
	ld sp, $c008
	ldh a, [rKEY1]
	push hl
	push de
	push bc
	push af

	; Now to copy the results to the tilemap!

.waitVBlank0
	ld a, [rLY]
	cp 144
	jr c, .waitVBlank0
	xor a
	ldh [rLCDC], a

	ld hl, $c00a
	ld de, $9800
	ld b, 8
.copyLoop1	
	ld a, [hli]
	ld c, a
	swap a
	and $0f
	inc a
	ld [de], a
	inc de
	ld a, c
	and $0f
	inc a
	ld [de], a
	inc de
	dec b
	jr nz, .copyLoop1

	ld hl, $c000
	ld de, $9820
	ld b, 8
.copyLoop2	
	ld a, [hli]
	ld c, a
	swap a
	and $0f
	inc a
	ld [de], a
	inc de
	ld a, c
	and $0f
	inc a
	ld [de], a
	inc de
	dec b
	jr nz, .copyLoop2

	; And now enable the LCD

	ld a, $80
	ldh [rLCDC], a

.lockup
	jr .lockup

SECTION "Tile data", ROMX[$4000], BANK[1]
TileData::
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	
	DB $00,$00,$7c,$7c,$ce,$ce,$de,$de
	DB $f6,$f6,$e6,$e6,$e6,$e6,$7c,$7c

	DB $00,$00,$38,$38,$78,$78,$18,$18
	DB $18,$18,$18,$18,$18,$18,$7e,$7e

	DB $00,$00,$7c,$7c,$c6,$c6,$06,$06
	DB $1c,$1c,$70,$70,$c6,$c6,$fe,$fe

	DB $00,$00,$7c,$7c,$c6,$c6,$06,$06
	DB $1c,$1c,$06,$06,$c6,$c6,$7c,$7c

	DB $00,$00,$1c,$1c,$3c,$3c,$6c,$6c
	DB $cc,$cc,$fe,$fe,$0c,$0c,$1e,$1e

	DB $00,$00,$fe,$fe,$c0,$c0,$fc,$fc
	DB $06,$06,$06,$06,$c6,$c6,$7c,$7c

	DB $00,$00,$7c,$7c,$c6,$c6,$c0,$c0
	DB $fc,$fc,$c6,$c6,$c6,$c6,$7c,$7c

	DB $00,$00,$fe,$fe,$c6,$c6,$0e,$0e
	DB $1c,$1c,$38,$38,$30,$30,$30,$30

	DB $00,$00,$7c,$7c,$c6,$c6,$c6,$c6
	DB $7c,$7c,$c6,$c6,$c6,$c6,$7c,$7c

	DB $00,$00,$7c,$7c,$c6,$c6,$c6,$c6
	DB $7e,$7e,$06,$06,$c6,$c6,$7c,$7c

	DB $00,$00,$7c,$7c,$c6,$c6,$c6,$c6
	DB $fe,$fe,$c6,$c6,$c6,$c6,$c6,$c6

	DB $00,$00,$fc,$fc,$c6,$c6,$c6,$c6
	DB $fc,$fc,$c6,$c6,$c6,$c6,$fc,$fc

	DB $00,$00,$7c,$7c,$c6,$c6,$c0,$c0
	DB $c0,$c0,$c0,$c0,$c6,$c6,$7c,$7c

	DB $00,$00,$fc,$fc,$ce,$ce,$c6,$c6
	DB $c6,$c6,$c6,$c6,$ce,$ce,$fc,$fc

	DB $00,$00,$fe,$fe,$c0,$c0,$c0,$c0
	DB $fc,$fc,$c0,$c0,$c0,$c0,$fe,$fe

	DB $00,$00,$fe,$fe,$c0,$c0,$c0,$c0
	DB $fc,$fc,$c0,$c0,$c0,$c0,$c0,$c0
TileDataEnd::