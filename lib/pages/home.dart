import 'package:flutter/material.dart';
import 'qt.dart';

void main() {
  runApp(QTRobotApp());
}

class QTRobotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QTRobotHomePage(),
    );
  }
}

class QTRobotHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABC1F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Déterminer si l'écran est étroit
          bool isNarrowScreen = constraints.maxWidth < 800;

          // Calculer les tailles en fonction de l'écran
          double fontSize = constraints.maxWidth * 0.035;
          // Maintenir la taille fixe du grid même sur les petits écrans
          double gridItemWidth = (800 / 4) * 0.75;

          // Si l'écran est trop étroit, ajuster pour que le grid reste lisible
          if (isNarrowScreen) {
            fontSize = constraints.maxWidth *
                0.05; // Police plus grande sur petit écran
          }

          // Créer le contenu du robot
          Widget robotContent = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              Text(
                "Bienvenue",
                style: TextStyle(
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Amusez-vous avec QT, le robot calculateur !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize * 0.6,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Image.asset(
                'homeQT.png',
                height: isNarrowScreen
                    ? constraints.maxHeight * 0.3
                    : constraints.maxHeight * 0.5,
              ),
            ],
          );

          // Créer le contenu du grid
          Widget gridContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 120), // Ajout d'un margin top
              Text(
                "Il est capable de :",
                style: TextStyle(
                  fontSize: fontSize * 0.55,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Container(
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
                          // Augmentation de 3 points de taille pour la police en mode mobile
                          fontSize: isNarrowScreen
                              ? (fontSize * 0.35) + 3
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
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Essayer",
                  style:
                      TextStyle(color: Colors.white, fontSize: fontSize * 0.35),
                ),
              ),
            ],
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: isNarrowScreen
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        robotContent,
                        SizedBox(height: 40),
                        gridContent,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: robotContent),
                        Expanded(flex: 1, child: gridContent),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
