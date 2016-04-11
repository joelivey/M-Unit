%utt4	; VEN/SMH/JLI - Coverage Test Runner;04/08/16  20:38
	;;1.4;MASH UTILITIES;;APR 11, 2016;
	; Submitted to OSEHRA Apr 11, 2016 by Joel L. Ivey under the Apache 2 license (http://www.apache.org/licenses/LICENSE-2.0.html)
	; Original routine authored by Sam H. Habiel 07/2013-04/2014
	; Additions and modifications made by Joel L. Ivey 05/2014-08/2015
	;
XTMUNITW	; VEN/SMH - Coverage Test Runner;2014-04-17  3:30 PM
	;;7.3;KERNEL TOOLKIT;;
	;
	; This tests code in XTMUNITV for coverage
	D EN^%ut($T(+0),1) QUIT
	;
MAIN	; @TEST - Test coverage calculations
	Q:$D(^TMP("%uttcovr",$J))  ; already running coverage analysis from %uttcovr
	S ^TMP("%utt4val",$J)=1
	D COV^%ut("%utt3","D EN^%ut(""%utt3"",1)",-1)  ; Only produce output global.
	D CHKEQ^%ut("14/19",^TMP("%utCOVREPORT",$J))
	D CHKEQ^%ut("2/5",^TMP("%utCOVREPORT",$J,"%utt3","INTERNAL"))
	D CHKTF^%ut($D(^TMP("%utCOVREPORT",$J,"%utt3","T2",4)))
	D CHKEQ^%ut("1/1",^TMP("%utCOVREPORT",$J,"%utt3","SETUP"))
	K ^TMP("%utt4val",$J)
	QUIT
