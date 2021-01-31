import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.0

Rectangle {
    id: canvas
    width: 1404
    height: 1872
    readonly property int screenMargin: 40
    readonly property int columns: 4
    readonly property int rows: 3
    readonly property int itemPerPage: rows * columns
    readonly property int bookWidth: (width - screenMargin * 2) / columns
    readonly property int itemContentWidth: bookWidth - 20

    Rectangle {
        id: closeApp
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: screenMargin
        width: 80
        height: 80
        radius: 40
        z: 1
        color: "black"
        Text {
            text: "x"
            font.family: "Maison Neue"
            font.bold: true
            font.pixelSize:40
            color: "white"
            anchors.centerIn: parent
            anchors.topMargin: 10
        }
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }


    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 40
        height: 100

        Rectangle {
            width: 250
            height: 80

            Image {
                source: "png/searchblack"
                width: 80
                height: 80
            }
            Text {
                text: "Search"
                font.pixelSize: 30

                font.family:"Maison Neue"
                font.styleName: "Demi"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                x: 100
            }
            MouseArea {
                anchors.fill: parent
                onClicked: queryUI.openSearch(true);
            }
        }
        Rectangle {
            width: accountStatusText.contentWidth + 60
            height: 60
            visible: store.accountStatus.length > 0
            border.color: "black"
            border.width: 3
            radius: 30
            color: "white"
            anchors {
                right: parent.right
                rightMargin: 120
                top: parent.top
                topMargin: 10
            }
            Text {
                id: accountStatusText
                text: store.accountStatus
                color: "black"
                font.pixelSize: 25
                font.family:"Maison Neue"
                font.styleName: "Medium"
                anchors.centerIn: parent
            }
        }
    }
    
    GridView {
        id: libView
        objectName: "libView"
        anchors.fill: parent
        anchors.margins: screenMargin
        anchors.topMargin: 140

        boundsBehavior: Flickable.StopAtBounds
        cellWidth: bookWidth
        cellHeight: bookWidth * 1.5 + 30
        model: store.books
        flickableDirection: Flickable.HorizontalFlick
        flow: GridView.TopToBottom
        clip: true
        snapMode: GridView.SnapToRow
        // pixelAligned: true
        flickDeceleration: 0
        onMovementEnded: currentIndex = indexAt(contentX, 0)

        delegate: Item {
            id: root
            width: libView.cellWidth
            height: libView.cellHeight
            
            Rectangle {
                id: background
                color: "white"
                anchors.fill: parent
            }
            Text {
                id: author
                text: model.modelData.author
                font.family:"Maison Neue"
                font.styleName: "Demi"
                font.pixelSize:25
                width: itemContentWidth
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: image.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 1
                wrapMode: Text.Wrap
            }
            Text {
                id: name
                text: model.modelData.name
                font.family:"Maison Neue"
                font.styleName: "Bold"
                font.pixelSize:25
                width: itemContentWidth
                anchors.horizontalCenter: image.horizontalCenter
                anchors.bottom: author.top
                anchors.bottomMargin: 5
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
            Image {
                id: image
                fillMode: Image.PreserveAspectFit
                height: name.y - 20
                source: model.modelData.imgFile
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                id: downloaded
                visible: model.modelData.status === "Downloaded"
                anchors.top: parent.top
                anchors.right: parent.right
                width: 40
                height: 40
                color: "black"

                Text {
                    text: "↓"
                    color: "white"
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family:"Maison Neue"
                    font.styleName: "Medium"
                    font.pixelSize:25
                }
            }
            
            MouseArea {
                anchors.fill: root
                onPressed: {
                    background.color = "black"
                    name.color = "white"
                    author.color = "white"
                }
                onReleased: {
                    background.color = "white"
                    name.color = "black"
                    author.color = "black"
                }
                onCanceled: {
                    background.color = "white"
                    name.color = "black"
                    author.color = "black"
                }
                onClicked: {
                    model.modelData.getDetail();
                    itemInfo.model = model.modelData;
                    itemInfo.popup.open();
                }
                onPressAndHold: {
                    return;
                }
            }
        }
    }

    
    Rectangle {
        property bool isClickable: (libView.currentIndex + itemPerPage) < libView.count
        id: goRight
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: screenMargin
        width: 80; height: 80; radius: 40
        color: isClickable ? "black" : "gray"
        Text {
            text: "v"
            font.family: "Maison Neue"
            font.bold: true
            font.pixelSize:40
            color: "white"
            anchors.centerIn: parent
        }
        transform: Rotation { 
            origin.x: 40;
            origin.y: 40; 
            angle: 270
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (parent.isClickable) {
                    libView.currentIndex += itemPerPage;
                } else {
                    return;
                }

                if (libView.currentIndex >= libView.count) {
                    libView.currentIndex = libView.count - itemPerPage + libView.count % itemPerPage;
                }
                libView.positionViewAtIndex(libView.currentIndex, GridView.Beginning);
            }
        }
    }

    
    Rectangle {
        property bool isClickable: (libView.currentIndex - itemPerPage) >= 0 ||
            (libView.currentIndex - rows) >= 0
        id: goLeft
        anchors.bottom: parent.bottom
        anchors.right: goRight.left
        anchors.margins: screenMargin
        width: 80; height: 80; radius: 40
        color: isClickable ? "black" : "gray"
        Text {
            text: "v"
            font.family: "Maison Neue"
            font.bold: true
            font.pixelSize:40
            color: "white"
            anchors.centerIn: parent
        }
        transform: Rotation { 
            origin.x: 40;
            origin.y: 40; 
            angle: 90
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (parent.isClickable) {
                    libView.currentIndex -= itemPerPage;
                } else {
                    return;
                }

                if (libView.currentIndex < 0) {
                    libView.currentIndex = 0
                }
                libView.positionViewAtIndex(libView.currentIndex, GridView.Beginning);
            }
        }
    }

    BookPopup {
        id: itemInfo
        anchors.fill: parent
    }
    
    Query {
        id: queryUI
        anchors.fill: parent
        z: 2
        storeFront: store
    }

    Image {
        z: 3
        source: "png/loading"
        visible: store.isBusy
        width: 100
        height: 100
        anchors.centerIn: parent
        onVisibleChanged: {
            if (!visible && queryUI.visible) {
                queryUI.visible = false;
            }
        }

        Rectangle {
            id: cancleButton
            color: "black"
            width: 200
            height: 70
            radius: 3
            anchors {
                top: parent.bottom
                topMargin: 40
                horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Cancel"
                color: "white"
                anchors.fill: parent
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family:"Maison Neue"
                font.styleName: "Bold"
                font.pixelSize: 30
            }
            MouseArea {
                anchors.fill: parent
                onClicked: store.stopQuery()
            }
        }
    }
}
