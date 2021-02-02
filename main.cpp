#include <QtQuick>
#include <QtGui>
#include <QtPlugin>
#include "store.h"
#include "quickvirtualkeyboard/register.h"

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

    QFontDatabase::addApplicationFont(":/fonts/MaisonNeue-Bold");
    QFontDatabase::addApplicationFont(":/fonts/MaisonNeue-Demi");
    QFontDatabase::addApplicationFont(":/fonts/MaisonNeue-Medium");

    view.engine()->addImportPath(QStringLiteral(DEPLOYMENT_PATH));
    registerQmlTypes();
    view.setSource(QUrl(QStringLiteral("qrc:/Main.qml")));

    QObject::connect(view.engine(), &QQmlEngine::quit, &QGuiApplication::quit);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [&view]() { delete &view; });

    view.show();
    return app.exec();
}
