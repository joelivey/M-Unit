%utt4	; VEN/SMH/JLI - Coverage Test Runner;08/07/15  20:26
	;;0.2;MASH UTILITIES;;;Build 7
XTMUNITW	; VEN/SMH - Coverage Test Runner;2014-04-17  3:30 PM
	;;7.3;KERNEL TOOLKIT;;
	;
	; This tests code in XTMUNITV for coverage
	D EN^%ut($T(+0),1) QUIT
	;
MAIN	; @TEST - Test coverage calculations
	Q:$D(^TMP("%uttcovr",$J))  ; already running coverage analysis from %uttcovr
	Q:'(+$SY=47)  ; GT.M ONLY
	D COV^%ut1("%utt3","D EN^%ut(""%utt3"",1)",-1)  ; Only produce output global.
	D CHKEQ^%ut("14/19",^TMP("%utCOVREPORT",$J))
	D CHKEQ^%ut("2/5",^TMP("%utCOVREPORT",$J,"%utt3","INTERNAL"))
	D CHKTF^%ut($D(^TMP("%utCOVREPORT",$J,"%utt3","T2",4)))
	D CHKEQ^%ut("1/1",^TMP("%utCOVREPORT",$J,"%utt3","SETUP"))
	QUIT
