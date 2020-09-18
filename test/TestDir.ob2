MODULE TestDir;

IMPORT
	Kernel,
	Out := arOut,
	arDir;

PROCEDURE Test(path-: ARRAY OF CHAR);
VAR
	f : arDir.FileFinder;
	name : ARRAY 256 OF CHAR;
BEGIN
	IF f.Open(path) THEN
		WHILE f.Next(name) DO
			Out.String(name); Out.Ln;
		END;
		f.Close;
	ELSE
		Out.String("Open failed for "); Out.String(path); Out.Ln;
	END;
END Test;

BEGIN
	Test(".");
END TestDir.
