module devisualization.font.glyphset;
import devisualization.image.color;
import devisualization.image;

interface GlyphSet {
    GlyphLine opIndex(size_t line);
    void removeLine(size_t line); // removes a line but remember it invalidates all GlyphLine's gotten previously
    GlyphSetModifiers modifiers();

    Image output();
}

interface GlyphLine {
    void opOpAssign(string type)(Glyph value); // ~= adds a glyph to the line
    void remove(size_t theGlyph); // removes a glyph from the line
    void removeLast(size_t amount = 1); // removes the last glyph from the line

    Image output();
}

interface GlyphSetModifiers {
    void italize(); // makes it italisized
    void bold(); // makes it boldenized
    void width(float width); // scales
    void kerning(float amount); // adds width but doesn't scale
    void height(float amount); // scales
    void lineHeight(float amount); // adds height to glyph but doesn't scale
    void color(Color_RGBA primary, Color_RGBA background = null);
    
    void lineWrap(double max); // wraps the the glyph lines on to a new next one based upon its width
    void reset(); // reload image for glpyh
}