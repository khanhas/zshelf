import QtQuick 2.2
import QuickKeyboard 1.0

Item {
	id: preview

	property bool hasPreview: false

	property Item keyboard
	property Item btn

	property int backgroundBorder: 3
	property int padding: 10

	property int centeredX: -width / 2 + btn.width / 2 + btn.x
	property int minX: - backgroundBorder
	property int maxX: btn.parent.width - width + backgroundBorder
    property bool initTouch: true

	x: Math.max(Math.min(centeredX, maxX), minX)
	y: btn.y - height
	width: buttonContent.width + backgroundBorder * 2
	height: buttonContent.height + backgroundBorder * 2
	visible: symbolsItems.count > 0
    
    Rectangle {
        id: shadow
        x: 10
        y: 5
        width: background.width - 20
        height: background.height
        color: "darkgray"
        radius: 4
	}

	Rectangle {
        id: background
        anchors.fill: parent
        color: "white"
        border.color: "black"
        border.width: backgroundBorder
        radius: 4
	}

    Component {
        id: textPreview
        
        Rectangle {
            property bool active: (index == currentSymbolIndex)
            color: active ? "black" : "transparent"
            width: 70
            height: 160

            Text {
                id: labelPreview
                anchors.fill: parent
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: active ? "white" : "black"
                font.family: "Noto Sans"
                font.pixelSize: 50
                font.weight: Font.Bold
                
            }
        }
    }

	Item {
		id: buttonContent
		x: backgroundBorder
        y: backgroundBorder
		height: 160
        width: chars.width
		Row {
			id: chars
			Repeater {
				id: symbolsItems
				model: 0
				delegate: textPreview
			}
		}

		MultiPointTouchArea {
			id: buttonsArea
			anchors.fill: parent
			onPressed: {
				symbolsItems.visible = true
                symbolsItems.model = symbols
			}
			onReleased: {
				if (touchPoints.length == 1) {
					btn.triggered();
				}
			}
			onTouchUpdated: {
				if (touchPoints.length > 0) {
                    if (initTouch) {
                        initTouch = false;
                        currentSymbolIndex = Math.floor(symbolsItems.count / 2)
                        return;
                    }
					var touchPoint = touchPoints[0];
					var underMouseIndex = Math.floor(touchPoint.x * symbolsItems.count / chars.width);
					if (underMouseIndex < 0) {
						underMouseIndex = 0;
					}
					if (underMouseIndex >= symbolsItems.count) {
						underMouseIndex = symbolsItems.count - 1;
					}
					currentSymbolIndex = underMouseIndex;
				}
			}
		}
	}

	Timer {
		interval: 500
		running: mouseDown && symbols.length > 1
		onTriggered: btn.GridLayout.layout.redirectEventsToItem(buttonsArea)
	}
}
