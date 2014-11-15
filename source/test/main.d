import devisualization.font;
import devisualization.font.bdf;
import devisualization.image;

void main() {
    Font font = createFont("test/gohufont-uni-14.bdf");
    Image glyph_a = font.get('a').output();
}