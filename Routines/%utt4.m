%utt4 ; VEN/SMH - Coverage Test Runner;08/23/14  08:33
 ;;0.1;MASH UTILITIES;
XTMUNITW ; VEN/SMH - Coverage Test Runner;2014-04-17  3:30 PM
 ;;7.3;KERNEL TOOLKIT;;
 ;
 ; This tests code in XTMUNITV for coverage
 D EN^%ut($T(+0),1) QUIT
 ;
MAIN ; @TEST - Test coverage calculations
 Q:$D(^TMP("%uttcovr",$J))  ; already running coverage analysis from %uttcovr
 Q:'(+$SY=47)  ; GT.M ONLY
 ;D COV^%ut1("XTMUNITV","D EN^%ut(""XTMUNITV"",1)",-1)  ; Only produce output global.
 D COV^%ut1("%utt3","D EN^%ut(""%utt3"",1)",-1)  ; Only produce output global.
 D CHKEQ^%ut(^TMP("%utCOVREPORT",$J),"15/20")
 ;D CHKEQ^%ut(^TMP("XTMCOVREPORT",$J,"XTMUNITV","INTERNAL"),"3/6")
 D CHKEQ^%ut(^TMP("%utCOVREPORT",$J,"%utt3","INTERNAL"),"3/6")
 ;D CHKTF^%ut($D(^TMP("XTMCOVREPORT",$J,"XTMUNITV","T2",4)))
 D CHKTF^%ut($D(^TMP("%utCOVREPORT",$J,"%utt3","T2",4)))
 ;D CHKEQ^%ut(^TMP("XTMCOVREPORT",$J,"XTMUNITV","SETUP"),"1/1")
 D CHKEQ^%ut(^TMP("%utCOVREPORT",$J,"%utt3","SETUP"),"1/1")
 QUIT
