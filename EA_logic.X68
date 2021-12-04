*-----------------------------------------------------------
* Title      :
* Written by :
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

    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVE.W  #$1008, $9000   ; machine code XXXX stored in $0009000
    
STORE_SOURCE
    MOVE.W  $9000,D5        
    AND.W   #%0000000000111111,D5 ; D2 = SOURCE
    MOVE.W  D5,D6
    MOVE.W  D5,D7   
    LSR.B   #3,D6                   ; D6 stores SOURCE_MODE
    AND.B   #%000111,D7             ; D7 stores SOURCE_REG
    MOVE.W  D6,SOURCE_MODE
    MOVE.W  D7,SOURCE_VAR
    
CHECK_SOURCE_MODE
    CMPI.W  #0,SOURCE_MODE           ;Source Dn
    BEQ     PRINT_S_DATA
    
    CMPI.W  #1,SOURCE_MODE           ;Source An
    BEQ     PRINT_S_ADDR
CHECK_SOURCE_VAR
    CMPI.W  #0,SOURCE_VAR
    BEQ     PRINT_S_ZERO
    
    CMPI.W  #1,SOURCE_VAR
    BEQ     PRINT_S_ONE
    
    CMPI.W  #2,SOURCE_VAR
    BEQ     PRINT_S_TWO
    
    CMPI.W  #3,SOURCE_VAR
    BEQ     PRINT_S_THREE
    
    CMPI.W  #4,SOURCE_VAR
    BEQ     PRINT_S_FOUR
    
    CMPI.W  #5,SOURCE_VAR
    BEQ     PRINT_S_FIVE
    
    CMPI.W  #6,SOURCE_VAR
    BEQ     PRINT_S_SIX
    
    CMPI.W  #7,SOURCE_VAR
    BEQ     PRINT_S_SEVEN
    
STORE_DEST
    MOVE.W  $9000,D1        ; starting address
    AND.W   #%0000111111000000,D1
    LSR.L   #6,D1                 ; D1 = DEST
    MOVE.W  D1,D2
    MOVE.W  D1,D3
    LSR.B   #3,D2                   ; D2 stores DEST_REG as bytes
    AND.B   #%000111,D3             ; D3 stores DEST_MODE as bytes
    MOVE.W  D2,DEST_VAR
    MOVE.W  D3,DEST_MODE
    
CHECK_DEST_MODE
    CMPI.W  #0,DEST_MODE    ;Destination Dn
    BEQ     PRINT_D_DATA
    
    CMPI.W  #1,DEST_MODE    ;Destination An
    BEQ     PRINT_D_ADDR
    
CHECK_DEST_VAR
    CMPI.W  #0,DEST_VAR
    BEQ     PRINT_D_ZERO
    
    CMPI.W  #1,DEST_VAR
    BEQ     PRINT_D_ONE
    
    CMPI.W  #2,DEST_VAR
    BEQ     PRINT_D_TWO

    CMPI.W  #3,DEST_VAR
    BEQ     PRINT_D_THREE

    CMPI.W  #4,DEST_VAR
    BEQ     PRINT_D_FOUR

    CMPI.W  #5,DEST_VAR
    BEQ     PRINT_D_FIVE

    CMPI.W  #6,DEST_VAR
    BEQ     PRINT_D_SIX
    
    CMPI.W  #7,DEST_VAR
    BEQ     PRINT_D_SEVEN
    
DONE
    SIMHALT             ; halt simulator
    
    
PRINT_S_ZERO
    LEA     P_CHAR_0,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
PRINT_S_ONE
    LEA     P_CHAR_1,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
PRINT_S_TWO
    LEA     P_CHAR_2,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
PRINT_S_THREE
    LEA     P_CHAR_3,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
PRINT_S_FOUR
    LEA     P_CHAR_4,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
PRINT_S_FIVE
    LEA     P_CHAR_5,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
PRINT_S_SIX
    LEA     P_CHAR_6,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
PRINT_S_SEVEN
    LEA     P_CHAR_7,A1
    JSR     PRINT
    LEA     P_COMMA,A1
    JSR     PRINT
    BRA     STORE_DEST
    
PRINT_S_DATA
    LEA     P_DATA,A1
    JSR     PRINT
    BRA     CHECK_SOURCE_VAR
PRINT_S_ADDR
    LEA     P_ADDR,A1
    JSR     PRINT
    BRA     CHECK_SOURCE_VAR
    
PRINT_D_ZERO
    LEA     P_CHAR_0,A1
    JSR     PRINT
    BRA     DONE
PRINT_D_ONE
    LEA     P_CHAR_1,A1
    JSR     PRINT
    BRA     DONE
PRINT_D_TWO
    LEA     P_CHAR_2,A1
    JSR     PRINT
    BRA     DONE
PRINT_D_THREE
    LEA     P_CHAR_3,A1
    JSR     PRINT
    BRA     DONE
PRINT_D_FOUR
    LEA     P_CHAR_4,A1
    JSR     PRINT
    BRA     DONE
PRINT_D_FIVE
    LEA     P_CHAR_5,A1
    JSR     PRINT
    BRA     DONE
PRINT_D_SIX
    LEA     P_CHAR_6,A1
    JSR     PRINT
    BRA     DONE
PRINT_D_SEVEN
    LEA     P_CHAR_7,A1
    JSR     PRINT
    BRA     DONE

    
PRINT_D_DATA
    LEA     P_DATA,A1
    JSR     PRINT
    BRA     CHECK_DEST_VAR
PRINT_D_ADDR
    LEA     P_ADDR,A1
    JSR     PRINT
    BRA     CHECK_DEST_VAR
    
PRINT
    MOVE.B  #14,D0
    TRAP    #15
    RTS    

    
    

* Put variables and constants here



P_CHAR_0    DC.B    '0',0
P_CHAR_1    DC.B    '1',0
P_CHAR_2    DC.B    '2',0
P_CHAR_3    DC.B    '3',0
P_CHAR_4    DC.B    '4',0
P_CHAR_5    DC.B    '5',0
P_CHAR_6    DC.B    '6',0
P_CHAR_7    DC.B    '7',0
P_COMMA     DC.B    ',',0
P_DATA      DC.B    'D',0
P_ADDR      DC.B    'A',0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
