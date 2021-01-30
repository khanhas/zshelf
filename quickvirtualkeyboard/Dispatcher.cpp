#include <QGuiApplication>
#include <QInputMethodEvent>
#include <QKeyEvent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QWindow>
#include "Dispatcher.h"

namespace QuickKeyboard
{

Dispatcher::Dispatcher(QObject *parent):
	QObject(parent),
	m_focusObject(0),
	m_sendReturnKey(false)
{
}

Dispatcher::~Dispatcher()
{
}

QObject *Dispatcher::focusObject() const
{
	return m_focusObject;
}

void Dispatcher::setFocusObject(QObject *focusObject)
{
	m_focusObject = focusObject;
}

void Dispatcher::sendSymbol(const QString &symbol)
{
	if (!m_focusObject) {
		return;
	}

	QInputMethodEvent ev;
	if (symbol == QString("\x7f")) { // backspace
		ev.setCommitString("", -1, 1);
	}
	else if (m_sendReturnKey && symbol == QString("\n")) {
		QWindow *window = 0;

		QQuickItem *quickItem = qobject_cast<QQuickItem *>(m_focusObject);
		if (quickItem) {
			window = quickItem->window();
		}

		if (window) {
			QKeyEvent *press = new QKeyEvent(QKeyEvent::KeyPress, Qt::Key_Return, Qt::NoModifier);
			QGuiApplication::postEvent(window, press);
			QKeyEvent *release = new QKeyEvent(QKeyEvent::KeyRelease, Qt::Key_Return, Qt::NoModifier);
			QGuiApplication::postEvent(window, release);
			return;
		}
		else {
			ev.setCommitString(symbol);
		}
	}
	else {
		ev.setCommitString(symbol);
	}
	QCoreApplication::sendEvent(m_focusObject, &ev);
}

} /* QuickKeyboard */

