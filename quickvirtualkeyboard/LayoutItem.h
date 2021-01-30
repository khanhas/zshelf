#ifndef LAYOUTITEM_H_ZHXO0UI7
#define LAYOUTITEM_H_ZHXO0UI7

#include <QQuickItem>
#include <QList>

namespace QuickKeyboard
{

class ButtonItem;

class LayoutItem: public QQuickItem
{
Q_OBJECT
public:
	explicit LayoutItem(QQuickItem *parent = 0);
	~LayoutItem();

	virtual void addButton(ButtonItem *button);
	virtual void clearButtons();

protected:
	const QList<ButtonItem *> &buttons() const;

private:
	QList<ButtonItem *> m_buttons;
}; /* -----  end of class LayoutItem  ----- */

} /* QuickKeyboard */

#endif /* end of include guard: LAYOUTITEM_H_ZHXO0UI7 */

