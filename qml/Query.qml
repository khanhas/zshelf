import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.0
import QuickKeyboard 1.0
import "modes"

Item {
    property variant storeFront;

    id: searchUI
    visible: false

    function openSearch(open) {
        if (open) {
            searchUI.visible = true
            keyboard.dispatcher.setFocusObject(textInput);
        } else {
            searchUI.visible = false;
        }
    }

    function sendQuery() {
        storeFront.newQuery(
            exactMatch.position,
            fromYear.currentText,
            toYear.currentText,
            language.currentText,
            extension.currentText,
            order.currentText,
            textInput.text
        );
    }

    Rectangle {
        id: background
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
        }
    }

    Rectangle {
        id: searchBox
        color: "black"
        height: 90
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Image {
            source: "png/search"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 40
            width: 50
            height: 50
        }

        TextField  {
            id: textInput
            font.pixelSize: 35
            color: "white"
            font.family: "Maison Neue"
            anchors { fill: parent; verticalCenter: parent.verticalCenter; topMargin: 10 }
            clip: true
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 120
            anchors.rightMargin: 40 + 150
            placeholderText: "Search for title, author, ISBN, publisher, md5..."
            background: Rectangle {
                anchors.fill: parent
                color: "black"
            }
        }

        Rectangle {
            visible: textInput.text.length > 0
            color: "black"
            border.color: "white"
            border.width: 3
            width: 130
            height: 50
            radius: 4
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 40
            }
            Text {
                text: "Clear"
                font.pixelSize: 25
                color: "white"
                font.family: "Maison Neue"
                font.bold: true
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: textInput.text = ""
            }
        }
    }

    
    ComboBox {
        id: fromYear
        model: {
            let a = ["Any"];
            let thisYear = (new Date).getFullYear();
            while (thisYear >= 1800) {
                a.push(thisYear);
                thisYear--;
            }
            return a;
        }
        anchors {
            left: parent.left
            top: searchBox.bottom
            topMargin: 90
            leftMargin: 40
        }
        width: 200
        height: 60
        Text {
            text: "From"
            font.pixelSize: 35
            font.family: "Maison Neue"
            font.styleName: "Medium"
            anchors {
                bottom: parent.top
                bottomMargin: 10
            }
        }
        Component.onCompleted: currentIndex = find(storeFront.fromYear, Qt.MatchExactly)
    }
    ComboBox {
        id: toYear
        model: fromYear.model
        anchors {
            left: fromYear.right
            top: searchBox.bottom
            topMargin: 90
            leftMargin: 30
        }
        width: 200
        height: 60
        Text {
            text: "To"
            font.pixelSize: 35
            font.family: "Maison Neue"
            font.styleName: "Medium"
            anchors {
                bottom: parent.top
                bottomMargin: 10
            }
        }
        Component.onCompleted: currentIndex = find(storeFront.toYear, Qt.MatchExactly)
    }
    ComboBox {
        id: language
        anchors {
            left: toYear.right
            top: searchBox.bottom
            topMargin: 90
            leftMargin: 30
        }
        width: 300
        height: 60
        model: ["Any","Afrikaans","Albanian","Arabic","Armenian","Azerbaijani","Bashkir","Belarusian","Bengali","Berber","Bulgarian","Catalan","Chinese","Crimean Tatar","Croatian","Czech","Danish","Dutch","English","Esperanto","Finnish","French","Georgian","German","Greek","Gujarati","Hebrew","Hindi","Hungarian","Icelandic","Indigenous","Indonesian","Italian","Japanese","Kannada","Kazakh","Kirghiz","Korean","Latin","Latvian","Lithuanian","Malayalam","Marathi","Mongolian","Nepali","Norwegian","Odia","Persian","Polish","Portuguese","Romanian","Russian","Sanskrit","Serbian","Sinhala","Slovak","Slovenian","Somali","Spanish","Swahili","Swedish","Tajik","Tamil","Tatar","Telugu","Turkish","Ukrainian","Urdu","Uzbek","Vietnamese"]
        Text {
            text: "Language"
            font.pixelSize: 35
            font.family: "Maison Neue"
            font.styleName: "Medium"
            anchors {
                bottom: parent.top
                bottomMargin: 10
            }
        }
        Component.onCompleted: currentIndex = find(storeFront.language, Qt.MatchExactly)
    }

    ComboBox {
        id: extension
        anchors {
            left: language.right
            top: searchBox.bottom
            topMargin: 90
            leftMargin: 30
        }
        width: 200
        height: 60
        model: ["Any","pdf","epub","djvu","fb2","txt","rar","mobi","lit","doc","rtf","azw3"]
        Text {
            text: "Extension"
            font.pixelSize: 35
            font.family: "Maison Neue"
            font.styleName: "Medium"
            anchors {
                bottom: parent.top
                bottomMargin: 10
            }
        }
        Component.onCompleted: currentIndex = find(storeFront.extension, Qt.MatchExactly)
    }

    ComboBox {
        id: order
        anchors {
            left: extension.right
            top: searchBox.bottom
            topMargin: 90
            leftMargin: 30
        }
        width: 300
        height: 60
        model: [ "Most Popular", "Best Match", "Recently added", "By Title (A-Z)", "By Title (Z-A)", "By Year", "File Size Asc.", "File Size Des." ]
        Text {
            text: "Sort by"
            font.pixelSize: 35
            font.family: "Maison Neue"
            font.styleName: "Medium"
            anchors {
                bottom: parent.top
                bottomMargin: 10
            }
        }
        Component.onCompleted: currentIndex = find(storeFront.order, Qt.MatchExactly)
    }

    Switch {
        id : exactMatch
        text: "Exact match"
        anchors {
            left: fromYear.left
            top: fromYear.bottom
            topMargin: 30
        }
        Component.onCompleted: storeFront.exactMatch == "1" && toggle()
    }

    Rectangle {
        id: startQuery
        width: 200
        height: 80
        color: "black"
        radius: 3
        anchors {
            right: parent.right
            top: exactMatch.bottom
            topMargin: 40
            rightMargin: 40
        }
        Text {
            color: "white"
            text: "Search"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family:"Maison Neue"
            font.styleName: "Bold"
            font.pixelSize: 30
        }

        MouseArea {
            anchors.fill: parent
            onClicked: sendQuery()
        }
    }

    Rectangle {
        width: 350
        height: 80
        color: "white"
        border.color: "black"
        border.width: 3
        radius: 3
        anchors {
            right: startQuery.left
            top: exactMatch.bottom
            topMargin: 40
            rightMargin: 20
        }
        Text {
            id: setDefaultText
            color: "black"
            text: "Set as default query"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family:"Maison Neue"
            font.styleName: "Bold"
            font.pixelSize: 30
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                storeFront.setConfig(
                    exactMatch.position,
                    fromYear.currentText,
                    toYear.currentText,
                    language.currentText,
                    extension.currentText,
                    order.currentText,
                    textInput.text
                );

                setDefaultText.text = "✔";
                resetButtonText.start()
            }
        }
        Timer {
            id: resetButtonText
            interval: 3000; running: false; repeat: false
            onTriggered: setDefaultText.text = "Set as default query";
        }
    }

    Keyboard {
        id: keyboard
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 626

        Rectangle {
            anchors.fill: parent
            color: "black"
        }

        mode: standard

        Standard {
            id: standard
            anchors.fill: parent
            anchors.topMargin: 93
            onSymbolsModeSwitched: keyboard.mode = symbols
            onEnter: sendQuery()
        }

        Symbols {
            id: symbols
            anchors.fill: parent
            anchors.topMargin: 93
            onStandardModeSwitched: keyboard.mode = standard
            onSymbolsModeSwitched: keyboard.mode = symbols2
            onEnter: sendQuery()
        }

        Symbols2 {
            id: symbols2
            anchors.fill: parent
            anchors.topMargin: 93
            onStandardModeSwitched: keyboard.mode = standard
            onSymbolsModeSwitched: keyboard.mode = symbols
            onEnter: sendQuery()
        }
    }

    Rectangle {
        id: closeSearchUI
        width: 80
        height: 80
        radius: 40
        color: "black"
        anchors {
            right: parent.right
            bottom: keyboard.top
            margins: 40
        }
        Text {
            text: "v"
            font.family: "Maison Neue"
            font.bold: true
            color: "white"
            anchors.centerIn: parent
            font.pixelSize:40
        }
        MouseArea {
            anchors.fill: parent
            onClicked: openSearch(false)
        }
    }

    Item {
        id: keyboardOverlay
        anchors.fill: keyboard
    }
}