#pragma once

#include <QThread>
#include <QProcess>
#include <QDebug>
#include <QLocalSocket>
#include <QtGui>

static QProcess *serverProc = nullptr;

class Worker : public QThread
{
    Q_OBJECT
public:
    Worker(QStringList args, bool isReadAll = false) : args(args), isReadAll(isReadAll) {}

    QStringList args;
    bool isReadAll;
    QString socketPath = "/tmp/zshelf_socket";

    static void createServer() {
        serverProc = new QProcess;
        serverProc->start("/opt/bin/node", {QGuiApplication::applicationDirPath() + "/backend/server.js"}, QIODevice::ReadOnly);
        serverProc->waitForStarted();
        serverProc->waitForReadyRead();
    }

    static void checkServer() {
        if (serverProc == nullptr) createServer();

        if (serverProc->state() == QProcess::NotRunning)
        {
            qDebug() << "[SERVER] Not running " << serverProc->state() << serverProc->error();
            delete serverProc;
            createServer();
        }
        qDebug() << "[SERVER] " << serverProc->state();
    }

    void work() {
        checkServer();
        start();
    }

    void run() override
    {
        QLocalSocket sock;
        sock.connectToServer(socketPath, QIODevice::ReadWrite);
        sock.waitForConnected();
        qDebug() << "[SOCKET]" << args[0] << "Connected";
        for (auto arg : args) {
            sock.write(arg.toStdString().c_str());
            sock.write("\n", 1);
        }
        sock.waitForBytesWritten();

        if (isReadAll)
        {
            sock.waitForReadyRead();
            emit readAll(sock.readLine());
        }
        else
        {
            while (sock.waitForReadyRead() || sock.canReadLine())
            {
                QString str = sock.readLine();

                if (str.startsWith("PROG:"))
                    emit updateProgress(str.section(':', 1, 1).toInt());
                else
                    emit updateStatus(str);
            }
        }
        sock.close();
        emit socketClosed();
        qDebug() << "[SOCKET]" << args[0] << "Closed";
    };
signals:
    void updateProgress(int result);
    void updateStatus(QString str);
    void readAll(QByteArray bytes);
    void socketClosed();
};