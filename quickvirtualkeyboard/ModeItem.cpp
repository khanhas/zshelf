#include <QChildEvent>
#include "ButtonItem.h"
#include "GridLayoutItem.h"
#include "ModeItem.h"

namespace QuickKeyboard
{

ModeItem::ModeItem(QQuickItem *parent):
	QQuickItem(parent),
	m_layout(0)
{
	setVisible(false);
	setLayout(new GridLayoutItem());
}

ModeItem::~ModeItem()
{
}

LayoutItem *ModeItem::layout() const
{
	return m_layout;
}

void ModeItem::setLayout(LayoutItem *layout)
{
	if (m_layout == layout) {
		return;
	}

	if (m_layout) {
		m_layout->setParentItem(0);
		delete m_layout;
	}

	if (layout) {
		layout->setParentItem(this);
		for (ButtonItem *button : m_buttons) {
			m_layout->addButton(button);
		}
		layout->property("anchors").value<QObject *>()->setProperty("fill", QVariant::fromValue<QQuickItem *>(this));
	}
	m_layout = layout;
}

QQmlListProperty<ButtonItem> ModeItem::buttons()
{
	return QQmlListProperty<ButtonItem>(
		this,
		&m_buttons,
		&ModeItem::buttons_append,
		&ModeItem::buttons_count,
		&ModeItem::buttons_at,
		&ModeItem::buttons_clear
	);
}

void ModeItem::buttons_append(QQmlListProperty<ButtonItem> *property, ButtonItem *button)
{
	ModeItem *that = static_cast<ModeItem *>(property->object);
	button->setParentItem(that);
	that->m_buttons.append(button);
	if (that->m_layout) {
		that->m_layout->addButton(button);
	}
	QObject::connect(button, SIGNAL(symbolTriggered(const QString &)), that, SIGNAL(symbolTriggered(const QString &)));
	QObject::connect(button, SIGNAL(triggered()), that, SLOT(setModifiersInactive()));
}

int ModeItem::buttons_count(QQmlListProperty<ButtonItem> *property)
{
	ModeItem *that = static_cast<ModeItem *>(property->object);
	return that->m_buttons.count();
}

ButtonItem *ModeItem::buttons_at(QQmlListProperty<ButtonItem> *property, int idx)
{
	ModeItem *that = static_cast<ModeItem *>(property->object);
	return that->m_buttons.value(idx, 0);
}

void ModeItem::buttons_clear(QQmlListProperty<ButtonItem> *property)
{
	ModeItem *that = static_cast<ModeItem *>(property->object);
	if (that->m_layout) {
		that->m_layout->clearButtons();
	}
	for (ButtonItem *button : that->m_buttons) {
		QObject::disconnect(button, SIGNAL(symbolTriggered(const QString &)), that, SIGNAL(symbolTriggered(const QString &)));
		QObject::disconnect(button, SIGNAL(triggered()), that, SLOT(setModifiersInactive()));
		button->setParentItem(0);
	}
	that->m_buttons.clear();
}

void ModeItem::itemChange(ItemChange change, const ItemChangeData &value)
{
	QQuickItem::itemChange(change, value);
	if (change == QQuickItem::ItemVisibleHasChanged && !isVisible()) {
		setModifiersInactive();
	}
}

void ModeItem::setModifiersInactive()
{
	for (ButtonItem *button : m_buttons) {
		if (button->isModifier()) {
			button->setActive(false);
		}
	}
}

} /* QuickKeyboard */

