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
module devisualization.font.font;
import devisualization.font.glyph;

alias FontNotExportable = Exception;

interface Font {
    //this(ubyte[] data);

    Glyph get(char c);  // gets a glyph for charactor
    Glyph get(dchar c); // "
    Glyph get(wchar c); // "

	final FontWithModifiers modifier() @property {
		return new FontWithModifiers(this);
	}
}

class FontWithModifiers : Font {
	private {
		import devisualization.image;
		Font font_;

		bool italize_;
		bool bold_;
		uint width_;
		ushort kerning_;
		uint height_;
		uint lineHeight_;
		Color_RGBA primary_;
		Color_RGBA background_;
	}

	this(Font font) {
		font_ = font;
	}

	@property {
		Font font() {
			return font_;
		}

		/**
		 * Modifies how future getting of glyphs works.
		 */
		GlyphModifiers modifiers() {
			class FontModifiers : GlyphModifiers {
				void italize() { // makes it italisized
					italize_ = true;
				}

				void bold() { // makes it boldenized
					bold_ = true;
				}

				void width(uint width) { // scales
					width_ = width;
				}

				void kerning(ushort amount) { // adds width but doesn't scale
					kerning_ = amount;
				}

				void height(uint amount) { // scales
					height_ = amount;
				}

				void lineHeight(uint amount) { // adds height to glyph but doesn't scale
					lineHeight_ = amount;
				}

				void color(Color_RGBA primary, Color_RGBA background = null) {
					primary_ = primary;
					background_ = background;
				}
				
				void reset() { // reload image for glyph
					italize_ = false;
					bold_ = false;
					width_ = 0;
					kerning_ = 0;
					height_ = 0;
					lineHeight_ = 0;
					primary_ = null;
					background_ = null;
				}
			}

			return new FontModifiers();
		}
	}

	Glyph get(char c) {  // gets a glyph for charactor
		Glyph ret = font_.get(c);
		modify(ret);
		return ret;
	}

	Glyph get(dchar c) { // "
		Glyph ret = font_.get(c);
		modify(ret);
		return ret;
	}

	Glyph get(wchar c) { // "
		Glyph ret = font_.get(c);
		modify(ret);
		return ret;
	}

	private {
		void modify(Glyph ret) {
			auto _ = ret.modifiers;
			if (italize_)
				_.italize();
			if (bold_)
				_.bold();
			if (width_ > 0)
				_.width(width_);
			if (kerning_ > 0)
				_.kerning(kerning_);
			if (height_ > 0)
				_.height(height_);
			if (lineHeight_ >  0)
				_.lineHeight(lineHeight_);
			if (primary_ !is null)
				_.color(primary_, background_);
		}
	}
}