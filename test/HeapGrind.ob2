MODULE HeapGrind;

(* 
When compiled with optimisation (-O2, or -O3) this program segfaults when a
live heap object is incorrectly freed by the GC.

Ofront+ -88 -s -e -2 -m HeapGrind.ob2
gcc -g -O3 -I$OFRONT/Mod/Lib -I$OFRONT/Target/$OTARGET/Lib/Obj -L$OFRONT/Target/$OTARGET/Lib HeapGrind.c -o HeapGrind -lOfront

./HeapGrind
Iteration: 0
8191 nodes created

ERROR: Pointer object is free 0000000107D9C020
Segmentation fault: 11
*)


IMPORT 
	Kernel,
	Console,
	HeapDebug,
	S := SYSTEM;

TYPE
	ADDRESS = S.ADRINT;

CONST
    SZA = SIZE(ADDRESS);
	NoPtrSntl   = S.VAL(ADDRESS, -SZA);

TYPE
	Node = POINTER TO RECORD
		id : LONGINT;
		left, right : Node;
	END;

	List = POINTER TO RECORD
		next : List;
		p0 : List;
		id : LONGINT;
	END;

(* Determine if memory block is free *)

PROCEDURE IsFreeBlock*(p : ADDRESS) : BOOLEAN;
VAR tag, offset : ADDRESS;
BEGIN
	S.GET(p-SZA, tag);
	S.GET(p+SZA, offset);
	RETURN (tag = p) & (offset = NoPtrSntl)
END IsFreeBlock;

PROCEDURE CheckAddress*(p : ADDRESS);
BEGIN
	IF IsFreeBlock(p) THEN
		Console.Ln; Console.String("ERROR: Pointer object is free "); Console.LongHex(p); Console.Ln;
	END;
END CheckAddress;

(* Check that a pointer is NIL or within the heap *)

PROCEDURE CheckPointer*(ptr : S.PTR);
BEGIN
	IF ptr = NIL THEN RETURN END;
	CheckAddress(S.VAL(ADDRESS, ptr));
END CheckPointer;

(* append ID to a list of LONGINTs *)

PROCEDURE Append(VAR list : List; id : LONGINT);
VAR element : List;
BEGIN
	NEW(element);
	element.id := id;
	element.next := list;
	list := element;
END Append;

(* Create a binary tree of given depth, assign a different id to each node. *)

PROCEDURE Tree(depth : LONGINT; VAR count : LONGINT) : Node;
VAR 
	node : Node;
BEGIN
	NEW(node);
	node.id := count; INC(count);
	IF depth = 0 THEN
		node.left := NIL;
		node.right := NIL;
	ELSE
		node.left := Tree(depth-1, count);
		node.right := Tree(depth-1, count);
	END;
	RETURN node;
END Tree;

(* Visit each node of a tree, returning a list of the LONGINT ids. *)

PROCEDURE Visit(node : Node; VAR list : List);
BEGIN
	IF node = NIL THEN RETURN END;
	Append(list, node.id);
	Visit(node.left, list);
	Visit(node.right, list);
END Visit;

PROCEDURE Test(depth, reps : LONGINT);
VAR 
	tree : Node;
	list : List;
	i, j, count : LONGINT;
BEGIN
	Console.String("ADR(list):"); Console.LongHex(S.ADR(list)); Console.Ln;
	FOR i := 0 TO reps-1 DO
		Console.String("Iteration: "); Console.Int(i, 0); Console.Ln;

		(* build a binary tree *)
		count := 0;
		tree := Tree(depth, count);
		Console.Int(count, 0); Console.String(" nodes created"); Console.Ln;

		FOR j := 1 TO 10 DO
			list := NIL;
			Visit(tree, list);
			count := 0;
			WHILE list # NIL DO
				HeapDebug.CheckPointer(list);		(* Note: list points to free block *)
				list := list.next;		(* <-- SEGFAULT here *)
				INC(count);
			END;
			Console.Int(count, 0); Console.String(" nodes visited"); Console.Ln;
		END;
	END;
END Test;

BEGIN
	HeapDebug.Set(TRUE, TRUE);
	Test(12, 100);
	Console.String("Success!"); Console.Ln;
END HeapGrind.
