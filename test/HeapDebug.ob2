(*
Perform basic consistency checks on the Heap.

Enumerates all Heap chunks, and all blocks within each chunk.
Checks for inconsistencies, and optionally traps on error.
Call HeapDebug.Check frequently, and use a debugger to catch the trap.

Created 2020/08/13 - Stewart Greenhill
*)

MODULE HeapDebug;

IMPORT 
	Heap,
	S := SYSTEM,
	Out := Console;

TYPE
	ADDRESS = S.ADRINT;

VAR
	verbose : BOOLEAN;		(* debug output which checking *)
	trap : BOOLEAN;			(* trap immediately on any errors *)

CONST
    SZA         = SIZE(ADDRESS);    (* Size of address *)

  (* heap chunks *)
	nextChnkOff = S.VAL(ADDRESS, 0);      (* next heap chunk, sorted ascendingly! *)
	endOff      = S.VAL(ADDRESS, SZA);    (* end of heap chunk *)
	blkOff      = S.VAL(ADDRESS, 3*SZA);  (* first block in a chunk, starts with tag *)

(* free heap blocks *)
	tagOff      = S.VAL(ADDRESS, 0*SZA);  (* any block starts with a tag *)
	sizeOff     = S.VAL(ADDRESS, 1*SZA);  (* block size in free block relative to block start *)
	sntlOff     = S.VAL(ADDRESS, 2*SZA);  (* pointer offset table sentinel in free block relative to block start *)
	nextOff     = S.VAL(ADDRESS, 3*SZA);  (* next pointer in free block relative to block start *)
	NoPtrSntl   = S.VAL(ADDRESS, -SZA);

PROCEDURE -Trap()
	"__builtin_trap()";

PROCEDURE -uLT(x, y: ADDRESS): BOOLEAN  "((__U_ADRINT)x <  (__U_ADRINT)y)";
PROCEDURE -uLE(x, y: ADDRESS): BOOLEAN  "((__U_ADRINT)x <= (__U_ADRINT)y)";

PROCEDURE Error(reason : ARRAY OF CHAR; code : ADDRESS);
BEGIN
	Out.String(reason); Out.String(" : "); Out.LongHex(code); Out.Ln;
	IF trap THEN
		Trap;
	END;
END Error;

(* determine if p points within heap *)

PROCEDURE WithinHeap*(p : ADDRESS) : BOOLEAN;
BEGIN
	RETURN uLE(Heap.heapMin, p) & uLT(p, Heap.heapMax);
END WithinHeap;

PROCEDURE Check*;
VAR
	chunk, end, size, blockSize, tag, totalSize, tagSize, offset, nPointers : ADDRESS;
	block : ADDRESS;
	nChunks, nBlocks, nHeapBlocks, totalBlocks : LONGINT;
	isFree : BOOLEAN;
	name : ARRAY 24 OF CHAR;

	PROCEDURE GetName(adr : ADDRESS);
	BEGIN
	END GetName;

	PROCEDURE ShowChunk;
	BEGIN
		Out.String("Chunk #"); Out.Int(nChunks, 0); Out.Ln;
		Out.String("  Addr: "); Out.LongHex(chunk); Out.Ln;
		Out.String("  Size: "); Out.LongInt(size, 0); Out.String(" bytes"); Out.Ln;
	END ShowChunk;

	PROCEDURE ShowBlock;
	VAR i : LONGINT; pName : ADDRESS; ch : CHAR;
	BEGIN
		Out.String("    Block #"); Out.Int(nHeapBlocks, 0); 
		Out.String(" Addr:"); Out.LongHex(block);
		Out.String(" Size:"); Out.LongInt(tagSize, 0);
		Out.String(" Ptrs:"); Out.LongInt(nPointers, 0);

		(* check if free block *)
		IF block + SZA = tag THEN
			Out.String(" Free");

(* Look for type name in statically allocated type descriptors. The
t__desc.name field is not normally initialised by default, but type names can
be enabled by adding the following line to __INITTYP in SYSTEM.Oh:

  strncpy(t##__desc.name, #t, sizeof(t##__desc.name)); \
*)
		ELSIF ~WithinHeap(tag) THEN
			pName := tag - 18 * SZA - 24;
			i := 0;
			LOOP
				IF i>= LEN(name)-1 THEN EXIT END;
				S.GET(pName, ch);
				IF ch = 0X THEN EXIT END;
				name[i] := ch;
				INC(i); INC(pName);
			END;
			name[i] := 0X;
			IF i > 0 THEN
				Out.String(" Type:"); Out.String(name);
			END;
		END;
		Out.Ln;
	END ShowBlock;

	PROCEDURE Summary;
	BEGIN
		Out.String("Chunks: "); Out.LongInt(nChunks, 0); Out.Ln;
		Out.String("Blocks: "); Out.LongInt(nHeapBlocks, 0); Out.Ln;
		Out.String("Total Size: "); Out.LongInt(totalSize, 0); 
		Out.String("   (Heap.Mod reports "); Out.LongInt(Heap.heapsize, 0); 
		Out.String(")"); Out.Ln;
	END Summary;

	PROCEDURE ShowLocation;
	BEGIN
		IF ~verbose THEN
			ShowChunk; ShowBlock;
		END;
	END ShowLocation;

BEGIN
	nChunks := 0;
	nBlocks := 0;
	totalSize := 0;
	chunk := Heap.heap;
	WHILE chunk # 0 DO
		S.GET(chunk + endOff, end);
		size := end - chunk - blkOff;
		INC(totalSize, size);
		IF verbose THEN
			ShowChunk;
		END;

		block := chunk + blkOff;
		nHeapBlocks := 0;
		WHILE uLT(block, end) DO
			S.GET(block, tag);

			S.GET(tag, tagSize);

			IF tagSize = 0 THEN
				ShowLocation;
				Error("Invalid Tag Size", 0);
			END;

			(* read offset table, and check length *)
			nPointers := 0;
			LOOP
				INC(tag, SZA);
				S.GET(tag, offset);
				IF offset < 0 THEN EXIT END;
				INC(nPointers);
			END;

			IF nPointers * SZA + SZA # -offset THEN
				ShowLocation;
				Error("Invalid Sentinel", offset);
			END;

			IF verbose THEN
				ShowBlock;
			END;

			INC(block, tagSize);
			INC(nHeapBlocks);
		END;

		INC(nChunks);
		S.GET(chunk + nextChnkOff, chunk);
	END;

	IF verbose THEN
		Summary;
	END;
	IF totalSize # Heap.heapsize THEN
		Summary;
		Error("Inconsistent Heap Size", totalSize);
	END;
END Check;

(* Check that an address is within the heap and is not free*)

PROCEDURE IsFreeBlock*(p : ADDRESS) : BOOLEAN;
VAR tag, offset : ADDRESS;
BEGIN
	S.GET(p-SZA, tag);
	S.GET(p+SZA, offset);
	RETURN (tag = p) & (offset = NoPtrSntl)
END IsFreeBlock;

PROCEDURE CheckAddress*(p : ADDRESS);
BEGIN
	IF ~WithinHeap(p) THEN
		Error("Address is outside Heap", p);
	END;
	IF IsFreeBlock(p) THEN
		Error("Pointer object is free", p);
	END;
END CheckAddress;

(* Check that a pointer is NIL or within the heap *)

PROCEDURE CheckPointer*(ptr : S.PTR);
BEGIN
	IF ptr = NIL THEN RETURN END;
	CheckAddress(S.VAL(ADDRESS, ptr));
END CheckPointer;

(* Get the offset within heap object <ptr> of the pointer number <idx> *)

PROCEDURE GetPointerOffset*(ptr : S.PTR; idx : LONGINT) : ADDRESS;
VAR 
	tag, op : ADDRESS;
BEGIN
	S.GET(S.VAL(ADDRESS, ptr) - SZA, tag);
	S.GET(tag + SZA + idx * SZA, op);
	RETURN op;
END GetPointerOffset;

PROCEDURE Set*(setVerbose, setTrap : BOOLEAN);
BEGIN
	verbose := setVerbose;
	trap := setTrap;
END Set;

BEGIN
	Set(FALSE, TRUE);
END HeapDebug.
