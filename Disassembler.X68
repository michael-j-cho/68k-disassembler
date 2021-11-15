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


    END    $1000        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
