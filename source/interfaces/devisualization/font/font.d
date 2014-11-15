module devisualization.font.font;
import devisualization.font.glyph;

interface Font {
    //this(ubyte[] data);

    Glyph get(char c);  // gets a glyph for charactor
    Glyph get(dchar c); // "
    Glyph get(wchar c); // "
}