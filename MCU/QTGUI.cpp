#include "QTGUI.hpp"
#include <iostream>
#include <QtCharts>
#include <Qt>

QTGUI::QTGUI()
{
	QGridLayout *topLevelGrid = new QGridLayout();

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

	chart->legend()->setVisible(true);
	chart->legend()->setAlignment(Qt::AlignBottom);

	QChartView* chartView = new QChartView(chart);
	chartView->setRenderHint(QPainter::Antialiasing);

	QTextEdit* UARTOutput = new QTextEdit();
	UARTOutput->setReadOnly(true);
	UARTOutput->setDocumentTitle("UART Output");
	UARTOutput->setTextInteractionFlags(Qt::NoTextInteraction);
	UARTOutput->setText("Text");

	topLevelGrid->addWidget(chartView, 0, 0, 3, -1, 0);
	topLevelGrid->addWidget(UARTOutput, 3, 0, 1, -1, Qt::AlignTop);
	setLayout(topLevelGrid);
	setWindowTitle("Measuring Vibrations");
}

QTGUI::~QTGUI()
{
}

void QTGUI::OnFPGADriverUpdated()
{

}
