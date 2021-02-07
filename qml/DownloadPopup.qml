import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Popup {
    id: downloadPopup
    width: 500
    height: Math.min(downloadListView.contentHeight + 10, 1000)
    x: accountStatus.x + accountStatus.width - 500 + screenMargin
    y: accountStatus.y + accountStatus.height + 60

    leftPadding: 20; rightPadding: 20
    topPadding: 5; bottomPadding: 5

    closePolicy: Popup.CloseOnPressOutside
    dim: true
    Overlay.modeless: Rectangle {
        color: "transparent"
        MouseArea {
            anchors.fill: parent
        }
    }
    background: Rectangle {
        anchors.fill: parent
        color: "white"
        border.width: 3
        border.color: "black"
        radius: 5
    }

    ListView {
        id: downloadListView
        width: 500 - parent.padding * 2
        anchors.fill: parent
        model: store.downloadList
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        flickDeceleration: 0

        delegate: Item {
            id: root
            width: parent.width
            height: 120
            Rectangle {
                id: wrapper
                width: parent.width
                height: parent.height
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                Text {
                    id: name
                    text: model.modelData.name
                    font.family: "Maison Neue"
                    font.styleName: "Medium"
                    font.pixelSize: 22
                    width: 350
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    id: downloadStatusText
                    visible: model.modelData.status === "Downloaded" ||
                        model.modelData.status.endsWith("%")
                    text: model.modelData.status === "Downloaded" ? "↓  " : model.modelData.status
                    color: "black"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    font.family:"Maison Neue"
                    font.styleName: "Bold"
                    font.pixelSize: 30
                }
                Rectangle {
                    color: "gray"
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        model.modelData.getDetail(itemInfo);
                        itemInfo.model = model.modelData;
                        downloadPopup.close();
                        itemInfo.open();

                    }
                    onPressAndHold: {
                        return;
                    }
                }
            }
        }
    }
}