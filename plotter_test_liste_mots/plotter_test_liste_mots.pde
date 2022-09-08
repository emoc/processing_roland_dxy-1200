/* Test plotter Roland DXY-1200
 La Baleine, résidence «Extension graphique», 7 sept. 2022
 pierre@lesporteslogiques.net / processing 4.0b2 @ kirin / debian 9 stretch
 dimensions d'une feuille A3 sur plotter : 16800 x 11880 (avec unité de 0,025mm)
 
 A partir d'une liste de mots,
 les tracer un par un avec plume, position et dimensions au hasard 
 */

import processing.serial.*;
Serial myPort;

String S = new String();
long last;
int compteur = 0;

String[] mots;

void setup() {

  size(500, 200);
  background(0);
  stroke(255);
  fill(255);
  
  mots = loadStrings("./data/liste_mots.txt");

  println(Serial.list());                             // List all the available serial ports:
  myPort = new Serial(this, Serial.list()[2], 9600);  // ouverture du port

  last = millis();
}

void draw() {

  background(255);
  stroke(0);
  fill(0);
  text("plotter Roland DXY-1200", 20, 20);

  if (millis() - last > 4000) {
    S  = "IN;";
    S += "DT*;";
    int pen = (int)random(8) + 1;
    int x = (int)random(1000, 10000);
    int y = (int)random(1000, 10000);
    float sx = float((int)random(10, 40)) / 100; // largeur
    float sy = float((int)random(20, 60)) / 100; // hauteur
    S += "SP"+pen+";";
    S += "PA" + x + "," + y + ";";
    S += "SI" + sx + "," + sy + ";";
    S += "LB" + mots[compteur] + "*;";
    println(S);
    myPort.write(S);
    last = millis();
    compteur ++;
  }
  if (compteur == mots.length) {
    println("THE END");
    noLoop();
  }
}
