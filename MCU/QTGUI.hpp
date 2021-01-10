#ifndef QTGUI_HPP
#define QTGUI_HPP
#include <QWidget>
#include <QtWidgets>

class QTGUI : public QWidget
{
	Q_OBJECT
	
public:
	QTGUI();
	~QTGUI();

	public slots:
	void OnFPGADriverUpdated();
};
#endif //QTGUI_HPP
