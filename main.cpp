#include <QtQuick>
#include <QtGui>
#include <QtPlugin>
#include "store.h"
#include "quickvirtualkeyboard/register.h"
#include "grayImage.h"

Q_IMPORT_PLUGIN(QsgEpaperPlugin)

int main(int argc, char *argv[])
{
    qputenv("QMLSCENE_DEVICE", "epaper");
    qputenv("QT_QPA_PLATFORM", "epaper:enable_fonts");
    qputenv("QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS", "rotate=180");

    QGuiApplication app(argc, argv);

    Store view;
    qmlRegisterType<Store>();

    auto context = view.rootContext();
    context->setContextProperty("screenGeometry", app.primaryScreen()->geometry());
    context->setContextProperty("store", &view);
    context->setContextProperty("storeProg", QVariant(0));
    context->setContextProperty("storeError", QVariant(""));
    context->setContextProperty("titleVisible", QVariant(true));

    QFontDatabase::addApplicationFont(":/fonts/MaisonNeue-Bold");
    QFontDatabase::addApplicationFont(":/fonts/MaisonNeue-Demi");
    QFontDatabase::addApplicationFont(":/fonts/MaisonNeue-Medium");

    view.engine()->addImportPath(QStringLiteral(DEPLOYMENT_PATH));
    view.engine()->addImageProvider(QLatin1String("gray"), new GrayImageProvider);
    registerQmlTypes();
    view.setSource(QUrl(QStringLiteral("qrc:/Main.qml")));

    QObject::connect(view.engine(), &QQmlEngine::quit, &QGuiApplication::quit);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [&view]() { delete &view; });

    view.show();
    view.open();

    return app.exec();
}
