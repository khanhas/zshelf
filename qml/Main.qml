import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Rectangle {
    id: canvas
    width: screenGeometry.width
    height: screenGeometry.height
    readonly property int screenMargin: 40
    readonly property int columns: 4
    readonly property int rows: 3
    readonly property int itemPerPage: rows * columns
    readonly property int bookWidth: (width - screenMargin * 2) / columns
    readonly property int itemContentWidth: bookWidth - 20

    Rectangle {
        id: title
        visible: titleVisible
        z: 3
        anchors.fill: parent
        color: "white"
        Image {
            id: titleImg
            source: "svg/title"
            anchors.centerIn: parent
        }
    }

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
            id: accountStatus
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
                anchors.verticalCenterOffset: 2
            }
            MouseArea {
                anchors.fill: parent
                onClicked: downloadList.open()
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
                anchors.bottomMargin: 60
                anchors.horizontalCenter: parent.horizontalCenter
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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: author.top
                anchors.bottomMargin: 5
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
            
            Image {
                id: image
                fillMode: Image.PreserveAspectFit
                width: 200
                source: model.modelData.imgFile || "png/book"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -50
                Image {
                    visible: image.status === Image.Error
                    source: "png/book"
                    width: 52; height: 52
                    anchors.centerIn: parent
                }
            }

            Rectangle {
                id: downloadStatus
                visible: model.modelData.status === "Downloaded" ||
                    model.modelData.status.endsWith("%")
                anchors.top: parent.top
                anchors.right: parent.right
                width: Math.max(40, downloadStatusText.contentWidth + 20)
                height: 40
                color: "black"

                Text {
                    id: downloadStatusText
                    text: model.modelData.status === "Downloaded" ? "↓" : model.modelData.status
                    color: "white"
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 2
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
                    model.modelData.getDetail(itemInfo);
                    itemInfo.model = model.modelData;
                    itemInfo.open();
                }
                onPressAndHold: {
                    return;
                }
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: screenMargin
        anchors.bottomMargin: screenMargin + 10
        Repeater {
            model: store.totalPages
            Rectangle {
                width: 100; height: 60
                Rectangle {
                    id: bg
                    width: 80; height: 60
                    border.width: store.currentPage == index ? 2 : 0
                    border.color: "black"
                    radius: 30
                    color: "white"
                }
                Text {
                    text: (index + 1) * 50
                    anchors.centerIn: bg
                    anchors.verticalCenterOffset: 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Maison Neue"
                    font.styleName: "Medium"
                    font.pixelSize: 20
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (store.currentPage == index) {
                            return;
                        }
                        store.newQuery(index);
                    }
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
        // anchors.fill: parent
    }
    
    Query {
        id: queryUI
        anchors.fill: parent
        z: 2
        storeFront: store
    }

    DownloadPopup {
        id: downloadList
    }

    Text {
        id: errorMessage
        text: storeError
        font.family: "Maison Neue"
        font.styleName: "Medium"
        font.pixelSize: 40
        width: 800
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Rectangle {
        z: 4
        visible: store.isBusy
        color: "white"
        width: 400; height: 200
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 160

        Rectangle {
            id: progBarBase
            color: "black";
            width: 344
            height: 2
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            color: "black";
            width: storeProg * 344
            height: 15
            anchors.bottom: progBarBase.bottom
            anchors.left: progBarBase.left
        }

        onVisibleChanged: {
            if (!visible && queryUI.visible) {
                queryUI.visible = false;
            }
        }

        Rectangle {
            id: cancleButton
            visible: !titleVisible
            color: "black"
            width: 200
            height: 70
            radius: 3
            anchors {
                bottom: parent.bottom
                bottomMargin: 30
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
