MODULE arOut;

IMPORT
	arText,
	arStream;

PROCEDURE String*(text-: ARRAY OF CHAR);
BEGIN
	arStream.out.String(text);
END String;

PROCEDURE Int*(value : LONGINT);
BEGIN
	arStream.out.Integer(value);
END Int;

PROCEDURE Hex*(value : LONGINT);
BEGIN
	arStream.out.Hex(value);
END Hex;

PROCEDURE Char*(value : CHAR);
BEGIN
	arStream.out.Char(value);
END Char;

PROCEDURE Real*(value : LONGREAL);
BEGIN
	arStream.out.Real(value);
END Real;

PROCEDURE Ln*;
BEGIN
	arStream.out.Ln;
END Ln;

PROCEDURE Flush*;
BEGIN
	arStream.out.Flush;
END Flush;

PROCEDURE Bool*(value : BOOLEAN);
BEGIN
	arStream.out.Boolean(value);
END Bool;

END arOut.
