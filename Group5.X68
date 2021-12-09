*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: ADDQ
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here
    ADDQ      #1,D0
    ADDQ.B    #2,D2
    ADDQ.W    #5,D5
    ADDQ.L    #8,A1
    ADDQ.L    #7,A3
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
