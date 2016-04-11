%utt2	; VEN/SMH - Bad Ass Continuation of Unit Tests;04/08/16  20:38
	;;1.4;MASH UTILITIES;;APR 11, 2016;
	; Submitted to OSEHRA Apr 11, 2016 by Joel L. Ivey under the Apache 2 license (http://www.apache.org/licenses/LICENSE-2.0.html)
	; Original routine authored by Sam H. Habiel
	; Modifications made by Joel L. Ivey 05/2014-09/2015
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
