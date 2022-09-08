/* Test plotter Roland DXY-1200
 La Baleine, résidence «Extension graphique», 7 sept. 2022
 pierre@lesporteslogiques.net / processing 4.0b2 @ kirin / debian 9 stretch
 dimensions d'une feuille A3 sur plotter : 16800 x 11880 (avec unité de 0,025mm)
 l'origine du repère est en bas à gauche
 
 A partir d'une image faible définition, tracer des carrés plus ou moins hachurés
 selon la couleur des pixels.
 */

boolean PLOT = true;      // activer la connexion série avec le plotter et tracer

import processing.serial.*;
Serial myPort;

String S = new String();  // chaîne de commandes RD-GL à envoyer
long last;                // dernière commande envoyée (millisecondes)
int delai = 2000;         // delai entre chaque envoi, si envoi!

PImage img;               // image à traiter
String fichier = "teapot.png";   // fichier à charger
int pixel_max;            // nombre de pixels de l'image
int pixel = 0;            // index du pixel en cours
int px, py;               // coordonnées du pixel en cours
float pixel_lum;          // luminosité du pixel

int xs, ys;               // position de départ du motif
int pen;                  // plume à utiliser

int ml, mh;               // largeur et hauteur du motif
int mx, my;               // coord. du motif à tracer

void setup() {

  size(500, 200);
  background(0);
  stroke(255);
  fill(255);

  img = loadImage(fichier);
  pixel_max = img.width * img.height;
  println("pixel_max : " + pixel_max);
  if (PLOT) {
    println(Serial.list());                             // List all the available serial ports:
    myPort = new Serial(this, Serial.list()[1], 9600);  // ouverture du port
  }
  last = millis();
}

void draw() {

  background(255);
  stroke(0);
  fill(0);
  text("plotter Roland DXY-1200", 20, 20);

  xs = 500;
  ys = 10000;      // attention zéro en bas...
  pen = 4;
  ml = 200;
  mh = 200;

  if (millis() - last > delai) {

    px = pixel % img.width;
    py = floor(pixel / img.width);

    float pixel_lum = brightness(img.get(px, py));

    mx = xs + (px * ml);
    my = ys - (py * mh);

    int espacement = (int)map(pixel_lum, 0, 255, 25, 100);

    // Exemple d'une commande
    //FT4,50;RR500,500;

    println("pixel n°" + pixel + " : " + px + ", " + py + " : " + pixel_lum);

    if (pixel_lum < 255) { // Si blanc on ne fait rien
      S  = "IN;";
      S += "SP" + pen + ";";
      S += "FT4," + espacement +";";
      S += "PU" + mx + "," + my + ";";
      S += "RR" + ml + "," + mh + ";";
      println(S);
      if (PLOT) myPort.write(S);
      delai = 2000;
    } else {
      delai = 10;
    }

    last = millis();

    pixel ++;
  } 

  if (pixel == pixel_max) {
    println("THE END");
    noLoop();
  }
}
