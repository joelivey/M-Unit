%utt1	; VEN/SMH - Testing routines for M-Unit;08/08/15  16:20
	;;0.2;MASH UTILITIES;;;Build 7
	;
	; THIS ROUTINE IS THE UNIFIED UNIT TESTER FOR ALL OF M-UNIT.
	;
	; Dear Users,
	;
	; I know about about the irony of a test suite for the testing suite,
	; so stop snikering. Aside from that, it's actually going to be hard.
	;
	; Truly yours,
	;
	; Sam H
	;
	D EN^%ut($T(+0),1) ; Run tests here, be verbose.
	QUIT
	;
STARTUP	; M-Unit Start-Up - This runs before anything else.
	; ZEXCEPT: KBANCOUNT - created here, removed in SHUTDOWN
	S ^TMP($J,"%ut","STARTUP")=""
	S KBANCOUNT=1
	QUIT
	;
SHUTDOWN	; M-Unit Shutdown - This runs after everything else is done.
	; ZEXCEPT: KBANCOUNT - created in STARTUP, removed here
	K ^TMP($J,"%ut","STARTUP")
	K KBANCOUNT
	QUIT
	;
	;
	;
SETUP	; This runs before every test.
	; ZEXCEPT: KBANCOUNT - created in STARTUP, removed in SHUTDOWN
	S KBANCOUNT=KBANCOUNT+1
	QUIT
	;
TEARDOWN	; This runs after every test
	; ZEXCEPT: KBANCOUNT - created in STARTUP, removed in SHUTDOWN
	S KBANCOUNT=KBANCOUNT-1
	QUIT
	;
	;
	;
T1	; @TEST - Make sure Start-up Ran
	D CHKTF($D(^TMP($J,"%ut","STARTUP")),"Start-up node on ^TMP must exist")
	QUIT
	;
T2	; @TEST - Make sure Set-up runs
	; ZEXCEPT: KBANCOUNT - created in STARTUP, removed in SHUTDOWN
	D CHKEQ(KBANCOUNT,2,"KBANCount not incremented properly at SETUP")
	QUIT
	;
T3	; @TEST - Make sure Teardown runs
	; ZEXCEPT: KBANCOUNT - created in STARTUP, removed in SHUTDOWN
	D CHKEQ(KBANCOUNT,2,"KBANCount not decremented properly at TEARDOWN")
	QUIT
	;
T4	; Specified in XTMTAG
	; 140731 JLI - note that this will fail when run from the GUI runner, since it calls each tag separately
	; ZEXCEPT: %utETRY - newed and created in EN1^%ut
	; ZEXCEPT: %utGUI      -- CONDITIONALLY DEFINED BY GUINEXT^%ut
	I $G(%utGUI) D CHKEQ(%utETRY,"T4","T4 should be the value for %utETRY in the GUI Runner")
	I '$G(%utGUI) D CHKEQ(%utETRY(4),"T4","T4 should be the collected as the fourth entry in %utETRY")
	QUIT
	;
T5	; ditto
	; ZEXCEPT: %ut - NEWed and created in EN1^%ut
	D CHKTF(0,"This is an intentional failure.")
	D CHKEQ(%ut("FAIL"),1,"By this point, we should have failed one test")
	D FAIL^%ut("Intentionally throwing a failure")
	D CHKEQ(%ut("FAIL"),2,"By this point, we should have failed two tests")
	; S %ut("FAIL")=0 ; Okay... Boy's and Girls... as the developer I can do that.
	QUIT
	;
T6	; ditto
	; ZEXCEPT: %ut - NEWed and created in EN1^%ut
	N TESTCOUNT S TESTCOUNT=%ut("CHK")
	D SUCCEED^%ut
	D SUCCEED^%ut
	D CHKEQ(%ut("CHK"),TESTCOUNT+2,"Succeed should increment the number of tests")
	QUIT
	;
T7	; Make sure we write to principal even though we are on another device
	; This is a rather difficult test to carry out for GT.M and Cache...
	; ZEXCEPT: GetEnviron,Util,delete,newversion,readonly - not really variables
	N D
	I +$SY=47 S D="/tmp/test.txt" ; All GT.M ; VMS not supported.
	I +$SY=0 D  ; All Cache
	. I $ZVERSION(1)=2 S D=$SYSTEM.Util.GetEnviron("temp")_"\test.txt" I 1 ; Windows
	. E  S D="/tmp/test.txt" ; not windows; VMS not supported.
	I +$SY=0 O D:"NWS" ; Cache new file
	I +$SY=47 O D:(newversion) ; GT.M new file
	U D
	WRITE "HELLO",!
	WRITE "HELLO",!
	C D
	;
	; Now open back the file, and read the hello, but open in read only so
	; M-Unit will error out if it will write something out there.
	;
	; Per VISTA conventions, current IO device should be IO, old is IO(0).
	;
	I +$SY=0 O D:"R"
	I +$SY=47 O D:(readonly)
	U D
	N X READ X:1
	D CHKTF(X="HELLO")  ; This should write to the screen the dot not to the file.
	D CHKTF(($$LO($IO)=$$LO(D)),"IO device didn't get reset back")       ; $$LO is b/c of a bug in Cache/Windows. $IO is not the same cas D.
	I +$SY=0 C D:"D"
	I +$SY=47 C D:(delete)
	U $P
	S IO=$IO
	QUIT
	;
	; At the moment T8^%utt1 throws a fail, with no message
	; in the GUI runner.  For some reason, both X and Y
	; variables are returned as null strings, while in the
	; command line runner, Y has a value containing the
	; word being sought
	;
T8	; If IO starts with another device, write to that device as if it's the pricipal device
	; ZEXCEPT: GetEnviron,Util,delete,newversion,readonly - not really variables
	N D
	I +$SY=47 S D="/tmp/test.txt" ; All GT.M ; VMS not supported.
	I +$SY=0 D  ; All Cache
	. I $ZVERSION(1)=2 S D=$SYSTEM.Util.GetEnviron("temp")_"\test.txt" I 1 ; Windows
	. E  S D="/tmp/test.txt" ; not windows; VMS not supported.
	I +$SY=0 O D:"NWS" ; Cache new file
	I +$SY=47 O D:(newversion) ; GT.M new file
	S IO=D
	U D
	D ^%utt4 ; Run some Unit Tests
	C D
	I +$SY=0 O D:"R" ; Cache read only
	I +$SY=47 O D:(readonly) ; GT.M read only
	U D
	N X,Y,Z R X:1,Y:1,Z:1
	I +$SY=0 C D:"D"
	I +$SY=47 C D:(delete)
	;D CHKTF(Y["MAIN") ; JLI 140829 commented out, gui doesn't run verbose
	D CHKTF((Y["MAIN")!(Z["Ran 1 Routine"),"Write to system during test didn't work")
	S IO=$P
	QUIT
	;
LO(X)	Q $TR(X,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	; Shortcut methods for M-Unit
CHKTF(X,Y)	;
	D CHKTF^%ut(X,$G(Y))
	QUIT
	;
CHKEQ(A,B,M)	;
	D CHKEQ^%ut(A,B,$G(M))
	QUIT
	;
XTENT	; Entry points
	;;T4;Entry point using XTMENT
	;;T5;Error count check
	;;T6;Succeed Entry Point
	;;T7;Make sure we write to principal even though we are on another device
	;;T8;If IO starts with another device, write to that device as if it's the pricipal device
	;
XTROU	; Routines containing additional tests
	;;%utt2; old %utNITU
	;;%utt4; old %utNITW
	;;%utt5;
	;;%utt6;
	;;%uttcovr;coverage related tests
