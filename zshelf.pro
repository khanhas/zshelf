TEMPLATE = app
QT += quick
CONFIG += c++11
LIBS += -lqsgepaper

TARGET = zshelf

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES = main.cpp \
    store.cpp

HEADERS = \
    worker.h \
    store.h

RESOURCES += qml.qrc

include(quickvirtualkeyboard/components.pri)

DEPLOYMENT_PATH = /usr/share/$$TARGET
DEFINES += DEPLOYMENT_PATH=\\\"$$DEPLOYMENT_PATH\\\"
DEFINES += QML_FOLDER=\\\"qml\\\"

# Installs /etc/draft and /lib/systemd/system/draft.service.
configFile.files=config.json
configFile.path =/etc/zshelf
INSTALLS += configFile

backend.files = backend
backend.path=/etc/zshelf
INSTALLS += backend

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

target.path = /usr/bin
INSTALLS += target

MOC_DIR = mocs
OBJECTS_DIR = objs