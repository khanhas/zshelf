#include "store.h"

Worker *infoThread = nullptr;
const QString nodePath("/opt/bin/node");

Store::Store() : rootView(rootObject()), context(rootContext())
{
    worker = new Worker(nodePath, {}, true);

    if (loadConfig())
    {
        newQuery(_exactMatch, _fromYear, _toYear, _language, _extension, _order, _query);
    }
    else
    {
        qDebug() << "config.json malformed";
        newQuery("0", "2021", "2021", "English", "epub", "Most Popular", "");
    }

    if (_cookieAvailable) {
        infoThread = new Worker(nodePath, {QCoreApplication::applicationDirPath() + "/backend/info.js"}, true);
        connect(infoThread, &Worker::readAll, this, [this](QByteArray bytes) {
            QJsonParseError jsonError;
            QJsonDocument document = QJsonDocument::fromJson(bytes, &jsonError);
            if (jsonError.error != QJsonParseError::NoError)
            {
                qDebug() << "fromJson failed: " << jsonError.errorString();
                return;
            }
            if (!document.isObject())
                return;

            QJsonObject jsonObj = document.object();
            QString downloads = jsonObj.value("today_download").toString("");
            if (downloads.length() > 0)
            {
                auto counts = downloads.split("/");
                downloads.prepend("Downloads: ");
                if (counts[0] == counts[1])
                {
                    downloads.prepend("⚠️ ");
                }
                this->setProperty("accountStatus", downloads);
            }
        });
        infoThread->start();
    } else {
        setProperty("accountStatus", "⚠️ Cookie is not configured");
    }
}

Store::~Store()
{
    if (worker != nullptr)
        delete worker;

    if (infoThread != nullptr)
        delete infoThread;
}

void Store::newQuery(QString exactMatch, QString fromYear, QString toYear, QString language, QString extension, QString order, QString query)
{
    QStringList args = {
        QCoreApplication::applicationDirPath() + "/backend/list.js",
        exactMatch,
        fromYear,
        toYear,
        language,
        extension,
        order,
        query,
    };

    stopQuery();

    setProperty("isBusy", true);

    worker->args = args;

    connect(worker, &Worker::readAll, this, [this](QByteArray bytes) {
        QJsonParseError jsonError;
        QJsonDocument document = QJsonDocument::fromJson(bytes, &jsonError);
        if (jsonError.error != QJsonParseError::NoError)
        {
            qDebug() << "fromJson failed: " << jsonError.errorString();
            return;
        }

        if (!document.isArray())
            return;

        QList<QObject *> booksList;
        QJsonArray list = document.array();
        for (auto book : list)
        {
            if (!book.isObject())
                continue;

            QJsonObject bookObj = book.toObject();
            Book *item = new Book(this->rootView);
            item->setProperty("name", bookObj.value("name").toString());
            item->setProperty("author", bookObj.value("author").toString());
            item->setProperty("imgFile", bookObj.value("img").toString());
            item->setProperty("url", bookObj.value("url").toString());

            booksList.push_back(item);
        }

        setProperty("isBusy", false);

        for (auto oldBook : _books) {
            delete oldBook;
        }

        setProperty("books", QVariant::fromValue(booksList));
    });
    worker->start();
}

void Store::stopQuery()
{
    if (worker->isRunning())
        worker->terminate();
    setProperty("isBusy", false);
}

bool Store::loadConfig()
{
    QFile file(QCoreApplication::applicationDirPath() + "/config.json");

    if (!file.open(QIODevice::ReadOnly))
        return false;

    QByteArray bytes = file.readAll();
    file.close();

    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(bytes, &jsonError);
    if (jsonError.error != QJsonParseError::NoError)
    {
        qDebug() << "fromJson failed: " << jsonError.errorString();
        return false;
    }
    if (!document.isObject())
        return false;

    QJsonObject jsonObj = document.object();

    _cookieAvailable = jsonObj.value("cookie").toString("").length() > 0;

    QJsonValue defaultQueryValue = jsonObj.value("defaultQuery");
    if (!defaultQueryValue.isObject())
        return false;

    QJsonObject defaultQueryObj = defaultQueryValue.toObject();

    _exactMatch = defaultQueryObj.value("exactMatch").toString("");
    _fromYear = defaultQueryObj.value("fromYear").toString("");
    _toYear = defaultQueryObj.value("toYear").toString("");
    _language = defaultQueryObj.value("language").toString("");
    _extension = defaultQueryObj.value("extension").toString("");
    _order = defaultQueryObj.value("order").toString("");
    _query = defaultQueryObj.value("query").toString("");

    return true;
}

bool Store::setConfig(QString exactMatch, QString fromYear, QString toYear, QString language, QString extension, QString order, QString query)
{
    QFile file(QCoreApplication::applicationDirPath() + "/config.json");

    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "Can't open config.json in read-only";
        return false;
    }

    QByteArray bytes = file.readAll();
    file.close();

    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(bytes, &jsonError);
    if (jsonError.error != QJsonParseError::NoError)
    {
        qDebug() << "fromJson failed: " << jsonError.errorString();
        return false;
    }
    if (!document.isObject())
    {
        qDebug() << "config.json malformed";
        return false;
    }

    QJsonObject jsonObj = document.object();

    QJsonObject defaultQuery;

    defaultQuery.insert("exactMatch", exactMatch);
    defaultQuery.insert("fromYear", fromYear);
    defaultQuery.insert("toYear", toYear);
    defaultQuery.insert("language", language);
    defaultQuery.insert("extension", extension);
    defaultQuery.insert("order", order);
    defaultQuery.insert("query", query);

    jsonObj.remove("defaultQuery");
    jsonObj.insert("defaultQuery", defaultQuery);

    file.remove();
    if (!file.open(QIODevice::WriteOnly))
    {
        qDebug() << "Can't open config.json in write-only";
        return false;
    }

    QByteArray writeBytes = QJsonDocument(jsonObj).toJson(QJsonDocument::Indented);

    QTextStream iStream(&file);
    iStream.setCodec("utf-8");
    iStream << writeBytes;
    file.close();

    return true;
}

Book::Book(QObject *parent) : QObject(parent) {}

Book::~Book() {
    if (worker != nullptr) {
        delete worker;
    }
}

void Book::getDetail()
{
    if (_metadownloaded)
    {
        return;
    }

    qDebug() << "Meta downloading";

    QProcess proc;
    proc.start(nodePath, QStringList{QCoreApplication::applicationDirPath() + "/backend/metadata.js", _url}, QIODevice::ReadOnly);
    proc.waitForFinished();
    QByteArray bytes = proc.readAll();
    proc.close();

    qDebug() << "Meta downloaded";

    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(bytes, &jsonError);
    if (jsonError.error != QJsonParseError::NoError)
    {
        qDebug() << "fromJson failed: " << jsonError.errorString();
        setProperty("desc", bytes);
        return;
    }
    if (!document.isObject())
    {
        return;
    }
    QJsonObject detail = document.object();
    setProperty("dlUrl", detail.value("downloadURL").toString());
    setProperty("desc", detail.value("description").toString());
    setProperty("imgFile", detail.value("imgFile").toString());
    setProperty("status", "Download");
    _metadownloaded = true;
}

void Book::download()
{
    if (worker == nullptr) {
        worker = new Worker(nodePath, {QCoreApplication::applicationDirPath() + "/backend/download.js", _dlUrl});

        connect(worker, &Worker::updateProgress, this, &Book::updateProgress);
        connect(worker, &Worker::updateStatus, this, [this](QString stat) {
            qDebug() << "LOG: " << stat;
            if (stat.startsWith("ERR:"))
            {
                this->setProperty("status", QVariant(stat.trimmed()));
                this->worker->terminate();
            }
        });
    }
    this->setProperty("status", QVariant("Downloading"));
    worker->start();
}

void Book::updateProgress(int prog)
{
    if (prog == 100)
    {
        setProperty("status", QVariant("Downloaded"));
        if (infoThread != nullptr && !infoThread->isRunning())
        {
            infoThread->start();
        }
        return;
    }
    setProperty("status", QVariant(QString::number(prog) + "%"));
}