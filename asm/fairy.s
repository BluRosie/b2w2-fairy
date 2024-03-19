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
 *  overlay 296
 *  overlay 298
 *  arm9
 *  y9.bin (or whatever the overlay table is called)
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
START_OF_BOX_TAGS equ 0x32

//.expfunc rgb555(red, green, blue), (red & 0x1F) | ((green & 0x1F) << 5) | ((blue & 0x1F) << 10)
//.expfunc rgb(red, green, blue), rgb555(red / 8, green / 8, blue / 8)


// notice of configurations
.notice "Building for " + (BLACK2 == 1 ? "Black" : "White") + " 2."

.if (MEROMERO_SUMMARY_SCREEN_FIX == 1 && BLU_SUMMARY_SCREEN_FIX == 1)
.error "Both MeroMero's summary screen fix and Blu's summary screen fix are enabled.  Aborting."
.endif

.notice "Building with " + (BLU_SUMMARY_SCREEN_FIX == 1 ? "Blu's" : (MEROMERO_SUMMARY_SCREEN_FIX == 1 ? "MeroMero's" : "no")) + " summary screen fix and Sunkern's PC and Dex screen fixes."
.notice "If these are not the desired settings, edit the \"configs\" at the beginning of the fairy.s file.  Building..."

// code


.if BLACK2 == 1
.open "filesys/overlay/overlay_0255.bin", "overlay_0255.bin", 0x021BB700
.else
.open "filesys/overlay/overlay_0255.bin", "overlay_0255.bin", 0x021BB740
.endif



StorageSystemStruct_SizeIncrease equ (NUM_OF_TYPES * 4) * 2

StorageSystemStruct_OldSize equ 0xA5BC

StorageSystemStruct_Size equ (StorageSystemStruct_OldSize + StorageSystemStruct_SizeIncrease)

StorageSystem_Component_UpdatePosition equ (BLACK2 == 1 ? 0x021CF6C8 : 0x021CF708)

StorageSystem_SetComponentActivity equ (BLACK2 == 1 ? 0x021CF63C : 0x021CF67C)

StorageSystem_CreateTypeComponents equ (BLACK2 == 1 ? 0x021D0978 : 0x021D09B8)

mem_copy equ (BLACK2 == 1 ? 0x02078920 : 0x0207894C)

StorageSystem_CreateComponent equ (BLACK2 == 1 ? 0x021CF51C : 0x021CF55C)

GetFileNumForType equ (BLACK2 == 1 ? 0x0202D7F4 : 0x0202D820)

NCGRManager_ReadNCGR equ (BLACK2 == 1 ? 0x0204B81C : 0x0204B848)

G2DManager_CreateSprite equ (BLACK2 == 1 ? 0x0204C040 : 0x0204C06C)

GetPaletteNumForType equ (BLACK2 == 1 ? 0x0202D7E8 : 0x0202D814)

SetSpriteActivity equ (BLACK2 == 1 ? 0x0204C124 : 0x0204C150)

StoreSpritePaletteIndex equ (BLACK2 == 1 ? 0x0204C378 : 0x0204C3A4)

StorageSystem_OnPokemonSelect_DisableTypes equ (BLACK2 == 1 ? 0x021D0A28 : 0x021D0A68)

StorageSystem_EnableTypes equ (BLACK2 == 1 ? 0x021D09DC : 0x021D0A1C)

StorageSystem_OnDeselect_DisableTypes equ (BLACK2 == 1 ? 0x021BF2B0 : 0x021BF2F0)



//StorageSystem_Initialize

.org BLACK2 == 1 ? 0x021C2A10 : 0x021C2A50
.word StorageSystemStruct_Size                            //Memory Allocation


//ReadTypeNCGRFiles


.org BLACK2 == 1 ? 0x021D0806 : 0x021D0846
    cmp r4, #NUM_OF_TYPES


.org BLACK2 == 1 ? 0x021D096C : 0x021D09AC
.word StorageSystemStruct_Size - StorageSystemStruct_SizeIncrease        	//Offset to where the type icon component NCGR file reference indices are stored.



//StorageSystem_CreateTypeComponents

.org StorageSystem_CreateTypeComponents
.area (BLACK2 == 1 ? 0x021D09DC : 0x021D0A1C) - ., 0
    push {r3-r7,lr}
    sub sp, #0x18
    mov r5, r0
    ldr r0, =(BLACK2 == 1 ? 0x021D755C : 0x021D759C)
    add r1, sp, #0
    mov r2, #25
    blx mem_copy
    add r7, sp, #0
    mov r4, #0
CreateTypeIconComponentsLoop:
    mov r0, r4
    add r0, #156
    add r0, #156
    str r0, [sp, #8]
    lsl r0, r4, #2
    add r6, r5, r0
    mov r0, r5
    mov r1, r7
    bl StorageSystem_CreateComponent
    ldr r1, =StorageSystemStruct_Size - (StorageSystemStruct_SizeIncrease / 2)    //Offset to where the type icon component pointers are stored. Index of the first icon is 475.
    str r0, [r6, r1]
    mov r0, r4
    bl GetPaletteNumForType
    mov r1, r0
    ldr r0, =StorageSystemStruct_Size - (StorageSystemStruct_SizeIncrease / 2)
    ldr r0, [r6, r0]
    mov r2, 1
    bl StoreSpritePaletteIndex
    mov r1, r4
    mov r0, r5
    add r1, #255
    add r1, #220
    mov r2, #0
    bl StorageSystem_SetComponentActivity
    add r4, r4, #1
    cmp r4, #NUM_OF_TYPES
    bcc CreateTypeIconComponentsLoop
    add sp, #0x18
    pop {r3-r7,pc}

.pool
.endarea


//StorageSystem_OnPokemonSelect_DisableTypes

.org StorageSystem_OnPokemonSelect_DisableTypes
.area (BLACK2 == 1 ? 0x021D0A58 : 0x021D0A98) - ., 0
    push {r3-r7, lr}
    mov r5, r0
    mov r7, r1
    mov r4, #220
    mov r6, #255
StorageSystem_OnPokemonSelect_DisableTypes_Loop:
    mov r0, r5
    add r1, r4, r6
    mov r2, #0
    bl StorageSystem_SetComponentActivity
    add r4, #1
    cmp r4, #220 + NUM_OF_TYPES
    bcc StorageSystem_OnPokemonSelect_DisableTypes_Loop
    ldrb r0, [r7, 0x12]
    lsl r0, r0, #0x18
    lsr r0, r0, #0x1F
    bne StorageSystem_OnPokemonSelect_DisableTypes_Return
    ldrb r1, [r7, #0xC]	  //Type1
    ldrb r2, [r7, #0xD]	  //Type2
    mov r0, r5
    bl StorageSystem_EnableTypes
StorageSystem_OnPokemonSelect_DisableTypes_Return:
    pop {r3-r7, pc}

.endarea

//StorageSystem_EnableTypes

.org StorageSystem_EnableTypes
.area (BLACK2 == 1 ? 0x021D0A28 : 0x021D0A68) - ., 0
    push {r3-r7, lr}
    mov r7, #255
    add r7, #220
    mov r4, r0
    add r1, r7
    mov r5, r1
    mov r6, r2
    mov r2, #1
    bl StorageSystem_SetComponentActivity
    mov r0, #1
    str r0, [sp]
    mov r1, r5
    mov r0, r4
    mov r2, #88
    mov r3, #56
    bl StorageSystem_Component_UpdatePosition
    cmp r6, #0
    beq StorageSystem_EnableTypes_Return
    add r6, r7
    cmp r5, r6
    beq StorageSystem_EnableTypes_Return
    mov r0, r4
    mov r1, r6
    mov r2, #1
    bl StorageSystem_SetComponentActivity
    mov r0, #1
    str r0, [sp]
    mov r0, r4
    mov r1, r6
    mov r2, #122
    mov r3, #56
    bl StorageSystem_Component_UpdatePosition
StorageSystem_EnableTypes_Return:
    pop {r3-r7, pc}
.endarea

//StorageSystem_OnDeselect_DisableTypes

.org StorageSystem_OnDeselect_DisableTypes
    mov r4, #220
    mov r6, #255
StorageSystem_OnDeselect_DisableTypes_Loop:
    ldr r0, [r5, #0x2C]
    add r1, r4, r6
    mov r2, #0
    bl StorageSystem_SetComponentActivity
    add r4, #1
    cmp r4, #220 + NUM_OF_TYPES
    bcc StorageSystem_OnDeselect_DisableTypes_Loop

.org BLACK2 == 1 ? 0x021BF2D4 : 0x021BF314
    mov r2, #0                	//Before 0 was stored in r6 and then moved into r2, but to optimize for code size we're just moving 0 directly into r2

.org BLACK2 == 1 ? 0x021BF2DE : 0x021BF31E
    mov r2, #0

.org BLACK2 == 1 ? 0x021BF2E8 : 0x021BF328
    mov r2, #0

.close


.if BLACK2 == 1
.open "filesys/overlay/overlay_0265.bin", "overlay_0265.bin", 0x021998C0
.else
.open "filesys/overlay/overlay_0265.bin", "overlay_0265.bin", 0x02199900
.endif

// edits to load a halfword from type_to_nameplate_palette (thanks sunkernenjoyer!)

.org BLACK2 == 1 ? 0x0219AF28 : 0x0219AF68
lsl r2, r1, #1

.org BLACK2 == 1 ? 0x0219AF2C : 0x0219AF6C
ldrh r1, [r1, r2]


.org BLACK2 == 1 ? 0x02199F74 : 0x02199FB4

.word type_to_loaded_gfx_hof // adjust this to go behind where it already is.


.org BLACK2 == 1 ? 0x0219B8C8 : 0x0219B908

type_to_loaded_gfx_hof:
/* TYPE_NORMAL   */ .halfword 0x2D
/* TYPE_FIGHTING */ .halfword 0x26
/* TYPE_FLYING   */ .halfword 0x28
/* TYPE_POISON   */ .halfword 0x2E
/* TYPE_GROUND   */ .halfword 0x2B
/* TYPE_ROCK     */ .halfword 0x30
/* TYPE_BUG      */ .halfword 0x22
/* TYPE_GHOST    */ .halfword 0x29
/* TYPE_STEEL    */ .halfword 0x31
/* TYPE_FIRE     */ .halfword 0x27
/* TYPE_WATER    */ .halfword 0x32
/* TYPE_GRASS    */ .halfword 0x2A
/* TYPE_ELECTRIC */ .halfword 0x25
/* TYPE_PSYCHIC  */ .halfword 0x2F
/* TYPE_ICE      */ .halfword 0x2C
/* TYPE_DRAGON   */ .halfword 0x24
/* TYPE_DARK     */ .halfword 0x23
/* TYPE_FAIRY    */ .halfword 0x2D // fairy loads the normal spa


.org BLACK2 == 1 ? 0x0219BA98 : 0x0219BAD8

type_to_nameplate_palette:
.halfword 3
.halfword 4
.halfword 11
.halfword 16
.halfword 14
.halfword 18
.halfword 5
.halfword 12
.halfword 19
.halfword 10
.halfword 20
.halfword 13
.halfword 8
.halfword 17
.halfword 15
.halfword 7
.halfword 6
.halfword 9







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
.byte /* TYPE_ELECTRIC */      4,      4,      8,      4,      0,      4,      4,      4,      4,      4,      8,      2,      2,      4,      4,      2,      4,      4
.byte /* TYPE_PSYCHIC  */      4,      8,      4,      8,      4,      4,      4,      4,      2,      4,      4,      4,      4,      2,      4,      4,      0,      4
.byte /* TYPE_ICE      */      4,      4,      8,      4,      8,      4,      4,      4,      2,      2,      2,      8,      4,      4,      2,      8,      4,      4
.byte /* TYPE_DRAGON   */      4,      4,      4,      4,      4,      4,      4,      4,      2,      4,      4,      4,      4,      4,      4,      8,      4,      0
.byte /* TYPE_DARK     */      4,      2,      4,      4,      4,      4,      4,      8,      4,      4,      4,      4,      4,      8,      4,      4,      2,      2
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

.endif

.close

.if BLACK2 == 1
.open "filesys/overlay/overlay_0296.bin", "overlay_0296.bin", 0x0219D6E0
.else
.open "filesys/overlay/overlay_0296.bin", "overlay_0296.bin", 0x0219D720
.endif


//TypeBitmapInfo, when viewing pokemon from other languages, the types position in the bitmap is defined in this table, with the structure of vertical row and horizontal row. This edit will make it display the ??? type icon instead of normal, where ??? will be replaced by the fairy graphics in a157

.org BLACK2 == 1 ? 0x0219FAEA : 0x0219FB2A
.byte 4
.byte 1


PokedexStruct_SizeIncrease equ (18 * 4) * 2


//InfoScreen_Initialize

.org BLACK2 == 1 ? 0x0219D770 : 0x0219D7B0
    mov r5, #173 + (PokedexStruct_SizeIncrease/4)            //Memory Allocation

.org BLACK2 == 1 ? 0x0219D776 : 0x0219D7B6
    lsl r5, #2

//InfoScreen_CreateTypeIcons


.org BLACK2 == 1 ? 0x0219ECBC : 0x0219ECFC
.area (BLACK2 == 1 ? 0x0219ED78 : 0x0219EDB8) - ., 0
    mov r0, #92
    lsl r0, #2
    mov r1, #num_of_types
    strb r1, [r5, r0]
    add r0, #1
    strb r1, [r5, r0]
    mov r0, #173
    lsl r0, #2
    str r0, [sp, #20]
    add r0, #72
    str r0, [sp, #24]
CreateTypeIconsForPokedexLoop:
    lsl r0, r6, #2
    add r4, r5, r0
    mov r0, r6
    bl GetFileNumForType
    mov r1, r0
    ldrh r0, [r5]
    str r0, [sp]
    mov r2, #0
    ldr r3, [sp, #12]
    ldr r0, [sp, #16]
    bl NCGRManager_ReadNCGR
    ldr r1, [sp, #20]
    str r0, [r4, r1]
    add r0, sp, #40
    str r0, [sp]
    str r7, [sp, #4]
    ldrh r0, [r5]
    str r0, [sp, #8]
    ldr r1, [sp, #20]
    mov r2, #200
    mov r3, #204
    ldr r1, [r4, r1]
    ldr r2, [r5, r2]
    ldr r3, [r5, r3]
    ldr r0, [r5, #36]
    bl G2DManager_CreateSprite
    ldr r1, [sp, #24]
    str r0, [r4, r1]
    mov r0, r6
    bl GetPaletteNumForType
    mov r1, r0
    ldr r0, [sp, #24]
    ldr r0, [r4, r0]
    mov r2, #1
    bl StoreSpritePaletteIndex
    ldr r1, [sp, #24]
    ldr r0, [r4, r1]
    mov r1, #2
    bl (BLACK2 == 1 ? 0x0204C438 : 0x0204C464)
    ldr r1, [sp, #24]
    ldr r0, [r4, r1]
    mov r1, #1
    bl (BLACK2 == 1 ? 0x0204C318 : 0x0204C344)
    ldr r1, [sp, #24]
    ldr r0, [r4, r1]
    mov r1, #0
    bl SetSpriteActivity
    add r6, #1
    cmp r6, #num_of_types
    bcc CreateTypeIconsForPokedexLoop
    add sp, #0x30
    pop {r3-r7, pc}


PokedexStruct_GetTypeIconSpritePointer:
    mov r1, #191
    lsl r1, #2
    ldr r0, [r0, r1]
    bx lr

.endarea

//OnSwitch_UpdateTypeIcons

.org BLACK2 == 1 ? 0x0219EE10 : 0x0219EE50
mov r2, #num_of_types


//OnLangageButtonPress_CreateTypeIconsFromBitmap

.org BLACK2 == 1 ? 0x0219F12E : 0x0219F16E
cmp r0, #num_of_types


//OnSwitch_DisableLanguageTypeIcons


.org BLACK2 == 1 ? 0x0219F6D6 : 0x0219F716
cmp r0, #num_of_types


.org BLACK2 == 1 ? 0x0219F6EC : 0x0219F72C
cmp r1, #num_of_types


.org BLACK2 == 1 ? 0x0219F6DE : 0x0219F71E
bl PokedexStruct_GetTypeIconSpritePointer

.org BLACK2 == 1 ? 0x0219F6F2 : 0x0219F732
add r0, r5, r1
bl PokedexStruct_GetTypeIconSpritePointer


//OnSwitch_ChangeTypeIcons

.org BLACK2 == 1 ? 0x0219EE7A : 0x0219EEBA
cmp r0, #num_of_types

.org BLACK2 == 1 ? 0x0219EE98 : 0x0219EED8
mov r1, #num_of_types

.org BLACK2 == 1 ? 0x0219EED4 : 0x0219EF14
cmp r0, #num_of_types

.org BLACK2 == 1 ? 0x0219EEF2 : 0x0219EF32
mov r1, #num_of_types

.org BLACK2 == 1 ? 0x0219EF24 : 0x0219EF64
cmp r4, #num_of_types

.org BLACK2 == 1 ? 0x0219EF5E : 0x0219EF9E
cmp r6, #num_of_types

.org BLACK2 == 1 ? 0x0219EFFC : 0x0219F03C
cmp r0, #num_of_types


.org BLACK2 == 1 ? 0x0219EE88 : 0x0219EEC8
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer
nop

.org BLACK2 == 1 ? 0x0219EEA8 : 0x0219EEE8
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer
nop


.org BLACK2 == 1 ? 0x0219EEC2 : 0x0219EF02
lsl r1, #2
add r0, r5, r1
bl PokedexStruct_GetTypeIconSpritePointer

.org BLACK2 == 1 ? 0x0219EEE2 : 0x0219EF22
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer
nop

.org BLACK2 == 1 ? 0x0219EEFE : 0x0219EF3E
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer
nop

.org BLACK2 == 1 ? 0x0219EF16 : 0x0219EF56
lsl r0, r1, #2
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer

.org BLACK2 == 1 ? 0x0219EF34 : 0x0219EF74
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer
nop

.org BLACK2 == 1 ? 0x0219EF4C : 0x0219EF8C
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer
nop
nop

.org BLACK2 == 1 ? 0x0219EF6C : 0x0219EFAC
add r0, r5
bl PokedexStruct_GetTypeIconSpritePointer
nop

.org BLACK2 == 1 ? 0x0219EF7C : 0x0219EFBC
lsl r2, r7, #16
lsr r2, r2, #16

.org BLACK2 == 1 ? 0x0219EF84 : 0x0219EFC4
bl PokedexStruct_GetTypeIconSpritePointer
add r1, sp, #40
add r1, 2


//InfoScreenExit_RemoveTypeIcons


.org BLACK2 == 1 ? 0x0219EDA6 : 0x0219EDE6
mov r4, #0
InfoScreenExit_RemoveTypeIconsLoop:
mov r7, #191
lsl r7, #2


.org BLACK2 == 1 ? 0x0219EDB6 : 0x0219EDF6
sub r7, #72
ldr r0, [r6, r7]


.org BLACK2 == 1 ? 0x0219EDC4 : 0x0219EE04
cmp r4, #num_of_types
bcc InfoScreenExit_RemoveTypeIconsLoop

.close


// should be fine to not differentiate here between B2/W2 because file offset ends up being the same
.open "filesys/overlay/overlay_0298.bin", "overlay_0298.bin", 0x0219FC00

//NCGR Manager Data


.org 0x021AC02C    	//Maximum amount of files it can read
.halfword 0x21

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



// repoint overlay 167 to load properly from new location

.open "filesys/y9.bin", "y9.bin", 0

.org (167 * 0x20 + 4)

.word (0x02199780 - ((BLACK2 == 1) ? 0x40 : 0))
.word filesize("overlay_0167.bin")

.close
