#ifndef STORE_H
#define STORE_H

#include <QObject>
#include <QtQuick>
#include <QQuickView>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include "worker.h"

class Book : public QObject
{
    Q_OBJECT

public:
    Book(QObject* parent) : QObject(parent) {};
    ~Book();

    Q_PROPERTY(QString imgFile MEMBER _imgFile NOTIFY imgFileChanged)
    Q_PROPERTY(QString name MEMBER _name NOTIFY nameChanged)
    Q_PROPERTY(QString author MEMBER _author NOTIFY authorChanged)
    Q_PROPERTY(QString url MEMBER _url NOTIFY urlChanged)
    Q_PROPERTY(QString desc MEMBER _desc NOTIFY descChanged)
    Q_PROPERTY(QString dlUrl MEMBER _dlUrl NOTIFY dlUrlChanged)
    Q_PROPERTY(QString status MEMBER _status NOTIFY statusChanged)
    Q_PROPERTY(QList<QObject *> similars MEMBER _similars NOTIFY similarsChanged)

    Q_INVOKABLE void getDetail(QObject *popup);

    void updateProgress(int prog);

signals:
    void imgFileChanged(QString);
    void nameChanged(QString);
    void authorChanged(QString);
    void urlChanged(QString);
    void descChanged(QString);
    void dlUrlChanged(QString);
    void statusChanged(QString);
    void similarsChanged(QList<QObject *>);

public:
    Worker *worker = nullptr;
    QString _imgFile;
    QString _name;
    QString _author;
    QString _url;
    QString _desc;
    QString _dlUrl;
    QString _status;
    QList<QObject *> _similars;
    bool _metadownloaded = false;
};

class Store : public QQuickView
{
    Q_OBJECT
public:
    Q_PROPERTY(QList<QObject *> books MEMBER _books NOTIFY booksChanged)
    Q_PROPERTY(QList<QObject *> downloadList MEMBER _downloadList NOTIFY downloadListChanged)
    Q_PROPERTY(bool isBusy MEMBER _isBusy NOTIFY isBusyChanged)
    Q_PROPERTY(QString exactMatch MEMBER _exactMatch)
    Q_PROPERTY(QString fromYear MEMBER _fromYear)
    Q_PROPERTY(QString toYear MEMBER _toYear)
    Q_PROPERTY(QString language MEMBER _language)
    Q_PROPERTY(QString extension MEMBER _extension)
    Q_PROPERTY(QString order MEMBER _order)
    Q_PROPERTY(QString query MEMBER _query)
    Q_PROPERTY(QString accountStatus MEMBER _accountStatus NOTIFY accountStatusChanged)

    Store();
    ~Store();
    bool loadConfig();
    void open();

public slots:
    Q_INVOKABLE void newQuery(QString exactMatch, QString fromYear, QString toYear, QString language, QString extension, QString order, QString query);
    Q_INVOKABLE void stopQuery();
    Q_INVOKABLE bool setConfig(QString exactMatch, QString fromYear, QString toYear, QString language, QString extension, QString order, QString query);
    Q_INVOKABLE void download(Book*);

signals:
    void booksChanged();
    void downloadListChanged();
    void isBusyChanged();
    void accountStatusChanged();

private:
    QQuickItem *rootView;
    QQmlContext *context;
    QQuickItem *storeView;
    QList<QObject *> _books;
    QList<QObject *> _downloadList;
    QObject *booksParent = nullptr;
    bool _isBusy;
    Worker *worker = nullptr;

    QString _exactMatch;
    QString _fromYear;
    QString _toYear;
    QString _language;
    QString _extension;
    QString _order;
    QString _query;
    QString _accountStatus;

    bool _cookieAvailable;
};

#endif /* STORE_H */