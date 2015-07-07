#include "Wpp.h"

#include "Application.h"
#include <QScreen>
#ifdef Q_OS_ANDROID
	#include <QAndroidJniObject>
	#include <QtAndroid>
#endif

namespace wpp {
namespace qt {

Wpp::Wpp(Application *app)
	: app(app), m_dp2px(1)
{
	//QScreen *screen = app->screens()[0];

/*	double dpi = screen->physicalDotsPerInch();
	qDebug() << "dpi:" << screen->physicalDotsPerInch();

	QString dpiLevel;

	//http://developer.android.com/guide/practices/screens_support.html
	if ( dpi >= 640 )
		dpiLevel = "xxxhdpi";
	else if ( dpi >= 480 )
		dpiLevel = "xxhdpi";
	else if ( dpi >= 320 )
		dpiLevel = "xhdpi";
	else if ( dpi >= 240 )
		dpiLevel = "hdpi";
	else if ( dpi >= 160 )
		dpiLevel = "mdpi";
	else if ( dpi >= 120 )
		dpiLevel = "ldpi";
	else
		dpiLevel = "ldpi";

	qDebug() << "dpi level = " << dpiLevel;
*/

#ifdef Q_OS_ANDROID
	//http://stackoverflow.com/questions/3166501/getting-the-screen-density-programmatically-in-android
	/*
	 DisplayMetrics metrics = getResources().getDisplayMetrics();
	 //metrics.densityDpi
	 //metrics.density
	 */

	/*
	 * http://developer.android.com/reference/android/util/DisplayMetrics.html
 DisplayMetrics metrics = new DisplayMetrics();
 getWindowManager().getDefaultDisplay().getMetrics(metrics);
	 */
	QAndroidJniObject activity = QtAndroid::androidActivity();
	qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

	QAndroidJniObject windowManager = activity.callObjectMethod(
				"getWindowManager","()Landroid/view/WindowManager;");
	qDebug() << __FUNCTION__ << "windowManager.isValid()=" << windowManager.isValid();

	QAndroidJniObject display = windowManager.callObjectMethod(
				"getDefaultDisplay","()Landroid/view/Display;");
	qDebug() << __FUNCTION__ << "display.isValid()=" << display.isValid();

	QAndroidJniObject metrics("android/util/DisplayMetrics","()V");
	qDebug() << __FUNCTION__ << "metrics.isValid()=" << metrics.isValid();

	display.callMethod<void>(
				"getMetrics","(Landroid/util/DisplayMetrics;)V", metrics.object<jobject>());
	qDebug() << __FUNCTION__ << "metrics.isValid()=" << metrics.isValid();

	jfloat metrics_density = metrics.getField<jfloat>("density");
	qDebug() << __FUNCTION__ << "metrics.density=" << metrics_density;

	jint DisplayMetrics__DENSITY_HIGH = QAndroidJniObject::getStaticField<jint>(
							"android/util/DisplayMetrics", "DENSITY_HIGH");
	qDebug() << __FUNCTION__ << "DisplayMetrics__DENSITY_HIGH=" << DisplayMetrics__DENSITY_HIGH;

	m_dp2px = metrics_density;
#endif
}

}
}
