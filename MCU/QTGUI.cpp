#include "QTGUI.hpp"
#include <iostream>
#include <QtCharts>
#include <Qt>

QTGUI::QTGUI()
{
	QGridLayout *topLevelContainer = new QGridLayout();

	QBarSet* bin0 = new QBarSet("Bin0");
	*bin0 << 10;

	QBarSeries* xAxis = new QBarSeries();
	xAxis->append(bin0);

	QChart* chart = new QChart();
	chart->addSeries(xAxis);
	chart->setTitle("FFT Output");
	chart->setAnimationOptions(QChart::SeriesAnimations);

	QStringList categories;
	categories << "0 - 10";
	QBarCategoryAxis *axisX = new QBarCategoryAxis();
	axisX->append(categories);
	chart->addAxis(axisX, Qt::AlignBottom);
	xAxis->attachAxis(axisX);

	QValueAxis *axisY = new QValueAxis();
	axisY->setRange(0, 15);
	chart->addAxis(axisY, Qt::AlignLeft);
	xAxis->attachAxis(axisY);

	QChartView* chartView = new QChartView(chart);
	chartView->setRenderHint(QPainter::Antialiasing);

	QTextEdit* UARTOutput = new QTextEdit();
	UARTOutput->setReadOnly(true);
	UARTOutput->setDocumentTitle("UART Output");
	UARTOutput->setTextInteractionFlags(Qt::NoTextInteraction);
	UARTOutput->setText("A ha ha");


	topLevelContainer->addWidget(chartView, 0, 0, 3, 1);
	topLevelContainer->addWidget(UARTOutput, 1, 0, 1, 1);
	setLayout(topLevelContainer);
	setWindowTitle("Measuring Vibrations");
}

QTGUI::~QTGUI()
{
}

void QTGUI::OnFPGADriverUpdated()
{

}
