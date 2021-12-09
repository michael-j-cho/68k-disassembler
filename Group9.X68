*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: SUB
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here
        ;SUB <ea>,Dn
        SUB.B   $1,D0
        SUB.W   $2,D2
        SUB.L   $3,D3
        ;SUB Dn,<ea>
        SUB.B   D0,$100
        SUB.W   D1,$120
        SUB.L   D2,$140
 
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
