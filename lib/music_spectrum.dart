import 'dart:math' as math;
import 'package:flutter/material.dart';

int columnCount = 15;
int columnSpace = 3;

class MusicSpectrum extends StatefulWidget {
  MusicSpectrum({Key key}) : super(key: key);

  @override
  _MusicSpectrumState createState() {
    return _MusicSpectrumState();
  }
}

class _MusicSpectrumState extends State<MusicSpectrum>
    with SingleTickerProviderStateMixin {
  List<double> finalData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<double> lastData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  AnimationController animation;

  @override
  void initState() {
    animation = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation.addListener(() {
      setState(() {});
    });
    play();
    super.initState();
  }

  void play() async {
    animation.forward(from: 0);
    if (finalData == null) {
      finalData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    } else {
      lastData = finalData;
      finalData = [];
      for (int i = 0; i < columnCount; i++) {
        int mix = 0;
        double height = 0.0 + mix + math.Random().nextInt(100 - 1 - mix);
        finalData.add(height);
      }
    }
    await Future.delayed(Duration(milliseconds: 300));
    if (mounted) {
      play();
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            List<double> _tempList = [];
            for(int i= 0; i< finalData.length; i++){
              double current = lastData[i] + (finalData[i] - lastData[i]) * animation.value;
              _tempList.add(current);
            }
            return SizedBox(
              height: 100,
              width: 300,
              child: CustomPaint(
                painter: DancePainter(
                  rangeList: _tempList,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DancePainter extends CustomPainter {
  List<double> rangeList = List();

  DancePainter({@required this.rangeList});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var rect = Offset.zero & size;
    // debugPrint('rect $rect');
    canvas.drawRect(rect, Paint()..color = Colors.black);
    LinearGradient gradient = LinearGradient(
      colors: [
        Color(0xFFF55B99),
        Color(0xFFC079E9),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    double width =
        (size.width - (columnSpace * (columnCount - 1))) / (columnCount);
    double step = size.height / 100;
    for (int i = 0; i < columnCount; i++) {
      double height = 1.0;
      if (this.rangeList != null && this.rangeList.length >= i) {
        height = this.rangeList[i] * step;
      }

      Rect _columnRect = Rect.fromLTWH(
          columnSpace * i + width * i, size.height - height, width, height);
      canvas.drawRect(
        _columnRect,
        Paint()..shader = gradient.createShader(_columnRect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DancePainter oldDelegate) {
    return true;
    // return oldDelegate.rangeList != this.rangeList;
  }
}