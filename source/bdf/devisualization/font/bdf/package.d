module devisualization.font.bdf;
public import devisualization.font.bdf.font;

shared static this() {
    import devisualization.font;
    Font creator(ubyte[] data) {
        return new BDFFont(data);
    }

    registerFont("bdf", &creator);
}
