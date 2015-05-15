import QtQuick 2.1
 
Rectangle {
    id: l
    property alias x1: l.x
    property alias y1: l.y
 
    property real x2: l.x
    property real y2: l.y
 
    color: "black"
    height: 2
    smooth: true;
 
    transformOrigin: Item.TopLeft;
 
    width: getWidth(x1,y1,x2,y2);
    rotation: getSlope(x1,y1,x2,y2);
 
    function getWidth(sx1,sy1,sx2,sy2)
    {
        var w=Math.sqrt(Math.pow((sx2-sx1),2)+Math.pow((sy2-sy1),2));
		//console.debug("W: "+w);
        return w;
    }
 
    function getSlope(sx1,sy1,sx2,sy2)
    {
        var a,m,d;
        var b=sx2-sx1;
        if (b===0)
            return 0;
        a=sy2-sy1;
        m=a/b;
        d=Math.atan(m)*180/Math.PI;
 
        if (a<0 && b<0)
            return d+180;
        else if (a>=0 && b>=0)
            return d;
        else if (a<0 && b>=0)
            return d;
        else if (a>=0 && b<0)
            return d+180;
        else
            return 0;
    }
}
