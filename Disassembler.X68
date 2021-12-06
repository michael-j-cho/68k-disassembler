*-----------------------------------------------------------
* Title      : Disassembler Project
* Written by : Calvin Lim, Derek Slater, Madeline Nguyen, Michael Cho
* Date       :
* Description:
*-----------------------------------------------------------
STARTING_ADDR   EQU     $350
ENDING_ADDR     EQU     $400
DEST_VAR        EQU     $450
DEST_MODE       EQU     $500
SOURCE_VAR      EQU     $550
SOURCE_MODE     EQU     $600
TEMP            EQU     $650
REG_NUM         EQU     $700
    
START ORG    $1000


*-----------------------------------------------------------
*///////////////////////////////////////////////////////////
*
*PROGRAM START (INPUT/OUTPUT)
*
*///////////////////////////////////////////////////////////
*-----------------------------------------------------------
                                          
INPUT_START_ADDR
        LEA     INPUT_START_MSG,A1          ;display message to input starting addr            
        MOVE    #14,D0
        TRAP    #15
        MOVE    #8,D7                       ;6 unit counter in d7
    
INPUT_START_ADDR_LOOP
        MOVE    #5,D0                       ;read single ASCII val from the keyboard into D1.B
        TRAP    #15
        JSR     CONVERT_TO_HEX              ;convert ASCII to hex
        ROL.L   #4,D2                       ;rotate D2 left 4 bits
        ADD.L   D1,D2                       ;add hex value to D2
        SUBQ    #1,D7                       ;decrement counter
        BNE     INPUT_START_ADDR_LOOP       ;repeat this loop  
        MOVE.L  D2,STARTING_ADDR            ;move D2 into STARTING_ADDR at $350
        CLR.L   D2                          ;clear D2 so it doesn't interrupt when there is a reinput of address
    
INPUT_END_ADDR
        JSR     ENDLINE                        
        CLR.L   D2                          
        LEA     INPUT_END_MSG,A1            ;display message to input ending addr
        MOVE    #14,D0                  
        TRAP    #15                         
        MOVE    #8,D7                       ;6 unit counter in d7

INPUT_END_ADDR_LOOP
        MOVE    #5,D0                       ;read single ASCII val from the keyboard into D1.B
        TRAP    #15
        JSR     CONVERT_TO_HEX              ;convert ASCII to hex
        ROL.L   #4,D2                       ;rotate D2 left 4 bits
        ADD.L   D1,D2                       ;add hex value to D2
        SUBQ    #1,D7                       ;decrement counter
        BNE     INPUT_END_ADDR_LOOP         ;repeat this loop 
        MOVE.L  D2,ENDING_ADDR              ;move D2 into ENDING_ADDR at $400    
        CLR.L   D2                          ;clear D2 so it doesn't interrupt when there is a reinput of address
        JSR     CHECK_MEM_RANGE
        
DECODE_OPCODE
        JSR     GET_NEXT_SET                ;D3 is set as counter here, only executes when D3 is #20
        JSR     PRINT_MEM_ADDR
        JSR     GET_MACHINE_WORD
        
*-----------------------------------------------------------
*///////////////////////////////////////////////////////////
*OPCODE_SUBROUTINE_START
*PRECONDITION: CURRENT_OPCODE contains the value to the current opcode to be decoded
*
*Opcodes can be roughly identified according to their highest 4 bits in hex:
*0:     Invalid - no supported opcodes
*1: MOVE.B
*2: MOVE.L, MOVEA.L
*3: MOVE.W, MOVEA.W
*4: LEA, JSR, RTS, MOVEM, NOT, NOP
*5: ADDQ
*6: BGT, BLT, BEQ, BRA
*7: MOVEQ
*8: OR
*9: SUB
*A:     Invalid - no supported opcodes
*B:     Invalid - no supported opcodes
*C: AND
*D: ADD, ADDA
*E: LSR, LSL, ASR, ASL, ROL, ROR
*F:     Invalid - no supported opcodes
*///////////////////////////////////////////////////////////
*-----------------------------------------------------------
OPCODE_SUBROUTINE_START ;move opcode to register and shift right to look at highest 4 bits
        MOVE.W  CURRENT_OPCODE,D0
        MOVE.B  #1,OPCODE_VALIDITY ;default validity to 1 (valid)
        MOVE.B  #12,D1
        LSR.L   D1,D0

    ;check for 0
        CMP.B   #$0,D0
        BEQ     CHECK_GROUP_0
    
    ;check for 1
        CMP.B   #$1,D0
        BEQ     CHECK_GROUP_1
    
    ;check for 2
        CMP.B   #$2,D0
        BEQ     CHECK_GROUP_2
    
    ;check for 3
        CMP.B   #$3,D0
        BEQ     CHECK_GROUP_3
    
    ;check for 4
        CMP.B   #$4,D0
        BEQ     CHECK_GROUP_4
    
    ;check for 5
        CMP.B   #$5,D0
        BEQ     CHECK_GROUP_5
    
    ;check for 6
        CMP.B   #$6,D0
        BEQ     CHECK_GROUP_6
    
    ;check for 7
        CMP.B   #$7,D0
        BEQ     CHECK_GROUP_7
    
    ;check for 8
        CMP.B   #$8,D0
        BEQ     CHECK_GROUP_8
    
    ;check for 9
        CMP.B   #$9,D0
        BEQ     CHECK_GROUP_9
    
    ;check for A
        CMP.B   #$A,D0
        BEQ     CHECK_GROUP_A
    
    ;check for B
        CMP.B   #$B,D0
        BEQ     CHECK_GROUP_B
    
    ;check for C
        CMP.B   #$C,D0
        BEQ     CHECK_GROUP_C
    
    ;check for D
        CMP.B   #$D,D0
        BEQ     CHECK_GROUP_D
    
    ;check for E
        CMP.B   #$E,D0
        BEQ     CHECK_GROUP_E
    
    ;check for F
        CMP.B   #$F,D0
        BEQ     CHECK_GROUP_F

*-----------------------------------------------------------
*Group 0
*Checks for these valid opcodes: None
*Nothing supported in this group
*-----------------------------------------------------------
CHECK_GROUP_0
        
        BRA     INVALID_OPCODE 
*-----------------------------------------------------------
*Group 1
*Checks for these valid opcodes: MOVE.B
*-----------------------------------------------------------
CHECK_GROUP_1

CHECK_FOR_MOVEB
        MOVE.W  CURRENT_OPCODE, D0
        ANDI.W  #$F000,D0
        CMP.W   #$1000,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_MOVEB
        JSR     PRINT_SOURCE
        JSR     PRINT_COMMA
        JSR     PRINT_DEST
        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 2
*Checks for these valid opcodes: MOVE.L, MOVEA.L
*-----------------------------------------------------------
CHECK_GROUP_2

CHECK_FOR_MOVEAL ;MOVEAL has a slight difference from MOVEL in that the addressing mode is different
        MOVE.W  CURRENT_OPCODE,D0
        MOVE.W  #7,D1
        LSL.W   D1,D0
        LSR.W   D1,D0
        MOVE.W  #6,D1
        LSR.W   D1,D0
        MOVE.W  D0,D1
        CMP.W   #$1,D0
        BNE     CHECK_FOR_MOVEL
        ;else
        JSR     PRINT_MOVEAL    ;MOVEAL
        JSR     PRINT_SOURCE
        JSR     PRINT_COMMA
        JSR     SAVE_DEST
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_MOVEL
        MOVE.W  CURRENT_OPCODE, D0
        ANDI.W  #$F000,D0
        CMP.W   #$2000,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_MOVEL ;MOVEL
        JSR     PRINT_SOURCE
        JSR     PRINT_COMMA
        JSR     PRINT_DEST
        BRA     OPCODE_SUBROUTINE_END

*-----------------------------------------------------------
*Group 3
*Checks for these valid opcodes: MOVE.W, MOVEA.W
*-----------------------------------------------------------
CHECK_GROUP_3

CHECK_FOR_MOVEAW ;MOVEAW has a slight difference from MOVEW in that the address mode is different
        MOVE.W  CURRENT_OPCODE,D0
        MOVE.W  #7,D1
        LSL.W   D1,D0
        LSR.W   D1,D0
        MOVE.W  #6,D1
        LSR.W   D1,D0
        MOVE.W  D0,D1
        CMP.W   #$1,D0
        BNE     CHECK_FOR_MOVEW
        ;else
        JSR     PRINT_MOVEAW
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_MOVEW
        MOVE.W  CURRENT_OPCODE, D0
        ANDI.W  #$F000,D0
        CMP.W   #$3000,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_MOVEW
        JSR     PRINT_SOURCE
        JSR     PRINT_COMMA
        JSR     PRINT_DEST
        BRA     OPCODE_SUBROUTINE_END

*-----------------------------------------------------------
*Group 4
*Checks for these valid opcodes: LEA, JSR, RTS, MOVEM.W, MOVEM.L, NOT, NOP
*-----------------------------------------------------------
CHECK_GROUP_4
       
       ;check for supported opcodes
CHECK_FOR_LEA
        MOVE.W  CURRENT_OPCODE, D0
        ANDI.W  #$F1C0,D0
        CMP.W   #$41C0,D0
        BNE     CHECK_FOR_JSR ;check for next opcode
        ;else
        JSR     PRINT_LEA
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_JSR
        MOVE.W  CURRENT_OPCODE, D0
        ANDI.W  #$FFC0,D0
        CMP.W   #$4E80,D0
        BNE     CHECK_FOR_RTS ;check for next opcode
        ;else
        JSR     PRINT_JSR
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_RTS ;full static, no masking
        MOVE.W  CURRENT_OPCODE, D0
        CMP.W   #$4E75,D0
        BNE     CHECK_FOR_MOVEMW ;check for next opcode
        ;else
        JSR     PRINT_RTS
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_MOVEMW
        JSR     ONE_BIT_SIZE_AT_BIT_6 ;find size to distinguish between L and W
        CMP.B   #$0,CURRENT_OPSIZE
        BNE     CHECK_FOR_MOVEML ;if size is 1, check for MOVEM.L
        ;else
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FB80,D0
        CMP.W   #$4880,D0
        BNE     CHECK_FOR_NOT
        ;else
        JSR     PRINT_MOVEMW
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_MOVEML
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FB80,D0
        CMP.W   #$4880,D0
        BNE     CHECK_FOR_NOT
        ;else
        JSR     PRINT_MOVEML
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_NOT
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FF00,D0
        CMP.W   #$4600,D0
        BNE     CHECK_FOR_NOP
        ;else
        JSR     PRINT_NOT
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_NOP
        MOVE.W  CURRENT_OPCODE,D0
        CMP.W   #$4E71,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_NOP
        BRA     OPCODE_SUBROUTINE_END
*-----------------------------------------------------------
*Group 5
*Checks for these valid opcodes: ADDQ
*-----------------------------------------------------------
CHECK_GROUP_5

CHECK_FOR_ADDQ
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F100,D0
        CMP.W   #$5000,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        JSR     PRINT_ADDQ
        BRA     OPCODE_SUBROUTINE_END
*-----------------------------------------------------------
*Group 6
*Checks for these valid opcodes: BGT, BLT, BEQ, BRA
*-----------------------------------------------------------
CHECK_GROUP_6

CHECK_FOR_BGT
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FF00,D0
        CMP.W   #$6E00,D0
        BNE     CHECK_FOR_BLT
        ;else
        JSR     PRINT_BGT
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_BLT
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FF00,D0
        CMP.W   #$6D00,D0
        BNE     CHECK_FOR_BEQ
        ;else
        JSR     PRINT_BLT
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_BEQ
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FF00,D0
        CMP.W   #$6700,D0
        BNE     CHECK_FOR_BRA
        ;else
        JSR     PRINT_BEQ
        BRA     OPCODE_SUBROUTINE_END

CHECK_FOR_BRA
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FF00,D0
        CMP.W   #$6000,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_BRA
        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 7
*Checks for these valid opcodes: MOVEQ
*-----------------------------------------------------------
CHECK_GROUP_7

CHECK_FOR_MOVEQ
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F100,D0
        CMP.W   #$7000,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_MOVEQ
        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 8
*Checks for these valid opcodes: OR
*Must first check DIVU, DIVS, and SBCD because of their similarity to OR
*-----------------------------------------------------------
CHECK_GROUP_8

CHECK_FOR_DIVU
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F1C0,D0
        CMP.W   #$80C0,D0
        BEQ     INVALID_OPCODE
        ;else check for next possible invalid opcode

CHECK_FOR_DIVS
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F1C0,D0
        CMP.W   #$81C0,D0
        BEQ     INVALID_OPCODE
        ;else check for next possible invalid opcode

CHECK_FOR_SBCD
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F1F0,D0
        CMP.W   #$8100,D0
        BEQ     INVALID_OPCODE
        ;else it's OR

CHECK_FOR_OR    ;must be OR
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        JSR     PRINT_OR
        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 9
*Checks for these valid opcodes: SUB
*Must first check for SUBX and SUBA because of their similarity to SUB
*-----------------------------------------------------------
CHECK_GROUP_9

CHECK_FOR_SUBX
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F130,D0
        CMP.W   #$9100,D0
        BEQ     INVALID_OPCODE
        ;else check for next possible invalid opcode

CHECK_FOR_SUBA
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F0C0,D0
        CMP.W   #$90C0,D0
        BEQ     INVALID_OPCODE
        ;else it's SUB 
        
CHECK_FOR_SUB    ;must be SUB
        JSR     PRINT_SUB
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group A
*Checks for these valid opcodes: None 
*-----------------------------------------------------------
CHECK_GROUP_A
        BRA     INVALID_OPCODE 
*-----------------------------------------------------------
*Group B
*Checks for these valid opcodes: None
*-----------------------------------------------------------
CHECK_GROUP_B
        BRA     INVALID_OPCODE 
*-----------------------------------------------------------
*Group C
*Checks for these valid opcodes: AND
*Must first check for EXG, ABCD, MULS, and MULU due to their similarity to AND
*(Since its bits are so dynamic)
*-----------------------------------------------------------
CHECK_GROUP_C

CHECK_FOR_EXG
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F130,D0
        CMP.W   #$C100,D0
        BEQ     INVALID_OPCODE
        ;else check for next possible invalid opcode
        
CHECK_FOR_MULU
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F1C0,D0
        CMP.W   #$C0C0,D0
        BEQ     INVALID_OPCODE
        ;else check for next possible invalid opcode
        
CHECK_FOR_MULS
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F1C0,D0
        CMP.W   #$C1C0,D0
        BEQ     INVALID_OPCODE
        ;else check for next possible invalid opcode

CHECK_FOR_ABCD
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F1F0,D0
        CMP.W   #$C100,D0
        BEQ     INVALID_OPCODE
        ;else it's AND

CHECK_FOR_AND ;it's AND at this point
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        JSR     PRINT_AND
        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group D
*Checks for these valid opcodes: ADD, ADDA
*Must first check for ADDX because of its similarity to the two
*-----------------------------------------------------------
CHECK_GROUP_D

CHECK_FOR_ADDX  
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F130,D0
        CMP.W   #$D100,D0
        BEQ     INVALID_OPCODE
        ;else check for valid opcode(s)
        
CHECK_FOR_ADDA
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F0F8,D0
        CMP.W   #$D0C8,D0
        BNE     CHECK_FOR_ADD
        ;else
        JSR     PRINT_ADDA
        BRA     OPCODE_SUBROUTINE_END

        ;there's only three opcodes in total, so has to be add at this point
CHECK_FOR_ADD
        JSR     PRINT_ADD
        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group E
*Checks for these valid opcodes: LSR, LSL, ASR, ASL, ROL, ROR 
*-----------------------------------------------------------
CHECK_GROUP_E

CHECK_FOR_LSR
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F118,D0
        CMP.W   #$E008,D0
        BNE     CHECK_FOR_LSL
        ;else
        JSR     PRINT_LSR
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_LSL
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F118,D0
        CMP.W   #$E108,D0
        BNE     CHECK_FOR_ASR
        ;else
        JSR     PRINT_LSL
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_ASR
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F118,D0
        CMP.W   #$E000,D0
        BNE     CHECK_FOR_ASL
        ;else
        JSR     PRINT_ASR
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_ASL
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F118,D0
        CMP.W   #$E100,D0
        BNE     CHECK_FOR_ROL
        ;else
        JSR     PRINT_ASL
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_ROL
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F118,D0
        CMP.W   #$E118,D0
        BNE     CHECK_FOR_ROR
        ;else
        JSR     PRINT_ROL
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_ROR
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$FF00,D0
        CMP.W   #$E018,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_ROR
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
        BRA     OPCODE_SUBROUTINE_END
*-----------------------------------------------------------
*Group F
*Checks for these valid opcodes: None 
*-----------------------------------------------------------
CHECK_GROUP_F
        BRA     INVALID_OPCODE
        
*-----------------------------------------------------------
*INVALID_OPCODE
*PRECONDITION: 
*Moves 0 to OPCODE_VALIDITY to signal that the current opcode is invalid
*-----------------------------------------------------------
INVALID_OPCODE
        MOVE.B  #0,OPCODE_VALIDITY
        MOVE.L  #P_INVALID,OPCODE_TO_PRINT
        BRA     OPCODE_SUBROUTINE_END
        
*-----------------------------------------------------------
*SIZE CHECKS
*These methods capture the size bit(s)
*The amount (1 or 2 bits) and location vary slightly between instructions,
*so a couple different methods are needed
*-----------------------------------------------------------
ONE_BIT_SIZE_AT_BIT_6
        MOVE.W  CURRENT_OPCODE,D0
        MOVE.W  #9,D1
        LSL.W   D1,D0
        LSR.W   D1,D0
        MOVE.W  #6,D1
        LSR.W   D1,D0
        MOVE.W  D0,CURRENT_OPSIZE
        RTS

ONE_BIT_SIZE_AT_BIT_8
        MOVE.W  CURRENT_OPCODE,D0
        MOVE.W  #7,D1
        LSL.W   D1,D0
        LSR.W   D1,D0
        MOVE.W  #8,D1
        LSR.W   D1,D0
        MOVE.W  D0,CURRENT_OPSIZE
        RTS

TWO_BIT_SIZE_AT_BITS_7_6
        ;most opcodes will fall under this method
        MOVE.W  CURRENT_OPCODE,D0
        MOVE.W  #8,D1
        LSL.W   D1,D0
        LSR.W   D1,D0
        MOVE.W  #6,D1
        LSR.W   D1,D0
        MOVE.W  D0,CURRENT_OPSIZE
        RTS

*-----------------------------------------------------------
*PRINTING
*These will load the appropriate variables with the constant to be printed out by I/O
*-----------------------------------------------------------

*-----------
*Size prints
*-----------
PRINT_SIZE
        MOVE.W  CURRENT_OPSIZE,D0
        CMP.B   #$00,D0
        BEQ     PRINT_BYTE
        CMP.B   #$01,D0
        BEQ     PRINT_WORD
        BRA     PRINT_LONG

PRINT_BYTE
        LEA     P_BYTE,A1
        JSR     PRINT_INLINE
        ;MOVE.W  #P_BYTE,SIZE_TO_PRINT
        RTS

PRINT_WORD
        LEA     P_WORD,A1
        JSR     PRINT_INLINE
        ;MOVE.W  #P_WORD,SIZE_TO_PRINT
        RTS

PRINT_LONG
        LEA     P_LONG,A1
        JSR     PRINT_INLINE
        ;MOVE.W  #P_LONG,SIZE_TO_PRINT
        RTS
*-----Group 0 - nothing to print-----*

*-----Group 1-----*
PRINT_MOVEB
        LEA     P_MOVE,A1
        JSR     PRINT_INLINE
        JSR     PRINT_BYTE
        ;MOVE.L  #P_MOVE,OPCODE_TO_PRINT
        ;MOVE.L  #P_Byte,SIZE_TO_PRINT
        RTS

*-----Group 2-----*
PRINT_MOVEL
        LEA     P_MOVE,A1
        JSR     PRINT_INLINE
        JSR     PRINT_LONG
        ;MOVE.L  #P_MOVE,OPCODE_TO_PRINT
        ;MOVE.L  #P_Long,SIZE_TO_PRINT
        RTS
        
PRINT_MOVEAL
        LEA     P_MOVEA,A1
        JSR     PRINT_INLINE
        JSR     PRINT_LONG
        ;MOVE.L  #P_MOVEA,OPCODE_TO_PRINT
        ;MOVE.L  #P_Long,SIZE_TO_PRINT
        RTS

*-----Group 3-----*
PRINT_MOVEW
        LEA     P_MOVE,A1
        JSR     PRINT_INLINE
        JSR     PRINT_WORD
        ;MOVE.L  #P_MOVE,OPCODE_TO_PRINT
        ;MOVE.L  #P_Word,SIZE_TO_PRINT
        RTS
        
PRINT_MOVEAW
        LEA     P_MOVEA,A1
        JSR     PRINT_INLINE
        JSR     PRINT_WORD
        ;MOVE.L  #P_MOVEA,OPCODE_TO_PRINT
        ;MOVE.L  #P_Word,SIZE_TO_PRINT
        RTS

*-----Group 4-----*
PRINT_LEA
        MOVE.L  #P_LEA,OPCODE_TO_PRINT
        RTS
        
PRINT_JSR
        MOVE.L  #P_JSR,OPCODE_TO_PRINT
        RTS

PRINT_RTS
        MOVE.L  #P_RTS,OPCODE_TO_PRINT
        RTS

PRINT_MOVEMW
        MOVE.L  #P_MOVEM,OPCODE_TO_PRINT
        MOVE.L  #P_Word,SIZE_TO_PRINT
        RTS
        
PRINT_MOVEML
        MOVE.L  #P_MOVEM,OPCODE_TO_PRINT
        MOVE.L  #P_Long,SIZE_TO_PRINT
        RTS

PRINT_NOT
        MOVE.L  #P_NOT,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_NOP
        MOVE.L  #P_NOP,OPCODE_TO_PRINT
        RTS

*-----Group 5-----*
PRINT_ADDQ
        LEA     P_ADDQ,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_ADDQ,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

*-----Group 6-----*
PRINT_BGT
        LEA     P_BGT,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_BGT,OPCODE_TO_PRINT
        RTS

PRINT_BLT
        LEA     P_BLT,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_BLT,OPCODE_TO_PRINT
        RTS

PRINT_BEQ
        LEA     P_BEQ,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_BEQ,OPCODE_TO_PRINT
        RTS

PRINT_BRA
        LEA     P_BRA,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_BRA,OPCODE_TO_PRINT
        RTS

*-----Group 7-----*
PRINT_MOVEQ ;only does longs
        LEA     P_MOVEQ,A1
        JSR     PRINT_INLINE
        LEA     P_LONG,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_MOVEQ,OPCODE_TO_PRINT
        ;MOVE.L  #P_LONG,SIZE_TO_PRINT
        RTS

*-----Group 8-----*
PRINT_OR
        LEA     P_OR,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_OR,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS
        
*-----Group 9-----*
PRINT_SUB
        LEA     P_SUB,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_SUB,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

*Group A - nothing to print

*Group B - nothing to print

*-----Group C-----*
PRINT_AND
        LEA     P_AND,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_AND,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

*-----Group D-----*
PRINT_ADD
        LEA     P_ADD,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_ADD,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ADDA
        LEA     P_ADDA,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_ADDA,OPCODE_TO_PRINT
        ;JSR     PRINT_ADDA_SIZE ;ADDA has special size location, make special method to handle it
        RTS

*-----Group E-----*
PRINT_LSR
        LEA     P_LSR,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_LSR,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_LSL
        LEA     P_LSL,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_LSL,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ASR
        LEA     P_ASR,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_ASR,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ASL
        LEA     P_ASL,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_ASL,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ROL
        LEA     P_ROL,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_ROL,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ROR
        LEA     P_ROR,A1
        JSR     PRINT_INLINE
        ;MOVE.L  #P_ROR,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

*-----Group F - nothing to print-----*


*-----------------------------------------------------------
*///////////////////////////////////////////////////////////
*OPCODE_SUBROUTINE_END
*///////////////////////////////////////////////////////////
*-----------------------------------------------------------
OPCODE_SUBROUTINE_END
        CMP.B   #1,OPCODE_VALIDITY
        *branch to some printing method if it's not equal (to print that it's invalid)
        *branch to parse ea if it's equal to check further
        JSR     IS_END
        BRA     DECODE_OPCODE

*-----------------------------------------------------------
*///////////////////////////////////////////////////////////
*EA_SUBROUTINE_START
*///////////////////////////////////////////////////////////
*-----------------------------------------------------------
P_DEST_EA_MODE
        ;LEA     REG_MODE_TABLE,A5
        ;MOVE.W  DEST_MODE,D6
        ;MOVE.W  DEST_VAR,TEMP
        ;MULU    #6,D6
        ;JSR     0(A5,D3)
        ;RTS 
*-----------------------------------------------------------
*SAVE_DEST
*Saves bits 11-6 in opcode.
*-----------------------------------------------------------
SAVE_DEST
        JSR     SAVE_DEST_MODE
        JSR     SAVE_DEST_VAR
        RTS
*-----------------------------------------------------------
*SAVE_DEST_MODE
*Bits 8-6 in opcode will be stored in DEST_MODE.
*-----------------------------------------------------------
SAVE_DEST_MODE
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #%0000000111000000,D0
        LSR.L   #6,D0
        MOVE.W  D0,DEST_MODE
        RTS
*-----------------------------------------------------------
*SAVE_DEST_VAR
*Bits 11-9 in opcode will be stored in SOURCE_VAR.
*-----------------------------------------------------------
SAVE_DEST_VAR
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #%0000111000000000,D0
        LSR.L   #6,D0
        LSR.L   #3,D0
        MOVE.W  D0,DEST_VAR
        RTS
*-----------------------------------------------------------
*PRINT_DEST
*-----------------------------------------------------------
PRINT_DEST
        JSR     SAVE_DEST
        MOVE.W  DEST_VAR,REG_NUM
        MOVE.W  DEST_MODE,D0
        CMPI.W  #0,D0               
        BEQ     PRINT_REG_MODE_0    ;Dn
        CMPI.W  #1,D0
        BEQ     PRINT_REG_MODE_1    ;An
        CMPI.W  #2,D0
        BEQ     PRINT_REG_MODE_2    ;(An)
        CMPI.W  #3,D0
        BEQ     PRINT_REG_MODE_3    ;(An)+
        CMPI.W  #4,D0
        BEQ     PRINT_REG_MODE_4    ;-(An)
        CMPI.W  #7,D0
        BEQ     PRINT_REG_MODE_7    ;Word/Long Address, #<data>
        RTS

        
P_SOURCE_EA_MODE
        ;LEA     REG_MODE_TABLE,A5
        ;MOVE.W  SOURCE_MODE,D6
        ;MOVE.W  SOURCE_VAR,TEMP
        ;MULU    #6,D6
        ;JSR     0(A5,D3)
        ;RTS
*-----------------------------------------------------------
*PRINT_SOURCE
*-----------------------------------------------------------
PRINT_SOURCE
        JSR     SAVE_SOURCE
        MOVE.W  SOURCE_VAR,REG_NUM
        MOVE.W  SOURCE_MODE,D0
        CMPI.W  #0,D0               
        BEQ     PRINT_REG_MODE_0    ;Dn
        CMPI.W  #1,D0
        BEQ     PRINT_REG_MODE_1    ;An
        CMPI.W  #2,D0
        BEQ     PRINT_REG_MODE_2    ;(An)
        CMPI.W  #3,D0
        BEQ     PRINT_REG_MODE_3    ;(An)+
        CMPI.W  #4,D0
        BEQ     PRINT_REG_MODE_4    ;-(An)
        CMPI.W  #7,D0
        BEQ     PRINT_REG_MODE_7    ;Word/Long Address, #<data>
        RTS
*-----------------------------------------------------------
*SAVE_SOURCE
*Saves bits 5-0 in opcode.
*-----------------------------------------------------------
SAVE_SOURCE
        JSR     SAVE_SOURCE_MODE
        JSR     SAVE_SOURCE_REG
        RTS

*-----------------------------------------------------------
*SAVE_SOURCE_MODE
*Bits 5-3 in opcode will be stored in SOURCE_MODE.
*-----------------------------------------------------------
SAVE_SOURCE_MODE
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #%0000000000111000,D0
        LSR.L   #3,D0
        MOVE.W  D0,SOURCE_MODE
        RTS
        
*-----------------------------------------------------------
*SAVE_SOURCE_REG
*Bits 2-0 in opcode will be stored in SOURCE_VAR.
*-----------------------------------------------------------
SAVE_SOURCE_REG
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #%0000000000000111,D0
        MOVE.W  D0,SOURCE_VAR
        RTS
        
*-----------------------------------------------------------
*PRINT_REG_MODE_X
*Prints the source/destination register/EA
*-----------------------------------------------------------    
PRINT_REG_MODE_0
        LEA     P_DATA_REG,A1   ;Dn
        MOVE.B  #14,D0
        TRAP    #15
        JSR     PRINT_REG_NUM
        RTS
PRINT_REG_MODE_1
        LEA     P_ADDR_REG,A1   ;An
        MOVE.B  #14,D0
        TRAP    #15
        JSR     PRINT_REG_NUM
        RTS
PRINT_REG_MODE_2
        LEA     P_OPEN_PAREN,A1     ;(
        MOVE.B  #14,D0
        TRAP    #15
        
        JSR     PRINT_REG_MODE_1    ;An
        
        LEA     P_CLOSE_PAREN,A1    ;)
        MOVE.B  #14,D0
        TRAP    #15
        RTS
PRINT_REG_MODE_3
        JSR     PRINT_REG_MODE_2    ;(An)
        
        LEA     P_POS_SIGN,A1       ;+
        MOVE.B  #14,D0
        TRAP    #15
        RTS
PRINT_REG_MODE_4
        LEA     P_NEG_SIGN,A1       ;-
        MOVE.B  #14,D0
        TRAP    #15
        
        JSR     PRINT_REG_MODE_2    ;(An)
        RTS
PRINT_REG_MODE_7
        ;Word/Long Address, #<data>
        MOVE.W  REG_NUM,D0
        CMPI.W  #0,D0
        BEQ     PRINT_WORD_ADDR
        CMPI.W  #1,D0
        BEQ     PRINT_LONG_ADDR
        CMPI.W  #4,D0
        ;BEQ     PRINT_IMMEDIATE_DATA (TODO)
        ;else
        RTS
        
*-----------------------------------------------------------
*PRINT_WORD_ADDR
*NOTE: BEQ from PRINT_REG_MODE_7, RTS back to JSR PRINT_REG_MODE_7
*----------------------------------------------------------- 
PRINT_WORD_ADDR
        LEA     P_HEX_SIGN,A1   ;$
        JSR     PRINT_INLINE
        
        MOVE.L  (A2),D1
        LSR.L   #8,D1       ;shift address to the right by a word; e.g. 5000FFFF -> 00005000
        LSR.L   #8,D1
        MOVE.B  #16,D2      ;base 16
        MOVE.B  #15,D0
        TRAP    #15
        ; increment address pointer by 2 to read the word address; e.g. 1038 5000, (A2) was 5000, now it's the next machine code (if valid)
        ADDA.W  #2,A2
        RTS
*-----------------------------------------------------------
*PRINT_LONG_ADDR
*NOTE: BEQ from PRINT_REG_MODE_7, RTS back to JSR PRINT_REG_MODE_7
*----------------------------------------------------------- 
PRINT_LONG_ADDR
        LEA     P_HEX_SIGN,A1   ;$
        JSR     PRINT_INLINE
        
        MOVE.L  (A2),D2
        JSR     PRINT_D2_LONG
        CLR.L   D2
        ; increment address pointer by 2 to read the word address; e.g. 1039 00005000, (A2) was 00005000, now it's the next machine code (if valid)
        ADDA.W  #4,A2
        RTS
*-----------------------------------------------------------
*PRINT_IMMEDIATE_DATA
*NOTE: BEQ from PRINT_REG_MODE_7, RTS back to JSR PRINT_REG_MODE_7
*----------------------------------------------------------- 
PRINT_IMMEDIATE_DATA
        LEA     P_IM_DATA_SIGN,A1   ;#
        JSR     PRINT_INLINE
        ; TODO
        
*-----------------------------------------------------------
*PRINT_REG_NUM
*Prints address/data register number. e.g. prints 0 in D0
*----------------------------------------------------------- 
PRINT_REG_NUM
        MOVE.W  REG_NUM,D0
        CMPI.W  #0,D0
        BEQ     PRINT_ZERO
        CMPI.W  #1,D0
        BEQ     PRINT_ONE
        CMPI.W  #2,D0
        BEQ     PRINT_TWO
        CMPI.W  #3,D0
        BEQ     PRINT_THREE
        CMPI.W  #4,D0
        BEQ     PRINT_FOUR
        CMPI.W  #5,D0
        BEQ     PRINT_FIVE
        CMPI.W  #6,D0
        BEQ     PRINT_SIX
        CMPI.W  #7,D0
        BEQ     PRINT_SEVEN
        ;else RTS, print error (TODO)
        RTS
        
*-----------------------------------------------------------
*Print number table
*NOTE: BEQ from PRINT_REG_NUM, RTS back to JSR PRINT_REG_MODE_X from PRINT_REG_NUM
*----------------------------------------------------------- 
PRINT_ZERO
        LEA     CHAR_0,A1
        JSR     PRINT_INLINE
        RTS                     
PRINT_ONE
        LEA     CHAR_1,A1
        JSR     PRINT_INLINE
        RTS
PRINT_TWO
        LEA     CHAR_2,A1
        JSR     PRINT_INLINE
        RTS
PRINT_THREE
        LEA     CHAR_3,A1
        JSR     PRINT_INLINE
        RTS
PRINT_FOUR
        LEA     CHAR_4,A1
        JSR     PRINT_INLINE
        RTS
PRINT_FIVE
        LEA     CHAR_5,A1
        JSR     PRINT_INLINE
        RTS
PRINT_SIX
        LEA     CHAR_6,A1
        JSR     PRINT_INLINE
        RTS
PRINT_SEVEN
        LEA     CHAR_7,A1
        JSR     PRINT_INLINE
        RTS
*-----------------------------------------------------------
*PRINT_COMMA
*-----------------------------------------------------------
PRINT_COMMA
        LEA     P_COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS
*-----------------------------------------------------------
*///////////////////////////////////////////////////////////
*EA_SUBROUTINE_END
*///////////////////////////////////////////////////////////
*-----------------------------------------------------------

*-----------------------------------------------------------
* CONVERT_TO_HEX
* CONVERT_TO_HEX_ALPHA
* PRECONDITION: Single ASCII value must be in D1
* Converts ASCII value in D1 into hex
*-----------------------------------------------------------

CONVERT_TO_HEX       
        CMP.B   #$39,D1
        BGT.B   CONVERT_TO_HEX_ALPHA        ;value greater than hex 39 is (A-F)
        SUBI.B  #$30,D1                     ;less than 39, sub 30 for number value
        RTS
        
CONVERT_TO_HEX_ALPHA       
        SUBI.B  #$37,D1                     ;sub 37 for alpha value
        RTS     
        
*-----------------------------------------------------------
* PRINT_BASE_16
* PRECONDITION: Move long to D1
* Prints long in D1 to console
*-----------------------------------------------------------
PRINT_BASE_16
        MOVE.B  #16,D2                      ;prints data in D1 in hex
        MOVE    #15,D0
        TRAP    #15
        CMP.W   #0,D1
        BNE     NOT_ZERO                    ;prints 00 for 0
        MOVE    #15,D0
        TRAP    #15
        
NOT_ZERO
        CLR.L   D1
        RTS

*-----------------------------------------------------------
* PRINT_D2_LONG
* PRECONDITION: None
* Prints long word in D2
*-----------------------------------------------------------
PRINT_D2_LONG
        MOVE.B  #8,D4

PRINT_D2_LOOP        
        MOVE.L  D2,D1                   ;move address into D1
        ROR.L   #8,D1                   ;rotate address to first char
        ROR.L   #8,D1
        ROR.L   #8,D1
        ROR.L   #4,D1
        AND.L   #$0000000F,D1           ;capture first hex char
        JSR     CHECK_HEX_ALPHA              ;detect for alpha char
        CMP.B   #9,D1                   
        BGT     PRINT_D2_SKIP                   ;skip trap #3 if alpha
        MOVE.B  #3,D0                   ;prints if D1 is a number

PRINT_D2_SKIP        
        TRAP    #15                     
        ASL.L   #4,D2                   ;removes MSB from D6
        SUB.B   #1,D4                   ;subtract from counter
        BNE     PRINT_D2_LOOP                   ;repeat to print whole longword addr
        RTS

*-----------------------------------------------------------
* CHECK_HEX_ALPHA
* PRECONDITION: None
* Checks for alpha characters, then prints
*-----------------------------------------------------------
CHECK_HEX_ALPHA
        CMP.B   #10,D1                  ;checks for hex alpha char
        BEQ     ALPHA_A
        CMP.B   #11,D1
        BEQ     ALPHA_B
        CMP.B   #12,D1
        BEQ     ALPHA_C
        CMP.B   #13,D1
        BEQ     ALPHA_D
        CMP.B   #14,D1
        BEQ     ALPHA_E
        CMP.B   #15,D1
        BEQ     ALPHA_F
        RTS
        
ALPHA_A
        LEA     CHAR_A,A1                    ;prints A char
        MOVE.B  #14,D0
        RTS
        
        
ALPHA_B
        LEA     CHAR_B,A1                    ;prints B char
        MOVE.B  #14,D0
        RTS
        
ALPHA_C
        LEA     CHAR_C,A1                    ;prints C char
        MOVE.B  #14,D0
        RTS
        
ALPHA_D
        LEA     CHAR_D,A1                    ;prints D char
        MOVE.B  #14,D0
        RTS
        
ALPHA_E
        LEA     CHAR_E,A1                    ;prints E char
        MOVE.B  #14,D0
        RTS
        
ALPHA_F
        LEA     CHAR_F,A1                    ;prints F char
        MOVE.B  #14,D0
        RTS      
        
*-----------------------------------------------------------
* GET_MACHINE_WORD
* PRECONDITION: (A2) is filled with machine code
* Saves the current word machine code, ends the program when there is none.
*-----------------------------------------------------------        
GET_MACHINE_WORD
        MOVE.W  (A2)+,CURRENT_OPCODE
        RTS
        
*-----------------------------------------------------------
* IS_END
* PRECONDITION: A2 contains current address, A3 contains end address.
* Checks if disassembler is at the end of the test program.
*-----------------------------------------------------------   
IS_END
        CMPA.L  A2,A3
        BLE     END
        RTS
*-----------------------------------------------------------
* GET_NEXT_SET
* PRECONDITION: STARTING_ADDR != ENDING_ADDR
* Decodes the next 20 machine code, and prompts to continue if program hasn't ended
*-----------------------------------------------------------      

END
        JSR     ENDLINE
        LEA     END_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15
        SIMHALT

GET_NEXT_SET
        ADDI.B  #1,D3
        CMPI.B  #20,D3
        BEQ     USER_ENTER_CONT
        RTS
*-----------------------------------------------------------
* USER_ENTER_CONT
* PRECONDITION: None
* Let users press enter to continue decoding
*-----------------------------------------------------------  
USER_ENTER_CONT
        JSR     ENDLINE         ;prints new line
        LEA     ENTER_CONT,A1   ;load message
        MOVE.B  #13,D0
        TRAP    #15
        CLR.B   D3              ;clear counter for next iteration
        MOVE.B  #5,D0           ;allow user to press enter
        TRAP    #15
        RTS
*-----------------------------------------------------------
* CHECK_MEM_RANGE
* PRECONDITION: STARTING_ADDR and ENDING_ADDR exists
* Checks if memory inputs are valid
*-----------------------------------------------------------
CHECK_MEM_RANGE
        MOVEA.L STARTING_ADDR,A2
        MOVEA.L ENDING_ADDR,A3
        CMPA.L  A2,A3
        BGT     WITHIN_RANGE
        JSR     ENDLINE
        LEA     MEM_OUT_OF_RANGE,A1                   
        MOVE    #14,D0
        TRAP    #15
        JSR     ENDLINE
        BRA     INPUT_START_ADDR
        
WITHIN_RANGE
        RTS

*-----------------------------------------------------------
* DISPLAY_MEMORY
* PRECONDITION: STARTING_ADDR and ENDING_ADDR exists
* Prints all data in memory range
*-----------------------------------------------------------
DISPLAY_MEMORY
        MOVEA.L STARTING_ADDR,A5            ;move starting addr to A5
        MOVEA.L ENDING_ADDR,A6              ;move ending addr to A6
        
COUNTER_20        
        MOVE.B  #20,D3
        
DISPLAY_MEM_LOOP
        JSR     ENDLINE                     ;endline
        MOVE.W  (A5),D1                     ;load byte at addr A5 into D1
        ADDA.L  #2,A5                       ;increment A5 by 2 since we accessed a word
        JSR     PRINT_BASE_16               ;print D1 in base 16
        CMPA.L  A5,A6                       ;compare A6 with ending addr
        BLE     DISPLAY_RETURN
        SUBI.B  #1,D3
        BNE     DISPLAY_MEM_LOOP            ;repeat loop if addr not equal
        JSR     ENDLINE
        LEA     ENTER_CONT,A1
        MOVE.B  #13,D0
        TRAP    #15
        MOVE.B  #5,D0
        TRAP    #15
        BRA     COUNTER_20
        
DISPLAY_RETURN
        RTS


*-----------------------------------------------------------
* PRINT_MEM_ADDR
* PRECONDITION: A2 filled with an addresss
* Outputs latest memory of test program
*-----------------------------------------------------------
PRINT_MEM_ADDR
        JSR     ENDLINE
        MOVE.L  A2,D2
        JSR     PRINT_D2_LONG
        CLR.L   D2
        RTS
        
PD_COUNTER_20        
        MOVE.B  #20,D3
        JSR     ENDLINE                     ;endline
        MOVE.L  A2,D2                       ;load byte at addr A5 into D1
        JSR     PRINT_D2_LONG               ;print D1 in base 16
        CMPA.L  A5,A6
        BLE     END
        SUBI.B  #1,D3
        RTS
        
        
*-----------------------------------------------------------
* PRINT_INLINE
* PRECONDITION: (A1) is filled with a null terminated string.
* Helper function to print without CR,LF.
*-----------------------------------------------------------
PRINT_INLINE
        MOVE.B  #14,D0
        TRAP    #15
        RTS

*-----------------------------------------------------------
* ENDLINE
*----------------------------------------------------------- 
ENDLINE       
        LEA     ENDL,A1
        MOVE    #13,D0
        TRAP    #15
        RTS
      
*Table for hex characters
CHAR_0	DC.B	'0',0
CHAR_1	DC.B	'1',0
CHAR_2	DC.B	'2',0
CHAR_3	DC.B	'3',0
CHAR_4	DC.B	'4',0
CHAR_5	DC.B	'5',0
CHAR_6	DC.B	'6',0
CHAR_7	DC.B	'7',0
CHAR_8	DC.B	'8',0
CHAR_9	DC.B	'9',0
CHAR_A	DC.B	'A',0
CHAR_B	DC.B	'B',0
CHAR_C	DC.B	'C',0
CHAR_D	DC.B	'D',0
CHAR_E	DC.B	'E',0
CHAR_F	DC.B	'F',0

*table for opcode constants
P_INVALID       DC.B    '   DATA   $',0
P_Byte          DC.B    '.B ',0
P_Word          DC.B    '.W ',0
P_Long          DC.B    '.L ',0
P_MOVE          DC.B    '   MOVE',0
P_MOVEA         DC.B    '   MOVEA',0
P_LEA           DC.B    '   LEA     ',0
P_JSR           DC.B    '   JSR     ',0
P_RTS           DC.B    '   RTS',0      *no operands
P_MOVEM         DC.B    '   MOVEM',0
P_NOT           DC.B    '   NOT     ',0
P_NOP           DC.B    '   NOP',0      *no operands
P_ADDQ          DC.B    '   ADDQ',0
P_BGT           DC.B    '   BGT     ',0
P_BLT           DC.B    '   BLT     ',0
P_BEQ           DC.B    '   BEQ     ',0
P_BRA           DC.B    '   BRA     ',0
P_MOVEQ         DC.B    '   MOVEQ',0
P_OR            DC.B    '   OR',0
P_SUB           DC.B    '   SUB',0
P_AND           DC.B    '   AND',0
P_ADD           DC.B    '   ADD',0
P_ADDA          DC.B    '   ADDA',0
P_LSR           DC.B    '   LSR',0
P_LSL           DC.B    '   LSL',0
P_ASR           DC.B    '   ASR',0
P_ASL           DC.B    '   ASL',0
P_ROL           DC.B    '   ROL',0
P_ROR           DC.B    '   ROR',0

*table for EA constants
P_OPEN_PAREN    DC.B    '(',0
P_CLOSE_PAREN   DC.B    ')',0
P_POS_SIGN      DC.B    '+',0
P_NEG_SIGN      DC.B    '-',0
P_DATA_REG      DC.B    'D',0
P_ADDR_REG      DC.B    'A',0

P_DOT_BYTE      DC.B    '.B'
P_DOT_WORD      DC.B    '.W'
P_DOT_LONG      DC.B    '.L'

P_COMMA         DC.B    ',',0
P_BIN_SIGN      DC.B    '%',0
P_HEX_SIGN      DC.B    '$',0
P_IM_DATA_SIGN  DC.B    '#',0

*Console messages
INPUT_START_MSG     DC.W    'Please enter an 8 hex digit starting address: ',0
INPUT_END_MSG       DC.W    'Please enter an 8 hex digit ending address: ',0
MEM_OUT_OF_RANGE    DC.W    'Memory outside of range! Check inputs!',0
ENTER_CONT          DC.W    'Press enter to continue...',0
END_MSG             DC.W    'Reached the end of test program!',0
ENDL                DC.W    '',0

*Variables
CURRENT_OPCODE      DS.W    1
CURRENT_OPSIZE      DS.W    1
OPCODE_VALIDITY     DS.B    1
OPCODE_TO_PRINT     DS.W    1
SIZE_TO_PRINT       DS.W    1


    END    $1000        ; last line of source

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
