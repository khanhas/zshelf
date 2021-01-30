#ifndef KEYBOARDITEM_H_PT4SCIAV
#define KEYBOARDITEM_H_PT4SCIAV

#include <QQuickItem>
#include <QList>

namespace QuickKeyboard
{

class ModeItem;
class Dispatcher;

class KeyboardItem: public QQuickItem
{
Q_OBJECT
Q_PROPERTY(QuickKeyboard::ModeItem* mode MEMBER m_mode WRITE setMode NOTIFY modeChanged DESIGNABLE false)
Q_PROPERTY(QuickKeyboard::Dispatcher* dispatcher READ dispatcher MEMBER m_dispatcher)
public:
	explicit KeyboardItem(QQuickItem *parent = 0);
	~KeyboardItem();

	void setMode(ModeItem *mode);
	Dispatcher *dispatcher() const;

signals:
	void modeChanged(ModeItem *mode);

private slots:
	void onSymbolTriggered(const QString &symbol);

private:
	ModeItem *m_mode;
	Dispatcher *m_dispatcher;
}; /* -----  end of class KeyboardItem  ----- */

} /* QuickKeyboard */

#endif /* end of include guard: KEYBOARDITEM_H_PT4SCIAV */

