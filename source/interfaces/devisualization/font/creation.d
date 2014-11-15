module devisualization.font.creation;
import devisualization.font.font;

private __gshared {
    Font delegate(ubyte[])[string] fontCreators;
}

void registerFont(string type, Font delegate(ubyte[]) creator) {
    fontCreators[type] = creator;
}

Font createFont(string file) {
    import std.file : read;
    import std.path : extension;
    return createFont(extension(file)[1 ..$], cast(ubyte[])read(file));
}

Font createFont(string type, ubyte[] data) {
    if (type in fontCreators) {
        return fontCreators[type](data);
    } else {
        return null;
    }
}