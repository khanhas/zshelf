import QtQuick 2.0
import QuickKeyboard 1.0
import "modes"

// import QtGraphicalEffects 1.0

Item {
	id: main
	width: 1404; height: 1872

	Rectangle {
		color: "black"
		height: 100
		// border { left: 9; top: 9; right: 9; bottom: 9 }
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
		}

		TextEdit {
			id: textInput
			font.pixelSize: 40
			color: "white"
			anchors { fill: parent; verticalCenter: parent.verticalCenter; }
			clip: true
		}
	}

	Keyboard {
		id: keyboard
		anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
		height: 626
		Component.onCompleted: keyboard.dispatcher.setFocusObject(textInput)

		Rectangle {
			anchors.fill: parent
			color: "black"
			// border { left: 1; top: 12; right: 1; bottom: 1 }
		}

		mode: standard

		Standard {
			id: standard
			anchors.fill: parent
			anchors.topMargin: 93
			onSymbolsModeSwitched: keyboard.mode = symbols
		}

		Symbols {
			id: symbols
			anchors.fill: parent
			anchors.topMargin: 93
			onStandardModeSwitched: keyboard.mode = standard
			onSymbolsModeSwitched: keyboard.mode = symbols2
		}

		Symbols2 {
			id: symbols2
			anchors.fill: parent
			anchors.topMargin: 93
			onStandardModeSwitched: keyboard.mode = standard
			onSymbolsModeSwitched: keyboard.mode = symbols
		}
	}

	Item {
		id: keyboardOverlay
		anchors.fill: keyboard
	}
}
