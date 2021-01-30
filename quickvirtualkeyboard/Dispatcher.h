#ifndef DISPATCHER_H_4JJ7SBUO
#define DISPATCHER_H_4JJ7SBUO

#include <QObject>

namespace QuickKeyboard
{

class Dispatcher: public QObject
{
Q_OBJECT
Q_PROPERTY(bool sendReturnKey MEMBER m_sendReturnKey)
public:
	explicit Dispatcher(QObject *parent = 0);
	~Dispatcher();
	QObject *focusObject() const;

public slots:
	void setFocusObject(QObject *focusObject);
	virtual void sendSymbol(const QString &symbol);

private:
	QObject *m_focusObject;
	bool m_sendReturnKey;
}; /* -----  end of class Dispatcher  ----- */

} /* QuickKeyboard */

#endif /* end of include guard: DISPATCHER_H_4JJ7SBUO */

