#include <QApplication>
#include <QWidget>
#include <QLabel>
#include "QTGUI.hpp"

int main(int argc, char** argv)
{
	QApplication app(argc, argv);
	QTGUI gui;
	gui.showMaximized();
	return app.exec();
}
