# OMake generated script for OMake
Ofront+ -88 -s -e -2 src/aria/arStrings.ob2
Ofront+ -88 -s -e -2 src/aria/arStringList.ob2
Ofront+ -88 -s -e -2 src/aria/arStringAssoc.ob2
Ofront+ -88 -s -e -2 src/aria/arC.ob2
Ofront+ -88 -s -e -2 src/aria/arCFormat.ob2
Ofront+ -88 -s -e -2 src/aria/arText.ob2
Ofront+ -88 -s -e -2 src/aria/arChar.ob2
Ofront+ -88 -s -e -2 src/aria/arStream.ob2
Ofront+ -88 -s -e -2 src/aria/arOut.ob2
Ofront+ -88 -s -e -2 src/aria/arPattern.ob2
Ofront+ -88 -s -e -2 src/aria/arSize.ob2
Ofront+ -88 -s -e -2 src/aria/arConfiguration.ob2
Ofront+ -88 -s -e -2 src/aria/arPath.ob2
Ofront+ -88 -s -e -2 -m tool/OMake.ob2
gcc -O3 -g3 -I$OFRONT/Mod/Lib -I$OFRONT/Target/$OTARGET/Lib/Obj -L$OFRONT/Target/$OTARGET/Lib arPath.c arSize.c arStream.c arOut.c arChar.c arC.c arCFormat.c arText.c arPattern.c arConfiguration.c arStringList.c arStringAssoc.c arStrings.c OMake.c -o OMake -lOfront 
