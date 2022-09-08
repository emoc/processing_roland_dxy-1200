/* Test plotter Roland DXY-1200 / envoi direct de commandes RD-GL
 La Baleine, résidence «Extension graphique», 7 sept. 2022
 pierre@lesporteslogiques.net / processing 4.0b2 @ kirin / debian 9 stretch
 dimensions d'une feuille A3 sur plotter : 16800 x 11880 (avec unité de 0,025mm)
 
 Chaque instruction est enregistrée dans un fichier texte
 */
/*
int[][] origines = {
 {    0,     0},
 {    0,  5940},
 { 4200,     0},
 { 4200,  5940},
 { 8400,     0},
 { 8400,  5940},
 {12600,     0},
 {12600,  5940} };
 
 boolean MODE_PLOTTER_ON = true;
 int CP = 0; // jusqu'à 7 (max carte postale)
 */

import processing.serial.*;
Serial myPort;

String S = new String();
String result;
//int H = 1600;

//boolean MODE_AUTO = false;
int last, now;

//boolean DISTRIB = false; // true : grands carrés, false : petits carrés
//int[] valeurs_distribuees = new int[10];

// fonctions de dates pour l'export d'images
//import java.util.Date;
//import java.text.SimpleDateFormat;
// variables utilisées pour les fonctions communes
//String SKETCH_NAME = getClass().getSimpleName();

// envoi de commandes directs
import controlP5.*;
ControlP5 cp5;
String textValue = "";
PFont font;

//String[] commande = loadStrings("commandes.txt");
Table commandes;

void setup() {

  size(500, 800);
  background(0);
  stroke(255);
  fill(255);

  loadCommandes();

  font = loadFont("BitstreamVeraSansMono-Roman-20.vlw");
  cp5 = new ControlP5(this);

  cp5.addTextfield("input")
    .setPosition(20, 30)
    .setSize(400, 40)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255, 0, 0))
    ;

  cp5.addBang("clear")
    .setPosition(430, 30)
    .setSize(60, 40)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
    ;


  println(Serial.list());                             // List all the available serial ports:
  myPort = new Serial(this, Serial.list()[1], 9600);  // ouverture du port

  //--- La commande "escape.L" doit permettre d'obtenir la taille du buffer de la machine
  char escape = char(27);
  myPort.write(str(escape)+".L;");
  result = null;
  while (result == null) {
    result = myPort.readString();
  }
  myPort.clear();
  println("Taille dispo dans le buffer : " + result);
  last = millis();
}

void draw() {

  background(255);
  stroke(0);
  fill(0);
  textFont(font, 16);
  text("plotter Roland DXY-1200", 20, 20);
  showCommandes();
}


void loadCommandes() {
  // Load CSV file into a Table object
  // "header" option indicates the file has a header row
  commandes = loadTable("commandes.csv", "header");
}

void showCommandes() {
  float tx = 20;
  float ty = 120;
  for (TableRow row : commandes.rows()) {
    // You can access the fields via their column name (or index)
    String com = row.getString("commande");
    text(com, tx, ty);
    ty += 18;
  }
}

void saveCommande(String S) {
  TableRow row = commandes.addRow();
  row.setString("commande", S);

  // Writing the CSV back to the same file
  saveTable(commandes, "commandes.csv");
  // And reloading it
  loadCommandes();
}

public void clear() {
  cp5.get(Textfield.class, "input").clear();
  char escape = char(27);
  myPort.write(str(escape)+".K;");
  myPort.clear();
}

public void input(String theText) {
  println("Message à envoyer au plotter : " + theText);
  envoyer(theText);
}







void envoyer(String S) {
  
  saveCommande(S);

  int tailleStringS = S.length();
  println("Taille String S : " + tailleStringS);
  println("------");


  //------------DECOUPAGE ET ENVOI DES PAQUETS DANS UN TABLEAU LISTE DE STRINGS "tabS" de taille "tailleTabS" (voir Test envoi ci dessous)------------------------
  //----La string "prov" (pour provisoire) sert un peu à tout tout au long du traitement-------------
  int taillePaq = 500;
  int tailleStringProv = tailleStringS;
  String prov = S;
  ArrayList tabS = new ArrayList();
  int index = taillePaq;
  String paquet = new String();
  while (prov.length()>0) {
    if (prov.length()>taillePaq) {
      index = prov.indexOf(";", taillePaq);
      paquet = prov.substring(0, index+1);
      prov = prov.substring(index+1);
    } else {
      paquet = prov;
      prov = "";
    }
    tabS.add(paquet);
  }

  //------------TEST ENVOI   la commande "OS" permet d'obtenir le "Output Status" et permet de savoir si le buffer est enfin vide-------------------
  int tailleTabS = tabS.size();
  prov = (String) tabS.get(tailleTabS-1);
  println(prov);
  println(str(tailleTabS) + "paquets");

  prov = (String) tabS.get(0);
  myPort.write(prov);
  println("Paquet numero 0 envoye");


  for (int i=1; i<tailleTabS; i++) {
    myPort.write("OS;");
    if (i%10==0) {
      println("----i%10==0---------");
      result = null;
      while (result == null) {
        result = myPort.readString();
      }
      myPort.clear();
      println("Output Status Obtenu : Buffer Vide:");
      println(result);
      myPort.write("IN;");
      println("Commande Initialisation envoyee");
      myPort.write("OS;");
      result = null;
      while (result == null) {
        result = myPort.readString();
      }
      myPort.clear();
      println("Commande Initialisation achevée");
    }
    prov = (String) tabS.get(i);
    myPort.write(prov);
    println("Paquet numero "+str(i)+" envoye");
    println(str(tailleTabS) + "paquets");

    if (i%10!=0) {
      result = null;
      while (result == null) {
        result = myPort.readString();
      }
      myPort.clear();
      println("Paquet numero "+str(i-1)+" dessiné");
      println("Output Status Obtenu :");
      println(result);
      println("------");
    }
  }
}
