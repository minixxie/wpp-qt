#ifndef VIEWCONTROLLER_H
#define VIEWCONTROLLER_H

#endif // VIEWCONTROLLER_H

#include <QQuickItem>
#include<QtQuick>


class IOSWebView : public QQuickItem
{
 Q_OBJECT
public:
 explicit IOSWebView(QQuickItem *parent = 0);

public slots:
 void open();

};

