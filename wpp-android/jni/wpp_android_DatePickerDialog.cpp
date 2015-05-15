#include "wpp_android_DatePickerDialog.h"

#include <QAndroidJniObject>
#include <QDebug>

extern void __NativeDateTimePicker__setDateTimeSelected(const QString& iso8601, void* qmlDateTimePickerPtr );

#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     wpp_android_DatePickerDialog
 * Method:    dateSelected
 * Signature: (Ljava/lang/String;J)V
 */
JNIEXPORT void JNICALL Java_wpp_android_DatePickerDialog_dateSelected
  (JNIEnv *, jclass, jstring iso8601, jlong qmlDateTimePickerPtr)
{
	qDebug() << "iso8601...===" << QAndroidJniObject(iso8601).toString();
	__NativeDateTimePicker__setDateTimeSelected( QAndroidJniObject(iso8601).toString(), (void*)qmlDateTimePickerPtr );
}


#ifdef __cplusplus
}
#endif
