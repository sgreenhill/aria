MODULE libSDL;

(* OMAKE LINK "SDL2" *)

IMPORT SYSTEM, C := arC;

CONST
	windowAllowHighDPI* = 2000H;
	windowShown* = 0004H;

CONST
	windowposUndefined* = 1FFF0000H;

CONST
	initTimer*=          000001H;
	initAudio*=          000010H;
	initVideo*=          000020H; (* SDL_INIT_VIDEO implies SDL_INIT_EVENTS *)
	initJoystick*=       000200H; (* SDL_INIT_JOYSTICK implies SDL_INIT_EVENTS *)
	initHaptic*=         001000H;
	initGamecontroller*= 002000H; (* SDL_INIT_GAMECONTROLLER implies SDL_INIT_JOYSTICK *)
	initEvents*=         004000H;
	initSensor*=         008000H;
	initNoparachute*=    100000H; (* compatibility; this flag is ignored. *)

CONST
	rendererSoftware* = 1;
	rendererAccelerated* = 2;
	rendererPresentVsync* = 4;
	rendererTargetTexture* = 8;

CONST
	msgQuit* = 100H;
    msgMouseMotion* = 400H;
    msgMouseButtonDown* = 401H;
    msgMouseButtonUp* = 402H;
    msgMouseWheel* = 403H;
	msgKeyDown* = 300H;
	msgKeyUp* = 301H;

TYPE
	Uint8 = SYSTEM.INT8; 	(* should be unsigned *)
	Uint16 = SYSTEM.INT16; 	(* should be unsigned *)
	Uint32 = SYSTEM.INT32; 	(* should be unsigned *)
	Sint32 = SYSTEM.INT32; 	(* should be unsigned *)

	Window* = POINTER TO RECORD [notag] END;
	Texture* = POINTER TO RECORD [notag] END;
	Renderer* = POINTER TO RECORD [notag] END;

	Event* = RECORD [notag]  (* FIXME! This is a massive UNION Type *)
		type* : C.int;
		guess : ARRAY 128 OF CHAR;
	END;

	MouseMotionEventPtr* = POINTER TO MouseMotionEvent;
	MouseMotionEvent* = RECORD [notag]
		type* : Uint32;
		timestamp* : Uint32;
		windowID* : Uint32;
		which* : Uint32;
		state : Uint32;
		x* : Sint32;
		y* : Sint32;
		xrel* : Sint32;
		yrel* : Sint32;
	END;

	MouseButtonEventPtr* = POINTER TO MouseButtonEvent;
	MouseButtonEvent* = RECORD [notag]
		type* : Uint32;
		timestamp* : Uint32;
		windowID* : Uint32;
		which* : Uint32;
		button* : Uint8;
		state* : Uint8;
		clicks* : Uint8;
		padding1 : Uint8;
		x* : Sint32;
		y* : Sint32;
	END;

	Keysym* = RECORD [notag]
		scancode* : Uint32;
		sym* : Uint32;
		mod* : Uint16;
	END;

	KeyboardEventPtr* = POINTER TO KeyboardEvent;
	KeyboardEvent* = RECORD [notag]
		type* : Uint32;
		timestamp* : Uint32;
		windowID* : Uint32;
		state* : Uint8;
		repeat* : Uint8;
		padding1, padding2* : Uint8;
		keysym* : Keysym;
	END;

	Color = RECORD [notag]
		r, g, b, a : Uint8;
	END;

	Palette = RECORD [notag]
		ncolors : C.int;
		colors : POINTER TO Color;
		version : Uint32;
		refcount : C.int;
	END;

	PixelFormat = RECORD [notag]
		format : Uint32;
		palette : POINTER TO Palette;
		BitsPerPixel : Uint8;
		BytesPerPixel : Uint8;
		padding : ARRAY 2 OF Uint8;		(* assuming ALIGN1 *)
		Rmask, Gmask, Bmask, Amask : Uint32;
		Rloss, Gloss, Bloss, Aloss : Uint32;
		Rshift, Gshift, Bshift, Ashift : Uint32;
		refcount : C.int;
		next : POINTER TO PixelFormat;
	END;

	ImageData* = POINTER TO RECORD[notag] END;

	Surface* = POINTER TO RECORD [notag]
		flags- : C.int;
		format- : POINTER TO PixelFormat;
		w-, h- : C.int;
		pitch- : SYSTEM.INT16;
		pixels- : ImageData;
		offset : C.int;
	END;

	RectPtr = POINTER TO RECORD [notag] END;

PROCEDURE -includeSDL* "#include <SDL.h>";

PROCEDURE -CreateWindow*(title : ARRAY OF CHAR; x, y, w, h, flags : C.int) : Window
	"(libSDL_Window)SDL_CreateWindow((const char *)title, x, y, w, h, flags)";

PROCEDURE -Init*(flags : C.int) : C.int
	"(int)SDL_Init(flags)";

PROCEDURE -PollEvent*(VAR event : Event) : C.int
	"(int)SDL_PollEvent((SDL_Event *)event)";

PROCEDURE -Delay*(ms : C.int)
	"SDL_Delay(ms)";

PROCEDURE -Quit*
	"SDL_Quit()";

PROCEDURE -DestroyWindow*(window : Window)
	"SDL_DestroyWindow((SDL_Window *)window)";

PROCEDURE -DestroyTexture*(texture : Texture)
	"SDL_DestroyTexture((SDL_Texture *)texture)";

PROCEDURE -GetWindowSize*(window : Window; VAR width, height : C.int)
	"SDL_GetWindowSize((SDL_Window *)window, width, height)";

PROCEDURE -CreateRenderer*(window : Window; index, flags : C.int) : Renderer
	"(libSDL_Renderer)SDL_CreateRenderer((SDL_Window *)window, (int)index, (int)flags)";

PROCEDURE -GetRendererOutputSize*(renderer : Renderer; VAR width, height : C.int)
	"SDL_GetRendererOutputSize((SDL_Renderer *)renderer, width, height)";

PROCEDURE -CreateRGBSurface*(flags, width, height, depth : C.int; rMask, gMask, bMask, aMask : C.int) : Surface
	"(libSDL_Surface)SDL_CreateRGBSurface(flags, width, height, depth, rMask, gMask, bMask, aMask)";

PROCEDURE -CreateTextureFromSurface*(renderer : Renderer; surface : Surface) : Texture
	"(libSDL_Texture)SDL_CreateTextureFromSurface((SDL_Renderer *) renderer, (SDL_Surface *)surface)";

PROCEDURE -RenderCopy*(renderer : Renderer; texture : Texture; srcRect, dstRect : RectPtr)
	"SDL_RenderCopy((SDL_Renderer *)renderer, (SDL_Texture *)texture, (const SDL_Rect *)srcRect, (const SDL_Rect *)dstRect)";

PROCEDURE -RenderPresent*(renderer : Renderer)
	"SDL_RenderPresent((SDL_Renderer *)renderer)";

END libSDL.
