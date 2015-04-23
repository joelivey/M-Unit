ut01PRE ;VEN/JLI - pre installation routine to set up MASH UTILITIES package and assign %ut routines and globals ;08/22/14  13:02
 ;;0.1;MASH UTILITIES
 ;
 ; The following is used to create, if it does not exist, the MASH UTILITIES
 ; package, and to assign the %u namespace to this package.  This special
 ; processing is necessary, since the input transform currently will not accept a
 ; % or lower case character in the namespace.
 I '$D(^DIC(9.4,"B","MASH UTILITIES")) N DIC,X S DIC="^DIC(9.4,",DIC(0)="",X="MASH UTILITIES",DIC("DR")="1////%u;2///Utilities associated with the M Advanced Shell" D FILE^DICN
 ; and if necessary, as in CACHE, map %ut routine and namespace in the current account.
 I +$SY=0 D CACHEMAP ; This routine is CACHE specific
 Q
 ; The following code was provided by Sam Habiel to map %
CACHEMAP ; Map %ut* Globals and Routines away from %SYS in Cache
 ; Get current namespace
 N NMSP
 I $P($P($ZV,") ",2),"(")<2012 S NMSP=$ZU(5)
 I $P($P($ZV,") ",2),"(")>2011 S NMSP=$NAMESPACE
 ;
 ; Map %ut globals away from %SYS
 ZN "%SYS" ; Go to SYS
 N % S %=##class(Config.Configuration).GetGlobalMapping(NMSP,"%ut*","",NMSP,NMSP)
 I '% S %=##class(Config.Configuration).AddGlobalMapping(NMSP,"%ut*","",NMSP,NMSP)
 I '% W !,"Error="_$SYSTEM.Status.GetErrorText(%) QUIT
 ;
 ; Map %ut routines away from %SYS
 N A S A("Database")=NMSP
 N % S %=##Class(Config.MapRoutines).Get(NMSP,"%ut*",.A)
 S A("Database")=NMSP
 I '% S %=##Class(Config.MapRoutines).Create(NMSP,"%ut*",.A)
 I '% W !,"Error="_$SYSTEM.Status.GetErrorText(%) QUIT
 ZN NMSP ; Go back
 QUIT
