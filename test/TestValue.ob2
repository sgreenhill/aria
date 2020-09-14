MODULE TestValue;

IMPORT
	T := Tests,
	F := arFormat, 
	V := arValue, 
	Out := arOut;

(* compare string representation of <o> with <text> *)

PROCEDURE Equals(o : V.Object; text : ARRAY OF CHAR);
VAR s : V.String;
BEGIN
	s := o.ToString();
	T.String(s.value^, text);
END Equals;

(* return a binary tree *)
PROCEDURE Tree*(levels : INTEGER) : V.Object;
VAR 
	id : INTEGER;

	PROCEDURE Inner(levels : INTEGER) : V.Object;
	VAR
		result : V.Integer;
	BEGIN
		IF levels = 0 THEN
			result := V.int(id); INC(id);
			RETURN result;
		END;
		RETURN V.array2(Inner(levels-1), Inner(levels-1));
    END Inner;

BEGIN
	id := 0;
	RETURN Inner(levels);
END Tree;

(* return a list of integers *)
PROCEDURE Range*(from, to : INTEGER) : V.List;
VAR l : V.List;
BEGIN
	l := V.list();
	WHILE from <= to DO
		l.Append(V.int(from)); INC(from);
	END;
	RETURN l
END Range;

PROCEDURE TestObject;
VAR
	l : V.List;
	o : V.Object;
	r : V.Record;
	shallowCopy, deepCopy : V.Object;
BEGIN
	T.Section("Objects");

	l := V.list();
	l.Append(V.str("string"));
	l.Append(V.int(0));
	l.Append(V.real(1.5));
	l.Append(V.bool(TRUE));
	l.Append(V.set({1,3,5,7,9,MAX(SET)}));
	l.Append(Range(0,3));

	r := V.record();
	r.Set("x", V.int(5));
	r.Set("y", V.int(6));
	l.Append(r);

	(* copies structure *)
	T.Assert(V.Equals(l, V.Copy(l)));
	T.Assert(V.Equals(l, V.DeepCopy(l)));

	(* shallow/deep copy *)
	l := V.list();
	l.Append(V.int(0));
	r := V.record();
	r.Set("l", l);
	Equals(r, "{l:[0]}");

	shallowCopy := V.Copy(r);
	deepCopy := V.DeepCopy(r);
	l.Set(0, V.int(1));

	(* shallow copy should be equal, deep copy different *)
	T.Assert(V.Equals(r, shallowCopy));
	T.Assert(~V.Equals(r, deepCopy));
END TestObject;

PROCEDURE TestList;
VAR
	a, b : V.List;
BEGIN
	T.Section("Lists");

	a := Range(0, 9);
	T.Int(a.length, 10);
	T.Assert(V.Equals(a, Range(0, 9)));
	Equals(a, "[0,1,2,3,4,5,6,7,8,9]");

	(* Get/Set *)
	T.Assert(V.Equals(a.Get(2), V.int(2)));
	a.Set(2, V.int(20));
	T.Assert(V.Equals(a.Get(2), V.int(20)));

	(* IndexOf *)
	T.Int(a.IndexOf(V.int(5)), 5);
	T.Int(a.IndexOf(V.int(0)), 0);
	T.Int(a.IndexOf(V.int(9)), 9);
	T.Int(a.IndexOf(V.str("Hello")), -1);

	(* Append/Prepend *)
	a := V.list();
	a.Append(V.str("one"));
	Equals(a, '["one"]');

	a.Append(V.str("two"));
	Equals(a, '["one","two"]');

	a.Prepend(V.str("zero"));
	Equals(a, '["zero","one","two"]');

	T.Int(a.IndexOf(V.str("one")), 1);
	T.Int(a.IndexOf(V.str("four")), -1);

	(* Concat/Extend *)
	a := Range(0,3);
	b := Range(4,6);
	Equals(a.Concat(b), "[0,1,2,3,4,5,6]");

	a := Range(0,3);
	a.Extend(b);
	Equals(a, "[0,1,2,3,4,5,6]");

	a := V.list();
	a.Append(Range(0,3));
	a.Append(Range(4,6));
	Equals(a, "[[0,1,2,3],[4,5,6]]");
END TestList;

PROCEDURE TestString;
VAR 
	a, b, c : V.String;
BEGIN
	T.Section("Strings");

	a := V.str("test string");
	T.String(a.value^, "test string");
	T.Int(a.length, 11);

	T.Int(a.Compare("test string"), 0);
	T.Int(a.Compare("string"), 1);
	T.Int(a.Compare("yes"), -1);

	T.Assert(a.EndsWith("string"));
	T.Assert(a.EndsWith(""));
	T.Assert(~a.EndsWith("thing"));
	T.Assert(~a.EndsWith("strinq"));

	T.Assert(a.StartsWith("test"));
	T.Assert(a.StartsWith(""));
	T.Assert(~a.StartsWith("tesx"));

	a := V.str("abc");
	b := V.str("def");
	T.Assert(a.Equals(a));
	T.Assert(~a.Equals(b));

	c := a.Concat(b);
	Equals(c, "abcdef");

	Equals(c.Extract(2,2), "cd");
	Equals(c.Extract(-3, 4), "def");
	Equals(c.Extract(1, 0), "");

	Equals(V.Split(",,,", ","), '["","","",""]');
	Equals(V.Split("one,two,three,four", ","), '["one","two","three","four"]');
	Equals(V.Split("one", ","), '["one"]');

END TestString;

BEGIN
	T.Begin("TestValue");

	TestString;
	TestList;
	TestObject;

	T.End;
END TestValue.
