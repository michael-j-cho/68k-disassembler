*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: BGT, BLT, BEQ, BRA
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here
        ADDQ    #1,D0
        CMP     #1,D0
        BGT     NEXT_1
NEXT_1
        CMP     #1,D0
        BLT     NEXT_2
NEXT_2  
        CMP     #1,D0
        BEQ     NEXT_3
NEXT_3  
        CMP     #1,D0
        BEQ     DONE
DONE    
        CMP     #1,D0
        BRA     END
        
    
END
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
