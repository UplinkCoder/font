module devisualization.font.bdf.glyph;
import devisualization.font;
import devisualization.font.bdf.font;
import devisualization.image;

class BDFGlyph : Glyph {
    private {
        BDFFont font;
        uint[] originalLines;
        ushort originalWidth;
        ushort originalEncodedValue;

        uint[] lines;
        ushort width;
        ushort height;
        Color_RGBA brush;
        Color_RGBA brushBKGD;
    }

    this(BDFFont font, ushort encoded, ushort width, uint[] lines) {
        this.font = font;
        this.originalEncodedValue = encoded;
        this.originalWidth = width;
        this.originalLines = lines;

        brush = new Color_RGBA(0, 0, 0, 1f);
        brushBKGD = new Color_RGBA(0, 0, 0, 0f);
    }

    GlyphModifiers modifiers() {
        return null;
    }

    Image output() {
        import devisualization.image.mutable;
        MutableImage image = new MutableImage(height, width);

        size_t index;
        foreach(line; lines) {
            for (size_t i = 0; i < width; i++) {
                image.rgba[index] = (line & (1 << i)) ? brush : brushBKGD;
                index++;
            }
        }

        return image;
    }
}