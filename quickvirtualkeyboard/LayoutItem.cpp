#include "ButtonItem.h"
#include "LayoutItem.h"

namespace QuickKeyboard
{

LayoutItem::LayoutItem(QQuickItem *parent):
	QQuickItem(parent)
{
}

LayoutItem::~LayoutItem()
{
}

void LayoutItem::addButton(ButtonItem *button)
{
	m_buttons.append(button);
}

void LayoutItem::clearButtons()
{
	m_buttons.clear();
}

const QList<ButtonItem *> &LayoutItem::buttons() const
{
	return m_buttons;
}

} /* QuickKeyboard */

