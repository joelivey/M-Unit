%ut1	;VEN/SMH/JLI - CONTINUATION OF M-UNIT PROCESSING ;08/10/15  14:32
	;;0.2;MASH UTILITIES;;;Build 7
	;
	; Submitted to OSEHRA 08/10/2015 by Joel L. Ivey
	; Original routine authored by Joel L. Ivey as XTMUNIT1 while working for U.S. Department of Veterans Affairs 2003-2012
	; Includes addition of original COV entry and code related coverage analysis as well as other substantial additions authored by Sam Habiel 07/2013?04/2014
	; Additions and modifications made by Joel L. Ivey 05/2014-08/2015
	;
	D ^%utt6 ; runs unit tests from several perspectives
	Q
	;
	;following is original header from XTMUNIT1 in unreleased patch XT*7.3*81 VA code
	;XTMUNIT1    ;JLI/FO-OAK-CONTINUATION OF UNIT TEST ROUTINE ;2014-04-17  5:26 PM
	;;7.3;TOOLKIT;**81**;APR 25 1995;Build 24
	;
	;
	; Original by Dr. Joel Ivey
	; Major contributions by Dr. Sam Habiel
	;
	; Changes:
	; 130726 SMH - Moved test collection logic from %utUNIT to here (multiple places)
	; 131218 SMH - dependence on XLFSTR removed
	; 131218 SMH - CHEKTEST refactored to use $TEXT instead of ^%ZOSF("LOAD")
	; 131218 SMH - CATCHERR now nulls out $ZS if on GT.M
	;
	; ------- COMMENTS moved from %ut due to space requirements
	;
	; 100622 JLI - corrected typo in comments where %utINPT was listed as %utINP
	; 100622 JLI - removed a comment which indicated data could potentially be returned from the called routine
	;              in the %utINPT array.
	; 100622 JLI - added code to handle STARTUP and SHUTDOWN from GUI app
	; 110719 JLI - modified separators in GUI handling from ^ to ~~^~~
	;              in the variable XTGUISEP if using a newer version of the
	;              GUI app (otherwise, it is simply set to ^) since results
	;              with a series of ^ embedded disturbed the output reported
	; 130726 SMH - Fixed SETUP and TEARDOWN so that they run before/after each
	;              test rather than once. General refactoring.
	; 130726 SMH - SETUT initialized IO in case it's not there to $P. Inits vars
	;              using DT^DICRW.
	; 131217 SMH - Change call in SETUP to S U="^" instead of DT^DICRW
	; 131218 SMH - Any checks to $ZE will also check $ZS for GT.M.
	; 131218 SMH - Remove calls to %ZISUTL to manage devices to prevent dependence on VISTA.
	;              Use %utNIT("DEV","OLD") for old devices
	; 140109 SMH - Add parameter %utBREAK - Break upon error
	; 1402   SMH - Break will cause the break to happen even on failed tests.
	; 140401 SMH - Added Succeed entry point for take it into your hands tester.
	; 140401 SMH - Reformatted the output of M-Unit so that the test's name
	;              will print BEFORE the execution of the test. This has been
	;              really confusing for beginning users of M-Unit, so this was
	;              necessary.
	; 140401 SMH - OK message gets printed at the end of --- as [OK].
	; 140401 SMH - FAIL message now prints. Previously, OK failed to be printed.
	;              Unfortunately, that's rather passive aggressive. Now it
	;              explicitly says that a test failed.
	; 140503 SMH - Fixed IO issues all over the routine. Much simpler now.
	; 140731 JLI - Combined routine changes between JLI and SMH
	;              Moved routines from %utNIT and %utNIT1 to %ut and %ut1
	;              Updated unit test routines (%utt1 to %utt6)
	;              Created M-UNIT TEST GROUP file at 17.9001 based on the 17.9001 file
	; 141030 JLI - Removed tag TESTCOVR and code under it, not necessary
	;              since %uttcovr can handle all of the calling needed
	;              Added call to run routine %utt6 if run from the top,
	;              since this will run the full range of unit tests
	;              Modified STARTUP and SHUTDOWN commands to handle in
	;              each routine where they are available, since only
	;              running one STARTUP and SHUTDOWN (the first seen by
	;              the program) restricted their use in suites of multiple
	;              tests.
	; 150101 JLI - Added COV entry to %ut (in addition to current in %ut1) so it is easier
	;              to remember how to use it.
	; 150621 JLI - Added a global location to pick up summary data for a unit test call, so
	;              programs running multiple calls can generate a summary if desired.
	;
	;
CHEKTEST(%utROU,%ut,%utUETRY)	; Collect Test list.
	; %utROU - input - Name of routine to check for tags with @TEST attribute
	; %ut - input/output - passed by reference
	; %utUETRY - input/output - passed by reference
	;
	; Test list collected in two ways:
	; - @TEST on labellines
	; - Offsets of XTENT
	;
	S %ut("ENTN")=0 ; Number of test, sub to %utUETRY.
	;
	; This stanza and everything below is for collecting @TEST.
	; VEN/SMH - block refactored to use $TEXT instead of ^%ZOSF("LOAD")
	N I,LIST
	S I=$L($T(@(U_%utROU))) I I<0 Q "-1^Invalid Routine Name"
	D NEWSTYLE(.LIST,%utROU)
	F I=1:1:LIST S %ut("ENTN")=%ut("ENTN")+1,%utUETRY(%ut("ENTN"))=$P(LIST(I),U),%utUETRY(%ut("ENTN"),"NAME")=$P(LIST(I),U,2,99)
	;
	; This Stanza is to collect XTENT offsets
	N %utUI F %utUI=1:1 S %ut("ELIN")=$T(@("XTENT+"_%utUI_"^"_%utROU)) Q:$P(%ut("ELIN"),";",3)=""  D
	. S %ut("ENTN")=%ut("ENTN")+1,%utUETRY(%ut("ENTN"))=$P(%ut("ELIN"),";",3),%utUETRY(%ut("ENTN"),"NAME")=$P(%ut("ELIN"),";",4)
	. Q
	;
	QUIT
	;
	; VEN/SMH 26JUL2013 - Moved GETTREE here.
GETTREE(%utROU,%utULIST)	;
	; first get any other routines this one references for running subsequently
	; then any that they refer to as well
	; this builds a tree of all routines referred to by any routine including each only once
	N %utUK,%utUI,%utUJ,%utURNAM,%utURLIN
	F %utUK=1:1 Q:'$D(%utROU(%utUK))  D
	. F %utUI=1:1 S %utURLIN=$T(@("XTROU+"_%utUI_"^"_%utROU(%utUK))) S %utURNAM=$P(%utURLIN,";",3) Q:%utURNAM=""  D
	. . F %utUJ=1:1:%utULIST I %utROU(%utUJ)=%utURNAM S %utURNAM="" Q
	. . I %utURNAM'="",$T(@("+1^"_%utURNAM))="" W:'$D(XWBOS) "Referenced routine ",%utURNAM," not found.",! Q
	. . S:%utURNAM'="" %utULIST=%utULIST+1,%utROU(%utULIST)=%utURNAM
	QUIT
	;
NEWSTYLE(LIST,ROUNAME)	; JLI 140726 identify and return list of newstyle tags or entries for this routine
	; LIST - input, passed by reference - returns containing array with list of tags identified as tests
	;                   LIST indicates number of tags identified, LIST(n)=tag^test_info where tag is entry point for test
	; ROUNAME - input - routine name in which tests should be identified
	;
	N I,VALUE,LINE
	K LIST S LIST=0
	; search routine by line for a tag and @TEST declaration
	F I=1:1 S LINE=$T(@("+"_I_"^"_ROUNAME)) Q:LINE=""  S VALUE=$$CHECKTAG(LINE) I VALUE'="" S LIST=LIST+1,LIST(LIST)=VALUE
	Q
	;
CHECKTAG(LINE)	; JLI 140726 check line to determine @test TAG
	; LINE - input - Line of code to be checked
	; returns null line if not @TEST line, otherwise TAG^NOTE
	N TAG,NOTE,CHAR
	I $E(LINE)=" " Q "" ; test entry must have a tag
	I $$UP(LINE)'["@TEST" Q "" ; must have @TEST declaration
	I $P($$UP(LINE),"@TEST")["(" Q "" ; can't have an argument
	S TAG=$P(LINE," "),LINE=$P(LINE," ",2,400),NOTE=$P($$UP(LINE),"@TEST"),LINE=$E(LINE,$L(NOTE)+5+1,$L(LINE))
	F  Q:NOTE=""  S CHAR=$E(NOTE),NOTE=$E(NOTE,2,$L(NOTE)) I " ;"'[CHAR Q  ;
	I $L(NOTE)'=0 Q "" ; @TEST must be first text on line
	F  Q:$E(LINE)'=" "  S LINE=$E(LINE,2,$L(LINE)) ; remove leading spaces from test info
	S TAG=TAG_U_LINE
	Q TAG
	;
CHKTF(XTSTVAL,XTERMSG)	; Entry point for checking True or False values
	; ZEXCEPT: %utERRL,%utGUI - CREATED IN SETUP, KILLED IN END
	; ZEXCEPT: %ut - NEWED IN EN
	; ZEXCEPT: XTGUISEP - newed in GUINEXT
	I '$D(XTSTVAL) D NVLDARG("CHKTF") Q
	I $G(XTERMSG)="" S XTERMSG="no failure message provided"
	S %ut("CHK")=$G(%ut("CHK"))+1
	I '$D(%utGUI) D
	. D SETIO
	. I 'XTSTVAL W !,%ut("ENT")," - " W:%ut("NAME")'="" %ut("NAME")," - " D
	. . W XTERMSG,! S %ut("FAIL")=%ut("FAIL")+1,%utERRL(%ut("FAIL"))=%ut("NAME"),%utERRL(%ut("FAIL"),"MSG")=XTERMSG,%utERRL(%ut("FAIL"),"ENTRY")=%ut("ENT")
	. . I $D(%ut("BREAK")) BREAK  ; Break upon failure
	. . Q
	. I XTSTVAL W "."
	. D RESETIO
	. Q
	I $D(%utGUI),'XTSTVAL S %ut("CNT")=%ut("CNT")+1,@%ut("RSLT")@(%ut("CNT"))=%ut("LOC")_XTGUISEP_"FAILURE"_XTGUISEP_XTERMSG,%ut("FAIL")=%ut("FAIL")+1
	Q
	;
CHKEQ(XTEXPECT,XTACTUAL,XTERMSG)	; Entry point for checking values to see if they are EQUAL
	N FAILMSG
	; ZEXCEPT: %utERRL,%utGUI -CREATED IN SETUP, KILLED IN END
	; ZEXCEPT: %ut  -- NEWED IN EN
	; ZEXCEPT: XTGUISEP - newed in GUINEXT
	I '$D(XTEXPECT)!'$D(XTACTUAL) D NVLDARG("CHKEQ") Q
	S XTACTUAL=$G(XTACTUAL),XTEXPECT=$G(XTEXPECT)
	I $G(XTERMSG)="" S XTERMSG="no failure message provided"
	S %ut("CHK")=%ut("CHK")+1
	I XTEXPECT'=XTACTUAL S FAILMSG="<"_XTEXPECT_"> vs <"_XTACTUAL_"> - "
	I '$D(%utGUI) D
	. D SETIO
	. I XTEXPECT'=XTACTUAL W !,%ut("ENT")," - " W:%ut("NAME")'="" %ut("NAME")," - " W FAILMSG,XTERMSG,! D
	. . S %ut("FAIL")=%ut("FAIL")+1,%utERRL(%ut("FAIL"))=%ut("NAME"),%utERRL(%ut("FAIL"),"MSG")=XTERMSG,%utERRL(%ut("FAIL"),"ENTRY")=%ut("ENT")
	    . . I $D(%ut("BREAK")) BREAK  ; Break upon failure
	. . Q
	. E  W "."
	. D RESETIO
	. Q
	I $D(%utGUI),XTEXPECT'=XTACTUAL S %ut("CNT")=%ut("CNT")+1,@%ut("RSLT")@(%ut("CNT"))=%ut("LOC")_XTGUISEP_"FAILURE"_XTGUISEP_FAILMSG_XTERMSG,%ut("FAIL")=%ut("FAIL")+1
	Q
	;
FAIL(XTERMSG)	; Entry point for generating a failure message
	; ZEXCEPT: %utERRL,%utGUI -CREATED IN SETUP, KILLED IN END
	; ZEXCEPT: %ut  -- NEWED ON ENTRY
	; ZEXCEPT: XTGUISEP - newed in GUINEXT
	I $G(XTERMSG)="" S XTERMSG="no failure message provided"
	S %ut("CHK")=%ut("CHK")+1
	I '$D(%utGUI) D
	. D SETIO
	. W !,%ut("ENT")," - " W:%ut("NAME")'="" %ut("NAME")," - " W XTERMSG,! D
	. . S %ut("FAIL")=%ut("FAIL")+1,%utERRL(%ut("FAIL"))=%ut("NAME"),%utERRL(%ut("FAIL"),"MSG")=XTERMSG,%utERRL(%ut("FAIL"),"ENTRY")=%ut("ENT")
	. . I $D(%ut("BREAK")) BREAK  ; Break upon failure
	. . Q
	. D RESETIO
	. Q
	I $D(%utGUI) S %ut("CNT")=%ut("CNT")+1,@%ut("RSLT")@(%ut("CNT"))=%ut("LOC")_XTGUISEP_"FAILURE"_XTGUISEP_XTERMSG,%ut("FAIL")=%ut("FAIL")+1
	Q
	;
NVLDARG(API)	; generate message for invalid arguments to test
	N XTERMSG
	; ZEXCEPT: %ut  -- NEWED ON ENTRY
	; ZEXCEPT: %utERRL,%utGUI -CREATED IN SETUP, KILLED IN END
	; ZEXCEPT: XTGUISEP - newed in GUINEXT
	S XTERMSG="NO VALUES INPUT TO "_API_"^%ut - no evaluation possible"
	I '$D(%utGUI) D
	. D SETIO
	. W !,%ut("ENT")," - " W:%ut("NAME")'="" %ut("NAME")," - " W XTERMSG,! D
	. . S %ut("FAIL")=%ut("FAIL")+1,%utERRL(%ut("FAIL"))=%ut("NAME"),%utERRL(%ut("FAIL"),"MSG")=XTERMSG,%utERRL(%ut("FAIL"),"ENTRY")=%ut("ENT")
	. . Q
	. D RESETIO
	. Q
	I $D(%utGUI) S %ut("CNT")=%ut("CNT")+1,@%ut("RSLT")@(%ut("CNT"))=%ut("LOC")_XTGUISEP_"FAILURE"_XTGUISEP_XTERMSG,%ut("FAIL")=%ut("FAIL")+1
	Q
	;
SETIO	; Set M-Unit Device to write the results to...
	; ZEXCEPT: %ut  -- NEWED ON ENTRY
	I $IO'=%ut("IO") S (IO(0),%ut("DEV","OLD"))=$IO USE %ut("IO") SET IO=$IO
	QUIT
	;
RESETIO	; Reset $IO back to the original device if we changed it.
	; ZEXCEPT: %ut  -- NEWED ON ENTRY
	I $D(%ut("DEV","OLD")) S IO(0)=%ut("IO") U %ut("DEV","OLD") S IO=$IO K %ut("DEV","OLD")
	QUIT
	;
	; VEN/SMH 17DEC2013 - Remove dependence on VISTA - Uppercase here instead of XLFSTR.
UP(X)	;
	Q $TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	;
COV(NMSP,COVCODE,VERBOSITY)	; VEN/SMH - PUBLIC ENTRY POINT; Coverage calculations
	; NMSP: Namespace of the routines to analyze. End with * to include all routines.
	;       Not using * will only include the routine with NMSP name.
	;       e.g. PSOM* will include all routines starting with PSOM
	;            PSOM will only include PSOM.
	; COVCODE: Mumps code to run over which coverage will be calculated. Typically Unit Tests.
	; VERBOSITY (optional): Scalar from -1 to 3.
	;    - -1 = Global output in ^TMP("%utCOVREPORT",$J)
	;    - 0 = Print only total coverage
	;    - 1 = Break down by routine
	;    - 2 = Break down by routine and tag
	;    - 3 = Break down by routine and tag, and print lines that didn't execute for each tag.
	;
	; ZEXCEPT: %utcovxx - SET and KILLED in this code at top level
	Q:'(+$SY=47)  ; GT.M only!
	;
	; ZEXCEPT: CTRAP - not really a variable
	S VERBOSITY=+$G(VERBOSITY) ; Get 0 if not passed.
	N %ZR ; GT.M specific
	D SILENT^%RSEL(NMSP,"SRC") ; GT.M specific. On Cache use $O(^$R(RTN)).
	;
	N RN S RN=""
	W !,"Loading routines to test coverage...",!
	F  S RN=$O(%ZR(RN)) Q:RN=""  W RN," " D
	. N L2 S L2=$T(+2^@RN)
	. S L2=$TR(L2,$C(9,32)) ; Translate spaces and tabs out
	. I $E(L2,1,2)'=";;" K %ZR(RN)  ; Not a human produced routine
	;
	N RTNS M RTNS=%ZR
	K %ZR
	;
	N GL
	S GL=$NA(^TMP("%utCOVCOHORT",$J))
	I '$D(^TMP("%utcovrunning",$J)) K @GL
	D RTNANAL(.RTNS,GL)
	I '$D(^TMP("%utcovrunning",$J)) D
	. K ^TMP("%utCOVCOHORTSAV",$J)
	. M ^TMP("%utCOVCOHORTSAV",$J)=^TMP("%utCOVCOHORT",$J)
	. K ^TMP("%utCOVRESULT",$J)
	. S ^TMP("%utcovrunning",$J)=1,%utcovxx=1
	. VIEW "TRACE":1:$NA(^TMP("%utCOVRESULT",$J))  ; GT.M START PROFILING
	. Q
	DO  ; Run the code, but keep our variables to ourselves.
	. NEW $ETRAP,$ESTACK
	. SET $ETRAP="Q:($ES&$Q) -9 Q:$ES  W ""CTRL-C ENTERED"""
	. USE $PRINCIPAL:(CTRAP=$C(3))
	. NEW (DUZ,IO,COVCODE,U,DILOCKTM,DISYS,DT,DTIME,IOBS,IOF,IOM,ION,IOS,IOSL,IOST,IOT,IOXY)
	. XECUTE COVCODE
	. Q
	; GT.M STOP PROFILING if this is the original level that started it
	I $D(^TMP("%utcovrunning",$J)),$D(%utcovxx) VIEW "TRACE":0:$NA(^TMP("%utCOVRESULT",$J)) K %utcovxx,^TMP("%utcovrunning",$J)
	;
	I '$D(^TMP("%utcovrunning",$J)) D
	. D COVCOV($NA(^TMP("%utCOVCOHORT",$J)),$NA(^TMP("%utCOVRESULT",$J))) ; Venn diagram matching between globals
	. ; Report
	. I VERBOSITY=-1 D
	. . K ^TMP("%utCOVREPORT",$J)
	. . D COVRPTGL($NA(^TMP("%utCOVCOHORTSAV",$J)),$NA(^TMP("%utCOVCOHORT",$J)),$NA(^TMP("%utCOVRESULT",$J)),$NA(^TMP("%utCOVREPORT",$J)))
	. . Q
	. E  D COVRPT($NA(^TMP("%utCOVCOHORTSAV",$J)),$NA(^TMP("%utCOVCOHORT",$J)),$NA(^TMP("%utCOVRESULT",$J)),VERBOSITY)
	. Q
	QUIT
	;
RTNANAL(RTNS,GL)	; [Private] - Routine Analysis
	; Create a global similar to the trace global produced by GT.M in GL
	; Only non-comment lines are stored.
	; A tag is always stored. Tag,0 is stored only if there is code on the tag line (format list or actual code).
	; tags by themselves don't count toward the total.
	;
	N RTN S RTN=""
	F  S RTN=$O(RTNS(RTN)) Q:RTN=""  D                       ; for each routine
	. N TAG
	. S TAG=RTN                                              ; start the tags at the first
	. N I,LN F I=2:1 S LN=$T(@TAG+I^@RTN) Q:LN=""  D         ; for each line, starting with the 3rd line (2 off the first tag)
	. . I $E(LN)?1A D  QUIT                                  ; formal line
	. . . N T                                                ; Terminator
	. . . N J F J=1:1:$L(LN) S T=$E(LN,J) Q:T'?1AN           ; Loop to...
	. . . S TAG=$E(LN,1,J-1)                                 ; Get tag
	. . . S @GL@(RTN,TAG)=TAG                                ; store line
	. . . ;I T="(" S @GL@(RTN,TAG,0)=LN                      ; formal list
	. . . I T="(" D                                          ; formal list
	. . . . N PCNT,STR,CHR S PCNT=0,STR=$E(LN,J+1,$L(LN))
	. . . . F  S CHR=$E(STR),STR=$E(STR,2,$L(STR)) Q:(PCNT=0)&(CHR=")")  D
	. . . . . I CHR="(" S PCNT=PCNT+1
	. . . . . I CHR=")" S PCNT=PCNT-1
	. . . . . Q
	. . . . S STR=$TR(STR,$C(9,32))
	. . . . I $E(STR)=";" QUIT
	. . . . S @GL@(RTN,TAG,0)=LN
	. . . . Q
	. . . E  D                                               ; No formal list
	. . . . N LNTR S LNTR=$P(LN,TAG,2,999),LNTR=$TR(LNTR,$C(9,32)) ; Get rest of line, Remove spaces and tabs
	. . . . I $E(LNTR)=";" QUIT                              ; Comment
	. . . . S @GL@(RTN,TAG,0)=LN                             ; Otherwise, store for testing
	. . . S I=0                                              ; Start offsets from zero (first one at the for will be 1)
	. . I $C(32,9)[$E(LN) D  QUIT                            ; Regular line
	. . . N LNTR S LNTR=$TR(LN,$C(32,9,46))                     ; Remove all spaces and tabs - JLI 150202 remove periods as well
	. . . I $E(LNTR)=";" QUIT                                ; Comment line -- don't want.
	. . . S @GL@(RTN,TAG,I)=LN                               ; Record line
	QUIT
	;
ACTLINES(GL)	; [Private] $$ ; Count active lines
	;
	N CNT S CNT=0
	N REF S REF=GL
	N GLQL S GLQL=$QL(GL)
	F  S REF=$Q(@REF) Q:REF=""  Q:(GL'=$NA(@REF,GLQL))  D
	. N REFQL S REFQL=$QL(REF)
	. N LASTSUB S LASTSUB=$QS(REF,REFQL)
	. I LASTSUB?1.N S CNT=CNT+1
	QUIT CNT
	;
COVCOV(C,R)	; [Private] - Analyze coverage Cohort vs Result
	N RTN S RTN=""
	F  S RTN=$O(@C@(RTN)) Q:RTN=""  D  ; For each routine in cohort set
	. I '$D(@R@(RTN)) QUIT             ; Not present in result set
	. N TAG S TAG=""
	. F  S TAG=$O(@R@(RTN,TAG)) Q:TAG=""  D  ; For each tag in the routine in the result set
	. . N LN S LN=""
	. . F  S LN=$O(@R@(RTN,TAG,LN)) Q:LN=""  D  ; for each line in the tag in the routine in the result set
	. . . I $D(@C@(RTN,TAG,LN)) K ^(LN)  ; if present in cohort, kill off
	QUIT
	;
COVRPT(C,S,R,V)	; [Private] - Coverage Report
	; C = COHORT    - Global name
	; S = SURVIVORS - Global name
	; R = RESULT    - Global name
	; V = Verbosity - Scalar from -1 to 3
	; JLI 150702 -  modified to be able to do unit tests on setting up the text via COVRPTLS
	N X,I
	S X=$NA(^TMP("%ut1-covrpt",$J)) K @X
	D COVRPTLS(C,S,R,V,X)
	I '$$ISUTEST^%ut() F I=1:1 W:$D(@X@(I)) !,@X@(I) I '$D(@X@(I)) K @X Q
	Q
	;
COVRPTLS(C,S,R,V,X)	;
	;
	N LINNUM S LINNUM=0
	N ORIGLINES S ORIGLINES=$$ACTLINES(C)
	N LEFTLINES S LEFTLINES=$$ACTLINES(S)
	;W !!
	S LINNUM=LINNUM+1,@X@(LINNUM)="",LINNUM=LINNUM+1,@X@(LINNUM)=""
	;W "ORIG: "_ORIGLINES,!
	S LINNUM=LINNUM+1,@X@(LINNUM)="ORIG: "_ORIGLINES
	;W "LEFT: "_LEFTLINES,!
	S LINNUM=LINNUM+1,@X@(LINNUM)="LEFT: "_LEFTLINES
	;W "COVERAGE PERCENTAGE: "_$S(ORIGLINES:$J(ORIGLINES-LEFTLINES/ORIGLINES*100,"",2),1:100.00),!
	S LINNUM=LINNUM+1,@X@(LINNUM)="COVERAGE PERCENTAGE: "_$S(ORIGLINES:$J(ORIGLINES-LEFTLINES/ORIGLINES*100,"",2),1:100.00)
	;W !!
	S LINNUM=LINNUM+1,@X@(LINNUM)="",LINNUM=LINNUM+1,@X@(LINNUM)=""
	;W "BY ROUTINE:",!
	S LINNUM=LINNUM+1,@X@(LINNUM)="BY ROUTINE:"
	I V=0 QUIT  ; No verbosity. Don't print routine detail
	N RTN S RTN=""
	F  S RTN=$O(@C@(RTN)) Q:RTN=""  D
	. N O S O=$$ACTLINES($NA(@C@(RTN)))
	. N L S L=$$ACTLINES($NA(@S@(RTN)))
	. ;W ?3,RTN,?21,$S(O:$J(O-L/O*100,"",2),1:"100.00"),!
	. N XX S XX="  "_RTN_"                    ",XX=$E(XX,1,20)
	. S LINNUM=LINNUM+1,@X@(LINNUM)=XX+$S(O:$J(O-L/O*100,"",2),1:"100.00")
	. I V=1 QUIT  ; Just print the routine coverage for V=1
	. N TAG S TAG=""
	. F  S TAG=$O(@C@(RTN,TAG)) Q:TAG=""  D
	. . N O S O=$$ACTLINES($NA(@C@(RTN,TAG)))
	. . N L S L=$$ACTLINES($NA(@S@(RTN,TAG)))
	. . ;W ?5,TAG,?21,$S(O:$J(O-L/O*100,"",2),1:"100.00"),!
	. . S XX="    "_TAG_"                  ",XX=$E(XX,1,20)
	. . S LINNUM=LINNUM+1,@X@(LINNUM)=XX_$S(O:$J(O-L/O*100,"",2),1:"100.00")
	. . I V=2 QUIT  ; Just print routine/tags coverage for V=2; V=3 print uncovered lines
	. . N LN S LN=""
	. . ;F  S LN=$O(@S@(RTN,TAG,LN)) Q:LN=""  W TAG_"+"_LN_": "_^(LN),!
	. . F  S LN=$O(@S@(RTN,TAG,LN)) Q:LN=""  S LINNUM=LINNUM+1,@X@(LINNUM)=TAG_"+"_LN_": "_^(LN)
	. . Q
	. Q
	QUIT
	;
COVRPTGL(C,S,R,OUT)	; [Private] - Coverage Global for silent invokers
	; C = COHORT    - Global name
	; S = SURVIVORS - Global name
	; R = RESULT    - Global name
	; OUT = OUTPUT  - Global name
	;
	N O S O=$$ACTLINES(C)
	N L S L=$$ACTLINES(S)
	S @OUT=(O-L)_"/"_O
	N RTN,TAG,LN S (RTN,TAG,LN)=""
	F  S RTN=$O(@C@(RTN)) Q:RTN=""  D
	. N O S O=$$ACTLINES($NA(@C@(RTN)))
	. N L S L=$$ACTLINES($NA(@S@(RTN)))
	. S @OUT@(RTN)=(O-L)_"/"_O
	. F  S TAG=$O(@C@(RTN,TAG)) Q:TAG=""  D
	. . N O S O=$$ACTLINES($NA(@C@(RTN,TAG)))
	. . N L S L=$$ACTLINES($NA(@S@(RTN,TAG)))
	. . S @OUT@(RTN,TAG)=(O-L)_"/"_O
	. . F  S LN=$O(@S@(RTN,TAG,LN)) Q:LN=""  S @OUT@(RTN,TAG,LN)=@S@(RTN,TAG,LN)
	QUIT
	;
