module devisualization.font.fontfamily;
import devisualization.font.font;
import devisualization.font.glyph;
import devisualization.image;

class FontFamily : Font {
	private {
		Font normal;
		Font bold;
		Font italize;
		Font boldItalize;
	}
	
	this(Font normal, Font bold, Font italize, Font boldItalize) {
		this.normal = normal;
		this.bold = bold;
		this.italize = italize;
		this.boldItalize = boldItalize;
	}
	
	Glyph get(char c) {  // gets a glyph for charactor
		import std.conv : to;
		return new FontFamilyGlyph(this, cast(wchar)c);
	}
	
	Glyph get(dchar c) { // "
		return new FontFamilyGlyph(this, cast(wchar)c);
	}
	
	Glyph get(wchar c) { // "
		return new FontFamilyGlyph(this, c);
	}
}


class FontFamilyGlyph : Glyph {
	private {
		FontFamily family;
		wchar c;
		
		bool italized_;
		bool bold_;
		uint width_;
		ushort kerning_;
		uint height_;
		uint lineHeight_;
		Color_RGBA primary_;
		Color_RGBA background_;
		
		bool tempChanged;
		Glyph temp;
		Image ret;
	}
	
	this(FontFamily family, wchar c) {
		this.family = family;
		this.c = c;
		tempChanged = true;
	}
	
	GlyphModifiers modifiers() {
		class FontFamilyGlyphModifiers : GlyphModifiers {
			void italize() { // makes it italisized
				italized_ = true;
				
				tempChanged = true;
			}
			
			void bold() { // makes it boldenized
				bold_ = true;
				
				tempChanged = true;
			}
			
			void width(uint width) { // scales
				width_ = width;
				
				tempChanged = true;
			}
			
			void kerning(ushort amount) { // adds width but doesn't scale
				kerning_ = amount;
				
				tempChanged = true;
			}
			
			void height(uint amount) { // scales
				height_ = amount;
				
				tempChanged = true;
			}
			
			void lineHeight(uint amount) { // adds height to glyph but doesn't scale
				lineHeight_ = amount;
				
				tempChanged = true;
			}
			
			void color(Color_RGBA primary, Color_RGBA background = null) {
				primary_ = primary;
				background_ = background;
				
				tempChanged = true;
			}
			
			void reset() { // reload image for glyph
				italized_ = false;
				bold_ = false;
				width_ = 0;
				kerning_ = 0;
				height_ = 0;
				lineHeight_ = 0;
				primary_ = null;
				background_ = null;
				
				tempChanged = true;
			}
		}
		
		return new FontFamilyGlyphModifiers;
	}
	
	Image output() {
		if (tempChanged) {
			tempChanged = false;
			Font theFont;
			
			bool needCallItalize;
			bool needCallBold;
			
			if (italized_ && bold_ && family.boldItalize !is null) {
				// italic is far harder then bolding
				theFont = family.boldItalize;
			} else if (italized_ && family.italize !is null) {
				theFont = family.italize;
				needCallBold = true;
			} else if (bold_ && family.bold !is null) {
				theFont = family.bold;
				needCallItalize = true;
			} else {
				theFont = family.normal;
				needCallBold = true;
				needCallItalize = true;
			}
			
			if (theFont is null) {
				throw new FontNotExportable("Unknown font");
			} else {
				temp = theFont.get(c);
				if (temp is null) {
					throw new FontNotExportable("Unknown symbol");
				} else {
					
					auto mods = temp.modifiers();
					if (bold_ && needCallBold)
						mods.bold();
					if (italized_ && needCallItalize)
						mods.italize();
					
					if (width_ > 0)
						mods.width(width_);
					if (kerning_ > 0)
						mods.kerning(kerning_);
					if (height_ > 0)
						mods.height(height_);
					if (lineHeight_ > 0)
						mods.lineHeight(lineHeight_);
					if (primary_ !is null || background_ !is null)
						mods.color(primary_, background_);
					
					ret = temp.output();
				}
			}
		}
		
		if (ret !is null)
			return ret;
		else
			throw new FontNotExportable("Not exported font");
	}
}