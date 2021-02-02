#include "store.h"

Worker *infoThread = nullptr;

Store::Store() : rootView(rootObject()), context(rootContext())
{
    worker = new Worker({}, true);
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
            Book *item = new Book();
            item->setProperty("name", bookObj.value("name").toString());
            item->setProperty("author", bookObj.value("author").toString());
            item->setProperty("imgFile", bookObj.value("img").toString());
            item->setProperty("url", bookObj.value("url").toString());

            booksList.push_back(item);
        }

        setProperty("isBusy", false);

        for (auto oldBook : _books)
        {
            delete oldBook;
        }

        setProperty("books", QVariant::fromValue(booksList));
    });

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
        infoThread = new Worker({"INFO"}, true);
        connect(infoThread, &Worker::readAll, this, [this](QByteArray bytes) {
            QJsonParseError jsonError;
            QJsonDocument document = QJsonDocument::fromJson(bytes, &jsonError);
            if (jsonError.error != QJsonParseError::NoError)
            {
                qDebug() << "fromJson failed: " << jsonError.errorString();
                qDebug() << "ERR: " << bytes;
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
        infoThread->work();
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
    
    if (serverProc != nullptr)
        delete serverProc;
}

void Store::newQuery(QString exactMatch, QString fromYear, QString toYear, QString language, QString extension, QString order, QString query)
{
    QStringList args = {
        "LIST",
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
    worker->work();
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

Book::~Book() {
    if (worker != nullptr) {
        delete worker;
    }
}

void Book::getDetail(QObject* popup)
{
    if (_metadownloaded)
    {
        return;
    }

    Worker *metaWorker = new Worker({"META", _url}, true);
    connect(metaWorker, &Worker::readAll, this, [this, metaWorker, popup](QByteArray bytes) {
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
        setProperty("name", detail.value("name").toString());
        setProperty("author", detail.value("author").toString());
        setProperty("dlUrl", detail.value("dlUrl").toString());
        setProperty("desc", detail.value("description").toString());
        setProperty("imgFile", detail.value("img").toString());

        QJsonArray similarsArray = detail.value("similars").toArray();
        QList<QObject *> recList;
        for (auto recom : similarsArray)
        {
            QJsonObject bookObj = recom.toObject();
            Book *item = new Book();
            item->setProperty("imgFile", bookObj.value("img").toString());
            item->setProperty("url", bookObj.value("url").toString());
            recList.push_back(item);
        }
        setProperty("similars", QVariant::fromValue(recList));

        setProperty("status", "Download");
        _metadownloaded = true;
        popup->setProperty("isBusy", false);

        qDebug() << "Meta downloaded";
        delete metaWorker;
    });

    qDebug() << "Meta downloading";
    popup->setProperty("isBusy", true);
    metaWorker->work();
}

void Book::download()
{
    if (worker == nullptr) {
        worker = new Worker({"DOWN", _dlUrl});

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
    worker->work();
}

void Book::updateProgress(int prog)
{
    if (prog == 100)
    {
        setProperty("status", QVariant("Downloaded"));
        if (infoThread != nullptr && !infoThread->isRunning())
        {
            infoThread->work();
        }
        return;
    }
    setProperty("status", QVariant(QString::number(prog) + "%"));
}