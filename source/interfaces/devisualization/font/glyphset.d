/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Devisualization (Richard Andrew Cattermole)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module devisualization.font.glyphset;
import devisualization.font.font;
import devisualization.font.glyph;
import devisualization.image.color;
import devisualization.image;
import std.traits : isSomeString;

struct GlyphSet {
	private {
		GlyphLine[] lines;
		Color_RGBA brushBKGD = new Color_RGBA(0f, 0f, 0f, 0f);
	}

    GlyphLine opIndex(size_t line) {
		if (line + 1 > lines.length) {
			foreach(i; lines.length .. line+1) {
				lines ~= new GlyphLine;
			}
		}

		return lines[line];
	}

    void removeLine(size_t line) { // removes a line but remember it invalidates all GlyphLine's gotten previously
		if (line == 0 && lines.length == 1) 
			lines = [];
		else if (line == lines.length - 1 && line > 0)
			lines = lines[0 .. $-1];
		else if (line == 0)
			lines = lines[1 .. $];
		else
			lines = lines[0 .. line] ~ lines[line + 1 .. $];
	}

	void fill(T)(Font font, T text, size_t offset) if (isSomeString!T) {
		bool justNewLine;
		GlyphLine line = this[offset];
		foreach(c; text) {
			if (c == '\n' || c == '\r') {
				if (!justNewLine) {
					offset++;
					line = this[offset];
					justNewLine = true;
				}
			} else {
				justNewLine = false;

				Glyph g = font.get(c);
				if (g !is null) {
					line ~= g;
				}
			}
		}
	}

	GlyphSetModifiers modifiers() {
		class SetModifiers : GlyphSetModifiers {
			void italize() { // makes it italisized
				foreach(line; lines) {
					line.modifiers.italize;
				}
			}
			
			void bold() { // makes it boldenized
				foreach(line; lines) {
					line.modifiers.bold;
				}
			}
			
			void width(uint width) { // scales
				foreach(line; lines) {
					line.modifiers.width(width);
				}
			}
			void kerning(ushort amount) { // adds width but doesn't scale
				foreach(line; lines) {
					line.modifiers.kerning(amount);
				}
			}
			
			void height(uint amount) { // scales
				foreach(line; lines) {
					line.modifiers.height(amount);
				}
			}
			
			void lineHeight(uint amount) { // adds height to glyph but doesn't scale
				foreach(line; lines) {
					line.modifiers.lineHeight(amount);
				}
			}
			
			void color(Color_RGBA primary, Color_RGBA background = null) {
				foreach(line; lines) {
					line.modifiers.color(primary, background);
				}

				brushBKGD = background;
			}
			
			void reset() { // reload image for glpyh
				foreach(line; lines) {
					line.modifiers.reset();
				}
			}
		}
		
		return new SetModifiers;
	}

    Image output() {
		import devisualization.image.mutable;
		Image[] iLines;

		size_t height;
		size_t width;

		foreach(line; lines) {
			iLines ~= line.output();
			height += iLines[$-1].height;
			if (width < iLines[$-1].width)
				width = iLines[$-1].width;
		}

		Image ret = new MutableImage(width, height);
		auto _ = ret.rgba;

		foreach(i; 0 .. _.length) {
			_[i] = brushBKGD;
		}

		size_t yy;
		foreach(line; iLines) {
			auto __ = line.rgba;

			foreach(j, pixel; __) {
				size_t x = __.xFromIndex(j);
				size_t y = yy + __.yFromIndex(j);

				_[_.indexFromXY(x, y)] = pixel;
			}

			yy += line.height;
		}

		return ret;
	}
}

class GlyphLine {
	import devisualization.font.glyph;

	private {
		Glyph[] glyphs;
		Color_RGBA brushBKGD = new Color_RGBA(0f, 0f, 0f, 0f);
	}

	void opOpAssign(string type)(Glyph value) { // ~= adds a glyph to the line
		glyphs ~= value;
	}

	void remove(size_t theGlyph) { // removes a glyph from the line
		if (theGlyph == 0 && glyphs.length == 1) 
			glyphs = [];
		else if (theGlyph == glyphs.length - 1 && theGlyph > 0)
			glyphs = glyphs[0 .. $-1];
		else if (theGlyph == 0)
			glyphs = glyphs[1 .. $];
		else
			glyphs = glyphs[0 .. theGlyph] ~ glyphs[theGlyph + 1 .. $];
	}

	void removeLast(size_t amount = 1) { // removes the last glyph from the line
		if (amount < glyphs.length + 1)
			glyphs = glyphs[0 .. $-amount];
		else
			glyphs = [];

	}

	GlyphLineModifiers modifiers() {
		class LineModifiers : GlyphLineModifiers {
			void italize() { // makes it italisized
				foreach(glyph; glyphs) {
					glyph.modifiers.italize;
				}
			}

			void bold() { // makes it boldenized
				foreach(glyph; glyphs) {
					glyph.modifiers.bold;
				}
			}

			void width(uint width) { // scales
				foreach(glyph; glyphs) {
					glyph.modifiers.width(width);
				}
			}
			void kerning(ushort amount) { // adds width but doesn't scale
				foreach(glyph; glyphs) {
					glyph.modifiers.kerning(amount);
				}
			}

			void height(uint amount) { // scales
				foreach(glyph; glyphs) {
					glyph.modifiers.height(amount);
				}
			}

			void lineHeight(uint amount) { // adds height to glyph but doesn't scale
				foreach(glyph; glyphs) {
					glyph.modifiers.lineHeight(amount);
				}
			}

			void color(Color_RGBA primary, Color_RGBA background = null) {
				foreach(glyph; glyphs) {
					glyph.modifiers.color(primary, background);
				}

				brushBKGD = background;
			}

			void reset() { // reload image for glpyh
				foreach(glyph; glyphs) {
					glyph.modifiers.reset();
				}
			}
			
		}
		
		return new LineModifiers;
	}

	Image output() {
		import devisualization.image.mutable;
		Image[] iGlyphs;
		
		size_t ascent;
		size_t descent;
		size_t width;
		
		foreach(glyph; glyphs) {
			Image output = glyph.output();
			iGlyphs ~= output;

			width += output.width;
			if (ascent < glyph.ascent) {
				ascent = glyph.ascent;
			}
			if (descent < glyph.descent) {
				descent = glyph.descent;
			}
		}
		
		Image ret = new MutableImage(width, ascent + descent);
		auto _ = ret.rgba;

		foreach(i; 0 .. _.length) {
			_[i] = brushBKGD;
		}
		
		size_t xx;
		foreach(i, glyph; iGlyphs) {
			auto __ = glyph.rgba;

			foreach(j, pixel; __) {
				size_t x = xx + __.xFromIndex(j);
				size_t y = __.yFromIndex(j);

				y += ascent - glyphs[i].ascent;
				if (x >= ret.width || y >= ret.height)
					continue;

				_[_.indexFromXY(x, y)] = pixel;
			}
			
			xx += glyph.width;
		}
		
		return ret;
	}
}

interface GlyphSetModifiers {
    void italize(); // makes it italisized
    void bold(); // makes it boldenized
	void width(uint width); // scales
    void kerning(ushort amount); // adds width but doesn't scale
	void height(uint amount); // scales
	void lineHeight(uint amount); // adds height to glyph but doesn't scale
    void color(Color_RGBA primary, Color_RGBA background = null);
    
    void reset(); // reload image for glpyh
}

alias GlyphLineModifiers = GlyphSetModifiers;