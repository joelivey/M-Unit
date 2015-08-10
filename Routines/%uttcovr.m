%uttcovr	;JIVEYSOFT/JLI - runs coverage tests on %ut and %ut1 routines via unit tests ;08/10/15  14:31
	;;0.2;MASH UTILITIES;;;Build 7
	;
	; Submitted to OSEHRA 08/10/2015 by Joel L. Ivey
	; Original routine authored by Joel L. Ivey
	;
	;
	; ZEXCEPT: DTIME - if present the value is Kernel timeout for reads
	N RUNCODE,XCLUDE
	;
	; Have it run the following entry points or, if no ^, call EN^%ut with routine name
	S RUNCODE(1)="^%utt1,%utt1,^%utt6,VERBOSE^%utt6,%uttcovr,^%ut,^%ut1,^%utcover"
	S RUNCODE("ENTRY^%uttcovr")=""
	I '(+$SY=47) D  Q  ; GT.M only!
	. W !,"This coverage analysis is currently only available in GT.M"
	. N VAL R !,"Do you want to run the same tests using MULTAPIS Y/N ? ",VAL:$G(DTIME,300) Q:'$T
	. I "Yy"[$E(VAL) D MULTAPIS^%ut(.RUNCODE)
	. Q
	; Have the analysis EXCLUDE the following routines from coverage - unit test routines
	S XCLUDE(1)="%utt1,%utt2,%utt3,%utt4,%utt5,%utt6,%uttcovr"
	S XCLUDE(2)="%utf2hex" ; a GT.M system file, although it wasn't showing up anyway
	M ^TMP("%uttcovr",$J,"XCLUDE")=XCLUDE
	D COVERAGE^%ut("%ut*",.RUNCODE,.XCLUDE,3)
	Q
	;
ENTRY	;
	K ^TMP("ENTRY^%uttcovr",$J,"VALS")
	M ^TMP("ENTRY^%uttcovr",$J,"VALS")=^TMP("%ut",$J,"UTVALS")
	K ^TMP("%ut",$J,"UTVALS")
	; these tests run outside of unit tests to handle CHKLEAKS calls not in unit tests
	; they need data set, so they are called in here
	; LEAKSOK ;
	N CODE,LOCATN,MYVALS,X,I
	S CODE="S X=$$NOW^XLFDT()",LOCATN="LEAKSOK TEST",MYVALS("X")=""
	D CHKLEAKS^%ut(CODE,LOCATN,.MYVALS) ; should find no leaks
	; LEAKSBAD ;
	N CODE,LOCATN,MYVALS,X
	S CODE="S X=$$NOW^XLFDT()",LOCATN="LEAKSBAD TEST - X NOT SPECIFIED"
	D CHKLEAKS^%ut(CODE,LOCATN,.MYVALS) ; should find X since it isn't indicated
	; try to run coverage
	W !,"xxxxxxxxxxxxxxxxxxxx GOING TO COV^%ut FOR %utt5 at 3",!!!
	D COV^%ut("%ut1","D EN^%ut(""%utt5"")",3)
	W !,"xxxxxxxxxxxxxxxxxxxx GOING TO COV^%ut FOR %utt5 at -1",!!!
	D COV^%ut("%ut1","D EN^%ut(""%utt5"")",-1)
	N RUNCODE S RUNCODE(1)="^%utt4,^%ut"
	N XCLUDE M XCLUDE=^TMP("%uttcovr",$J,"XCLUDE")
	W !,"xxxxxxxxxxxxxxxxxxxx GOING TO MULTAPIS for %utt4 and %ut",!!!
	D MULTAPIS^%ut(.RUNCODE)
	W !,"xxxxxxxxxxxxxxxxxxxx GOING TO COVERAGE for %utt4 and %ut at 3",!!!
	D COVERAGE^%ut("%ut*",.RUNCODE,.XCLUDE,3)
	N GLT S GLT=$NA(^TMP("%uttcovr-text",$J)) K @GLT
	W !,"xxxxxxxxxxxxxxxxxxxx LISTING DATA VIA LIST",!!!
	D LIST^%utcover(.XCLUDE,3,GLT) ; get coverage for listing and trimdata in %utcover
	F I=1:1 Q:'$D(@GLT@(I))  W !,@GLT@(I)
	K @GLT
	; restore unit test totals from before entry
	K ^TMP("%ut",$J,"UTVALS")
	M ^TMP("%ut",$J,"UTVALS")=^TMP("ENTRY^%uttcovr",$J,"VALS")
	K ^TMP("ENTRY^%uttcovr",$J,"VALS")
	W !,"xxxxxxxxxxxxxxxxxxxx Finished in ENTRY^%uttcovr",!!!
	Q
	;
RTNANAL	; @TEST - routine analysis
	N ROUS,GLB
	S ROUS("%utt4")=""
	S GLB=$NA(^TMP("%uttcovr-rtnanal",$J)) K @GLB
	D RTNANAL^%ut1(.ROUS,GLB)
	D CHKTF^%ut($D(@GLB@("%utt4","MAIN"))>1,"Not enough 'MAIN' nodes found")
	D CHKTF^%ut($G(@GLB@("%utt4","MAIN",2))["+$SY=47","Check for GT.M not found in expected line")
	D CHKTF^%ut($G(@GLB@("%utt4","MAIN",8))=" QUIT","Final QUIT not on expected line")
	K @GLB
	Q
	;
COVCOV	; @TEST - check COVCOV - remove seen lines
	N C,R
	S C=$NA(^TMP("%uttcovr_C",$J))
	S R=$NA(^TMP("%uttcovr_R",$J))
	S @C@("ROU1")=""
	S @C@("ROU2")="",@R@("ROU2")=""
	S @C@("ROU2","TAG1")="",@R@("ROU2","TAG1")=""
	S @C@("ROU2","TAG1",1)="AAA"
	S @C@("ROU2","TAG1",2)="AAA",@R@("ROU2","TAG1",2)="AAA"
	S @C@("ROU2","TAG1",3)="ABB",@R@("ROU2","TAG1",3)="ABB"
	S @C@("ROU2","TAG2",6)="ACC"
	S @C@("ROU2","TAG2",7)="ADD",@R@("ROU2","TAG2",7)="ADD"
	S @C@("ROU3","TAG1",2)="BAA",@R@("ROU3","TAG1",2)="BAA"
	S @C@("ROU3","TAG1",3)="CAA"
	S @C@("ROU3","TAG1",4)="DAA"
	S @C@("ROU3","TAG1",5)="EAA",@R@("ROU3","TAG1",5)="EAA"
	S @C@("ROU3","TAG1",6)="FAA",@R@("ROU3","TAG1",6)="FAA"
	D COVCOV^%ut1(C,R)
	D CHKTF^%ut($D(@C@("ROU2","TAG1",1)),"Invalid value for ""ROU2"",""TAG1"",1")
	D CHKTF^%ut('$D(@C@("ROU2","TAG1",2)),"Unexpected value for ""ROU2"",""TAG1"",1")
	D CHKTF^%ut($D(@C@("ROU2","TAG2",6)),"Invalid value for ""ROU2"",""TAG1"",1")
	D CHKTF^%ut('$D(@C@("ROU2","TAG2",7)),"Unexpected value for ""ROU2"",""TAG1"",1")
	D CHKTF^%ut($D(@C@("ROU3","TAG1",4)),"Invalid value for ""ROU2"",""TAG1"",1")
	D CHKTF^%ut('$D(@C@("ROU3","TAG1",5)),"Unexpected value for ""ROU2"",""TAG1"",1")
	K @C,@R
	Q
	;
COVRPTGL	; @TEST - coverage report returning global
	N GL1,GL2,GL3,GL4
	S GL1=$NA(^TMP("%utCOVCOHORTSAVx",$J)) K @GL1
	S GL2=$NA(^TMP("%utCOVCOHORTx",$J)) K @GL2
	S GL3=$NA(^TMP("%utCOVRESULTx",$J)) K @GL3
	S GL4=$NA(^TMP("%utCOVREPORTx",$J)) K @GL4
	D SETGLOBS(GL1,GL2)
	D COVRPTGL^%ut1(GL1,GL2,GL3,GL4)
	D CHKEQ^%ut($G(@GL4@("%ut1","ACTLINES")),"0/9","Wrong number of lines covered f>>or ACTLINES")
	D CHKEQ^%ut($G(@GL4@("%ut1","ACTLINES",9))," QUIT CNT","Wrong result for last l>>ine not covered for ACTLINES")
	D CHKEQ^%ut($G(@GL4@("%ut1","CHEKTEST")),"8/10","Wrong number of lines covered >>for CHEKTEST")
	D CHKEQ^%ut($G(@GL4@("%ut1","CHEKTEST",39))," . Q","Wrong result for last line >>not covered for CHEKTEST")
	K @GL1,@GL2,@GL3,@GL4
	Q
	;
COVRPT	 ; @TEST
	N GL1,GL2,GL3,GL4,VRBOSITY,GL5
	S GL1=$NA(^TMP("%utCOVCOHORTSAVx",$J)) K @GL1
	S GL2=$NA(^TMP("%utCOVCOHORTx",$J)) K @GL2
	S GL3=$NA(^TMP("%utCOVRESULTx",$J)) K @GL3
	S GL4=$NA(^TMP("%utCOVREPORTx",$J)) K @GL4
	S GL5=$NA(^TMP("%ut1-covrpt",$J)) K @GL5
	D SETGLOBS(GL1,GL2)
	S VRBOSITY=1
	D COVRPT^%ut1(GL1,GL2,GL3,VRBOSITY)
	D CHKEQ^%ut("COVERAGE PERCENTAGE: 42.11",$G(@GL5@(5)),"Verbosity 1 - not expected percentage value")
	D CHKEQ^%ut("42.11",$G(@GL5@(9)),"Verbosity 1 - not expected value for line 9")
	D CHKTF^%ut('$D(@GL5@(10)),"Verbosity 1 - unexpected data in 10th line")
	;
	S VRBOSITY=2
	D COVRPT^%ut1(GL1,GL2,GL3,VRBOSITY)
	D CHKEQ^%ut("    ACTLINES        0.00",$G(@GL5@(10)),"Verbosity 2 - not expected value for 10th line")
	D CHKEQ^%ut("    CHEKTEST        80.00",$G(@GL5@(11)),"Verbosity 2 - not expected value for 11th line")
	D CHKTF^%ut('$D(@GL5@(12)),"Verbosity 2 - unexpected data for 12th line")
	;
	S VRBOSITY=3
	D COVRPT^%ut1(GL1,GL2,GL3,VRBOSITY)
	D CHKEQ^%ut("    ACTLINES        0.00",$G(@GL5@(10)),"Verbosity 3 - unexpected value for line 10")
	D CHKEQ^%ut("ACTLINES+9:  QUIT CNT",$G(@GL5@(19)),"Verbosity 3 - unexpected value for line 19")
	D CHKEQ^%ut("    CHEKTEST        80.00",$G(@GL5@(20)),"Verbosity 3 - unexpected value for line 20")
	D CHKEQ^%ut("CHEKTEST+39:  . Q",$G(@GL5@(22)),"Verbosity 3 - unexpected value for line 22")
	D CHKTF^%ut('$D(@GL5@(23)),"Verbosity 3 - unexpected line 23")
	;
	K @GL1,@GL2,@GL3,@GL4,@GL5
	Q
	;
COVRPTLS	; @TEST - coverage report returning text in global
	N GL1,GL2,GL3,GL4,VRBOSITY
	S GL1=$NA(^TMP("%utCOVCOHORTSAVx",$J)) K @GL1
	S GL2=$NA(^TMP("%utCOVCOHORTx",$J)) K @GL2
	S GL3=$NA(^TMP("%utCOVRESULTx",$J)) K @GL3
	S GL4=$NA(^TMP("%utCOVREPORTx",$J)) K @GL4
	D SETGLOBS(GL1,GL2)
	S VRBOSITY=1
	D COVRPTLS^%ut1(GL1,GL2,GL3,VRBOSITY,GL4)
	D CHKEQ^%ut("COVERAGE PERCENTAGE: 42.11",$G(@GL4@(5)),"Verbosity 1 - not expected percentage value")
	D CHKEQ^%ut("42.11",$G(@GL4@(9)),"Verbosity 1 - not expected value for line 9")
	D CHKTF^%ut('$D(@GL4@(10)),"Verbosity 1 - unexpected data in 10th line")
	K @GL4
	;
	S VRBOSITY=2
	D COVRPTLS^%ut1(GL1,GL2,GL3,VRBOSITY,GL4)
	D CHKEQ^%ut("    ACTLINES        0.00",$G(@GL4@(10)),"Verbosity 2 - not expected value for 10th line")
	D CHKEQ^%ut("    CHEKTEST        80.00",$G(@GL4@(11)),"Verbosity 2 - not expected value for 11th line")
	D CHKTF^%ut('$D(@GL4@(12)),"Verbosity 2 - unexpected data for 12th line")
	K @GL4
	;
	S VRBOSITY=3
	D COVRPTLS^%ut1(GL1,GL2,GL3,VRBOSITY,GL4)
	D CHKEQ^%ut("    ACTLINES        0.00",$G(@GL4@(10)),"Verbosity 3 - unexpected value for line 10")
	D CHKEQ^%ut("ACTLINES+9:  QUIT CNT",$G(@GL4@(19)),"Verbosity 3 - unexpected value for line 19")
	D CHKEQ^%ut("    CHEKTEST        80.00",$G(@GL4@(20)),"Verbosity 3 - unexpected value for line 20")
	D CHKEQ^%ut("CHEKTEST+39:  . Q",$G(@GL4@(22)),"Verbosity 3 - unexpected value for line 22")
	D CHKTF^%ut('$D(@GL4@(23)),"Verbosity 3 - unexpected line 23")
	;
	K @GL1,@GL2,@GL3,@GL4
	Q
	;
TRIMDATA	; @TEST - TRIMDATA in %utcover
	N GL1,XCLUD
	S GL1=$NA(^TMP("%uttcovr-trimdata",$J)) K @GL1
	S @GL1@("GOOD",1)="1"
	S @GL1@("BAD",1)="1"
	S XCLUD("BAD")=""
	D TRIMDATA^%utcover(.XCLUD,GL1)
	D CHKTF^%ut($D(@GL1@("GOOD")),"GOOD ENTRY WAS REMOVED")
	D CHKTF^%ut('$D(@GL1@("BAD")),"ENTRY WAS NOT TRIMMED")
	K @GL1,XCLUD
	Q
	;
LIST	; @TEST - LIST in %utcover
	N GL1,GLT S GL1=$NA(^TMP("%uttcovr-list",$J)),GLT=$NA(^TMP("%uttcovr-text",$J))
	S @GL1@("%ut1")="89/160"
	S @GL1@("%ut1","%ut1")="2/2"
	S @GL1@("%ut1","ACTLINES")="0/8"
	S @GL1@("%ut1","ACTLINES",2)=" N CNT S CNT=0"
	S @GL1@("%ut1","ACTLINES",3)=" N REF S REF=GL"
	S @GL1@("%ut1","ACTLINES",4)=" N GLQL S GLQL=$QL(GL)"
	S @GL1@("%ut1","ACTLINES",5)=" F  S REF=$Q(@REF) Q:REF=""""  Q:(GL'=$NA(@REF,GLQL))  D"
	S @GL1@("%ut1","ACTLINES",6)=" . N REFQL S REFQL=$QL(REF)"
	S @GL1@("%ut1","ACTLINES",7)=" . N LASTSUB S LASTSUB=$QS(REF,REFQL)"
	S @GL1@("%ut1","ACTLINES",8)=" . I LASTSUB?1.N S CNT=CNT+1"
	S @GL1@("%ut1","ACTLINES",9)=" QUIT CNT"
	S @GL1@("%ut1","CHECKTAG")="11/11"
	S @GL1@("%ut1","CHEKTEST")="10/10"
	N XCLUD S XCLUD("%utt1")=""
	D LIST^%utcover(.XCLUD,1,GLT,GL1)
	D CHKEQ^%ut("Routine %ut1   89 out of 160 lines covered  (55%)",$G(@GLT@(3)),"Verbosity 1 - Unexpected text for line 3")
	D CHKEQ^%ut("Overall Analysis 89 out of 160 lines covered (55% coverage)",$G(@GLT@(6)),"Verbosity 1 - unexpected text for line 6")
	D CHKTF^%ut('$D(@GLT@(7)),"Verbosity 1 - Unexpected line 7 present")
	K @GLT
	;
	D LIST^%utcover(.XCLUD,2,GLT,GL1)
	D CHKEQ^%ut("  - Summary",$G(@GLT@(4)),"Verbosity 2 - unexpected text at line 4")
	D CHKEQ^%ut(" Tag ACTLINES^%ut1   0 out of 8 lines covered",$G(@GLT@(6)),"Verbosity 2 - unexpected text at line 6")
	D CHKEQ^%ut(" Tag CHEKTEST^%ut1   10 out of 10 lines covered",$G(@GLT@(8)),"Verbosity 2 - unexpected text at line 8")
	D CHKTF^%ut($D(@GLT@(14)),"Verbosity 2 - expected line at line 14")
	D CHKTF^%ut('$D(@GLT@(15)),"Verbosity 2 - unexpected line at line 15")
	K @GLT
	;
	D LIST^%utcover(.XCLUD,3,GLT,GL1)
	D CHKEQ^%ut(" Tag %ut1^%ut1   2 out of 2 lines covered",$G(@GLT@(5)),"Verbosity 3 - Incorrect text at line 5")
	D CHKEQ^%ut("     ACTLINES+9   QUIT CNT",$G(@GLT@(15)),"Verbosity 3 - incorrect line 15")
	D CHKTF^%ut($D(@GLT@(31)),"Verbosity 3 - expected data in line 31")
	D CHKTF^%ut('$D(@GLT@(32)),"Verbosity 3 - did not expect a line 32")
	;
	K @GL1,@GLT
	Q
	;
SETGLOBS(GL1,GL2)	;
	S @GL1@("%ut1","ACTLINES")="ACTLINES"
	S @GL1@("%ut1","ACTLINES",0)="ACTLINES(GL) ; [Private] $$ ; Count active lines"
	S @GL1@("%ut1","ACTLINES",2)=" N CNT S CNT=0"
	S @GL1@("%ut1","ACTLINES",3)=" N REF S REF=GL"
	S @GL1@("%ut1","ACTLINES",4)=" N GLQL S GLQL=$QL(GL)"
	S @GL1@("%ut1","ACTLINES",5)=" F  S REF=$Q(@REF) Q:REF=""""  Q:(GL'=$NA(@REF,GLQL))  D"
	S @GL1@("%ut1","ACTLINES",6)=" . N REFQL S REFQL=$QL(REF)"
	S @GL1@("%ut1","ACTLINES",7)=" . N LASTSUB S LASTSUB=$QS(REF,REFQL)"
	S @GL1@("%ut1","ACTLINES",8)=" . I LASTSUB?1.N S CNT=CNT+1"
	S @GL1@("%ut1","ACTLINES",9)=" QUIT CNT"
	S @GL1@("%ut1","CHEKTEST")="CHEKTEST"
	S @GL1@("%ut1","CHEKTEST",0)="CHEKTEST(%utROU,%ut,%utUETRY) ; Collect Test list."
	S @GL1@("%ut1","CHEKTEST",13)=" N I,LIST"
	S @GL1@("%ut1","CHEKTEST",14)=" S I=$L($T(@(U_%utROU))) I I<0 Q ""-1^Invalid Routine Name"""
	S @GL1@("%ut1","CHEKTEST",31)=" D NEWSTYLE(.LIST,%utROU)"
	S @GL1@("%ut1","CHEKTEST",32)=" F I=1:1:LIST S %ut(""ENTN"")=%ut(""ENTN"")+1,%utUETRY(%ut(""ENTN""))=$P(LIST(I),U),%utUETRY(%ut(""ENTN""),""NAME"")=$P(LIST(I),U,2,99)"
	S @GL1@("%ut1","CHEKTEST",37)=" N %utUI F %utUI=1:1 S %ut(""ELIN"")=$T(@(""XTENT+""_%utUI_""^""_%utROU)) Q:$P(%ut(""ELIN""),"";"",3)=""""  D"
	S @GL1@("%ut1","CHEKTEST",38)=" . S %ut(""ENTN"")=%ut(""ENTN"")+1,%utUETRY(%ut(""ENTN""))=$P(%ut(""ELIN""),"";"",3),%utUETRY(%ut(""ENTN""),""NAME"")=$P(%ut(""ELIN""),"";"",4)"
	S @GL1@("%ut1","CHEKTEST",39)=" . Q"
	S @GL1@("%ut1","CHEKTEST",41)=" QUIT"
	S @GL1@("%ut1","CHEKTEST",9)=" S %ut(""ENTN"")=0 ; Number of test, sub to %utUETRY."
	S @GL2@("%ut1","ACTLINES")="ACTLINES"
	S @GL2@("%ut1","ACTLINES",0)="ACTLINES(GL) ; [Private] $$ ; Count active lines"
	S @GL2@("%ut1","ACTLINES",2)=" N CNT S CNT=0"
	S @GL2@("%ut1","ACTLINES",3)=" N REF S REF=GL"
	S @GL2@("%ut1","ACTLINES",4)=" N GLQL S GLQL=$QL(GL)"
	S @GL2@("%ut1","ACTLINES",5)=" F  S REF=$Q(@REF) Q:REF=""""  Q:(GL'=$NA(@REF,GLQL))  D"
	S @GL2@("%ut1","ACTLINES",6)=" . N REFQL S REFQL=$QL(REF)"
	S @GL2@("%ut1","ACTLINES",7)=" . N LASTSUB S LASTSUB=$QS(REF,REFQL)"
	S @GL2@("%ut1","ACTLINES",8)=" . I LASTSUB?1.N S CNT=CNT+1"
	S @GL2@("%ut1","ACTLINES",9)=" QUIT CNT"
	S @GL2@("%ut1","CHEKTEST")="CHEKTEST"
	S @GL2@("%ut1","CHEKTEST",38)=" . S %ut(""ENTN"")=%ut(""ENTN"")+1,%utUETRY(%ut(""ENTN""))=$P(%ut(""ELIN""),"";"",3),%utUETRY(%ut(""ENTN""),""NAME"")=$P(%ut(""ELIN""),"";"",4)"
	S @GL2@("%ut1","CHEKTEST",39)=" . Q"
	Q
	;
