import QtQuick 2.0
import QuickKeyboard 1.0
import ".."

Mode {
	signal symbolsModeSwitched
	signal enter

	property variant btn_q:
		shift.pressed ?
			["Q", "Ω"] :
			["q", "\\"]
	property variant btn_w:
		shift.pressed ?
			acute.pressed ? ["Ẃ"] : ["W", "Ŵ", "Ẁ", "Ẇ", "Ẃ", "Ẅ", "Ł"] :
			acute.pressed ? ["ẃ"] : ["w", "ŵ", "ẘ", "ẁ", "ẇ", "ẃ", "ẅ", "|"]
	property variant btn_e:
		shift.pressed ?
			acute.pressed ? ["É"] : (caron.pressed ? ["Ě"] : ["E", "Ẽ", "Ě", "Ê", "Ĕ", "Ę", "È", "Ė", "É", "Ë", "Ȩ"]) :
			acute.pressed ? ["é"] : (caron.pressed ? ["ě"] : ["e", "ě", "ê", "ĕ", "ę", "è", "ė", "é", "ë", "ȩ", "€"])
	property variant btn_r:
		shift.pressed ?
			acute.pressed ? ["Ŕ"] : (caron.pressed ? ["Ř"] : ["R", "Ř", "Ṙ", "Ŕ", "Ŗ", "®"]) :
			acute.pressed ? ["ŕ"] : (caron.pressed ? ["ř"] : ["r", "ř", "ṙ", "ŕ", "ŗ", "¶"])
	property variant btn_t:
		shift.pressed ?
			caron.pressed ? ["Ť"] : ["T", "Ť", "Ṫ", "Ţ", "Ŧ"] :
			caron.pressed ? ["ť"] : ["t", "ť", "ṫ", "ẗ", "ţ", "ŧ"]
	property variant btn_y:
		shift.pressed ?
			acute.pressed ? ["Ý"] : ["Y", "Ỹ", "Ŷ", "Ỳ", "Ẏ", "Ý", "Ÿ", "¥"] :
			acute.pressed ? ["ý"] : ["y", "ỹ", "ŷ", "ẙ", "ỳ", "ẏ", "ý", "ÿ", "←"]
	property variant btn_u:
		shift.pressed ?
			acute.pressed ? ["Ú"] : (caron.pressed ? ["Ǔ"] : ["U", "Ũ", "Ǔ", "Û", "Ŭ", "Ů", "Ų", "Ù", "Ú", "Ű", "Ü", "Ǚ", "Ǜ", "Ǘ", "↑"]) :
			acute.pressed ? ["ú"] : (caron.pressed ? ["ǔ"] : ["u", "ũ", "ǔ", "û", "ŭ", "ů", "ų", "ù", "ú", "ű", "ü", "ǚ", "ǜ", "ǘ", "↓"])
	property variant btn_i:
		shift.pressed ?
			acute.pressed ? ["Í"] : (caron.pressed ? ["Ǐ"] : ["I", "Ĩ", "Ǐ", "Î", "Ĭ", "Į", "Ì", "İ", "Í", "Ï", "ı"]) :
			acute.pressed ? ["í"] : (caron.pressed ? ["ǐ"] : ["i", "ĩ", "ǐ", "î", "ĭ", "į", "ì", "ı", "í", "ï", "→"])
	property variant btn_o:
		shift.pressed ?
			acute.pressed ? ["Ó"] : (caron.pressed ? ["Ǒ"] : ["O", "Õ", "Ǒ", "Ô", "Ŏ", "Ǫ", "Ò", "Ȯ", "Ó", "Ő", "Ö", "Ø"]) :
			acute.pressed ? ["ó"] : (caron.pressed ? ["ǒ"] : ["o", "õ", "ǒ", "ô", "ŏ", "ǫ", "ò", "ȯ", "ó", "ő", "ö", "ø"])
	property variant btn_p:
		shift.pressed ?
			acute.pressed ? ["Ṕ"] : ["P", "Ṗ", "Ṕ", "Þ"] :
			acute.pressed ? ["ṕ"] : ["p", "ṗ", "ṕ", "þ"]
	property variant btn_a:
		shift.pressed ?
			acute.pressed ? ["Á"] : (caron.pressed ? ["Ǎ"] : ["A", "Ã", "Ǎ", "Â", "Ă", "Å", "Ą", "À", "Ȧ", "Á", "Ä", "Æ"]) :
			acute.pressed ? ["á"] : (caron.pressed ? ["ǎ"] : ["a", "ã", "ǎ", "â", "ă", "å", "ą", "à", "ȧ", "á", "ä", "~"])
	property variant btn_s:
		shift.pressed ?
			acute.pressed ? ["Ś"] : (caron.pressed ? ["Š"] : ["S", "Š", "Ŝ", "Ṡ", "Ś", "Ş", "§"]) :
			acute.pressed ? ["ś"] : (caron.pressed ? ["š"] : ["s", "š", "ŝ", "ṡ", "ś", "ş", "đ"])
	property variant btn_d:
		shift.pressed ?
			caron.pressed ? ["Ď"] : ["D", "Ď", "Ḋ", "Ḑ", "Đ"] :
			caron.pressed ? ["ď"] : ["d", "ď", "ḋ", "ḑ", "đ"]
	property variant btn_f:
		shift.pressed ?
			["F", "Ḟ", "ª"] : ["f", "ḟ", "["]
	property variant btn_g:
		shift.pressed ?
			acute.pressed ? ["Ǵ"] : (caron.pressed ? ["Ǧ"] : ["G", "Ǧ", "Ĝ", "Ğ", "Ġ", "Ǵ", "Ģ", "Ŋ"]) :
			acute.pressed ? ["ǵ"] : (caron.pressed ? ["ǧ"] : ["g", "ǧ", "ĝ", "ğ", "ġ", "ǵ", "ģ", "]"])
	property variant btn_h:
		shift.pressed ?
			caron.pressed ? ["Ȟ"] : ["H", "Ȟ", "Ĥ", "Ḣ", "Ḧ", "Ḩ", "Ħ"] :
			caron.pressed ? ["ȟ"] : ["h", "ȟ", "ĥ", "ḣ", "ḧ", "ḩ", "`"]
	property variant btn_j:
		shift.pressed ?
			["J", "Ĵ", "J́", "'"] :
			caron.pressed ? ["ǰ"] : ["j", "ǰ", "ĵ", "ȷ", " ̛"]
	property variant btn_k:
		shift.pressed ?
			acute.pressed ? ["Ḱ"] : (caron.pressed ? ["Ǩ"] : ["K", "Ǩ", "Ḱ", "Ķ", "&"]) :
			acute.pressed ? ["ḱ"] : (caron.pressed ? ["ǩ"] : ["k", "ǩ", "ḱ", "ķ", "ł"])
	property variant btn_l:
		shift.pressed ?
			acute.pressed ? ["Ĺ"] : (caron.pressed ? ["Ľ"] : ["L", "Ľ", "Ŀ", "Ĺ", "Ļ", "Ł"]) :
			acute.pressed ? ["ĺ"] : (caron.pressed ? ["ľ"] : ["l", "ľ", "ŀ", "ĺ", "ļ", "Ł"])
	property variant btn_z:
		shift.pressed ?
			acute.pressed ? ["Ź"] : (caron.pressed ? ["Ž"] : ["Z", "Ž", "Ẑ", "Ż", "Ź", "<"]) :
			acute.pressed ? ["ź"] : (caron.pressed ? ["ž"] : ["z", "ž", "ẑ", "ż", "ź", "°"])
	property variant btn_x:
		shift.pressed ?
			["X", "Ẋ", "Ẍ", ">"] : ["x", "ẋ", "ẍ", "#"]
	property variant btn_c:
		shift.pressed ?
			acute.pressed ? ["Ć"] : (caron.pressed ? ["Č"] : ["C", "Č", "Ĉ", "Ċ", "Ć", "Ç", "©"]) :
			acute.pressed ? ["ć"] : (caron.pressed ? ["č"] : ["c", "č", "ĉ", "ċ", "ć", "ç", "&"])
	property variant btn_v:
		shift.pressed ?
			["V", "Ṽ", "‘"] : ["v", "ṽ", "@"]
	property variant btn_b:
		shift.pressed ?
			["B", "Ḃ", "’"] : ["b", "ḃ", "{"]
	property variant btn_n:
		shift.pressed ?
			acute.pressed ? ["Ń"] : (caron.pressed ? ["Ň"] : ["N", "Ñ", "Ň", "Ǹ", "Ṅ", "Ń", "Ņ"]) :
			acute.pressed ? ["ń"] : (caron.pressed ? ["ň"] : ["n", "ñ", "ň", "ǹ", "ṅ", "ń", "ņ", "}"])
	property variant btn_m:
		shift.pressed ?
			acute.pressed ? ["Ḿ"] : ["M", "Ṁ", "Ḿ", "º"] :
			acute.pressed ? ["ḿ"] : ["m", "ṁ", "ḿ", "^"]
	property variant btn_dot:
		shift.pressed ?
			[",", ".", ":", ";", "!", "?"] : [".", ",", ":", ";", "!", "?"]

	layout: GridLayout{ rowLengths : [20, 0, 18, 0, 22, 0, 0, 24] }

    Btn { col:  0; row: 0; label: shift.pressed ? "Q" : "q"; symbols: btn_q }
    Btn { col:  2; row: 0; label: shift.pressed ? "W" : "w"; symbols: btn_w }
    Btn { col:  4; row: 0; label: shift.pressed ? "E" : "e"; symbols: btn_e }
    Btn { col:  6; row: 0; label: shift.pressed ? "R" : "r"; symbols: btn_r }
    Btn { col:  8; row: 0; label: shift.pressed ? "T" : "t"; symbols: btn_t }
    Btn { col: 10; row: 0; label: shift.pressed ? "Y" : "y"; symbols: btn_y }
    Btn { col: 12; row: 0; label: shift.pressed ? "U" : "u"; symbols: btn_u }
    Btn { col: 14; row: 0; label: shift.pressed ? "I" : "i"; symbols: btn_i }
    Btn { col: 16; row: 0; label: shift.pressed ? "O" : "o"; symbols: btn_o }
    Btn { col: 18; row: 0; label: shift.pressed ? "P" : "p"; symbols: btn_p }
	
	Btn { col:  0; row: 2; label: shift.pressed ? "A" : "a"; symbols: btn_a }
	Btn { col:  2; row: 2; label: shift.pressed ? "S" : "s"; symbols: btn_s }
	Btn { col:  4; row: 2; label: shift.pressed ? "D" : "d"; symbols: btn_d }
	Btn { col:  6; row: 2; label: shift.pressed ? "F" : "f"; symbols: btn_f }
	Btn { col:  8; row: 2; label: shift.pressed ? "G" : "g"; symbols: btn_g }
	Btn { col: 10; row: 2; label: shift.pressed ? "H" : "h"; symbols: btn_h }
	Btn { col: 12; row: 2; label: shift.pressed ? "J" : "j"; symbols: btn_j }
	Btn { col: 14; row: 2; label: shift.pressed ? "K" : "k"; symbols: btn_k }
	Btn { col: 16; row: 2; label: shift.pressed ? "L" : "l"; symbols: btn_l }

	Btn { col:  0; row: 4; GridLayout.colSpan: 4; icon: "png/shift"; id: shift; modifier: true; hasPreview: false }
	Btn { col:  4; row: 4; label: shift.pressed ? "Z" : "z"; symbols: btn_z }
	Btn { col:  6; row: 4; label: shift.pressed ? "X" : "x"; symbols: btn_x }
	Btn { col:  8; row: 4; label: shift.pressed ? "C" : "c"; symbols: btn_c }
	Btn { col: 10; row: 4; label: shift.pressed ? "V" : "v"; symbols: btn_v }
	Btn { col: 12; row: 4; label: shift.pressed ? "B" : "b"; symbols: btn_b }
	Btn { col: 14; row: 4; label: shift.pressed ? "N" : "n"; symbols: btn_n }
	Btn { col: 16; row: 4; label: shift.pressed ? "M" : "m"; symbols: btn_m }
	Btn { col: 18; row: 4; GridLayout.colSpan: 4; icon: "png/backspace"; hasPreview: false; symbols: ["\x7f"] }

	Btn { col:  0; row: 7; GridLayout.colSpan: 4; label: "123"; onTriggered: symbolsModeSwitched(); hasPreview: false; smallFont: true  }
	Btn { col:  4; row: 7; label: "´"; id: acute; modifier: true; hasPreview: false; onActiveChanged: if (active) caron.active = false }
	Btn { col:  6; row: 7; GridLayout.colSpan: 11; label: "space"; hasPreview: false; symbols: " "; hasBorder: true; smallFont: true }
	Btn { col: 18; row: 7; label: "ˇ"; id: caron; modifier: true; hasPreview: false; onActiveChanged: if (active) acute.active = false }
	Btn { col: 20; row: 7; GridLayout.colSpan: 4; label: "enter"; onTriggered: enter(); hasPreview: false; forceFlip: true; smallFont: true }
}
