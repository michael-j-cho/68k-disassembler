*-----------------------------------------------------------
* Title      : Disassembler Project
* Written by : Calvin Lim, Derek Slater, Madeline Ngoc Nguyen, Michael Cho
* Date       :
* Description:
*-----------------------------------------------------------
STARTING_ADDR   EQU     $350
ENDING_ADDR     EQU     $400

    
START ORG    $1000
                                          
INPUT_START_ADDR
        LEA     INPUT_START_MSG,A1              
        MOVE    #14,D0
        TRAP    #15
        MOVE    #6,D7
    
INPUT_START_ADDR_LOOP
        MOVE    #5,D0
        TRAP    #15
        JSR     CONVERT_TO_HEX
        ROL.L   #4,D2
        ADD.L   D1,D2
        SUBQ    #1,D7
        BNE     INPUT_START_ADDR_LOOP
        MOVE.L  D2,STARTING_ADDR
    
INPUT_END_ADDR
        JSR     ENDLINE
        CLR.L   D2
        LEA     INPUT_END_MSG,A1
        MOVE    #14,D0
        TRAP    #15
        MOVE    #6,D7

INPUT_END_ADDR_LOOP
        MOVE    #5,D0
        TRAP    #15
        JSR     CONVERT_TO_HEX
        ROL.L   #4,D2
        ADD.L   D1,D2
        SUBQ    #1,D7
        BNE     INPUT_END_ADDR_LOOP
        MOVE.L  D2,ENDING_ADDR
    
    
        JSR     ENDLINE
        MOVE.L  STARTING_ADDR,D1
        JSR     PRINT_BASE_16
        
        ;JSR     OPCODE_SUBROUTINE_START
        
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
        
        BRA     OPCODE_SUBROUTINE_END
    
    
*-----------------------------------------------------------
*Group 0
*Checks for these valid opcodes: None
*Checks for these invalid/unsupported opcodes:
*-----------------------------------------------------------
CHECK_GROUP_0

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 1
*Checks for these valid opcodes: MOVE.B
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_1

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 2
*Checks for these valid opcodes: MOVE.L, MOVEA.L
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_2

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 3
*Checks for these valid opcodes: MOVE.W, MOVEA.W
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_3

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 4
*Checks for these valid opcodes: LEA, JSR, RTS, MOVEM, NOT, NOP
*Checks for these invalid/unsupported opcodes:
*-----------------------------------------------------------
CHECK_GROUP_4

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 5
*Checks for these valid opcodes: ADDQ
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_5

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 6
*Checks for these valid opcodes: BGT, BLT, BEQ, BRA
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_6

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 7
*Checks for these valid opcodes: MOVEQ
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_7

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 8
*Checks for these valid opcodes: OR
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_8

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group 9
*Checks for these valid opcodes: SUB
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_9

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group A
*Checks for these valid opcodes: None
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_A

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group B
*Checks for these valid opcodes: None
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_B

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group C
*Checks for these valid opcodes: AND
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_C

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group D
*Checks for these valid opcodes: ADD, ADDA
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_D

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group E
*Checks for these valid opcodes: LSR, LSL, ASR, ASL, ROL, ROR
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_E

        BRA     OPCODE_SUBROUTINE_END 
*-----------------------------------------------------------
*Group F
*Checks for these valid opcodes: None
*Checks for these invalid/unsupported opcodes: 
*-----------------------------------------------------------
CHECK_GROUP_F

        BRA     OPCODE_SUBROUTINE_END        
*-----------------------------------------------------------
*///////////////////////////////////////////////////////////
*OPCODE_SUBROUTINE_END
*///////////////////////////////////////////////////////////
*-----------------------------------------------------------
OPCODE_SUBROUTINE_END
    

    SIMHALT             ; halt simulator
    
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
        MOVE.B  #16,D2
        MOVE    #15,D0
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

*Console messages
INPUT_START_MSG     DC.W    'Please enter an 8 character starting address in hex: ',0
INPUT_END_MSG       DC.W    'Please enter an 8 character ending address in hex: ',0
ENDL                DC.W    '',0

*Variables
CURRENT_OPCODE      DS.W    1


    END    $1000        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
