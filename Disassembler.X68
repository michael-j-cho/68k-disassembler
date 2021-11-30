*-----------------------------------------------------------
* Title      : Disassembler Project
* Written by : Calvin Lim, Derek Slater, Madeline Ngoc Nguyen, Michael Cho
* Date       :
* Description:
*-----------------------------------------------------------
STARTING_ADDR   EQU     $350
ENDING_ADDR     EQU     $400
        
    
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
        MOVE    #6,D7                       ;6 unit counter in d7
    
INPUT_START_ADDR_LOOP
        MOVE    #5,D0                       ;read single ASCII val from the keyboard into D1.B
        TRAP    #15
        JSR     CONVERT_TO_HEX              ;convert ASCII to hex
        ROL.L   #4,D2                       ;rotate D2 left 4 bits
        ADD.L   D1,D2                       ;add hex value to D2
        SUBQ    #1,D7                       ;decrement counter
        BNE     INPUT_START_ADDR_LOOP       ;repeat this loop  
        MOVE.L  D2,STARTING_ADDR            ;move D2 into STARTING_ADDR at $350
    
INPUT_END_ADDR
        JSR     ENDLINE                        
        CLR.L   D2                          
        LEA     INPUT_END_MSG,A1            ;display message to input ending addr
        MOVE    #14,D0                  
        TRAP    #15                         
        MOVE    #6,D7                       ;6 unit counter in d7

INPUT_END_ADDR_LOOP
        MOVE    #5,D0                       ;read single ASCII val from the keyboard into D1.B
        TRAP    #15
        JSR     CONVERT_TO_HEX              ;convert ASCII to hex
        ROL.L   #4,D2                       ;rotate D2 left 4 bits
        ADD.L   D1,D2                       ;add hex value to D2
        SUBQ    #1,D7                       ;decrement counter
        BNE     INPUT_END_ADDR_LOOP         ;repeat this loop 
        MOVE.L  D2,ENDING_ADDR              ;move D2 into ENDING_ADDR at $400     
        
        JSR     CHECK_MEM_RANGE
        MOVE.W  (A1),CURRENT_OPCODE
        JSR     DISPLAY_MEMORY
        
        SIMHALT
        
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
        CMP.W   #$1,D2
        BNE     CHECK_FOR_MOVEL
        ;else
        JSR     PRINT_MOVEAL    ;MOVEAL
        BRA     OPCODE_SUBROUTINE_END
        
CHECK_FOR_MOVEL
        MOVE.W  CURRENT_OPCODE, D0
        ANDI.W  #$F000,D0
        CMP.W   #$2000,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_MOVEL ;MOVEL
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
        CMP.W   #$1,D2
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
        CMP.W   #$5100,D0
        BNE     INVALID_OPCODE
        ;else
        JSR     PRINT_ADDQ
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
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
        JSR     PRINT_OR
        JSR     TWO_BIT_SIZE_AT_BITS_7_6
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
*-----------------------------------------------------------
CHECK_GROUP_C

CHECK_FOR_EXG
        MOVE.W  CURRENT_OPCODE,D0
        ANDI.W  #$F130,D0
        CMP.W   #$9100,D0
        BEQ     INVALID_OPCODE
        ;else check for next possible invalid opcode

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group D
*Checks for these valid opcodes: ADD, ADDA
*-----------------------------------------------------------
CHECK_GROUP_D

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
        MOVE.W  #P_BYTE,SIZE_TO_PRINT
        RTS

PRINT_WORD
        MOVE.W  #P_WORD,SIZE_TO_PRINT
        RTS

PRINT_LONG
        MOVE.W  #P_LONG,SIZE_TO_PRINT
        RTS
*-----Group 0 - nothing to print-----*

*-----Group 1-----*
PRINT_MOVEB
        MOVE.L  #P_MOVE,OPCODE_TO_PRINT
        MOVE.L  #P_Byte,SIZE_TO_PRINT
        RTS

*-----Group 2-----*
PRINT_MOVEL
        MOVE.L  #P_MOVE,OPCODE_TO_PRINT
        MOVE.L  #P_Long,SIZE_TO_PRINT
        RTS
        
PRINT_MOVEAL
        MOVE.L  #P_MOVEA,OPCODE_TO_PRINT
        MOVE.L  #P_Long,SIZE_TO_PRINT
        RTS

*-----Group 3-----*
PRINT_MOVEW
        MOVE.L  #P_MOVE,OPCODE_TO_PRINT
        MOVE.L  #P_Word,SIZE_TO_PRINT
        RTS
        
PRINT_MOVEAW
        MOVE.L  #P_MOVEA,OPCODE_TO_PRINT
        MOVE.L  #P_Word,SIZE_TO_PRINT
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
        MOVE.L  #P_ADDQ,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

*-----Group 6-----*
PRINT_BGT
        MOVE.L  #P_BGT,OPCODE_TO_PRINT
        RTS

PRINT_BLT
        MOVE.L  #P_BLT,OPCODE_TO_PRINT
        RTS

PRINT_BEQ
        MOVE.L  #P_BEQ,OPCODE_TO_PRINT
        RTS

PRINT_BRA
        MOVE.L  #P_BRA,OPCODE_TO_PRINT
        RTS

*-----Group 7-----*
PRINT_MOVEQ ;only does longs
        MOVE.L  #P_MOVEQ,OPCODE_TO_PRINT
        MOVE.L  #P_LONG,SIZE_TO_PRINT
        RTS

*-----Group 8-----*
PRINT_OR
        MOVE.L  #P_OR,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS
        
*-----Group 9-----*
PRINT_SUB
        MOVE.L  #P_SUB,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

*Group A - nothing to print

*Group B - nothing to print

*-----Group C-----*
PRINT_AND
        MOVE.L  #P_AND,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

*-----Group D-----*
PRINT_ADD
        MOVE.L  #P_ADD,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ADDA
        MOVE.L  #P_ADDA,OPCODE_TO_PRINT
        ;JSR     PRINT_ADDA_SIZE ;ADDA has special size location, make special method to handle it
        RTS

*-----Group E-----*
PRINT_LSR
        MOVE.L  #P_LSR,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_LSL
        MOVE.L  #P_LSL,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ASR
        MOVE.L  #P_ASR,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ASL
        MOVE.L  #P_ASL,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ROL
        MOVE.L  #P_ROL,OPCODE_TO_PRINT
        JSR     PRINT_SIZE
        RTS

PRINT_ROR
        MOVE.L  #P_ROR,OPCODE_TO_PRINT
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
        
        RTS
    
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
        CMP.B   #0,D1
        BNE     NOT_ZERO                    ;prints 00 for 0
        MOVE    #15,D0
        TRAP    #15
        
NOT_ZERO
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
        MOVEA.L STARTING_ADDR,A6            ;move starting addr to A6
        MOVEA.L ENDING_ADDR,A7              ;move ending addr to A7
        
COUNTER_20        
        MOVE.B  #20,D3
        
DISPLAY_MEM_LOOP
        JSR     ENDLINE                     ;endline
        MOVE.B  (A6)+,D1                    ;load byte at addr A6 into D1
        JSR     PRINT_BASE_16               ;print D1 in base 16
        CMPA.W  A6,A7                       ;compare A6 with ending addr
        BEQ     DISPLAY_RETURN
        SUBI.B  #1,D3
        BNE     DISPLAY_MEM_LOOP              ;repeat loop if addr not equal
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

*Console messages
INPUT_START_MSG     DC.W    'Please enter an 6 character starting address in hex: ',0
INPUT_END_MSG       DC.W    'Please enter an 6 character ending address in hex: ',0
MEM_OUT_OF_RANGE    DC.W    'Memory outside of range! Check inputs!',0
ENTER_CONT          DC.W    'Press enter to continue...',0
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
