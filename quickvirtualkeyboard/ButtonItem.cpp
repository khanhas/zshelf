#include "ButtonItem.h"

namespace QuickKeyboard
{

ButtonItem::ButtonItem(QQuickItem *parent):
	QQuickItem(parent),
	m_active(false),
	m_mouseDown(false),
	m_modifier(false),
	m_col(0),
	m_row(0),
	m_colSpan(1),
	m_rowSpan(1),
	m_currentSymbolIndex(-1)
{
	connect(this, SIGNAL(symbolsChanged(const QStringList &)), SLOT(onSymbolsChanged()));
	connect(this, SIGNAL(triggered()), SLOT(onTriggered()));
	connect(this, SIGNAL(released()), SLOT(onReleased()));
}

ButtonItem::~ButtonItem()
{
}

void ButtonItem::setActive(bool active)
{
	if (m_active == active) {
		return;
	}

	m_active = active;
	emit activeChanged(active);
	emit pressedChanged(m_active || m_mouseDown);
	setCurrentSymbolIndex(0);
}

void ButtonItem::setMouseDown(bool mouseDown)
{
	if (m_mouseDown == mouseDown) {
		return;
	}

	m_mouseDown = mouseDown;
	emit mouseDownChanged(mouseDown);
	emit pressedChanged(m_active || m_mouseDown);
	setCurrentSymbolIndex(0);
}

void ButtonItem::setCurrentSymbolIndex(int currentSymbolIndex)
{
	if (m_symbols.length() == 0) {
		currentSymbolIndex = -1;
	}
	if (currentSymbolIndex == -1 && m_symbols.length() > 0) {
		currentSymbolIndex = 0;
	}

	if (currentSymbolIndex == m_currentSymbolIndex) {
		return;
	}

	m_currentSymbolIndex = currentSymbolIndex;
	emit currentSymbolIndexChanged(currentSymbolIndex);
}

void ButtonItem::onSymbolsChanged()
{
	if (m_symbols.length() == 0) {
		setCurrentSymbolIndex(-1);
	}
	else {
		if (m_currentSymbolIndex < 0 || m_currentSymbolIndex >= m_symbols.length()) {
			setCurrentSymbolIndex(0);
		}
	}
}

void ButtonItem::onTriggered()
{
	if (m_currentSymbolIndex < 0 || m_currentSymbolIndex >= m_symbols.length()) {
		return;
	}

	emit symbolTriggered(m_symbols[m_currentSymbolIndex]);
}

void ButtonItem::onReleased()
{
	bool active = m_active;
	if (m_modifier) {
		setActive(!active);
	}
	if (isStandard() || active) {
		emit triggered();
	}
}

} /* QuickKeyboard */

