/*
 * follow the parts of the meromero tutorial where you edit the narcs.  keep the edited ones on standby.
 *
 * run extract.bat
 * run decompress.bat
 * run makefairytype.bat
 *
 * open rom in tinke and "Change file" all of:
 *  overlay 167
 *  overlay 168
 *  overlay 207
 *  overlay 255
 *  overlay 265
 *  arm9
 *  the narcs that you edited from the tutorial
 *
 * save rom--should be all set.  fairy type becomes type 17.
 * from there:
 *  make struggle type 18 and that should be good to get it typeless (i believe it used to be type 17 to get the typeless advantage).
 */

// initializations

.nds
.thumb

// configs
MEROMERO_SUMMARY_SCREEN_FIX equ 0
BLU_SUMMARY_SCREEN_FIX equ 1
BLU_PC_SCREEN_FIX equ 1

BLACK2 equ 0


// defines
TYPE_NORMAL equ 0
TYPE_FIGHTING equ 1
TYPE_FLYING equ 2
TYPE_POISON equ 3
TYPE_GROUND equ 4
TYPE_ROCK equ 5
TYPE_BUG equ 6
TYPE_GHOST equ 7
TYPE_STEEL equ 8
TYPE_FIRE equ 9
TYPE_WATER equ 10
TYPE_GRASS equ 11
TYPE_ELECTRIC equ 12
TYPE_PSYCHIC equ 13
TYPE_ICE equ 14
TYPE_DRAGON equ 15
TYPE_DARK equ 16
TYPE_FAIRY equ 17
NUM_OF_TYPES equ 18

START_OF_NEW_TAGS equ 0x20 // god damn it

//.expfunc rgb555(red, green, blue), (red & 0x1F) | ((green & 0x1F) << 5) | ((blue & 0x1F) << 10)
//.expfunc rgb(red, green, blue), rgb555(red / 8, green / 8, blue / 8)


// notice of configurations
.notice "Building for " + (BLACK2 == 1 ? "Black" : "White") + " 2."

.if (MEROMERO_SUMMARY_SCREEN_FIX == 1 && BLU_SUMMARY_SCREEN_FIX == 1)
.error "Both MeroMero's summary screen fix and Blu's summary screen fix are enabled.  Aborting."
.endif

.notice "Building with " + (BLU_SUMMARY_SCREEN_FIX == 1 ? "Blu's" : (MEROMERO_SUMMARY_SCREEN_FIX == 1 ? "MeroMero's" : "no")) + " summary screen fix and " + (BLU_PC_SCREEN_FIX == 1 ? "Blu's" : "no") + " PC screen fix."
.notice "If these are not the desired settings, edit the \"configs\" at the beginning of the fairy.s file.  Building..."

// code


// relative offsets are the same so loading address should not matter
//.if BLACK2 == 1
//.open "filesys/overlay/overlay_0255.bin", "overlay_0255.bin", 0x021BB700
//.else
.open "filesys/overlay/overlay_0255.bin", "overlay_0255.bin", 0x021BB740
//.endif

// gotta get 0xA268 (where gfx info for fairy type is loaded) to be the old end of the structure, 0xA5BC.  expand structure to be 0xA700

.org 0x021C2A50 // increase allocation

.if BLU_PC_SCREEN_FIX == 1
.word 0xA700
.else
.word 0xA5BC
.endif


.org 0x021D0846 // load in fairy gfx
.if BLU_PC_SCREEN_FIX == 1
cmp r4, NUM_OF_TYPES
.else
cmp r4, NUM_OF_TYPES-1
.endif

.org 0x021D09AC // move type gfx tracker whatever to end of old structure
.if BLU_PC_SCREEN_FIX == 1
.word 0xA5BC
.else
.word 0xA268
.endif


// put a read breakpoint at 0x02271558 (0x022672F0+0xA268).  need to find where the old one is
// 021cf578 - A0DC from 226747C ends up being 2271558.  need to make this A430 under the right circumstances (if A0DC would have been A268-A2AC)


// starting index below
.org 0x021D0A00
.if BLU_PC_SCREEN_FIX == 1
add r1, #START_OF_NEW_TAGS
.else
add r1, #0x20
.endif

.org 0x021D0A0A
.if BLU_PC_SCREEN_FIX == 1
cmp r4, NUM_OF_TYPES
.else
cmp r4, NUM_OF_TYPES-1
.endif


.if BLU_PC_SCREEN_FIX == 1
.org 0x021CF574
bl (patch_load_fairy_from_elsewhere + (BLACK2 == 1 ? 0x40 : 0))
.else
ldr r1, [pc, #0x2c]  ; +0 = 0b 49
ldr r0, [pc, #0x30]  ; +2 = 0c 48
.endif


// starting index below
.org 0x021BF2F0
.if BLU_PC_SCREEN_FIX == 1
mov r4, #START_OF_NEW_TAGS
.else
mov r4, #0x20
.endif

.org 0x021BF300 // deletes when moving to a blank spot with the rest of the sprites
.if BLU_PC_SCREEN_FIX == 1
cmp r4, #(START_OF_NEW_TAGS + NUM_OF_TYPES)
.else
cmp r4, #(0x20 + NUM_OF_TYPES-1)
.endif


.org 0x021D0A6E // starting index below
.if BLU_PC_SCREEN_FIX == 1
mov r4, #START_OF_NEW_TAGS
.else
mov r4, #0x20
.endif


.org 0x021D0A7E // deletes when swapping to a new mon
.if BLU_PC_SCREEN_FIX == 1
cmp r4, #(START_OF_NEW_TAGS + NUM_OF_TYPES)
.else
cmp r4, #(0x20 + NUM_OF_TYPES-1)
.endif


.org 0x021D0A22 // move the type tags
.if BLU_PC_SCREEN_FIX == 1
add r7, #START_OF_NEW_TAGS
.else
add r7, #0x20
.endif


.org 0x021D0A4A // move the type tags here too?
.if BLU_PC_SCREEN_FIX == 1
add r4, #START_OF_NEW_TAGS
.else
add r4, #0x20
.endif









// me when i write too much asm in the name of fixing things that are not broken:

// this is the 0x81 loop deallocator--does everything for the summary screen.  works without patch
//.org 0x021CF4D2
//.if BLU_PC_SCREEN_FIX == 1
//bl patch_load_fairy_from_elsewhere_r7
//.else
//lsl r0, r4, #2
//add r0, r5, r0
//.endif


//// new:
//.org 0x021CF51C // 0x81 loop that works?
//.if BLU_PC_SCREEN_FIX == 1
//.word 0xA5DC
//.else
//.word 0xA0DC
//.endif



//.org 0x021CF7DC
//.if BLU_PC_SCREEN_FIX == 1
//bl patch_load_fairy_from_elsewhere_r1
//.else
//add r2, r5, r1
//ldr r1, [pc, #0xa0]  ; +0 = 28 49
//.endif

//.org 0x021CF880 // 0x60 loop that does not work
//.if BLU_PC_SCREEN_FIX == 1
//.word 0xA5DC
//.else
//.word 0xA0DC
//.endif


//.org 0x021CF5A4 // called once each thing i believe
//.if BLU_PC_SCREEN_FIX == 1
//.word 0xA5DC
//.else
//.word 0xA0DC
//.endif



.close


.if BLACK2 == 1
.open "filesys/overlay/overlay_0265.bin", "overlay_0265.bin", 0x021998C0
.else
.open "filesys/overlay/overlay_0265.bin", "overlay_0265.bin", 0x02199900
.endif

.org BLACK2 == 1 ? 0x02199F74 : 0x02199FB4

.word type_to_loaded_gfx_hof // adjust this to go behind where it already is.


.org BLACK2 == 1 ? 0x0219B8C8 : 0x0219B908

type_to_loaded_gfx_hof:
/* TYPE_NORMAL   */ .word 0x2D
/* TYPE_FIGHTING */ .word 0x26
/* TYPE_FLYING   */ .word 0x28
/* TYPE_POISON   */ .word 0x2E
/* TYPE_GROUND   */ .word 0x2B
/* TYPE_ROCK     */ .word 0x30
/* TYPE_BUG      */ .word 0x22
/* TYPE_GHOST    */ .word 0x29
/* TYPE_STEEL    */ .word 0x31
/* TYPE_FIRE     */ .word 0x27
/* TYPE_WATER    */ .word 0x32
/* TYPE_GRASS    */ .word 0x2A
/* TYPE_ELECTRIC */ .word 0x25
/* TYPE_PSYCHIC  */ .word 0x2F
/* TYPE_ICE      */ .word 0x2C
/* TYPE_DRAGON   */ .word 0x24
/* TYPE_DARK     */ .word 0x23
/* TYPE_FAIRY    */ .word 0x2D // fairy loads the normal spa

// unsure yet
.orga 0x21DC
.word 4

.orga 0x221C // fairy pal 9 is the new pal, but actually loading anything causes a hardware crash for some reason.  it literally loads and frees immediately too, so not sure what is going on.
.word 0







// 915A of structure is u16 type.  used to index the above table.  r5 is structure pointer.  the load does not seem to take anything unusual








.close

// BLACK2 should not need a separate config here because relative offsets are the same.
.open "filesys/overlay/overlay_0207.bin", "overlay_0207.bin", 0x021B2FC0

.if BLU_SUMMARY_SCREEN_FIX == 1

// rewrite 0x130 to be 0x264, the end of the old structure, reserving quite a bit of new space for the new substructure as well.  also double heap memory allocated, just in case.

.org 0x021B5110 // double heap for summary screen
    lsl r2, #0x11

.org 0x021B511A // structure clearing
    mov r1, #0xB0

.org 0x021B5126 // structure allocation
    mov r2, #0xB0

.org 0x021B3A5A // make loop run one more time for fairy type
    cmp r4, #NUM_OF_TYPES



.org 0x021B3A32 // used to subtract 1A0 to 130, now we want to get 1A0 to 264
    add r0, #(0x264 - 0x1A0) // will restore and get everything properly

.org 0x021B6BF0 // 0x130 -> 0x264
    add r1, r6, r0
    mov r0, #(0x264 >> 2)
    lsl r0, #2
    ldr r0, [r1, r0]

.org 0x021B6C5C // var_7C is not even used the rest of the function, we do not have to rewrite to it or grab from it
    mov r0, #(0x264 >> 2)
    lsl r0, #2
    add r5, sp, #0x24
    nop // one extra instruction pog
    //ldr r0, [sp, #0x1C]
    //add r5, sp, #0x24
    //add r0, #0xD0
    //str r0, [sp, #0x1C]




.org 0x021B8EE0 // second type from the other one
    mov r0, #(0x264 >> 2)
    lsl r0, #2
    //mov r0, #0xAF
    //add r0, #0x81



.else

.org 0x021B5110
    lsl r2, #0x10

.org 0x021B511A
    mov r1, #0x99

.org 0x021B5126
    mov r2, #0x99

.org 0x021B3A5A
    cmp r4, #NUM_OF_TYPES-1



.org 0x021B3A32
    sub r0, #0x70

.org 0x021B6BF0
    add r1, r6, r0
    mov r0, #(0x130 >> 4)
    lsl r0, #4
    ldr r0, [r1, r0]

.org 0x021B6C5C
    ldr r0, [sp, #0x1C]
    add r5, sp, #0x24
    add r0, #0xD0
    str r0, [sp, #0x1C]




.org 0x021B8EE0
    mov r0, #0xAF
    add r0, #0x81

.endif

.if MEROMERO_SUMMARY_SCREEN_FIX == 1

.org 0x021B6BE0
    ldr r1, =patch_1 | 1
    bx r1

.pool

.org 0x021B6BF0
    ldr r1, =patch_2 | 1
    bx r1

.pool

.org 0x021B8E68
    ldr r1, =patch_3 | 1
    bx r1

.pool

.org 0x021B8E78
    ldr r1, =patch_4 | 1
    bx r1

.pool

.org 0x021BA848
    ldr r1, =patch_5 | 1
    bx r1

.pool

.else // MEROMERO_SUMMARY_SCREEN_FIX != 1

.org 0x021B6BE0 // patch 1
    ldr  r0, [sp, #0x18]  ; +0 = 06 98
    mov  r1, #0xaf        ; +2 = af 21
    mov  r2, #0           ; +4 = 00 22
    mov  r4, #0xaf        ; +6 = af 24

.if BLU_SUMMARY_SCREEN_FIX != 1 // type 2 normal summary screen
.org 0x021B6BF0 // patch 2
    add  r1, r6, r0    ; +0 = 31 18
    mov  r0, #0xaf     ; +2 = af 20
    add  r0, #0x81     ; +4 = 81 30
    ldr  r0, [r1, r0]  ; +6 = 08 58
.endif

.org 0x021B8E68 // patch 3
    add  r5, r0, #0  ; +0 = 05 1c
    add  r0, r4, #0  ; +2 = 20 1c
    mov  r1, #0xaf   ; +4 = af 21
    mov  r2, #0      ; +6 = 00 22

.org 0x021B8E78 // patch 4
    lsl  r0, r5, #2  ; +0 = a8 00
    add  r1, r6, r0  ; +2 = 31 18
.if BLU_SUMMARY_SCREEN_FIX != 1
    mov  r0, #0xaf   ; +4 = af 20
    add  r0, #0x81   ; +6 = 81 30
.else
    mov r0, #(0x264 >> 2)
    lsl r0, #2
.endif

.org 0x021BA848 // this one fixes moves
    lsl  r0, r6, #2  ; +0 = b0 00
    add  r1, r5, r0  ; +2 = 29 18
.if BLU_SUMMARY_SCREEN_FIX != 1
    mov  r0, #0x13   ; +4 = 13 20
    lsl  r0, r0, #4  ; +6 = 00 01
.else
    mov r0, #(0x264 >> 2)
    lsl r0, #2
.endif

.endif

.close


// BLACK2 should not need a separate config here because relative offsets are the same.
.open "filesys/overlay/overlay_0168.bin", "overlay_0168.bin", 0x021DDAA0

.org 0x021F38E8

.word 572 // new nclr file in a011, colors written below.  only written to if extracted accordingly

.close











.create "overlay_0167.bin", (0x02199780 - ((BLACK2 == 1) ? 0x40 : 0)) // adjusted load location for type chart, originally use 02199900

.area 0x180, 0xFF


// 4 is normal effectiveness, 2 is not very effective, 8 is super effective, 0 has no effect
// go down to the attacker type then over to the defender type

type_effectiveness_table: // u8 [NUM_OF_TYPES][NUM_OF_TYPES] // [attack][defend] grabs effectiveness

//             atk \ def  NORMAL,  FIGHT, FLYING, POISON, GROUND,   ROCK,    BUG,  GHOST,  STEEL,   FIRE,  WATER,  GRASS,ELECTRC,PSYCHIC,    ICE, DRAGON,   DARK,  FAIRY
.byte /* TYPE_NORMAL   */      4,      4,      4,      4,      4,      2,      4,      0,      2,      4,      4,      4,      4,      4,      4,      4,      4,      4
.byte /* TYPE_FIGHTING */      8,      4,      2,      2,      4,      8,      2,      0,      8,      4,      4,      4,      4,      2,      8,      4,      8,      2
.byte /* TYPE_FLYING   */      4,      8,      4,      4,      4,      2,      8,      4,      2,      4,      4,      8,      2,      4,      4,      4,      4,      4
.byte /* TYPE_POISON   */      4,      4,      4,      2,      2,      2,      4,      2,      0,      4,      4,      8,      4,      4,      4,      4,      4,      8
.byte /* TYPE_GROUND   */      4,      4,      0,      8,      4,      8,      2,      4,      8,      8,      4,      2,      8,      4,      4,      4,      4,      4
.byte /* TYPE_ROCK     */      4,      2,      8,      4,      2,      4,      8,      4,      2,      8,      4,      4,      4,      4,      8,      4,      4,      4
.byte /* TYPE_BUG      */      4,      2,      2,      2,      4,      4,      4,      2,      2,      2,      4,      8,      4,      8,      4,      4,      8,      2
.byte /* TYPE_GHOST    */      0,      4,      4,      4,      4,      4,      4,      8,      4,      4,      4,      4,      4,      8,      4,      4,      2,      4
.byte /* TYPE_STEEL    */      4,      4,      4,      4,      4,      8,      4,      4,      2,      2,      2,      4,      2,      4,      8,      4,      4,      8
.byte /* TYPE_FIRE     */      4,      4,      4,      4,      4,      2,      8,      4,      8,      2,      2,      8,      4,      4,      8,      2,      4,      4
.byte /* TYPE_WATER    */      4,      4,      4,      4,      8,      8,      4,      4,      4,      8,      2,      2,      4,      4,      4,      2,      4,      4
.byte /* TYPE_GRASS    */      4,      4,      2,      2,      8,      8,      2,      4,      2,      2,      8,      2,      4,      4,      4,      2,      4,      4
.byte /* TYPE_ELECTRIC */      4,      4,      2,      4,      0,      4,      4,      4,      4,      4,      8,      2,      2,      4,      4,      2,      4,      4
.byte /* TYPE_PSYCHIC  */      4,      8,      4,      8,      4,      4,      4,      2,      2,      4,      4,      4,      4,      4,      4,      4,      4,      4
.byte /* TYPE_ICE      */      4,      4,      8,      4,      8,      4,      4,      4,      2,      2,      2,      8,      4,      4,      4,      8,      4,      4
.byte /* TYPE_DRAGON   */      4,      4,      4,      4,      4,      4,      4,      4,      2,      4,      4,      4,      4,      4,      4,      8,      4,      0
.byte /* TYPE_DARK     */      4,      2,      4,      4,      4,      4,      4,      8,      4,      4,      4,      4,      4,      8,      4,      4,      4,      2
.byte /* TYPE_FAIRY    */      4,      8,      4,      2,      4,      4,      4,      4,      2,      2,      4,      4,      4,      4,      4,      8,      8,      4

.endarea











.org (0x02199900 - ((BLACK2 == 1) ? 0x40 : 0))

.incbin "filesys/overlay/overlay_0167.bin" // import the old overlay at the same address, but new beginning at 0x180 of the file

// repoint
.orga 0x23A6C
.word type_effectiveness_table

.orga 0x23BA4
.word type_effectiveness_table

// code rewrites
.orga 0xC312
.byte NUM_OF_TYPES, 0x2A, 0x08, 0xDA

.orga 0x11226
.byte NUM_OF_TYPES, 0x28, 0x02, 0xDB

.orga 0x21884
.byte NUM_OF_TYPES

.orga 0x21896
.byte NUM_OF_TYPES

.orga 0x218A2
.byte NUM_OF_TYPES, 0x29, 0x06, 0xDB
.byte NUM_OF_TYPES, 0x28, 0x01, 0xDB

.orga 0x218B4
.byte NUM_OF_TYPES, 0x28, 0x00, 0xDB

.orga 0x218DA
.byte NUM_OF_TYPES, 0x2C, 0x0E, 0xDA

.orga 0x23A20
.byte NUM_OF_TYPES, 0x28, 0x01, 0xDA
.byte NUM_OF_TYPES, 0x29, 0x01, 0xDB

.orga 0x23A2C
.byte NUM_OF_TYPES, 0x22, 0x42, 0x43

.orga 0x23B98
.byte NUM_OF_TYPES

.orga 0x260E2
.byte NUM_OF_TYPES, 0x2E, 0x1E, 0xDA

.orga 0x306F0
.byte NUM_OF_TYPES, 0x2C, 0x3C, 0xDA

.orga 0x306F6
.byte NUM_OF_TYPES

.close












.open "filesys/arm9.bin", "arm9.bin", 0x02004000

// type pal table selection - make pal grab from pal 2 and not 0
.orga ((BLACK2 == 1) ? 0x8E09D : 0x8E0C9)
.byte 2

.if MEROMERO_SUMMARY_SCREEN_FIX == 1

/*
 *
 * brief:  if incoming type is fairy, set it to 0 to prevent it from displaying fucked up.
 * somewhere, type is added to 0x22 to get the right index in the narc
 *
 * patch_1 and patch_2 are type1 and type2 of the function at 021B6B14
 * patch_3 and patch_4 are type1 and type2 of the function at 021B8D90
 * patch_5 also grabs pal from the one function?
 *
 * all of these have the type multiplied by 4 (shifted left 2).  what does it load then?  find out:
 * patch_5 is specifically for moves.
 * patch_1 and patch_2 appear to be for the type as displayed in the main page
 * patch_3 and patch_4 fix the types when they move to the bottom screen
 *
 */

.org 0x02093BF0

ret_1 equ BLACK2 == 1 ? 0x021B6BA9 : 0x021B6BE9
ret_2 equ BLACK2 == 1 ? 0x021B6BB9 : 0x021B6BF9
ret_5 equ BLACK2 == 1 ? 0x021BA811 : 0x021BA851
ret_3 equ BLACK2 == 1 ? 0x021B8E31 : 0x021B8E71
ret_4 equ BLACK2 == 1 ? 0x021B8E43 : 0x021B8E83

patch_1:
    cmp  r5, #TYPE_FAIRY  ; +0 = 11 2d
    blt  @@default        ; +2 = 00 db
    mov  r5, #0           ; +4 = 00 25
@@default:
    ldr  r0, [sp, #0x18]  ; +6 = 06 98
    mov  r1, #0xaf        ; +8 = af 21
    mov  r2, #0           ; +10 = 00 22
    mov  r4, #0xaf        ; +12 = af 24
    ldr  r7, =ret_1       ; +14 = 13 4f
    bx   r7               ; +16 = 38 47


patch_2:
    cmp  r7, #TYPE_FAIRY  ; +0 = 11 2f
    blt  @@default        ; +2 = 00 db
    mov  r7, #0           ; +4 = 00 27
@@default:
    add  r1, r6, r0       ; +6 = 31 18
    mov  r0, #0xaf        ; +8 = af 20
    add  r0, #0x81        ; +10 = 81 30
    ldr  r0, [r1, r0]     ; +12 = 08 58
    ldr  r1, =ret_2       ; +14 = 0f 49
    bx   r1               ; +16 = 08 47


patch_5:
    cmp  r6, #TYPE_FAIRY  ; +0 = 11 2e
    blt  @@default        ; +2 = 00 db
    mov  r6, #0           ; +4 = 00 26
@@default:
    lsl  r0, r6, #2       ; +6 = b0 00
    add  r1, r5, r0       ; +8 = 29 18
    mov  r0, #0x13        ; +10 = 13 20
    lsl  r0, r0, #4       ; +12 = 00 01
    ldr  r5, =ret_5       ; +14 = 0c 4d
    bx   r5               ; +16 = 28 47


patch_3:
    add  r5, r0, #0       ; +0 = 05 1c
    cmp  r5, #TYPE_FAIRY  ; +2 = 11 2d
    blt  @@default        ; +4 = 00 db
    mov  r5, #0           ; +6 = 00 25
@@default:
    add  r0, r4, #0       ; +8 = 20 1c
    mov  r1, #0xaf        ; +10 = af 21
    mov  r2, #0           ; +12 = 00 22
    ldr  r4, =ret_3       ; +14 = 08 4c
    bx   r4               ; +16 = 20 47


patch_4:
    cmp  r7, #TYPE_FAIRY  ; +0 = 11 2f
    blt  @@default        ; +2 = 00 db
    mov  r7, #0           ; +4 = 00 27
@@default:
    lsl  r0, r5, #2       ; +6 = a8 00
    add  r1, r6, r0       ; +8 = 31 18
    mov  r0, #0xaf        ; +10 = af 20
    add  r0, #0x81        ; +12 = 81 30
    ldr  r0, [r1, r0]     ; +14 = 08 58
    ldr  r1, =ret_4       ; +16 = 04 49
    bx   r1               ; +18 = 08 47

.pool

.elseif BLU_PC_SCREEN_FIX == 1

.org 0x02093BF0

/*
 *
 * brief:
 *
 * basically sub_21CF55C handles a bunch of gfx and there is like a substructure within the bigger structure that starts at like 0x18C of the bigger structure.
 * in there, there is an 0xA0DC--and this A0DC is the offset that loads what we want, corresponds to A268 under the right circumstances (when loading the types).
 * so i can create a little somewhat hacky workaround that does not involve expanding the inner structure but detects if it is loading within A268-A2AC of the overall structure,
 * and redirect it to load from A5BC instead.
 *
 * r4 is overall structure.
 *
 * needs to return offset in r1 and 9E94 in r0
 *
 */

patch_load_fairy_from_elsewhere:
push {r2-r3, lr}
ldr r1, =0xA0DC
add r2, r1
sub r2, r4
ldr r3, =(0xA268/*-0x18C*/)
cmp r2, r3
blt @@keep_r1_A0DC
ldr r3, =(0xA2AC/*-0x18C*/)
cmp r2, r3
bhi @@keep_r1_A0DC

ldr r1, =(0xA5BC-0x18C)//0xA430

@@keep_r1_A0DC:
ldr r0, =0x9E94
pop {r2-r3, pc}


//// r1, r2 free
//patch_load_fairy_from_elsewhere_r7:
//ldr r7, =0xA0DC
//lsl r0, r4, #2
//add r0, r7, r0
//ldr r1, =(0xA268-0x18C)
//cmp r0, r1
//blt @@keep_r7_A0DC
//ldr r1, =(0xA2AC-0x18C)
//cmp r0, r1
//bhi @@keep_r7_A0DC
//
//ldr r7, =(0xA5BC-0x18C)//0xA430
//
//@@keep_r7_A0DC:
//lsl r0, r4, #2
//add r0, r5, r0
//bx lr
//
//
//// r2, r3 free
//patch_load_fairy_from_elsewhere_r1:
//ldr r2, =0xA0DC
//add r1, r2
//ldr r2, =(0xA268-0x18C)
//cmp r1, r2
//blt @@keep_r1_A0DC
//ldr r2, =(0xA2AC-0x18C)
//cmp r1, r2
//bhi @@keep_r1_A0DC
//
//ldr r1, =(0xA5BC-0x18C)//0xA430
//b @@return
//
//@@keep_r1_A0DC:
//ldr r1, =0xA0DC
//@@return:
//bx lr

.pool

.endif

.close



// repoint overlay 167 to load properly from new location

.open "filesys/y9.bin", 0

.org (167 * 0x20 + 4)

.word (0x02199780 - ((BLACK2 == 1) ? 0x40 : 0))
.word filesize("overlay_0167.bin")

.close


.notice "All done!"





// random notes and ramblings section.  a little crazy



/*
 * patch_* notes as taken from the rom with the working patch:
 *
 *           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
 * patch_1:
 * 02093BF0  11 2D 00 DB 00 25 06 98 AF 21 00 22 AF 24 13 4F
 * 02093C00  38 47
 *
 * patch_2:
 *                 11 2F 00 DB 00 27 31 18 AF 20 81 30 08 58
 * 02093C10  0F 49 08 47
 *
 * patch_5:
 *                       11 2E 00 DB 00 26 B0 00 29 18 13 20
 * 02093C20  00 01 0C 4D 28 47
 *
 * patch_3:
 *                             05 1C 11 2D 00 DB 00 25 20 1C
 * 02093C30  AF 21 00 22 08 4C 20 47
 *
 * patch_4:
 *                                   11 2F 00 DB 00 27 A8 00
 * 02093C40  31 18 AF 20 81 30 08 58 04 49 08 47
 *
 * .pool:
 *                                               E9 6B 1B 02
 * 02093C50  F9 6B 1B 02 51 A8 1B 02 71 8E 1B 02 83 8E 1B 02
 */








/*
 *
 * the fairy type persists in pc screen for some reason!
 * 021BF0AE - grabs type 1 and type 2 from current mon in pc.  stores at r4+C and r4+D respectively
 * 021D0A8A of sub_21D0A68 - reads type 1 and type 2 as r1 and r2 for sub_21D0A1C -
 *
 *
 *
 * new idea:  reroute all of A0DC
 *
 * 021CF4CC is called when exiting
 * 021CF7DE is called when coming in
 * i think i just need hooks on both of these.
 *
 */















/*
 *
 * serperior - grass dragon - loads 0x10 and 0x14
 * infernape - fire fight - 0xE 0x6
 * metagross - steel psychic - 0xD 0x12
 * braviary - normal flying - 0x5 0x7
 * gyarados - water flying - 0xF 0x7
 * type+5 is fed in.  does not work necessarily tho
 *
 */


/*
 * 022572E0 + type*4 + 0x130 = type+5 to load
 * CpuFill8 - writes 0s to the place?
 * 021B3A52 actually fills it out--needs more space?  nah, we hacking this shit.  fuck memory shenanigans
 *
 * can we hotswap nitrofs references real time?  something like that?
 *
 * (ptr at (ptr at 214197C)+0x10C) + 0x40*(type+5)
 */
