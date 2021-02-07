import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Popup {
    property var model;
    property bool isBusy;

    id: bookPopup

    width: 1000
    height: 1300
    x: (parent.width / 2) - (width / 2)
    y: (parent.height / 2) - (height / 2) + 150
    closePolicy: Popup.CloseOnPressOutside
    dim: true
    padding: 40

    Overlay.modeless: Rectangle {
        color: "#90ffffff"
        MouseArea {
            anchors.fill: parent
        }
    }

    background: Rectangle {
        border.width: 2
        border.color: "black"
        radius: 5
    }

    onOpened: bar.currentIndex = 0;

    contentChildren: [
        Image {
            id: bookImage
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: model ? model.imgFile : ""
            width: 400
            height: 400 * 1.5
            anchors.horizontalCenter: parent.horizontalCenter
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
        },
        Text {
            id: bookName
            text: model ? model.name : ""
            anchors {
                left: parent.left; right: parent.right
                top: bookImage.bottom
                topMargin: 30
            }
            font.family:"Maison Neue"
            font.styleName: "Bold"
            font.pixelSize: 40
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        },
        Text {
            id: bookAuthor
            text: model ? model.author : ""
            anchors {
                left: parent.left; right: parent.right
                top: bookName.bottom
                topMargin: 20
            }
            font.family:"Maison Neue"
            font.styleName: "Medium"
            font.pixelSize: 35
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        },
        TabBar {
            id: bar
            visible: !isBusy
            anchors {
                left: parent.left; right: parent.right
                top: bookAuthor.bottom
                topMargin: 30
            }
            font.pixelSize: 25
            TabButton {
                contentItem: Label {
                    text: "Details"
                    color: bar.currentIndex == 0 ? "black" : "gray"
                    font.underline: bar.currentIndex == 0
                    horizontalAlignment: Text.AlignHCenter
                }
                background: Rectangle {}
            }
            TabButton {
                contentItem: Label {
                    text: "Similar books"
                    color: bar.currentIndex == 1 ? "black" : "gray"
                    font.underline: bar.currentIndex == 1
                    horizontalAlignment: Text.AlignHCenter
                }
                background: Rectangle {}
            }
        },
        StackLayout {
            id: stack
            anchors {
                left: parent.left; right: parent.right
                top: bar.bottom
                topMargin: 30
                bottom: parent.bottom
                bottomMargin: 30
            }
            currentIndex: bar.currentIndex
            Item {
                Flickable {
                    anchors.fill: parent
                    contentHeight: bookDesc.height
                    clip: true
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds

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
            }
            Item {
                GridView {
                    id: recGrid
                    anchors.fill: parent
                    boundsBehavior: Flickable.StopAtBounds
                    cellHeight: stack.height / 2
                    cellWidth: cellHeight / 1.5
                    model: bookPopup.model ? bookPopup.model.similars : []
                    flickableDirection: Flickable.HorizontalFlick
                    flow: GridView.TopToBottom
                    clip: true
                    snapMode: GridView.SnapToRow
                    flickDeceleration: 0
                    delegate: Item {
                        id: itemRoot
                        width: recGrid.cellWidth
                        height: recGrid.cellHeight
                        Image {
                            id: image
                            fillMode: Image.PreserveAspectCrop
                            source: model.modelData.imgFile || "png/book"
                            anchors.fill: itemRoot
                            anchors.margins: 10
                            Image {
                                visible: image.status === Image.Error
                                source: "png/book"
                                width: 52; height: 52
                                anchors.centerIn: parent
                            }
                        }
                        MouseArea {
                            anchors.fill: itemRoot
                            onClicked: {
                                model.modelData.getDetail(bookPopup);
                                bar.currentIndex = 0;
                                bookPopup.model = model.modelData;
                            }
                        }
                    }
                }
            }
        },
        Image {
            z: 1
            source: "png/loading"
            visible: isBusy
            width: 60
            height: 60
            anchors.centerIn: parent
        }
    ]

    FlatButton {
        id: download
        visible: !isBusy
        width: 300
        x: parent.width - 220
        y: parent.height - 5
        bgColor: "black"
        fgColor: "white"
        text: !model || !model.dlUrl ? "Unavailable" : model.status
        onTapped: {
            if(!model || !model.dlUrl || model.status !== "Download") {
                return
            }
            store.download(model);
        }
    }
}