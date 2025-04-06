import 'package:flutter/material.dart';
import 'package:qtism_math/components/q_t.dart';

class GridContent extends StatelessWidget {
  const GridContent({
    super.key,
    required this.fontSize,
    required this.isNarrowScreen,
    required this.constraints,
  });

  final double fontSize;
  final bool isNarrowScreen;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 0),
        Text(
          "Il est capable de :",
          style: TextStyle(
            fontSize: fontSize * 0.65,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 30),
        SizedBox(
          width: isNarrowScreen ? constraints.maxWidth * 0.9 : 600,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
            childAspectRatio: 4.5,
            children: [
              "Additionner des nombres",
              "Soustraire des nombres",
              "Multiplier des nombres",
              "Diviser des nombres",
              "Évaluer des calculs",
              "Corriger des calculs"
            ].map((text) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isNarrowScreen
                        ? (fontSize * 0.35) + 3.1
                        : fontSize * 0.35,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QT()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 68, 255),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "Essayer",
            style:
                TextStyle(color: Colors.white, fontSize: fontSize * 0.5),
          ),
        ),
      ],
    );
  }
}
