#include <QtGlobal>
#include <QQuickWindow>
#include "ButtonItem.h"
#include "ModeItem.h"
#include "GridLayoutItem.h"

namespace QuickKeyboard
{

GridLayoutItemAttached::GridLayoutItemAttached(QObject *parent):
	QObject(parent),
	m_col(0),
	m_row(0),
	m_colSpan(1),
	m_rowSpan(1)
{
}

GridLayoutItemAttached::~GridLayoutItemAttached()
{
}

GridLayoutItem *GridLayoutItemAttached::layout() const
{
	QObject *predecessor = parent();
	ModeItem *mode = 0;
	while (predecessor != 0) {
		predecessor = predecessor->parent();
		mode = qobject_cast<ModeItem *>(predecessor);
		if (mode) {
			return qobject_cast<GridLayoutItem *>(mode->layout());
		}
	}
	return 0;
}

GridLayoutItem::GridLayoutItem(QQuickItem *parent):
	LayoutItem(parent),
	m_autoSize(true)
{
	setFlag(QQuickItem::ItemHasContents);
	setAcceptedMouseButtons(Qt::LeftButton);
	setZ(1);
	m_touchPositions << QPointF();
}

GridLayoutItem::~GridLayoutItem()
{
}

void GridLayoutItem::addButton(ButtonItem *button)
{
	LayoutItem::addButton(button);
	connect(button, SIGNAL(triggered()), this, SLOT(synchronizeMouseDownPoints()));
}

void GridLayoutItem::clearButtons()
{
	for (const ButtonItem *button : buttons()) {
		QObject *layoutAttached = qmlAttachedPropertiesObject<GridLayoutItem>(button);
		if (layoutAttached) {
			disconnect(button, SIGNAL(triggered()), this, SLOT(synchronizeMouseDownPoints()));
		}
	}
	LayoutItem::clearButtons();
}

void GridLayoutItem::setRowLength(QList<int> rows)
{
	m_autoSize = false;
    m_rowLengths = rows;
}

GridLayoutItemAttached *GridLayoutItem::qmlAttachedProperties(QObject *object)
{
	return new GridLayoutItemAttached(object);
}

void GridLayoutItem::redirectEventsToItem(QQuickItem *item)
{
	if (!item) {
		return;
	}

	if (!m_touchPositions[0].isNull()) {
		ungrabMouse();
		QMouseEvent pressEvent(QMouseEvent::MouseButtonPress, QPointF(0, 0), Qt::LeftButton, Qt::LeftButton, 0);
		QCoreApplication::sendEvent(item, &pressEvent);
		item->grabMouse();
	}
	if (!m_touchPoints.isEmpty()) {
		ungrabTouchPoints();

		QVector<int> ids;
		for (const QTouchEvent::TouchPoint &point : m_touchPoints) {
			ids << point.id();
		}

		QTouchEvent touchEvent(
			QEvent::TouchBegin,
			(QTouchDevice *)QTouchDevice::devices().first(),
			Qt::NoModifier,
			Qt::TouchPointPressed,
			m_touchPoints
		);

		QCoreApplication::sendEvent(item, &touchEvent);
		item->grabTouchPoints(ids);
	}

	m_touchPositions.clear();
	m_touchPositions << QPointF();
	m_touchPoints.clear();
}

void GridLayoutItem::triggerOnPosition(const QPointF &point)
{
	for (ButtonItem *button : buttons()) {
		if (checkButtonAtPoint(button, point)) {
			emit button->released();
		}
	}
}

void GridLayoutItem::setMousePosition(const QPointF &position)
{
	m_touchPositions[0] = position;
	synchronizeMouseDownPoints();
}

void GridLayoutItem::setTouchPositions(const QList<QPointF> &positions)
{
	m_touchPositions = QList<QPointF>() << m_touchPositions[0];
	m_touchPositions += positions;
	synchronizeMouseDownPoints();
}

bool GridLayoutItem::checkMouseDown(const ButtonItem *button) const
{
	for (const QPointF &point : m_touchPositions) {
		if (!point.isNull()) {
			if (checkButtonAtPoint(button, point)) {
				return true;
			}
		}
	}
	return false;
}

inline bool GridLayoutItem::checkButtonAtPoint(const ButtonItem *button, const QPointF &point)
{
	QPointF mapped = point - QPointF(button->x(), button->y());
	if (mapped.x() >= 0.0f && mapped.y() >= 0.0f && mapped.x() < button->width() && mapped.y() < button->height()) {
		return true;
	}
	return false;
}

void GridLayoutItem::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
	LayoutItem::geometryChanged(newGeometry, oldGeometry);
    int width = property("width").toInt();
    int height = property("height").toInt();

    if (!width || !height) return;

    hCenter = width / 2;
    vCenter = height / 2;
    recalculatePositions();
}

void GridLayoutItem::touchEvent(QTouchEvent *event)
{
	QVector<QPointF> points;
	m_touchPoints = event->touchPoints();
	points.reserve(m_touchPoints.length());
	for (const QTouchEvent::TouchPoint &point : m_touchPoints) {
		points << point.pos();
	}
	setTouchPositions(points.toList());

	QVector<QPointF> pointsAfterRelease;
	pointsAfterRelease.reserve(m_touchPoints.length());

	for (const QTouchEvent::TouchPoint &point : m_touchPoints) {
		if (point.state() == Qt::TouchPointReleased) {
			pointsAfterRelease << QPointF();
			triggerOnPosition(point.pos());
		}
		else {
			pointsAfterRelease << point.pos().toPoint();
		}
	}

	if (points != pointsAfterRelease) {
		setTouchPositions(pointsAfterRelease.toList());
	}
}

void GridLayoutItem::mouseMoveEvent(QMouseEvent *event)
{
	QPointF scenePos = QPointF(event->x(), event->y());
	setMousePosition(scenePos);
}

void GridLayoutItem::mousePressEvent(QMouseEvent *event)
{
	QPointF scenePos = QPointF(event->x(), event->y());
	setMousePosition(scenePos);
}

void GridLayoutItem::mouseReleaseEvent(QMouseEvent *event)
{
	QPointF scenePos = QPointF(event->x(), event->y());
	triggerOnPosition(scenePos);
	setMousePosition(QPointF());
}

int GridLayoutItem::layoutProperty(const ButtonItem *button, const char *property, int fallback)
{
	QObject *layoutAttached = qmlAttachedPropertiesObject<GridLayoutItem>(button);
	if (!layoutAttached) {
		return fallback;
	}
	return layoutAttached->property(property).toInt();
}

void GridLayoutItem::recalculatePositions()
{
    int w = 52;
    int h = 52;
    int gap = 5;

    QList<int> offsets = m_rowLengths;
    for (int i = 0; i < offsets.size(); i++) {
        if (offsets[i] == 0) continue;

        offsets[i] = (1404 - (offsets[i] * w + (offsets[i] - 2) * gap )) / 2;
    }

	for (ButtonItem *button : buttons()) {
		QObject *layoutAttached = qmlAttachedPropertiesObject<GridLayoutItem>(button);
		if (!layoutAttached) {
			continue;
		}

		int left = layoutAttached->property("col").toInt();
		int top = layoutAttached->property("row").toInt();
		int width = layoutAttached->property("colSpan").toInt() * w;
		int height = layoutAttached->property("rowSpan").toInt() * h;

        int x = left * (w + gap);
		int y = top * (h + gap);

        x += offsets[top];
        
        button->setProperty("x", x);
        button->setProperty("y", y);
        button->setProperty("width", width);
        button->setProperty("height", height);
    }
}

void GridLayoutItem::synchronizeMouseDownPoints()
{
    for (auto button : buttons()) {
        bool pointMouseDown = checkMouseDown(button);
        if (button->isMouseDown() != pointMouseDown) {
            button->setMouseDown(pointMouseDown);
        }
    }
}

} /* QuickKeyboard */

