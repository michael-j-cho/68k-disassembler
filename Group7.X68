*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: MOVEQ
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here
    MOVEQ       #1,D0
    MOVEQ       #1,D2
    MOVEQ       #3,D3
    MOVEQ.L     #4,D4

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
