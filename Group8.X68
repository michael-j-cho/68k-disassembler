*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: OR
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here
        ;OR <ea>,Dn
        OR.B    D0,D1
        OR.W    D2,D3
        OR.L    D4,D5
        ;OR Dn,<ea>
        OR.B    D1,$1
        OR.W    D2,$2
        OR.L    D4,$4

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
