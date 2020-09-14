MODULE libCK;

	(* OMAKE LINK "CK" *)

IMPORT SYSTEM, C := arC;

TYPE
	Entry* = POINTER TO EntryDesc;

	EntryDesc* = RECORD
		next* : Entry;
	END;

	Stack* = RECORD
		head, generation : C.address;
	END;

(*
	Queue* = RECORD
		first, last : C.address;
	END;
*)

PROCEDURE -includeLibCK* "#include <ck_stack.h>";


PROCEDURE StackInit*(VAR stack : Stack);
BEGIN
	stack.head := 0;
	stack.generation := 0;
END StackInit;

PROCEDURE -StackPush*(VAR stack : Stack; entry : Entry)
	"ck_stack_push_upmc((struct ck_stack *)stack, (struct ck_stack_entry *)entry)";

PROCEDURE -StackPop*(VAR stack : Stack) : Entry
	"(libCK_Entry)ck_stack_pop_upmc((struct ck_stack *)stack)";

PROCEDURE -StackPopAll*(VAR stack : Stack) : Entry
	"(libCK_Entry)ck_stack_batch_pop_upmc((struct ck_stack *)stack)";

PROCEDURE Reverse*(VAR entry : Entry);
VAR in, out, this : Entry;
BEGIN
	in := entry;
	out := NIL;
	WHILE in # NIL DO
		this := in;
		in := in.next;
		this.next := out;
		out := this;
	END;
	entry := out;
END Reverse;

(*
PROCEDURE QueueInit*(VAR queue : Queue);
BEGIN
	queue.first := 0;
	queue.last := SYSTEM.ADR(queue.first);
END QueueInit;

PROCEDURE -QueueRemoveHead(VAR queue : Queue) : Entry
	"(LibCK_Entry)CK_STAILQ_REMOVE(queue"

PROCEDURE -QueueInsertTail(VAR queue : Queue; entry : Entry)
	CK_STAILQ_INSERT_TAIL(queue, 
*)

END libCK.
