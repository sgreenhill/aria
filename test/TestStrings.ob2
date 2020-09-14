MODULE TestStrings;

IMPORT 
	T := Tests,
	S := arStrings;

VAR
	buffer : ARRAY 128 OF CHAR;
	ptr : S.StringPtr;

BEGIN
	T.Begin("TestStrings");

	(* Strings.Length *)
	T.Int(S.Length("three"), 5);
	T.Int(S.Length(""), 0);

	(* Strings.Equal *)
	T.Assert(S.Equal("one", "one"));
	T.Assert(S.Equal("", ""));
	T.Assert(~S.Equal("on", "one"));
	T.Assert(~S.Equal("one", "on"));

	(* Strings.Assign / Strings.Append *)
	S.Assign("", buffer);
	T.String(buffer, "");

	S.Assign("one", buffer);
	T.String(buffer, "one");

	S.Append("", buffer);
	T.String(buffer, "one");
	
	S.Append("two", buffer);
	T.String(buffer, "onetwo");

	(* Strings.Extract *)
	S.Extract("one,two,three", 4, 3, buffer);
	T.String(buffer, "two");

	S.Extract("one,two,three", 4, 100, buffer);
	T.String(buffer, "two,three");

	S.Extract("one,two,three", 4, 0, buffer);
	T.String(buffer, "");

	(* Strings.StartsWith *)
	T.Assert(S.StartsWith("test.Mod", "test"));
	T.Assert(~S.StartsWith("test.Mod", "tess"));
	T.Assert(S.StartsWith("test.Mod", ""));

	(* Strings.EndsWith *)
	T.Assert(S.EndsWith("test.Mod", ".Mod"));
	T.Assert(~S.EndsWith("test.Mod", ".Mo"));
	T.Assert(S.EndsWith("test.Mod", ""));

	T.Int(S.IndexOf("one.two.three", "#", 0), -1);
	T.Int(S.IndexOf("one.two.three", ".", 0), 3);
	T.Int(S.IndexOf("one.two.three", ".", 3), 3);
	T.Int(S.IndexOf("one.two.three", ".", 4), 7);

	T.Int(S.LastIndexOf("one.two.three", "#", 0), -1);
	T.Int(S.LastIndexOf("one.two.three", ".", 0), -1);
	T.Int(S.LastIndexOf("one.two.three", ".", 12), 7);
	T.Int(S.LastIndexOf("one.two.three", ".", -1), 7);
	T.Int(S.LastIndexOf("one.two.three", ".", 7), 7);
	T.Int(S.LastIndexOf("one.two.three", ".", 6), 3);

	ptr := S.Copy("a string");
	T.String(ptr^, "a string");

	T.End;
END TestStrings.
