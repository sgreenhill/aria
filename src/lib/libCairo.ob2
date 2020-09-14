(* 
An Oberon-2 binding for part of the Cairo 1.16.0 API. 
*)

MODULE libCairo;

(* OMAKE LINK "cairo" *)

IMPORT SYSTEM, C := arC;

CONST (* FormatT = cairo_format_t *)
	formatInvalid*   = -1;
	formatARGB32*    = 0;
	formatRGB24*     = 1;
	formatA8*        = 2;
	formatA1*        = 3;
	formatRGB16565*  = 4;
	formatRGB30*     = 5;

CONST (* FillRuleT = cairo_fill_rule_t *)
	fillRuleWinding* = 0;
	fillRuleEvenOdd* = 1;

TYPE
	Surface* = POINTER [notag] TO RECORD [notag] END;

	ImageData* = POINTER [notag] TO ARRAY OF CHAR;

	Cairo* = POINTER [notag] TO RECORD [notag] END;

	TextExtents* = RECORD [notag]
		xBearing*, yBearing* : LONGREAL;
		width*, height* : LONGREAL;
		xAdvance*, yAdvance* : LONGREAL;
	END;

	FormatT* = C.int;
	FillRuleT* = C.int;

	(* object-based interface to Cairo drawing *)
	Painter* = POINTER TO RECORD
		cairo : Cairo;
	END;

PROCEDURE -includeCairo* "#include <cairo.h>";

(* Create surface in an array *)

PROCEDURE -imageSurfaceCreateForData* (
	data : ImageData;
	format : FormatT; width, height, stride : C.int) : Surface
	"(libCairo_Surface)cairo_image_surface_create_for_data((unsigned char *)data, (cairo_format_t) format, (int)width, (int)height, (int)stride)";

(* Write surface to PNG file *)

PROCEDURE -surfaceWriteToPNG* (surface : Surface; file : ARRAY OF CHAR)
	"(cairo_status_t)cairo_surface_write_to_png((cairo_surface_t *)surface, (const char *) file)";

PROCEDURE -surfaceDestroy* (surface : Surface)
	"cairo_surface_destroy((cairo_surface_t *)surface)";

(* Create drawing context *)

PROCEDURE -create* (surface : Surface) : Cairo
	"(libCairo_Cairo) cairo_create((cairo_surface_t *) surface)";

PROCEDURE -destroy* (cairo : Cairo)
	"cairo_destroy((cairo_t *) cairo)";

(* Drawing operations *)

PROCEDURE -setSourceRGB* (cairo : Cairo; red, green, blue : LONGREAL)
	"cairo_set_source_rgb((cairo_t *) cairo, (double)red, (double)green, (double)blue)";

		PROCEDURE (self : Painter) SetSourceRGB* (red, green, blue : LONGREAL);
		BEGIN
			setSourceRGB(self.cairo, red, green, blue);
		END SetSourceRGB;

PROCEDURE -setSourceRGBA* (cairo : Cairo; red, green, blue, alpha : LONGREAL)
	"cairo_set_source_rgba((cairo_t *) cairo, (double)red, (double)green, (double)blue, (double) alpha)";

		PROCEDURE (self : Painter) SetSourceRGBA* (red, green, blue, alpha : LONGREAL);
		BEGIN
			setSourceRGBA(self.cairo, red, green, blue, alpha);
		END SetSourceRGBA;

PROCEDURE -moveTo* (cairo : Cairo; x, y : LONGREAL)
	"cairo_move_to((cairo_t *) cairo, (double)x, (double)y)";

		PROCEDURE (self : Painter) MoveTo* (x, y : LONGREAL);
		BEGIN
			moveTo(self.cairo, x, y);
		END MoveTo;

PROCEDURE -relLineTo* (cairo : Cairo; dx, dy : LONGREAL)
	"cairo_rel_line_to((cairo_t *) cairo, (double)dx, (double)dy)";

		PROCEDURE (self : Painter) RelLineTo* (x, y : LONGREAL);
		BEGIN
			relLineTo(self.cairo, x, y);
		END RelLineTo;

PROCEDURE -lineTo* (cairo : Cairo; dx, dy : LONGREAL)
	"cairo_line_to((cairo_t *) cairo, (double)dx, (double)dy)";

		PROCEDURE (self : Painter) LineTo* (x, y : LONGREAL);
		BEGIN
			lineTo(self.cairo, x, y);
		END LineTo;

PROCEDURE -setLineWidth* (cairo : Cairo; width : LONGREAL)
	"cairo_set_line_width((cairo_t *) cairo, width)";

		PROCEDURE (self : Painter) SetLineWidth* (width : LONGREAL);
		BEGIN
			setLineWidth(self.cairo, width);
		END SetLineWidth;

PROCEDURE -getLineWidth* (cairo : Cairo) : LONGREAL
	"cairo_get_line_width((cairo_t *) cairo)";

		PROCEDURE (self : Painter) GetLineWidth* () : LONGREAL;
		BEGIN
			RETURN getLineWidth(self.cairo);
		END GetLineWidth;

PROCEDURE -arc* (cairo : Cairo; xc, yc, radius, angle1, angle2 : LONGREAL)
	"cairo_arc((cairo_t *) cairo, xc, yc, radius, angle1, angle2)";

		PROCEDURE (self : Painter) Arc* (xc, yc, radius, angle1, angle2 : LONGREAL);
		BEGIN
			arc(self.cairo, xc, yc, radius, angle1, angle2);
		END Arc;

PROCEDURE -rotate* (cairo : Cairo; angle : LONGREAL)
	"cairo_rotate((cairo_t *) cairo, (double)angle)";

		PROCEDURE (self : Painter) Rotate* (angle : LONGREAL);
		BEGIN
			rotate(self.cairo, angle);
		END Rotate;

PROCEDURE -closePath* (cairo : Cairo)
	"cairo_close_path((cairo_t *) cairo)";

		PROCEDURE (self : Painter) ClosePath;
		BEGIN
			closePath(self.cairo);
		END ClosePath;

PROCEDURE -rectangle* (cairo : Cairo; x, y, width, height : LONGREAL)
	"cairo_rectangle((cairo_t *) cairo, (double)x, (double)y, (double)width, (double)height)";

		PROCEDURE (self : Painter) Rectangle* (x, y, width, height : LONGREAL);
		BEGIN
			rectangle(self.cairo, x, y, width, height);
		END Rectangle;

PROCEDURE -setFillRule* (cairo : Cairo; fillRule : INTEGER)
	"cairo_set_fill_rule((cairo_t *) cairo, (cairo_fill_rule_t) fillRule)";

		PROCEDURE (self : Painter) SetFillRule* (fillRule : INTEGER);
		BEGIN	
			setFillRule(self.cairo, fillRule);
		END SetFillRule;

PROCEDURE -fill* (cairo : Cairo)
	"cairo_fill((cairo_t *) cairo)";

		PROCEDURE (self : Painter) Fill*;
		BEGIN
			fill(self.cairo);
		END Fill;

PROCEDURE -stroke* (cairo : Cairo)
	"cairo_stroke((cairo_t *) cairo)";

		PROCEDURE (self : Painter) Stroke*;
		BEGIN
			stroke(self.cairo);
		END Stroke;

(* Text *)

PROCEDURE -textExtents* (cairo : Cairo; text : ARRAY OF CHAR; VAR extents : TextExtents)
	"cairo_text_extents((cairo_t *) cairo, (const char *) text, (cairo_text_extents_t *) extents)";

	PROCEDURE (self : Painter) TextExtents* (text : ARRAY OF CHAR; VAR extents : TextExtents);
	BEGIN
		textExtents(self.cairo, text, extents);
	END TextExtents;

PROCEDURE -showText* (cairo : Cairo; text : ARRAY OF CHAR)
	"cairo_show_text((cairo_t *) cairo, (const char *) text)";

	PROCEDURE (self : Painter) ShowText* (text : ARRAY OF CHAR);
	BEGIN
		showText(self.cairo, text);
	END ShowText;

PROCEDURE -setFontSize* (cairo : Cairo; size : LONGREAL)
	"cairo_set_font_size((cairo_t *) cairo, (double)size)";

	PROCEDURE (self : Painter) SetFontSize* (size : LONGREAL);
	BEGIN
		setFontSize(self.cairo, size);
	END SetFontSize;

(* Save and restore state *)

PROCEDURE -save* (cairo : Cairo)
	"cairo_save((cairo_t *) cairo)";

		PROCEDURE (self : Painter) Save*;
		BEGIN
			save(self.cairo);
		END Save;

PROCEDURE -restore* (cairo : Cairo)
	"cairo_restore((cairo_t *) cairo)";

		PROCEDURE (self : Painter) Restore*;
		BEGIN
			restore(self.cairo);
		END Restore;

(* Transforms *)

PROCEDURE -translate* (cairo : Cairo; tx, ty : LONGREAL)
	"cairo_translate((cairo_t *) cairo, (double)tx, (double)ty)";

		PROCEDURE (self : Painter) Translate* (tx, ty : LONGREAL);
		BEGIN
			translate(self.cairo, tx, ty);
		END Translate;

PROCEDURE -scale* (cairo : Cairo; sx, sy : LONGREAL)
	"cairo_scale((cairo_t *) cairo, (double)sx, (double)sy)";

		PROCEDURE (self : Painter) Scale* (sx, sy : LONGREAL);
		BEGIN
			scale(self.cairo, sx, sy);
		END Scale;

		PROCEDURE (self : Painter) Init* (cairo : Cairo);
		BEGIN
			self.cairo := cairo;
		END Init;

END libCairo.
