#ifndef QT_APP_BASE_RESOLUTION_H
#define QT_APP_BASE_RESOLUTION_H

#include <QObject>
#include <QWindow>
#include <QGuiApplication>

namespace wpp
{
namespace qt
{

class Resolution : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool isLandscape READ getIsLandscape NOTIFY isLandscapeChanged)
	Q_PROPERTY(bool isPortrait READ getIsPortrait NOTIFY isPortraitChanged)
	Q_PROPERTY(double dp2px READ getDp2px WRITE setDp2px NOTIFY dp2pxChanged)
	Q_PROPERTY(double px2dp READ getPx2dp WRITE setPx2dp NOTIFY px2dpChanged)
	Q_PROPERTY(double diagonalLength READ getDiagonalLength NOTIFY diagonalLengthChanged)
	Q_PROPERTY(QString dpiLevel READ getDpiLevel NOTIFY dpiLevelChanged)

private:
	QWindow *window;
	QGuiApplication *app;
	int horizontalDips;
	int screenWidth;
	int screenHeight;
	bool isLandscape;
	bool isPortrait;
	double dp2px;
	double px2dp;
	double diagonalLength;
	QString dpiLevel;

	void initScreenSize();
public:
	//Resolution( QWindow *window, int horizontalDips = 320 );
	Resolution( QGuiApplication *app, int horizontalDips = 320 );

	Q_INVOKABLE bool getIsLandscape() const;
	Q_INVOKABLE bool getIsPortrait() const
	{
		return !getIsLandscape();
	}

	Q_INVOKABLE double getDp2px()
	{
		return dp2px;
	}
	Q_INVOKABLE double getPx2dp()
	{
		return px2dp;
	}
	Q_INVOKABLE void setDp2px(double dp2px)
	{
		this->dp2px = dp2px;
	}
	Q_INVOKABLE void setPx2dp(double px2dp)
	{
		this->px2dp = px2dp;
	}
	Q_INVOKABLE double getDiagonalLength() const //in mm
	{
		return this->diagonalLength;
	}
	Q_INVOKABLE const QString& getDpiLevel() const { return this->dpiLevel; }

signals:
	void dp2pxChanged();
	void px2dpChanged();
	void isLandscapeChanged();
	void isPortraitChanged();
	void diagonalLengthChanged();
	void dpiLevelChanged();
public slots:
	void onOrientationChanged(Qt::ScreenOrientation);
	void onWindowWidthChanged(int newWidth);
	void onWindowHeightChanged(int newHeight);
	void onWindowGeometryChanged(int newWidth, int newHeight);
	void onFocusWindowChanged(QWindow *focusedWindow);
};

}//namespace qt
}//namespace wpp

#endif
