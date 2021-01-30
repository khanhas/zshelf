import QtQuick 2.0
import QuickKeyboard 1.0
import ".."

Mode {
	signal standardModeSwitched
	signal symbolsModeSwitched
	signal enter

	layout: GridLayout{ rowLengths : [20, 0, 18, 0, 24, 0, 0, 24] }

	Btn { col:  0; row: 0; label: "~"; symbols: ["~"] }
	Btn { col:  2; row: 0; label: "$"; symbols: ["$"] }
	Btn { col:  4; row: 0; label: "£"; symbols: ["£"] }
	Btn { col:  6; row: 0; label: "¥"; symbols: ["¥"] }
	Btn { col:  8; row: 0; label: "§"; symbols: ["§"] }
	Btn { col: 10; row: 0; label: "&"; symbols: ["&"] }
	Btn { col: 12; row: 0; label: "@"; symbols: ["@"] }
	Btn { col: 14; row: 0; label: "©"; symbols: ["©"] }
	Btn { col: 16; row: 0; label: "®"; symbols: ["®"] }
	Btn { col: 18; row: 0; label: "°"; symbols: ["°"] }

	Btn { col:  0; row: 2; label: "="; symbols: ["="] }
	Btn { col:  2; row: 2; label: "#"; symbols: ["#"] }
	Btn { col:  4; row: 2; label: "|"; symbols: ["|"] }
	Btn { col:  6; row: 2; label: "_"; symbols: ["_"] }
	Btn { col:  8; row: 2; label: "+"; symbols: ["+"] }
	Btn { col: 10; row: 2; label: "-"; symbols: ["-"] }
	Btn { col: 12; row: 2; label: "/"; symbols: ["/"] }
	Btn { col: 14; row: 2; label: "*"; symbols: ["*"] }
	Btn { col: 16; row: 2; label: "%"; symbols: ["%"] }

	Btn { col:  0; row: 4; GridLayout.colSpan: 4; label: "12"; hasPreview: false; onTriggered: symbolsModeSwitched(); }
	Btn { col:  4; row: 4; label: "("; symbols: ["("] }
	Btn { col:  6; row: 4; label: ")"; symbols: [")"] }
	Btn { col:  8; row: 4; label: "["; symbols: ["["] }
	Btn { col: 10; row: 4; label: "]"; symbols: ["]"] }
	Btn { col: 12; row: 4; label: "{"; symbols: ["{"] }
	Btn { col: 14; row: 4; label: "}"; symbols: ["}"] }
	Btn { col: 16; row: 4; label: "<"; symbols: ["<"] }
	Btn { col: 18; row: 4; label: ">"; symbols: [">"] }
	Btn { col: 20; row: 4; GridLayout.colSpan: 4; icon: "png/backspace"; hasPreview: false; symbols: ["\x7f"] }

	Btn { col:  0; row: 7; GridLayout.colSpan: 4; label: "ABC"; onTriggered: standardModeSwitched(); hasPreview: false; smallFont: true  }
	Btn { col:  6; row: 7; GridLayout.colSpan: 11; label: "space"; hasPreview: false; symbols: " "; hasBorder: true; smallFont: true }
	Btn { col: 20; row: 7; GridLayout.colSpan: 4; label: "enter"; hasPreview: false; onTriggered: enter(); forceFlip: true; smallFont: true }
}
