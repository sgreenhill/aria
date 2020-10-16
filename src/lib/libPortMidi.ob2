MODULE libPortMidi;

(* OMAKE LINK "portmidi" *)

IMPORT SYSTEM, C := arC;

CONST
	noDeviceId* = -1;

CONST
	filtActive* = ASH(1, 14);
	filtClock* = ASH(1, 8);
	filtSysEx* = ASH(1, 0);

CONST
	true* = 1;
	false* = 0;

TYPE
	DeviceID* = C.int;
	Error* = C.int;

	DeviceInfo* = POINTER [notag] TO DeviceInfoDesc;
	DeviceInfoDesc* = RECORD [notag]
		structVersion- : C.int; (* internal structure version *)
		interf- : C.string;		(* underlying MIDI API, e.g. MMSystem or DirectX *)
		name- : C.string;		(* device name, e.g. USB MidiSport 1x1 *)
		input- : C.int;			(* true iff input is available *)
		output- : C.int;		(* true iff output is availalble *)
		opened- : C.int;		(* used by PortMidi code for error checking *)
	END;

	Stream* = POINTER [notag] TO RECORD [notag] END;

	Message* = C.int;
	Timestamp* = C.int;

	Event* = RECORD [notag]
		message- : Message;
		timestamp- : Timestamp;
	END;

PROCEDURE -includePortMidi* "#include <portmidi.h>";
PROCEDURE -includePortTime* "#include <porttime.h>";

PROCEDURE -Initialize* () : Error
	"Pm_Initialize()";

PROCEDURE -Terminate* () : Error
	"Pm_Terminate()";

PROCEDURE -GetDefaultInputDeviceID* () : DeviceID
	"Pm_GetDefaultInputDeviceID()";

PROCEDURE -CountDevices* () : LONGINT
	"Pm_CountDevices()";

PROCEDURE -GetDeviceInfo* (id : DeviceID) : DeviceInfo
	"(libPortMidi_DeviceInfo)Pm_GetDeviceInfo(id)";

PROCEDURE -OpenInput*(VAR stream : Stream; inputDevice : DeviceID; bufferSize : LONGINT) : Error
	"(PmError)Pm_OpenInput((PortMidiStream **)stream, (PmDeviceID)inputDevice, NULL, bufferSize, ((int32_t (*)(void *)) Pt_Time), NULL)";

PROCEDURE -OpenOutput*(VAR stream : Stream; outputDevice : DeviceID; bufferSize, latency : LONGINT) : Error
	"(PmError)Pm_OpenInput((PortMidiStream **)stream, (PmDeviceID)outputDevice, NULL, bufferSize, ((int32_t (*)(void *)) Pt_Time), NULL, latency)";

(*
	Close() closes a midi stream, flushing any pending buffers.  (PortMidi
	attempts to close open streams when the application exits -- this is
	particularly difficult under Windows.)
*)

PROCEDURE -Close*(stream : Stream) : Error
	"(PmError)Pm_Close((PortMidiStream *)stream)";

(*
	Abort() terminates outgoing messages immediately The caller should
	immediately close the output port; this call may result in transmission of
	a partial midi message.  There is no abort for Midi input because the user
	can simply ignore messages in the buffer and close an input device at any
	time.
*)

PROCEDURE -Abort*(stream : Stream) : Error
	"(PmError)Pm_Abort((PortMidiStream *)stream)";

PROCEDURE -SetFilter*(stream : Stream; filters : C.int) : Error
	"(PmError)Pm_SetFilter((PortMidiStream *)stream, filters)";

PROCEDURE -Poll*(stream : Stream) : Error
	"(PmError)Pm_Poll((PortMidiStream *)stream)";

PROCEDURE -Read*(stream : Stream; VAR buffer : ARRAY OF Event) : LONGINT
	"Pm_Read((PortMidiStream *)stream, (PmEvent*)buffer, (int32_t)buffer__len)";

PROCEDURE -Write*(stream : Stream; VAR buffer : ARRAY OF Event) : Error
	"(PmError)Pm_Write((PortMidiStream *)stream, (PmEvent*)buffer, (int32_t)buffer__len)";

PROCEDURE -MessageStatus*(msg : Message) : SHORTINT
	"Pm_MessageStatus(msg)";

PROCEDURE -MessageData1*(msg : Message) : SHORTINT
	"Pm_MessageData1(msg)";

PROCEDURE -MessageData2*(msg : Message) : SHORTINT
	"Pm_MessageData2(msg)";

END libPortMidi.
