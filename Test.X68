*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $00009000
START:                  ; first instruction of program

* Put program code here

    MOVE.B  D0,D1
    MOVE.B  D2,D3
    MOVE.W  A0,D0
    MOVE.B  (A0),D0
    MOVE.B  (A0)+,D0
    MOVE.B  -(A0),D0
    MOVE.B  $F9999,D0
    MOVE.B  $1000,D0
    MOVE.B  $0001,D0
    MOVE.L  #2,D0
    ;MOVE.B  $00010000,d0
    ;MOVE.B  #3,D0
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
