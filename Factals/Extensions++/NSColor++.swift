//  color0++.swift -- named colors

import SceneKit

extension NSColor {

         // MARK: - 2. Object Variables:
	var name : String? {	/// Find name for given color0
		let computedValueString		= fmt("#%2X%2X%2XFF", redComponent*255, greenComponent*255, blueComponent*255)
		for (colorName, colorValue) in fwColorSpace {
			if colorValue == computedValueString {
				return colorName
			}
		}
		return nil
	}
	func change(alphaTo:CGFloat? 				= nil,
				saturationBy satFactor:CGFloat 	= 1, 
				fadeTo fadeVal:CGFloat 			= 0.5) -> NSColor 
	{
		let fadeFinal				= fadeVal * (1 - satFactor)
		switch colorSpace.numberOfColorComponents {
		case 3:		// RGBA
			var r:CGFloat			= -1; var g = r; var b = r; var a = r
			getRed(&r, green:&g, blue:&b, alpha:&a)
			let rr					= pegBetween0n1(satFactor * r + fadeFinal)
			let gg					= pegBetween0n1(satFactor * g + fadeFinal)
			let bb					= pegBetween0n1(satFactor * b + fadeFinal)
			/// (set alpha from arg, or from NSColor)
			return NSColor(red:rr, green:gg, blue:bb, alpha:alphaTo ?? a)
		case 1:		// WA
			var a:CGFloat 			= -1; var w = a
			getWhite(&w, alpha:&a)
			return NSColor(white:pegBetween0n1(satFactor * w + fadeFinal), alpha:alphaTo ?? a)
		default:
			panic("NSColor \(colorSpace): change(alphaTo")
			return self
		}
	}
	 // MARK: - 3. Factory
	 /// N.B: color0 must have 4 components. Specifically, generic .white has 2
	public convenience init(mix cA:NSColor, with pctB:Float, of cB:NSColor) {
		let pB :CGFloat 	= pegBetween0n1(CGFloat(pctB))
		let pA :CGFloat 	= 1.0 - pB;
		let r				= cA  .redComponent * pA  +  cB  .redComponent * pB
		let g				= cA.greenComponent * pA  +  cB.greenComponent * pB
		let b				= cA .blueComponent * pA  +  cB .blueComponent * pB
		let a				= cA.alphaComponent * pA  +  cB.alphaComponent * pB
		self.init(red:r, green:g, blue:b, alpha:a)
	}
	public convenience init?(hexString: String) {
		if hexString.hasPrefix("#") {
			let hexColor 	= String(hexString.dropFirst())
			if hexColor.count == 8 {

				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0

				if scanner.scanHexInt64(&hexNumber) {
					let r, g, b, a: CGFloat
					r 		= CGFloat((hexNumber & 0xff000000) >> 24) / 255
					g 		= CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
					b 		= CGFloat((hexNumber & 0x0000ff00) >>  8) / 255
					a 		= CGFloat((hexNumber & 0x000000ff) >>  0) / 255

					self.init(red: r, green: g, blue: b, alpha: a)
					return
				}
			}
		}
		return nil
	}

    public convenience init?(_ name: String) {
		let n			= name
//		let n2			= n.removeUnneededSpaces()
        let cleanedName = n/*name*/.replacingOccurrences(of: " ", with: "").lowercased()
        if let hexString = fwColorSpace[cleanedName] {
            self.init(hexString: hexString)										}
        else {
            return nil															}
    }
    public convenience init(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat = 1.0) {
		self.init(red:r, green:g, blue:b, alpha:a)
	}
    public convenience init(random:CGFloat) {
		let r				= random * (CGFloat(arc4random()) / 0xFFFFFFFF)
		let g				= random * (CGFloat(arc4random()) / 0xFFFFFFFF)
		let b				= random * (CGFloat(arc4random()) / 0xFFFFFFFF)
		let a				=  			CGFloat(1)
		self.init(red:r, green:g, blue:b, alpha:a)
	}

	 /// mix==0 ==> use B
	func lerp(a:NSColor, b:NSColor, mixA:CGFloat) -> NSColor {
		let mixB 			= 1.0 - mixA
		return NSColor(calibratedRed: a  .redComponent * mixA + b  .redComponent * mixB,
							   green: a.greenComponent * mixA + b.greenComponent * mixB,
							    blue: a .blueComponent * mixA + b .blueComponent * mixB,
							   alpha: a.alphaComponent * mixA + b.alphaComponent * mixB)
	}

	 // MARK: - 15. PrettyPrint
	 /// Find a good color name for rgba, matching values within epsilon
	static func ppColor(scnString:String) -> String? {
		var scnStringS			= scnString
		if scnString.contains("NSImage") {
			return "NSImage"
		}

		enum KnownColorSpaces : String {
			case rgb 			= "sRGB IEC61966-2.1 colorspace "
			case gray 			= "Generic Gray Gamma 2.2 Profile colorspace "
		}
		var colorSpace :KnownColorSpaces? = nil

		 // Find kind of ColorSpace
		for cs in [KnownColorSpaces.rgb, KnownColorSpaces.gray] {
			if scnStringS.contains(cs.rawValue) {
				scnStringS		= scnStringS.replacingOccurrences(of:cs.rawValue, with:"")
				colorSpace		= cs
			}
		}
		assert(colorSpace != nil, "Didn't find a known color space")
	
		 // Find values (e.g. rgb, rgba, grey, ...) of color
		var values : [Int]	= []
		for str in scnStringS.split(separator:" ") {			 /// %1.4f:
			let str1			= str.replacingOccurrences(of:">", with:"")
			if let flo			= Float(str1) {
				let num1		= min(Int(flo * 256), 0xff)
				values.append(num1)
			}else{ 				panic("Illegal Float value \(str1)") 			}
		}	

		 // convert all collers to rgba array
		switch colorSpace! {
		case .rgb:
			nop
		case .gray:
			values.insert(values[0], at:0)		// pad out gray to r, g, and b
			values.insert(values[0], at:0)
		}
		assert(values.count == 4, "could not convert color to four RGBA values")

		 // See if a color for this is defined
		let wantHex			= fmt("#%02X%02X%02X%02X", values[0], values[1], values[2], values[3])
		for (name, hex) in fwColorSpace {
			if hex == wantHex {
				return name
			}
		}
		return wantHex
	}
	 // MARK: - 16. Global Constants
	static let whiteX		= NSColor("white")!	// this white is in colorspace 1 1 1 1
}

 // for open/close bulb/frob
let systemColor					= NSColor(hexString:"#8080ff80") ?? .white	//"#c0c0ff40"

let fwColorSpace = [	//	rrggbbaa
	"aliceblue"			: "#F0F8FFFF",		"antiquewhite"		: "#FAEBD7FF",
	"aqua"				: "#00FFFFFF",		"aquamarine"		: "#7FFFD4FF",
	"azure"				: "#F0FFFFFF",		"beige"				: "#F5F5DCFF",
	"bisque"			: "#FFE4C4FF",		"black"				: "#000000FF",
	"blanchedalmond"	: "#FFEBCDFF",		"blue"				: "#0000FFFF",
	"blueviolet"		: "#8A2BE2FF",		"brown"				: "#A52A2AFF",
	"burlywood"			: "#DEB887FF",		"cadetblue"			: "#5F9EA0FF",
	"chartreuse"		: "#7FFF00FF",		"chocolate"			: "#D2691EFF",
	"coral"				: "#FF7F50FF",		"cornflowerblue"	: "#6495EDFF",
	"cornsilk"			: "#FFF8DCFF",		"crimson"			: "#DC143CFF",
	"cyan"				: "#00FFFFFF",		"darkblue"			: "#00008BFF",
	"darkcyan"			: "#008B8BFF",		"darkgoldenrod"		: "#B8860BFF",
	"darkgray"			: "#A9A9A9FF",		"darkgrey"			: "#A9A9A9FF",
	"darkgreen"			: "#004000FF",	//	"darkgreen"			: "#006400FF",
	"darkkhaki"			: "#BDB76BFF",		"darkmagenta"		: "#8B008BFF",
	"darkolivegreen"	: "#556B2FFF",		"darkorange"		: "#FF8C00FF",
	"darkorchid"		: "#9932CCFF",		"darkred"			: "#800000FF",
	"darksalmon"		: "#E9967AFF",		"darkseagreen"		: "#8FBC8FFF",
	"darkslateblue"		: "#483D8BFF",		"darkslategray"		: "#2F4F4FFF",
	"darkslategrey"		: "#2F4F4FFF",		"darkturquoise"		: "#00CED1FF",
	"darkviolet"		: "#9400D3FF",		"deeppink"			: "#FF1493FF",
	"deepskyblue"		: "#00BFFFFF",		"dimgray"			: "#696969FF",
	"dimgrey"			: "#696969FF",		"dodgerblue"		: "#1E90FFFF",
	"firebrick"			: "#B22222FF",		"floralwhite"		: "#FFFAF0FF",
	"forestgreen"		: "#228B22FF",		"fuchsia"			: "#FF00FFFF",
	"gainsboro"			: "#DCDCDCFF",		"ghostwhite"		: "#F8F8FFFF",
	"gold"				: "#FFD700FF",		"goldenrod"			: "#DAA520FF",
	"gray"				: "#808080FF",		"grey"				: "#808080FF",
	"green"				: "#00FF00FF",		"greenyellow"		: "#ADFF2FFF",
	"honeydew"			: "#F0FFF0FF",		"hotpink"			: "#FF69B4FF",
	"indianred"			: "#CD5C5CFF",		"indigo"			: "#4B0082FF",
	"ivory"				: "#FFFFF0FF",		"khaki"				: "#F0E68CFF",
	"lavender"			: "#E6E6FAFF",		"lavenderblush"		: "#FFF0F5FF",
	"lawngreen"			: "#7CFC00FF",		"lemonchiffon"		: "#FFFACDFF",
	"lightblue"			: "#ADD8E6FF",		"lightcoral"		: "#F08080FF",
	"lightcyan"			: "#E0FFFFFF",		"lightgoldenrodyellow":"#FAFAD2FF",
	"lightgray"			: "#D3D3D3FF",		"lightgrey"			: "#D3D3D3FF",
	"lightgreen"		: "#90EE90FF",		"lightpink"			: "#FFB6C1FF",
	"lightsalmon"		: "#FFA07AFF",		"lightseagreen"		: "#20B2AAFF",
	"lightskyblue"		: "#87CEFAFF",		"lightslategray"	: "#778899FF",
	"lightslategrey"	: "#778899FF",		"lightsteelblue"	: "#B0C4DEFF",
	"lightyellow"		: "#FFFFE0FF",		"lime"				: "#00FF00FF",
	"limegreen"			: "#32CD32FF",		"linen"				: "#FAF0E6FF",
	"magenta"			: "#FF00FFFF",		"maroon"			: "#800000FF",
	"mediumaquamarine"	: "#66CDAAFF",		"mediumblue"		: "#0000CDFF",
	"mediumorchid"		: "#BA55D3FF",		"mediumpurple"		: "#9370D8FF",
	"mediumseagreen"	: "#3CB371FF",		"mediumslateblue"	: "#7B68EEFF",
	"mediumspringgreen"	: "#00FA9AFF",		"mediumturquoise"	: "#48D1CCFF",
	"mediumvioletred"	: "#C71585FF",		"midnightblue"		: "#191970FF",
	"mintcream"			: "#F5FFFAFF",		"mistyrose"			: "#FFE4E1FF",
	"moccasin"			: "#FFE4B5FF",		"navajowhite"		: "#FFDEADFF",
	"navy"				: "#000080FF",		"oldlace"			: "#FDF5E6FF",
	"olive"				: "#808000FF",		"olivedrab"			: "#6B8E23FF",
	"orange"			: "#FFA500FF",		"orangered"			: "#FF4500FF",
	"orchid"			: "#DA70D6FF",		"palegoldenrod"		: "#EEE8AAFF",
	"palegreen"			: "#98FB98FF",		"paleturquoise"		: "#AFEEEEFF",
	"palevioletred"		: "#D87093FF",		"papayawhip"		: "#FFEFD5FF",
	"peachpuff"			: "#FFDAB9FF",		"peru"				: "#CD853FFF",
	"pink"				: "#FFC0CBFF",		"plum"				: "#DDA0DDFF",
	"powderblue"		: "#B0E0E6FF",		"purple"			: "#800080FF",
	"rebeccapurple"		: "#663399FF",		"red"				: "#FF0000FF",
/*	"darkred"			: "#800000FF",*/	"rosybrown"			: "#BC8F8FFF",
	"royalblue"			: "#4169E1FF",		"saddlebrown"		: "#8B4513FF",
	"salmon"			: "#FA8072FF",		"sandybrown"		: "#F4A460FF",
	"seagreen"			: "#2E8B57FF",		"seashell"			: "#FFF5EEFF",
	"sienna"			: "#A0522DFF",		"silver"			: "#C0C0C0FF",
	"skyblue"			: "#87CEEBFF",		"slateblue"			: "#6A5ACDFF",
	"slategray"			: "#708090FF",		"slategrey"			: "#708090FF",
	"snow"				: "#FFFAFAFF",		"springgreen"		: "#00FF7FFF",
	"steelblue"			: "#4682B4FF",		"tan"				: "#D2B48CFF",
	"teal"				: "#008080FF",		"thistle"			: "#D8BFD8FF",
	"tomato"			: "#FF6347FF",		"turquoise"			: "#40E0D0FF",
	"violet"			: "#EE82EEFF",		"wheat"				: "#F5DEB3FF",
	"white"				: "#FFFFFFFF",		"whitesmoke"		: "#F5F5F5FF",
	"yellow"			: "#FFFF00FF",		"yellowgreen"		: "#9ACD32FF",

	"verylightgray"		: "#E0E0E0FF",		"invisible"			: "#00000000",	//PAK
]


//https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-html-name-string-into-a-uicolor
//CGColorRetain([NSColor colorWithCalibratedRed:0 green:100 blue:0 alpha:0.5f].CGColor);
//class NNSColor : NSColor, Codable {
//	enum NSColorKeys: String, CodingKey {
//		case r,g,b, a
//	}
//	public func encode(to encoder: Encoder) throws  {
//		var container 			= encoder.container(keyedBy:NSColorKeys.self)
//
//		try container.encode(redComponent,   forKey:.r)
//		try container.encode(greenComponent, forKey:.g)
//		try container.encode(blueComponent,  forKey:.b)
//		try container.encode(alphaComponent, forKey:.a)
//		logSer(3, logg("Encoded  as? NSColor"))
//	}
////	public required init(from decoder: Decoder) throws {
////	}
//	required convenience init(from decoder: Decoder) throws {
//		let container 			= try decoder.container(keyedBy:NSColorKeys.self)
//
//		let r 					= try container.decode(Float.self, forKey:.r)
//		let g 					= try container.decode(Float.self, forKey:.g)
//		let b 					= try container.decode(Float.self, forKey:.b)
//		let a 					= try container.decode(Float.self, forKey:.a)
//
//		self.init(_colorLiteralRed:r, green:g, blue:b, alpha:a)
////		self = NSColor(red:r, green:g, blue:b, alpha:a)
//
//		logSer(3, logg("Decoded  as? NSColor"))
//	}
//}
//extension NSColor : Codable {
//	//'required' initializer must be declared directly in class 'NSColor' (not in an extension)
//	public required convenience init(from decoder: Decoder) throws {
//		debugger("irrelevant")
//	}
//
//	public func encode(to encoder: Encoder) throws {
//		debugger("irrelevant")
//	}
//
//	enum NSColorKeys: String, CodingKey {
//		case r,g,b, a
//	}
//	public func encode(to encoder: Encoder) throws  {
//		var container 			= encoder.container(keyedBy:NSColorKeys.self)
//		try container.encode(redComponent,   forKey:.r)
//		try container.encode(greenComponent, forKey:.g)
//		try container.encode(blueComponent,  forKey:.b)
//		try container.encode(alphaComponent, forKey:.a)
//		logSer(3, logg("Encoded  as? NSColor"))
//	}
////    public required init(from decoder: Decoder) throws {
////    }
//	required convenience public init(from decoder: Decoder) throws {
//		let container 			= try decoder.container(keyedBy:NSColorKeys.self)
//		let r 					= try container.decode(CGFloat.self, forKey:.r)
//		let g 					= try container.decode(CGFloat.self, forKey:.g)
//		let b 					= try container.decode(CGFloat.self, forKey:.b)
//		let a 					= try container.decode(CGFloat.self, forKey:.a)
//
//        self.init(red:r, green:g, blue:b, alpha:a)
////		self = NSColor(red:r, green:g, blue:b, alpha:a)
//
//		logSer(3, logg("Decoded  as? NSColor"))
//	}
//}
