*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: MOVE.L, MOVEA.L
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here
        MOVE.L  D0,D1
        MOVEA.L D1,A0

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
