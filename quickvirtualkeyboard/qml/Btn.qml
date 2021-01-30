import QtQuick 2.11
import QuickKeyboard 1.0
import QtQuick.Shapes 1.11

Button {
	id: btn
	property string icon
	property int row
	property int col
	property Item buttonPreview
	property bool hasPreview: false
	property bool hasBorder: false
	property bool forceFlip: false
	property bool smallFont: false
	GridLayout.row: row
	GridLayout.col: col
	GridLayout.colSpan: 2
	GridLayout.rowSpan: 2
    readonly property string fromColor: forceFlip ? "white" : "black"
    readonly property string toColor: forceFlip ? "black" : "white"

	Rectangle {
        id: background
		anchors.fill: parent
		// color: mouseDown || active ? toColor : fromColor
		color: fromColor
        border.width: hasBorder ? 4 : 0
        radius: hasBorder ? 2 : 0
        border.color: "white"
	}

	Text {
        id: keyName
		text: label
		color: toColor
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			right: parent.right
			leftMargin: 5
			rightMargin: 5
		}
		font.pixelSize: smallFont ? 26 : 32
        font.family: "Maison Neue"
		font.styleName: "Bold"
		maximumLineCount: 1
		horizontalAlignment: Text.AlignHCenter
	}

    Image {
        id: iconImg
        source: icon ? (icon + toColor) : ""
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

    }

	Component {
		id: buttonPreviewComponent
		BtnPreview {hasPreview: btn.hasPreview}
	}

	Timer {
		id: createPreviewTimer
		interval: 500

		onTriggered: {
			if (buttonPreview !== null) {
				buttonPreview.destroy();
				buttonPreview = null;
			}
			buttonPreview = buttonPreviewComponent.createObject(keyboardOverlay, {"btn": btn, "keyboard": keyboard});
		}
	}

    function lowState() {
        background.color = fromColor;
        keyName.color = toColor;
        iconImg.source = icon ? (icon + toColor) : "";
    }

    function highState() {
        background.color = toColor;
        keyName.color = fromColor;
        iconImg.source = icon ? (icon + fromColor) : "";
    }

    onMouseDownChanged: {
        if (modifier) return;

        if (mouseDown) {
            highState();
            createPreviewTimer.restart();
        } else {
            lowState();
            createPreviewTimer.stop();
            if (buttonPreview !== null) {
                buttonPreview.destroy();
                buttonPreview = null;
            }
        }
    }

    onActiveChanged: {
        if (active) highState();
        else lowState();
    }
}
