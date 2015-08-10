%utt2	; VEN/SMH - Bad Ass Continuation of Unit Tests;08/07/15  13:28
	;;0.2;MASH UTILITIES;;;Build 7
	;
T11	; @TEST An @TEST Entry point in Another Routine invoked through XTROU offsets
	D CHKTF^%ut(1)
	QUIT
T12	;
	D CHKTF^%ut(1)
	QUIT
XTENT	;
	;;T12;An XTENT offset entry point in Another Routine invoked through XTROU offsets
