%utt3 ; VEN/SMH - Unit Tests Coverage Tests;08/14/14  14:02
 ;;0.1;MASH UTILITIES;
XTMUNITV ; VEN/SMH - Unit Tests Coverage Tests;2014-04-16  7:14 PM
 ;
 ; *** BE VERY CAREFUL IN MODIFIYING THIS ROUTINE ***
 ; *** THE UNIT TEST COUNTS ACTIVE AND INACTIVE LINES OF CODE ***
 ; *** IF YOU MODIFY THIS, MODIFY XTMUNITW AS WELL ***
 ;
 ; Coverage tester in %utt4
 ; 20 Lines of code
 ; 5 do not run as they are dead code
 ; Expected Coverage: 15/20 = 75%
 ;
STARTUP ; Doesn't count
 N X    ; Counts
 S X=1  ; Counts
 QUIT   ; Counts
 ;
SHUTDOWN K X,Y QUIT     ; Counts; ZEXCEPT: X,Y
 ;
SETUP S Y=$G(Y)+1 QUIT  ; Counts
 ;
TEARDOWN ; Doesn't count
 S Y=Y-1 ; Counts
 QUIT    ; Counts
 ;
T1 ; @TEST Test 1
 D CHKTF^%ut($D(Y)) ; Counts
 QUIT                   ; Counts
 ;
T2 ; @TEST Test 2
 D INTERNAL(1)          ; Counts
 D CHKTF^%ut(1)     ; Counts
 QUIT                   ; Counts
 S X=1                  ; Dead code
 QUIT                   ; Dead code
 ;
INTERNAL(A) ; Counts
 S A=A+1    ; Counts
 QUIT       ; Counts
 S A=2      ; Dead code
 S Y=2      ; Dead code
 QUIT       ; Dead code
