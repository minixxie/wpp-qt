import QtQuick 2.4

Canvas {
  id:canvas
  width: 12*wpp.dp2px
  height: 8*wpp.dp2px

  property bool invert: false

  onPaint:{
	  var context = canvas.getContext('2d'); //Context2D
	  context.clearRect(0, 0, canvas.width, canvas.height);

	  context.fillStyle = '#cc000000';
	  context.strokeStyle = '#cc000000';
	  context.lineWidth = 1;
	  context.beginPath();

	  //用移动线段来完成三角形并根据invert判断是否反转
	  if (invert) {
		  context.moveTo(6*wpp.dp2px, 0);
		  context.lineTo(12*wpp.dp2px, 8*wpp.dp2px);
		  context.lineTo(0, 8*wpp.dp2px);
		  context.lineTo(6*wpp.dp2px, 0);
	  } else {
		  context.moveTo(0, 0);
		  context.lineTo(12*wpp.dp2px, 0);
		  context.lineTo(6*wpp.dp2px, 8*wpp.dp2px);
		  context.lineTo(0, 0);
	  }

	  //闭合线段
	  context.closePath();
	  //必须调用了以下两个方法才显出三角形
	  context.fill();
	  context.stroke();
  }
}
