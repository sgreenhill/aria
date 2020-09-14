MODULE TestJSON;

IMPORT
	T := Tests,
	TV := TestValue,
	Out := arOut, 
	F := arFormat,
	V := arValue,
	J := arJSON;

(* compare JSON representation of <o> with <text> *)

PROCEDURE Equals(o : V.Object; text : ARRAY OF CHAR);
VAR s : V.String;
BEGIN
	s := o.ToJSON();
	T.String(s.value^, text);
END Equals;

PROCEDURE Test;
CONST
	json1 = '{"one":1,"two":2,"debug":false,"pi":3.14159,"list":[0,1,2,3]}';
VAR
	r : V.Record;
BEGIN
	Equals(V.int(22),'22');
	Equals(V.real(1.2), '1.2');
	Equals(V.str("a string"), '"a string"');
	Equals(TV.Range(0, 9), '[0,1,2,3,4,5,6,7,8,9]');
	Equals(TV.Tree(4), '[[[[0,1],[2,3]],[[4,5],[6,7]]],[[[8,9],[10,11]],[[12,13],[14,15]]]]');

	r := V.record();
	r.Set("one", V.int(1));
	r.Set("two", V.int(2));
	r.Set("debug", V.bool(FALSE));
	r.Set("pi", V.real(3.14159265));
	r.Set("list", TV.Range(0,3));

	Equals(r, json1);
	Equals(J.ParseString(json1), json1);
END Test;

BEGIN
	T.Begin("TestJSON");
	Test;
	T.End;
END TestJSON.
