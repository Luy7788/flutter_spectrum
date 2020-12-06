# flutter_spectrum

使用自定义画布绘制的一个模拟音频的频谱变化动画
先看下效果
![20201205075153-7c011ad592.gif](https://upload-images.jianshu.io/upload_images/1938605-19e9b77bc535f181.gif?imageMogr2/auto-orient/strip)

自定义一个StatefulWidget继承自CustomPainter，
重写paint方法，画一个柱状图
```
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = Colors.black);
    //渐变色
    LinearGradient gradient = LinearGradient(
      colors: [Color(0xFFF55B99), Color(0xFFC079E9)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    //计算每个的宽度，这里columnCount为几根柱子，默认15根柱子，
    double width = (size.width - (columnSpace * (columnCount - 1))) / (columnCount);
    //将高度分成100份
    double step = size.height / 100;
    for (int i = 0; i < columnCount; i++) {
      double height = 1.0;
      //计算高度
      if (this.rangeList != null && this.rangeList.length >= i) {
        height = this.rangeList[i] * step;
      }
      //计算每个柱子的位置
      Rect _columnRect = Rect.fromLTWH(
        columnSpace * i + width * i,
        size.height - height,
        width,
        height,
      );
      //画在画布上
      canvas.drawRect(
        _columnRect,
        Paint()..shader = gradient.createShader(_columnRect),
      );
    }
  }
```
画完柱状图，接下来是让它们动起来：

使用两个数组存放高度，一组存放当前高度，一组保留上一次高度，高度是随机产生的0~100数，在用animationController来控制过度。

初始化数组：
```
  //当前高度
  List<double> finalData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  //上一次高度
  List<double> lastData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
```

```
  void initState() {
    animation = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation.addListener(() {
      setState(() {});
    });
    play();
    super.initState();
  }

  //处理高度数组
  void play() async {
    animation.forward(from: 0);
    if (finalData == null) {
      finalData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    } else {
      //保存上一次高度数值
      lastData = finalData;
      finalData = [];
      //产生新高度的随机数
      for (int i = 0; i < columnCount; i++) {
        int mix = 0;
        double height = 0.0 + mix + math.Random().nextInt(100 - mix);
        finalData.add(height);
      }
    }
    await Future.delayed(Duration(milliseconds: 300));
    if (mounted) {
      play();
    }
  }
```
build方法内根据animation.value的值，处理过渡效果，value的值为0~1
```
@override
Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            List<double> _tempList = [];
            for (int i = 0; i < finalData.length; i++) {
              //根据上次的高度以及value的值计算当前显示的高度
              double current = lastData[i] + (finalData[i] - lastData[i]) * animation.value;
              _tempList.add(current);
            }
            return SizedBox(
              height: 100,
              width: 300,
              child: CustomPaint(
                painter: SpectrumPainter(
                  rangeList: _tempList,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
```
