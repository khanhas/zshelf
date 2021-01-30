#pragma once

#include <QThread>
#include <QProcess>
#include <QDebug>
#include <string.h>

class Worker : public QThread
{
    Q_OBJECT
public:
    Worker(QString prog, QStringList args, bool isReadAll = false) : program(prog), args(args), isReadAll(isReadAll) {}

    QString program;
    QStringList args;
    bool isReadAll;

    void run() override
    {
        QProcess proc;
        proc.start(program, args, QIODevice::ReadOnly);
        proc.setReadChannel(QProcess::StandardOutput);
        qDebug() << args;

        if (isReadAll) {
            proc.waitForFinished();
            emit readAll(proc.readAll());
        } else {
            while (proc.waitForReadyRead() || proc.canReadLine())
            {
                QString str = proc.readLine();

                if (str.startsWith("PROG:"))
                    emit updateProgress(str.section(':', 1, 1).toInt());
                else
                    emit updateStatus(str);
            }
        }
        proc.close();
        qDebug() << "Process closed";
    };
signals:
    void updateProgress(int result);
    void updateStatus(QString str);
    void readAll(QByteArray bytes);
};