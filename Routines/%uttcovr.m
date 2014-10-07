%uttcovr	;JLI/JIVEYSOFT - runs coverage tests on %ut and %ut1 routines via unit tests ;2014-09-10  5:19 PM
	;;0.1;MASH UTILITIES;
	;
	I '(+$SY=47) W !,"This coverage analysis is currently only available in GT.M" Q  ; GT.M only!
	;
	; if SHOWALL is true (1) all coverage globals data are listed
	; if SHOWALL is false (0), only the %utCOVREPORT global is listed
	I '$D(SHOWALL) N SHOWALL S SHOWALL=0
	; set global node so %utt4 doesn't run its own analysis
	S ^TMP("%uttcovr",$J)=1
	; start analysis of %ut - it calls entry below
	D COV^%ut1("%ut","D TESTCOVR^%ut",3)
	D LIST("%ut") ; output results of analysis
	; start analysis of %ut1
	D COV^%ut1("%ut1","D TESTCOVR^%ut1",3)
	D LIST("%ut1")
	K ^TMP("%uttcovr",$J)
	Q
	;
SHOWALL	; Entry to get all coverage globals listed
	N SHOWALL
	S SHOWALL=1
	D ^%uttcovr
	Q
	;
ENTRY	;
	D ^%utt1 ; verbose
	D EN^%ut("%utt1") ; non-verbose
	; run tests from top of %utt6, runs both command line and gui analyses
	D ^%utt6 ; non-verbose
	D VERBOSE^%utt6 ; verbose
	Q
	;
LIST(ROU)	;
	; ZEXCEPT: SHOWALL - NEWed and set in SHOWALL or entering at %uttcovr
	N JOB,NAME,BASE,GLOB
	S JOB=$J
	W !!!,ROU_" COVERAGE ANALYSIS"
	F NAME="%utCOVREPORT","%utCOVRESULT","%utCOVCOHORT","%utCOVCOHORTSAV" D
	. I 'SHOWALL,NAME'="%utCOVREPORT" Q
	. W !!!,NAME," GLOBAL DATA",!
	. S BASE="^TMP("""_NAME_""","_JOB,GLOB=BASE_")"
	. I $D(GLOB)#2 W !,GLOB,"=",$G(@GLOB)
	. F  S GLOB=$Q(@GLOB) Q:GLOB'[BASE  I $D(GLOB)#2 W !,GLOB,"=",@GLOB
	. Q
	Q
