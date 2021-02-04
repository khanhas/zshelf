import QtQuick 2.5
import QtQuick.Controls 2.4

Item {
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

    anchors {
        leftMargin: 33
        top: searchBox.bottom
        topMargin: 30
    }

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
            font.family: "Maison Neue"
            font.styleName: "light"
            color: "black"
        }
        onActivated: parent.activated(index);
    }
}