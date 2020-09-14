MODULE Tests;

IMPORT
	Kernel,
	Out := arOut,
	Strings := arStrings;

TYPE
	StringFunc* = PROCEDURE (path-: Strings.String; VAR result : Strings.String);

VAR
	tests, errors : LONGINT;
	inSection : BOOLEAN;
	section : ARRAY 128 OF CHAR;
	sectionStart : LONGINT;

PROCEDURE Init;
BEGIN
	Strings.Assign("", section);
	tests := 0;
	errors := 0;
	inSection := FALSE;
END Init;

PROCEDURE Begin*(name : ARRAY OF CHAR);
BEGIN
	Out.String(name); Out.Char(":"); Out.Ln;
	Init;
END Begin;

PROCEDURE End*;
BEGIN
	Out.String("- Completed "); Out.Int(tests);
	Out.String(" tests with "); Out.Int(errors);
	Out.String(" errors"); Out.Ln;
END End;

PROCEDURE Section*(name : ARRAY OF CHAR);
BEGIN
	inSection := TRUE;
	Strings.Assign(name, section);
	sectionStart := tests;
END Section;

PROCEDURE Error*;
BEGIN
	INC(errors);
	IF inSection THEN
		Out.String("  ");
		Out.String(section);
		Out.String(" #"); Out.Int(tests-sectionStart);
	ELSE
		Out.String("  Test #"); Out.Int(tests);
	END;
	Out.Char(" ");
END Error;

PROCEDURE Assert*(value : BOOLEAN);
BEGIN
	INC(tests);
	IF ~value THEN
		Error;
		Out.String("Returned:FALSE"); Out.Ln;
	END;
END Assert;

PROCEDURE Int*(value, expected : LONGINT);
BEGIN
	INC(tests);
	IF value # expected THEN
		Error;
		Out.String("Expected:"); Out.Int(expected);
		Out.String(", Returned:"); Out.Int(value); Out.Ln;
	END;
END Int;

PROCEDURE String*(value-, expected- : Strings.String);
BEGIN
	INC(tests);
	IF ~Strings.Equal(value, expected) THEN
		Error;
		Out.String("Expected:"); Out.String(expected);
		Out.String(", Returned:"); Out.String(value); Out.Ln;
	END;
END String;

PROCEDURE StringF*(func : StringFunc; value-, expected-: Strings.String);
VAR buffer : ARRAY 1024 OF CHAR;
BEGIN
	func(value, buffer);
	String(buffer, expected);
END StringF;

PROCEDURE Done*;
BEGIN
	Kernel.Exit(errors);
END Done;

BEGIN
	Init;
END Tests.
