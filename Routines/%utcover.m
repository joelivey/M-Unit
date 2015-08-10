%utcover	;JLI - generic coverage and unit test runner ;08/07/15  14:35
	;;0.2;MASH UTILITIES;;
	D EN^%ut("%uttcovr") ; unit tests
	Q
	;
MULTAPIS(TESTROUS)	; RUN TESTS FOR SPECIFIED ROUTINES AND ENTRY POINTS
	; can be run from %ut using D MULTAPIS^%ut(.TESTROUS)
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
	K ^TMP("%utcover",$J,"TESTROUS")
	M ^TMP("%utcover",$J,"TESTROUS")=TESTROUS
	D COVENTRY
	K ^TMP("%utcover",$J,"TESTROUS")
	Q
	;
COVENTRY	; setup of COVERAGE NEWs most variables, so TESTROUS passed by global
	;
	N I,ROU,VAL,VALS,UTDATA,TESTS,TESTROUS
	M TESTROUS=^TMP("%utcover",$J,"TESTROUS")
	S ROU="" F  S ROU=$O(TESTROUS(ROU)) Q:ROU=""  D
	. I ROU'=+ROU S TESTS(ROU)=""
	. F I=1:1 S VAL=$P(TESTROUS(ROU),",",I) Q:VAL=""  S TESTS(VAL)=""
	. Q
	S ROU="" F  S ROU=$O(TESTS(ROU)) Q:ROU=""  D
	. W !!,"------------------- RUNNING ",ROU," -------------------"
	. I ROU[U D @ROU
	. I ROU'[U D @("EN^%ut("""_ROU_""")")
	. D GETUTVAL^%ut(.UTDATA)
	. Q
	I $D(UTDATA) D LSTUTVAL^%ut(.UTDATA)
	Q
	;
COVERAGE(ROUNMSP,TESTROUS,XCLDROUS,RESLTLVL)	; run coverage analysis for multiple routines and entry points
	; can be run from %ut using D COVERAGE^%ut(ROUNMSP,.TESTROUS,.XCLDROUS,RESLTLVL)
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
	I (RESLTLVL<1) S RESLTLVL=1
	I (RESLTLVL>3) S RESLTLVL=3
	M ^TMP("%utcover",$J,"TESTROUS")=TESTROUS ;
	D COV^%ut1(ROUNMSP,"D COVENTRY^%utcover",-1)
	K ^TMP("%utcover",$J,"TESTROUS")
	S ROU="" F  S ROU=$O(XCLDROUS(ROU)) Q:ROU=""  D
	. I ROU'=+ROU S XCLUDE(ROU)=""
	. F I=1:1 S VAL=$P(XCLDROUS(ROU),",",I) Q:VAL=""  S XCLUDE(VAL)=""
	. Q
	N TEXTGLOB S TEXTGLOB=$NA(^TMP("%utcover-text",$J)) K @TEXTGLOB
	D LIST(.XCLUDE,RESLTLVL,TEXTGLOB)
	F I=1:1 Q:'$D(@TEXTGLOB@(I))  W !,@TEXTGLOB@(I)
	K @TEXTGLOB
	Q
	;
LIST(XCLDROUS,TYPE,TEXTGLOB,GLOB,LINNUM)	;
	; ZEXCEPT: TYPE1  - NEWed and set below for recursion
	; input - ROULIST - a comma separated list of routine names that will
	;       be used to identify desired routines.  Any name
	;       that begins with one of the specified values will
	;       be included
	; input - TYPE - value indicating amount of detail desired
	;       3=full with listing of untouched lines
	;       2=moderated with listing by tags
	;       1=summary with listing by routine
	; input - TEXTGLOB - closed global location in which text is returned
	; input - GLOB - used for unit tests - specifies global to work with
	;                so that coverage data is not impacted
	;
	N CURRCOV,CURRLIN,LINCOV,LINE,LINTOT,ROULIST,ROUNAME,TAG,TOTCOV,TOTLIN,XVAL
	;
	I '$D(LINNUM) S LINNUM=0 ; initialize on first entry
	I '$D(GLOB) N GLOB S GLOB=$NA(^TMP("%utCOVREPORT",$J))
	D TRIMDATA(.XCLDROUS,GLOB) ; remove undesired routines from data
	;
	N JOB,NAME,BASE
	S TOTCOV=0,TOTLIN=0
	; F NAME="%utCOVREPORT","%utCOVRESULT","%utCOVCOHORT","%utCOVCOHORTSAV" D
	I TYPE>1 S ROUNAME="" F  S ROUNAME=$O(@GLOB@(ROUNAME)) Q:ROUNAME=""  S XVAL=^(ROUNAME) D
	. S CURRCOV=$P(XVAL,"/"),CURRLIN=$P(XVAL,"/",2)
	. S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="",LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)=""
	. S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="Routine "_ROUNAME_"   "_CURRCOV_" out of "_CURRLIN_" lines covered"_$S(CURRLIN>0:"  ("_$P((100*CURRCOV)/CURRLIN,".")_"%)",1:"")
	. I TYPE>1 S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="  - "_$S(TYPE=2:"Summary",1:"Detailed Breakdown")
	. S TAG="" F  S TAG=$O(@GLOB@(ROUNAME,TAG)) Q:TAG=""  S XVAL=^(TAG) D
	. . S LINCOV=$P(XVAL,"/"),LINTOT=$P(XVAL,"/",2)
	. . S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)=" Tag "_TAG_"^"_ROUNAME_"   "_LINCOV_" out of "_LINTOT_" lines covered"
	. . I TYPE=2 Q
	. . I LINCOV=LINTOT Q
	. . S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="   the following is a list of the lines **NOT** covered"
	. . S LINE="" F  S LINE=$O(@GLOB@(ROUNAME,TAG,LINE)) Q:LINE=""  D
	. . . I LINE=0 S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="     "_TAG_"  "_@GLOB@(ROUNAME,TAG,LINE) Q
	. . . S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="     "_TAG_"+"_LINE_"  "_@GLOB@(ROUNAME,TAG,LINE)
	. . . Q
	. . Q
	. Q
	; for type=3 generate a summary at bottom after detail
	I TYPE=3 N TYPE1 S TYPE1=2 D LIST(.XCLDROUS,2,TEXTGLOB,GLOB,.LINNUM) K TYPE1
	I TYPE=2,$G(TYPE1) Q  ; CAME IN FROM ABOVE LINE
	; summarize by just routine name
	S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="",LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)=""
	S ROUNAME="" F  S ROUNAME=$O(@GLOB@(ROUNAME)) Q:ROUNAME=""  S XVAL=^(ROUNAME) D
	. S CURRCOV=$P(XVAL,"/"),CURRLIN=$P(XVAL,"/",2)
	. S TOTCOV=TOTCOV+CURRCOV,TOTLIN=TOTLIN+CURRLIN
	. S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="Routine "_ROUNAME_"   "_CURRCOV_" out of "_CURRLIN_" lines covered"_$S(CURRLIN>0:"  ("_$P((100*CURRCOV)/CURRLIN,".")_"%)",1:"")
	. Q
	S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="",LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)=""
	S LINNUM=LINNUM+1,@TEXTGLOB@(LINNUM)="Overall Analysis "_TOTCOV_" out of "_TOTLIN_" lines covered"_$S(TOTLIN>0:" ("_$P((100*TOTCOV)/TOTLIN,".")_"% coverage)",1:"")
	Q
	;
TRIMDATA(ROULIST,GLOB)	;
	N ROUNAME
	S ROUNAME="" F  S ROUNAME=$O(ROULIST(ROUNAME)) Q:ROUNAME=""  K @GLOB@(ROUNAME)
	Q
	;
