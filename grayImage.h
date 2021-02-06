#ifndef GRAYIMAGE_H
#define GRAYIMAGE_H

#include <QQuickImageProvider>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

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

            int w = m_requestedSize.width(), h = m_requestedSize.height();
            if (w != -1)
            {
                if (h != -1)
                {
                    img = img.scaled(w, h, Qt::KeepAspectRatio, Qt::SmoothTransformation);
                }
                else
                {
                    img = img.scaledToWidth(w, Qt::SmoothTransformation);
                }
            }
            else if (h != -1)
            {
                img = img.scaledToHeight(h, Qt::SmoothTransformation);
            }

            _img = img;
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