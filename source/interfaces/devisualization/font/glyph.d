module devisualization.font.glyph;
import devisualization.image;

interface Glyph {
    GlyphModifiers modifiers();
    Image output();
}

interface GlyphModifiers {
    void italize(); // makes it italisized
    void bold(); // makes it boldenized
	void width(uint width); // scales
	void kerning(ushort amount); // adds width but doesn't scale
	void height(uint amount); // scales
	void lineHeight(uint amount); // adds height to glyph but doesn't scale
    void color(Color_RGBA primary, Color_RGBA background = null);

    void reset(); // reload image for glyph
}