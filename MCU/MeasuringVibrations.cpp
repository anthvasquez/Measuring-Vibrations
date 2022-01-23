#include <QApplication>
#include <QWidget>
#include <QLabel>
#include "QTGUI.hpp"
#include "UARTDriver.hpp"

int main(int argc, char** argv)
{
	QApplication app(argc, argv);
	QTGUI gui;
	UARTDriver uart;
	gui.showMaximized();
	return app.exec();
}
