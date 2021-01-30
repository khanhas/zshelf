#include <QQmlEngine>
#include "KeyboardItem.h"
#include "Dispatcher.h"
#include "ModeItem.h"
#include "ButtonItem.h"
#include "GridLayoutItem.h"


inline void registerQmlTypes()
{
	qmlRegisterType<QuickKeyboard::KeyboardItem>("QuickKeyboard", 1, 0, "Keyboard");
	qmlRegisterType<QuickKeyboard::ModeItem>("QuickKeyboard", 1, 0, "Mode");
	qmlRegisterType<QuickKeyboard::ButtonItem>("QuickKeyboard", 1, 0, "Button");
	qmlRegisterType<QuickKeyboard::Dispatcher>("QuickKeyboard", 1, 0, "Dispatcher");
	qmlRegisterType<QuickKeyboard::LayoutItem>();
	qmlRegisterType<QuickKeyboard::GridLayoutItemAttached>();
	qmlRegisterType<QuickKeyboard::GridLayoutItem>("QuickKeyboard", 1, 0, "GridLayout");
}
