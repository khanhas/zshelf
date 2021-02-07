import QtQuick 2.5
import QtQuick.Controls 2.4

Item {
    id: root
    signal activated(int index);
    property alias model: combo.model
    property alias text: name.text
    property alias curIndex: combo.currentIndex

    function setDefault(value) {
        const id = combo.find(value, Qt.MatchExactly);
        if (id !== -1) combo.currentIndex = id;
        else combo.currentIndex = 0;
    }

    function reset() {
        combo.currentIndex = 0;
    }

    function value() {
        return combo.currentText;
    }

    height: 100

    Text {
        id: name
        font.pixelSize: 35
        font.family: "Maison Neue"
        font.styleName: "Bold"
    }
    ComboBox {
        id: combo
        anchors {
            top: name.bottom
            topMargin: 20
        }
        width: parent.width
        height: 60

        font.family: "Maison Neue"
        font.styleName: "light"

        background: Rectangle {
            border.width: 2
            border.color: "black"
            color: "white"
            radius: 2
        }
        contentItem: Label {
            text: parent.currentText
            anchors {
                left: parent.left
                leftMargin: 15
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 2
            }
            verticalAlignment: Text.AlignVCenter
            color: "black"
        }

        delegate: ItemDelegate {
            width: root.width - 25
            contentItem: Text {
                text: modelData
                color: "black"
                font.family: "Maison Neue"
                font.styleName: "light"
                font.bold: combo.highlightedIndex === index
                verticalAlignment: Text.AlignVCenter
            }
        }

        popup: Popup {
            readonly property int columns: combo.model.length > 12 ? 2 : 1
            y: combo.height + 20
            width: root.width * columns
            implicitHeight: Math.min(contentItem.contentHeight + 20, 800)
            clip: true

            contentItem: GridView {
                id: grid
                flow: GridView.FlowLeftToRight
                model: combo.popup.visible ? combo.delegateModel : null
                currentIndex: combo.highlightedIndex
                cellWidth: root.width - 15
                cellHeight: combo.height

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }

            background: Rectangle {
                border.color: "black"
                border.width: 2
                radius: 3
            }
        }

        onActivated: parent.activated(index);
    }
}