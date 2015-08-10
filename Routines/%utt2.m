%utt2	; VEN/SMH - Bad Ass Continuation of Unit Tests;08/10/15  14:29
	;;0.2;MASH UTILITIES;;;Build 7
	;
	; Submitted to OSEHRA 08/10/2015 by Joel L. Ivey
	; Original routine authored by Sam H. Habiel
	; Modifications made by Joel L. Ivey 05/2014-08/2015
	;
	;
T11	; @TEST An @TEST Entry point in Another Routine invoked through XTROU offsets
	D CHKTF^%ut(1)
	QUIT
T12	;
	D CHKTF^%ut(1)
	QUIT
XTENT	;
	;;T12;An XTENT offset entry point in Another Routine invoked through XTROU offsets
