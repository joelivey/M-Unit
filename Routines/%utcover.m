%utcover	;JLI - generic coverage and unit test runner ;07/02/15  09:56
	;;1.0;MASH UTILITIES;;
	;
	Q
	;
TESTONLY(TESTROUS)	; RUN TESTS FOR SPECIFIED ROUTINES
	; input TESTROUS - passed by reference - array of routine names to run tests for
	;               specify those to be called directly by including ^ as part of
	;               TAG^ROUTINE or ^ROUTINE.
	;               ROUTINE names without a ^ will be called as EN^%ut("ROUTINE")
	;               Sometimes to get complete coverage, different entry points may
	;               need to be called (e.g., at top and for VERBOSE), these should each
	;               be included.
	;               If the subscript is a number, it will take the list of comma separated
	;               values as the routines.  If the the subscript is not a number, it will
	;               take it as a routine to be added to the list, then if the value of the
	;               contains a comma separated list of routines, they will be added as well.
	;               Thus a value of
	;                 TESTROUS(1)="A^ROU1,^ROU1,^ROU2,ROU3"
	;               or a value of
	;                 TESTROUS("A^ROU1")="^ROU1,^ROU2,ROU3"
	;               will both result in tests for
	;                 D A^ROU1,^ROU1,^ROU2,EN^%ut("ROU3")
	K ^TMP("%utCOVER",$J,"TESTROUS")
	M ^TMP("%utCOVER",$J,"TESTROUS")=TESTROUS
	;
COVENTRY	; setup of COVERAGE NEWs most variables, so TESTROUS passed by global
	;
	N I,ROU,VAL,VALS,UTDATA,TESTS,TESTROUS
	M TESTROUS=^TMP("%utCOVER",$J,"TESTROUS")
	S ROU="" F  S ROU=$O(TESTROUS(ROU)) Q:ROU=""  D
	. I ROU'=+ROU S TESTS(ROU)=""
	. F I=1:1 S VAL=$P(TESTROUS(ROU),",",I) Q:VAL=""  S TESTS(VAL)=""
	. Q
	S ROU="" F  S ROU=$O(TESTS(ROU)) Q:ROU=""  D
	. W !!,"RUNNING ",ROU
	. I ROU[U D @ROU
	. I ROU'[U D @("EN^%ut("""_ROU_""")")
	. S VALS=$G(^TMP("%ut",$J,"UTVALS")) I VALS="" Q
	. F I=1:1 S VAL=$P(VALS,U,I) Q:VAL=""  S UTDATA(I)=$G(UTDATA(I))+VAL
	. K ^TMP("%ut",$J,"UTVALS")
	. Q
	I $D(UTDATA) D
	. W !!!,"------------ SUMMARY ------------"
	. W !,"Ran ",UTDATA(1)," Routine",$S(UTDATA(1)>1:"s",1:""),", ",UTDATA(2)," Entry Tag",$S(UTDATA(2)>1:"s",1:"")
	. W !,"Checked ",UTDATA(3)," test",$S(UTDATA(3)>1:"s",1:""),", with ",UTDATA(4)," failure",$S(UTDATA(4)'=1:"s",1:"")," and encountered ",UTDATA(5)," error",$S(UTDATA(5)'=1:"s",1:""),"."
	. Q
	K ^TMP("%utCOVER",$J,"TESTROUS")
	Q
	;
COVERAGE(ROUNMSP,TESTROUS,XCLDROUS,RESLTLVL)	; run coverage analysis
	; input ROUNMSP - Namespace for routine(s) to be analyzed
	;                 ROUNAME will result in only the routine ROUNAME being analyzed
	;                 ROUN* will result in all routines beginning with ROUN being analyzed
	; input TESTROUS - passed by reference - see TESTROUS description for JUSTTEST
	; input XCLDROUS - passed by reference - routines passed in a manner similar to TESTROUS,
	;                  but only the routine names, whether as arguments or a comma separated
	;                  list of routines, will be excluded from the analysis of coverage.  These
	;                  would normally be names of routines which are only for unit tests, or
	;                  others which should not be included in the analysis for some reason.
	; input RESLTLVL - This value determines the amount of information to be generated for the
	;                  analysis.  A missing or null value will be considered to be level 1
	;                     1  -  Listing of analysis only for routine overall
	;                     2  -  Listing of analysis for routine overall and for each TAG
	;                     3  -  Full analysis for each tag, and lists out those lines which were
	;                           not executed during the analysis
	;
	N I,ROU,TYPE,VAL,XCLUDE
	S RESLTLVL=$G(RESLTLVL,1)
	I RESLTLVL<1 S RESLTLVL=1
	I RESLTLVL>3 S RESLTLVL=3
	M ^TMP("%utCOVER",$J,"TESTROUS")=TESTROUS ;
	D COV^%ut(ROUNMSP,"D COVENTRY^%utCOVER",-1)
	K ^TMP("%utCOVER",$J,"TESTROUS")
	S ROU="" F  S ROU=$O(XCLDROUS(ROU)) Q:ROU=""  D
	. I ROU'=+ROU S XCLUDE(ROU)=""
	. F I=1:1 S VAL=$P(XCLDROUS(ROU),",",I) Q:VAL=""  S XCLUDE(VAL)=""
	. Q
	D LIST(.XCLUDE,RESLTLVL)
	Q
	;
LIST(XCLDROUS,TYPE)	;
	; ZEXCEPT: TYPE1  - NEWed and set below for recursion
	; input - ROULIST - a comma separated list of routine names that will
	;       be used to identify desired routines.  Any name
	;       that begins with one of the specified values will
	;       be included
	; input - TYPE - value indicating amount of detail desired
	;       1=summary with listing by routine
	;       2=moderate with listing by tags
	;       3=full with listing of untouched lines
	;
	N CURRCOV,CURRLIN,LINCOV,LINE,LINTOT,ROULIST,ROUNAME,TAG,TOTCOV,TOTLIN,XVAL
	;
	D TRIMDATA(.XCLDROUS) ; remove undesired routines from data
	;
	N JOB,NAME,BASE,GLOB
	S GLOB=$NA(^TMP("%utCOVREPORT",$J))
	S TOTCOV=0,TOTLIN=0
	; F NAME="%utCOVREPORT","%utCOVRESULT","%utCOVCOHORT","%utCOVCOHORTSAV" D
	I TYPE>1 S ROUNAME="" F  S ROUNAME=$O(@GLOB@(ROUNAME)) Q:ROUNAME=""  S XVAL=^(ROUNAME) D
	. S CURRCOV=$P(XVAL,"/"),CURRLIN=$P(XVAL,"/",2)
	. W !!,"Routine ",ROUNAME,"   ",CURRCOV," out of ",CURRLIN," lines covered"
	. I CURRLIN>0 W "  (",$P((100*CURRCOV)/CURRLIN,"."),"%)"
	. I TYPE=2 W "  - Summary"
	. S TAG="" F  S TAG=$O(@GLOB@(ROUNAME,TAG)) Q:TAG=""  S XVAL=^(TAG) D
	. . S LINCOV=$P(XVAL,"/"),LINTOT=$P(XVAL,"/",2)
	. . W !," Tag ",TAG,"^",ROUNAME,"   ",LINCOV," out of ",LINTOT," lines covered"
	. . I TYPE=2 Q
	. . I LINCOV=LINTOT Q
	. . W !,"   the following is a list of lines NOT covered"
	. . S LINE="" F  S LINE=$O(@GLOB@(ROUNAME,TAG,LINE)) Q:LINE=""  D
	. . . I LINE=0 W !,"   ",TAG,"  ",@GLOB@(ROUNAME,TAG,LINE) Q
	. . . W !,"   ",TAG,"+",LINE,"  ",@GLOB@(ROUNAME,TAG,LINE)
	. . . Q
	. . Q
	. Q
	; for type=3 generate a summary at bottom after detail
	I TYPE=3 N TYPE1 S TYPE1=2 D LIST(.XCLDROUS,2) K TYPE1
	I TYPE=2,$G(TYPE1) Q  ; CAME IN FROM ABOVE LINE
	; summarize by just routine name
	W !!
	S ROUNAME="" F  S ROUNAME=$O(@GLOB@(ROUNAME)) Q:ROUNAME=""  S XVAL=^(ROUNAME) D
	. S CURRCOV=$P(XVAL,"/"),CURRLIN=$P(XVAL,"/",2)
	. S TOTCOV=TOTCOV+CURRCOV,TOTLIN=TOTLIN+CURRLIN
	. W !,"Routine ",ROUNAME,"   ",CURRCOV," out of ",CURRLIN," lines covered"
	. I CURRLIN>0 W "  (",$P((100*CURRCOV)/CURRLIN,"."),"%)"
	W !!,"Overall Analysis ",TOTCOV," out of ",TOTLIN," lines covered"
	I TOTLIN>0 W " (",$P((100*TOTCOV)/TOTLIN,"."),"% coverage)"
	Q
	;
TRIMDATA(ROULIST)	;
	N TYPNAME,ROUNAME
	F TYPNAME="%utCOVREPORT","%utCOVRESULT","%utCOVCOHORT","%utCOVCOHORTSAV" D
	. S ROUNAME="" F  S ROUNAME=$O(ROULIST(ROUNAME)) Q:ROUNAME=""  K ^TMP(TYPNAME,$J,ROUNAME)
	. Q
	Q
	;
