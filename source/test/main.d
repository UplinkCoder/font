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
import devisualization.font;
import devisualization.image;

void main() {
	import devisualization.image.png;
	Font font;

	version(Have_de_font_bdf) {
		import devisualization.font.bdf;
		font = createFont("test/gohufont-uni-14.bdf");
	} else version(Have_de_font_opentype) {
		import devisualization.font.opentype;
		font = createFont("test/Roboto-Regular.ttf");
	} else {
		static assert(0, "No font provider available");
	}

	GlyphSet letters;
	GlyphLine line;

	// { bold

	line = letters[0];
	foreach(c; 'A' .. 'Z' + 1) {
		line ~= font.get(c);
	}
	line.modifiers().bold();

	line = letters[1];
	foreach(c; 'a' .. 'z' + 1) {
		line ~= font.get(c);
	}
	line.modifiers().bold();

	// bold }
	// { italize

	line = letters[2];
	foreach(c; 'A' .. 'Z' + 1) {
		line ~= font.get(c);
	}
	line.modifiers().italize();

	line = letters[3];
	foreach(c; 'a' .. 'z' + 1) {
		line ~= font.get(c);
	}
	line.modifiers().italize();

	// italize }
	// {

	line = letters[4];
	foreach(c; 'A' .. 'Z' + 1) {
		line ~= font.get(c);
	}
	
	line = letters[5];
	foreach(c; 'a' .. 'z' + 1) {
		line ~= font.get(c);
	}

	// }

	letters.modifiers().kerning(2);
	letters.output().convertTo("png").exportTo("lines.png");
}