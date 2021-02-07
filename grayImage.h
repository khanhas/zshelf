#ifndef GRAYIMAGE_H
#define GRAYIMAGE_H

#include <QQuickImageProvider>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QPainter>

class AsyncImageResponse : public QQuickImageResponse
{
public:
    AsyncImageResponse(const QString &id, const QSize &requestedSize)
        : m_id(id), m_requestedSize(requestedSize)
    {
        connect(&netManager, &QNetworkAccessManager::finished, this, [this](QNetworkReply *rep) {
            rep->deleteLater();
            if (rep->error() != QNetworkReply::NoError)
            {
                qDebug() << "[NET] ERR: " << rep->errorString();
                emit finished();
                return;
            }

            QByteArray bytes = rep->readAll();
            QImage img = QImage::fromData(bytes).convertToFormat(QImage::Format_Grayscale8);

            _img = QImage(img.size(), QImage::Format_ARGB32);
            _img.fill(Qt::transparent);
            QPainter p(&_img);
            p.setBrush(QBrush(img));
            p.setPen(Qt::NoPen);
            qreal radius = 8.0;
            if (img.width() > 200) {
                p.setRenderHint(QPainter::Antialiasing, true);
                radius = 16.0;
            }
            p.drawRoundedRect(1, 1, img.width() - 2, img.height() - 2, radius, radius);
            p.end();

            emit finished();
        });

        netManager.get(QNetworkRequest(m_id));
    }

    QQuickTextureFactory *textureFactory() const
    {
        return QQuickTextureFactory::textureFactoryForImage(_img);
    }

private:
    QImage _img;
    QString m_id;
    QSize m_requestedSize;
    QNetworkAccessManager netManager;
};

class GrayImageProvider : public QQuickAsyncImageProvider
{
public:
    GrayImageProvider() {}

    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override
    {
        AsyncImageResponse *response = new AsyncImageResponse(id, requestedSize);
        return response;
    }
};

#endif /* GRAYIMAGE_H */