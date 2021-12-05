*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: AND
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here
        ;AND <ea>,Dn
        AND.B   #1,D1
        AND.W   #100,D2
        AND.L   #1000,D3
        ;AND Dn,<ea>
        AND.B   D1,(A0)
        AND.W   D2,(A1)
        AND.L   D3,(A2)

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
