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
module devisualization.font.bdf.font;
import devisualization.font;

class BDFFont : Font {
    private {
        string name;
        string comments;
        ushort height;
        ushort width;

        BDFParsingGlyph[ushort] glyphs;
    }

    this(ubyte[] data) {
        parser(this, data);

        import std.stdio;
        writeln(comments);
        writeln(glyphs);
    }

    Glyph get(char c) {
        import devisualization.font.bdf.glyph;
        if (cast(ushort)c in glyphs) {
            return new BDFGlyph(this, cast(ushort)c, width, glyphs[cast(ushort)c].lines);
        }
        return null;
    }  // gets a glyph for charactor

    Glyph get(dchar c) {
        import devisualization.font.bdf.glyph;
        if (cast(ushort)c in glyphs) {
            return new BDFGlyph(this, cast(ushort)c, width, glyphs[cast(ushort)c].lines);
        }
        return null;
    } // "

    Glyph get(wchar c) {
        import devisualization.font.bdf.glyph;
        if (cast(ushort)c in glyphs) {
            return new BDFGlyph(this, cast(ushort)c, width, glyphs[cast(ushort)c].lines);
        }
        return null;
    } // "
}

private {
    void parser(BDFFont _, ubyte[] data) {
        with(_) {
            string buffer;
            BDFParsingGlyph glyph;

            foreach(c; cast(char[])data) {
                if (c == '\n') {
                    string keyword;
                    string[] values;

                    parseLine(_, buffer, keyword, values);
                    lineLogic(_, keyword, values, glyph);

                    buffer = "";
                } else {
                    buffer ~= c;
                }
            }

        }
    }

    void parseLine(BDFFont _, string line, out string keyword, out string[] values) {
        with(_) {
            string buffer;

            bool quoted;
            foreach(c; line) {
                if (quoted && c == '"') {
                    // seperate out value
                    quoted = false;
                    values ~= buffer;
                    buffer = "";
                } else if (!quoted && c == '"') {
                    quoted = true;
                    if (buffer != " ") {
                        // do something with previous buffer?
                    }
                    buffer = "";
                } else if (!quoted && c == ' ' && buffer != "") {
                    // not empty buffer, its a value or maybe keyword?
                    if (keyword == "") {
                        keyword = buffer;
                    } else {
                        values ~= buffer;
                    }

                    buffer = "";
                } else {
                    buffer ~= c;
                }
            }

            if (!quoted && buffer != "") {
                // not empty buffer, its a value or maybe keyword?
                if (keyword == "") {
                    keyword = buffer;
                } else {
                    values ~= buffer;
                }
            }
        }
    }

    void lineLogic(BDFFont _, string keyword, string[] values, ref BDFParsingGlyph glyph) {
        import std.string : toLower;
        import std.conv : to;

        with(_) {
            switch(keyword.toLower) {
                case "comment":
                    foreach(value; values) {
                        comments ~= value ~ "\n";
                    }
                    break;
                case "font_name":
                    foreach(value; values) {
                        name ~= value;
                    }
                    break;

                case "pixel_size":
                    foreach(value; values) {
                        height = to!ushort(value);
                    }
                    break;
                case "figure_width":
                    foreach(value; values) {
                        width = to!ushort(value);
                    }
                    break;

                case "startchar": 
                    glyph = new BDFParsingGlyph;
                    break;
                case "encoding":
                    if (glyph !is null) {
                        foreach(value; values) {
                            glyph.encoding = to!ushort(value);
                        }
                    }
                    break;
                case "bitmap":
                    if (glyph !is null) {
                        glyph.inBitmap = true;
                    }
                    break;
                case "endchar":
                    if (glyph !is null) {
                        glyph.inBitmap = false;
                        glyphs[glyph.encoding] = glyph;
                        glyph = null;
                    }
                    break;

                case "swidth":
                case "dwidth":
                case "bbx":
                    break;
                   
                default:
                    if (glyph !is null && glyph.inBitmap) {
                        glyph.lines ~= to!uint(keyword, 16);
                    }
                    break;
            }
        }
    }

    class BDFParsingGlyph {
        private  {
            ushort encoding;
            uint[] lines;

            bool inBitmap;
        }

        override string toString() {
            import std.conv : text;
            return "[ Encoding: " ~ text(encoding) ~ " \n\tValues: " ~ text(lines) ~ "\n]";
        }
    }
}