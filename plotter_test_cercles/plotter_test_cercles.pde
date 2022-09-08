/* Test plotter Roland DXY-1200 / test généatif 1
 La Baleine, résidence «Extension graphique», 7 sept. 2022
 pierre@lesporteslogiques.net / processing 4.0b2 @ kirin / debian 9 stretch
 dimensions d'une feuille A3 sur plotter : 16800 x 11880 (avec unité de 0,025mm)
 
 Chaque instruction est enregistrée dans un fichier texte
 */

import processing.serial.*;
Serial myPort;

String S = new String();
long last;
int compteur = 0;


void setup() {

  size(500, 200);
  background(0);
  stroke(255);
  fill(255);

  println(Serial.list());                             // List all the available serial ports:
  myPort = new Serial(this, Serial.list()[2], 9600);  // ouverture du port

  last = millis();
}

void draw() {

  background(255);
  stroke(0);
  fill(0);
  text("plotter Roland DXY-1200", 20, 20);

  if (millis() - last > 2000) {
    S = "IN;";
    int pen = (int)random(8) + 1;
    int x = (int)random(1000, 15000);
    int y = (int)random(1000, 10000);
    S += "SP"+pen+";";
    S += "PU" + x + "," + y + ";";
    S += "CI500;";
    println(S);
    myPort.write(S);
    last = millis();
    compteur ++;
  }
  if (compteur == 20) {
    println("THE END");
    noLoop();
  }
}
