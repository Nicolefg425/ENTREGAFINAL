PImage mom3; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
PFont miFuente;
int index = 0;

//Sonido
import processing.sound.*;
import processing.sound.FFT;
SoundFile soundfile;
FFT fft;

int bands = 512;
float[] spectrum = new float[bands];

//Tiempo de los efectos
int startMillis;
float inicioMomento3 = 43.0;
float duracionMomento3 = 27.0;
float inicioMomento4 = 70.0;
float duracionMomento4 = 29.0;

boolean sonidoIniciado = false;
boolean mostrarTexto = true;

//Letra
String[] letras;


float[] tiempoLetra = {
  0.0, 04.0, 09.0, 11.0, 13.0, 17.0, 21.0, 23.0, 25.0, 26.0, 29.0, 31.0, 36.0,
  39.0, 41.0, 43.0, 45.0, 49.0, 51.0, 53.0, 58.0, 62.0, 66.0, 70.0, 73.0, 75.0,
  77.0, 78.0, 83.0, 84.0, 88.0, 91.0, 93.0, 95.0, 97.0, 99.0, 101.0, 104.0, 106.0, 110.0,
  114.0, 119.0, 122.0, 125.0, 127.0, 130.0, 131.0, 134.0, 136.0, 142.0, 144.0, 146.0,
  149.0, 151.0, 154.0, 156.0, 158.0, 161.0
};

void setup() {
  size (900, 900);
  letras = loadStrings ("lovelostletra.txt");

  println(" Presiona la barra espaciadora para quitar la letra");

  //Fuente
  miFuente = createFont("tipografia.ttf", 35);
  textFont(miFuente);

  //Imagenes
  mom3 = loadImage ("ilustracion3.png");

  //Sonido
  soundfile = new SoundFile(this, "lovelost.mp3");
  fft = new FFT (this, bands);
  fft.input (soundfile);

  // Empieza el audio en el segundo 43
  soundfile.cue(0);
  soundfile.play();
  startMillis = millis();
  sonidoIniciado = true;
}

void draw () {
  background (0);
  
  
  float currentTime = (millis() - startMillis) / 1000.0;
  float tiempoRelativo = currentTime;

  // Mostrar letra
  String lineaActual = ""; //<>//
  for (int i = 0; i < tiempoLetra.length; i++) { //<>//
    if (tiempoRelativo >= tiempoLetra[i]) { //<>//
      lineaActual = letras[i];
    } //<>//
  } //<>//
  //Inicia el Efecto momento 3
  if (sonidoIniciado) {
    fft.analyze(spectrum);

    // Calcula cuántas imágenes mostrar
    float totalEnergy = 0;
    for (int i = 0; i < bands; i++) {
      totalEnergy += spectrum[i];
    }

    //Ilustracion 1

    //Ilustracion 2


    //Ilustracion 3
    if (currentTime >= inicioMomento3 && currentTime < inicioMomento3 + duracionMomento3)
    {
      loadImageEvent (index);

      // Escala de cantidad de imágenes
      int numImages = int(map(totalEnergy, 0, 10, 1, 50));
      numImages = constrain(numImages, 1, 100);

      // Dibuja imágenes según la energía
      for (int i = 0; i < numImages; i++) {
        float x = random(width);
        float y = random(height);
        float sizeFactor = random(0.2, 0.5);
        image(mom3, x, y, mom3.width * sizeFactor, mom3.height * sizeFactor);
      }
    } else if (currentTime >= inicioMomento4 && currentTime < inicioMomento4 + duracionMomento4) {
      // Ilustracion 4
      pushMatrix();  // ← Nuevo
      translate(width / 2, height / 2);

      int levels = 8;
      float baseRadius = map(totalEnergy, 0, 10, 250, 280);
      baseRadius = constrain(baseRadius, 150, 280);

      for (int i = levels; i > 0; i--) {
        int num = i * 5;
        float r = baseRadius * i / levels;

        for (int j = 0; j < num; j++) {
          float angle = TWO_PI * j / num;
          float x = cos(angle) * r;
          float y = sin(angle) * r;
          fill(255, 100 + i * 20, 150, 180);
          ellipse(x, y, r / 3, r / 3);
        }
      }
      popMatrix();
    }

    //Ilustración 5

    //Ilustracion 6
  }

  // Mostrar letra al final para que no quede oculta
  if (lineaActual != "" && mostrarTexto) {
    fill(255);
    textFont(miFuente);
    textAlign(CENTER, CENTER);
    textSize(20);
    text(lineaActual, width / 2, height * 0.88);
  }
}
//Cargar imagenes
void loadImageEvent (int i) {
  switch (i) {
  default:
    image(mom3, 0, 0, width, height);
  }
}

//Efecto de quitar la letra
void keyPressed() {
  if (key == ' ') {
    mostrarTexto = !mostrarTexto;
  }
}
