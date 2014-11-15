module devisualization.font.glyph;
import devisualization.image;

interface Glyph {
    GlyphModifiers modifiers();
    Image output();
}

interface GlyphModifiers {
    void italize(); // makes it italisized
    void bold(); // makes it boldenized
    void width(float width); // scales
    void kerning(float amount); // adds width but doesn't scale
    void height(float amount); // scales
    void lineHeight(float amount); // adds height to glyph but doesn't scale
    void color(Color_RGBA primary, Color_RGBA background = null);

    void reset(); // reload image for glpyh
}