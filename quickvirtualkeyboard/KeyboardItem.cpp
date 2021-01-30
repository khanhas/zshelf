#include "Dispatcher.h"
#include "ModeItem.h"
#include "KeyboardItem.h"

namespace QuickKeyboard
{

KeyboardItem::KeyboardItem(QQuickItem *parent):
	QQuickItem(parent),
	m_mode(0),
	m_dispatcher(new Dispatcher(this))
{
	setObjectName("QuickKeyboard");
}

KeyboardItem::~KeyboardItem()
{
}

void KeyboardItem::setMode(ModeItem *mode)
{
	if (m_mode == mode) {
		return;
	}

	if (m_mode) {
		m_mode->setVisible(false);
		disconnect(m_mode, SIGNAL(symbolTriggered(const QString &)), this, SLOT(onSymbolTriggered(const QString &)));
	}

	m_mode = mode;
	if (mode) {
		mode->setVisible(true);
		connect(mode, SIGNAL(symbolTriggered(const QString &)), this, SLOT(onSymbolTriggered(const QString &)));
	}
	emit modeChanged(m_mode);
}

Dispatcher *KeyboardItem::dispatcher() const
{
	return m_dispatcher;
}

void KeyboardItem::onSymbolTriggered(const QString &symbol)
{
	if (!m_dispatcher) {
		return;
	}

	m_dispatcher->sendSymbol(symbol);
}

} /* QuickKeyboard */

