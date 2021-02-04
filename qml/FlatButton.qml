import QtQuick 2.5
import QtQuick.Controls 2.4

Item {
    signal tapped;
    property alias bgColor: button.color
    property alias fgColor: name.color
    property alias text: name.text
    property int borderWidth: 0

    Rectangle {
        id: button
        width: parent.width
        height: 80
        radius: 3
        border.color: name.color
        border.width: borderWidth

        MouseArea {
            id: click
            anchors.fill: parent
            onClicked: tapped()
        }
    }
    
    Text {
        id: name
        anchors.centerIn: button
        anchors.verticalCenterOffset: 2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Maison Neue"
        font.styleName: "Bold"
        font.pixelSize: 30
    }
}