import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.0

Item {
    property var model;

    property Popup popup: Popup {
        id: bookPopup
        width: 1000
        height: 1300
        x: (parent.width / 2) - (width / 2)
        y: (parent.height / 2) - (height / 2) + 150
        closePolicy: Popup.CloseOnPressOutside
        dim: true
        Overlay.modeless: Rectangle {
            color: "#505050f0"
            MouseArea {
                anchors.fill: parent
            }
        }

        Image {
            id: bookImage
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: model ? model.imgFile : ""
            width: 400
            height: 400 * 1.5
            x: parent.width / 2 - 400 / 2
            y: -(parent.height / 2 - height / 2)
            ProgressBar {
                visible: parent.progress < 1.0
                value: parent.progress
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 80
                }
            }
        }
        Text {
            id: bookName
            text: model ? model.name : ""
            width: parent.width - 90
            x: 30
            anchors.top: bookImage.bottom
            anchors.topMargin: 30
            font.family:"Maison Neue"
            font.styleName: "Bold"
            font.pixelSize: 40
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: bookAuthor
            text: model ? model.author : ""
            width: bookName.width
            x: bookName.x
            anchors.top: bookName.bottom
            anchors.topMargin: 20
            font.family:"Maison Neue"
            font.styleName: "Medium"
            font.pixelSize: 35
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        Flickable {
            anchors.top: bookAuthor.bottom
            anchors.topMargin: 30
            anchors.leftMargin: 100
            anchors.rightMargin: 100
            x: 30
            width: bookPopup.width - 80
            height: parent.height - bookAuthor.y - bookAuthor.height - 110
            contentHeight: bookDesc.height
            clip: true
            Text {
                id: bookDesc
                textFormat: Text.RichText
                text: model ? model.desc : ""
                font.family:"EB Garamond"
                font.styleName: "Medium"
                font.pixelSize: 30
                width: parent.width
                wrapMode: Text.Wrap
            }
        }
        
        Rectangle {
            width: 300
            height: 80
            x: parent.width - 260
            y: parent.height - 30
            color: "black"
            Text {
                anchors.centerIn: parent
                text: !model || !model.dlUrl ? "Unavailable" : model.status
                font.family:"Maison Neue"
                font.styleName: "Medium"
                font.pixelSize: 30
                color: "white"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(!model || model.status !== "Download") {
                        return
                    }
                    model.download();
                }
            }
        }
    }
}