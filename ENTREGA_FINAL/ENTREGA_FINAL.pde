//Sara Pacheco, Maite Figueroa y Nicole Fernandez //<>//
//Sonido
import processing.sound.*;
import processing.sound.FFT;
SoundFile soundfile;
FFT fft;

//Fondo
color fondo = color(0);
int ultimoMovimientoMouse = 0;
int tiempoEspera = 2000;

//Ilustraciones y fuente
PImage ojo, mom3;
PFont miFuente;

//Variables ilustracion 1 (espiral y ojo)
float fade = 255;
float zoom = 1.0;
boolean transicion = false;
float tiempo;
float angulo = 0;

//Variables ilustraciones 3 y 4
int index = 0;
int bands = 512;
float[] spectrum = new float[bands];

//Tiempo de los efectos ilustracion 3 y 4
float inicioMomento3 = 43.0;
float duracionMomento3 = 27.0;
float inicioMomento4 = 70.0;
float duracionMomento4 = 29.0;

boolean sonidoIniciado = false;
boolean mostrarTexto = true;

//Letra
color textoColor = color(255);
String[] letras;
float[] tiempoLetra = {
  0.0, 4.0, 9.0, 11.0, 13.0, 17.0, 21.0, 23.0, 25.0, 26.0, 29.0, 31.0, 36.0,
  39.0, 41.0, 43.0, 45.0, 49.0, 51.0, 53.0, 58.0, 62.0, 66.0, 70.0, 73.0, 75.0,
  77.0, 78.0, 83.0, 84.0, 88.0, 91.0, 93.0, 95.0, 97.0, 99.0, 101.0, 104.0, 106.0, 110.0,
  114.0, 119.0, 122.0, 125.0, 127.0, 130.0, 131.0, 134.0, 136.0, 142.0, 144.0, 146.0,
  149.0, 151.0, 154.0, 156.0, 158.0, 161.0
};

int startMillis;

class Particula {
  PVector pos;
  PVector vel;
  float radio;
  color col;

  Particula(PVector p, float r, color c) {
    pos = p.copy();
    radio = r;
    col = c;
    vel = PVector.random2D().mult(random(1, 3));
  }

  void mover() {
    pos.add(vel);

    // Rebote en los bordes del sketch
    if (pos.x - radio < 0 || pos.x + radio > width) {
      vel.x *= -1;
      pos.x = constrain(pos.x, radio, width - radio);
    }
    if (pos.y - radio < 0 || pos.y + radio > height) {
      vel.y *= -1;
      pos.y = constrain(pos.y, radio, height - radio);
    }
  }

  void dibujar() {
    noStroke();
    fill(col);
    ellipse(pos.x, pos.y, radio, radio);
  }
}

ArrayList<Particula> particulas = new ArrayList<Particula>();
boolean particulasInicializadas = false;

void setup() {
  size(900, 900);
  imageMode(CENTER);
  noStroke();

  //Sonido
  soundfile = new SoundFile(this, "lovelost.mp3");
  fft = new FFT(this, bands);
  fft.input(soundfile);
  soundfile.cue(0);
  soundfile.play();
  sonidoIniciado = true;

  //Letra canción
  letras = loadStrings("lovelostletra.txt");

  //Fuente
  miFuente = createFont("tipografia.ttf", 35);
  textFont(miFuente);

  //Imagenes
  ojo = crearOjoVibrante();
  mom3 = loadImage("ilustracion3.png");

  startMillis = millis();
}

void draw() {
  if (millis() - ultimoMovimientoMouse > tiempoEspera) {
    fondo = color(0);
  }
  background(fondo);

  float currentTime = (millis() - startMillis) / 1000.0;
  tiempo = currentTime;

  // Letra actual
  String lineaActual = "";
  for (int i = 0; i < tiempoLetra.length; i++) {
    if (tiempo >= tiempoLetra[i]) {
      lineaActual = letras[i];
    }
  }

  // Ilustración 3
  if (currentTime >= inicioMomento3 && currentTime < inicioMomento3 + duracionMomento3) {
    fft.analyze(spectrum);
    loadImageEvent(index);

    float totalEnergy = 0;
    for (int i = 0; i < bands; i++) {
      totalEnergy += spectrum[i];
    }

    int numImages = int(map(totalEnergy, 0, 10, 1, 50));
    numImages = constrain(numImages, 1, 100);

    for (int i = 0; i < numImages; i++) {
      float x = random(width);
      float y = random(height);
      float sizeFactor = random(0.2, 0.5);
      image(mom3, x, y, mom3.width * sizeFactor, mom3.height * sizeFactor);
    }
  }

  // Ilustración 4
  else if (currentTime >= inicioMomento4 && currentTime < inicioMomento4 + duracionMomento4) {
    fft.analyze(spectrum);
    float totalEnergy = 0;
    for (int i = 0; i < bands; i++) {
      totalEnergy += spectrum[i];
    }

    float baseRadius = map(totalEnergy, 0, 10, 250, 280);
    baseRadius = constrain(baseRadius, 150, 280);
    float t = currentTime - inicioMomento4;

    if (t < 5) {
      particulas.clear();
      particulasInicializadas = false;
      pushMatrix();
      translate(width / 2, height / 2);
      int levels = 8;
      for (int i = levels; i > 0; i--) {
        int num = i * 5;
        float r = baseRadius * i / levels;
        for (int j = 0; j < num; j++) {
          float angle = TWO_PI * j / num;
          float baseX = cos(angle) * r;
          float baseY = sin(angle) * r;
          float offsetX = sin(frameCount * 0.02 + j) * 20;
          float offsetY = cos(frameCount * 0.02 + j) * 20;
          float x = baseX + offsetX;
          float y = baseY + offsetY;
          fill(255, 100 + i * 20, 150, 180);
          ellipse(x, y, r / 3, r / 3);
        }
      }
      popMatrix();
    } else {
      if (!particulasInicializadas) {
        particulas.clear();
        int levels = 8;
        for (int i = levels; i > 0; i--) {
          int num = i * 5;
          float r = baseRadius * i / levels;
          for (int j = 0; j < num; j++) {
            float angle = TWO_PI * j / num;
            float baseX = cos(angle) * r;
            float baseY = sin(angle) * r;
            PVector posicion = new PVector(width / 2 + baseX, height / 2 + baseY);
            float tam = r / 3;
            color c = color(255, 100 + i * 20, 150, 180);
            particulas.add(new Particula(posicion, tam, c));
          }
        }
        particulasInicializadas = true;
      }
      for (Particula p : particulas) {
        p.mover();
        p.dibujar();
      }
    }
  }

 // Ilustración 1 y 2 (espiral y ojo)
  else if (currentTime < 43) {
    if (tiempo > 37) {
      transicion = true;
      zoom -= 0.005;
    }

    pushMatrix();
    translate(width / 2, height / 2);
    scale(zoom);
    dibujarEspiralPsy();
    float vibracion = sin(frameCount * 0.2) * 5;
    image(ojo, vibracion, vibracion, 100, 100);
    popMatrix();

    if (tiempo < 10) {
      fill(255);
      textFont(miFuente);
      textAlign(CENTER, TOP);
      text("Pero aún se siente bonito...", width / 2, height * 0.1);
    }
  }
  

  // ESCENA FINAL
  else if (currentTime > 99) {
    float fadeOutAlpha = map(currentTime, 99, 108, 255, 0);
    background(0, 0, 0, 255 - fadeOutAlpha);

    noFill();
    stroke(255, fadeOutAlpha);
    strokeWeight(2);
    float sep = 150;
    ellipse(width / 2 - sep, height / 2, 100, 180);
    ellipse(width / 2 + sep, height / 2, 100, 180);

    fill(255, fadeOutAlpha);
    textFont(miFuente);
    textAlign(CENTER, CENTER);
    textSize(22);
    float desplazamientoY = sin(frameCount * 0.05) * 5;
    text("I miss you, but I’m better off now.", width / 2, height * 0.8 + desplazamientoY);

    if (currentTime >= 105 && soundfile.isPlaying()) {
      float volumen = map(currentTime, 105, 108, 1.0, 0.0);
      volumen = constrain(volumen, 0, 1);
      soundfile.amp(volumen);

      if (currentTime >= 108) {
        soundfile.stop();
        noLoop();
      }
    }
  }

  // Mostrar letra todo el tiempo si está activada
  if (mostrarTexto && lineaActual != "") {
    fill(textoColor);
    textFont(miFuente);
    textAlign(CENTER, CENTER);
    textSize(20);
    text(lineaActual, width / 2, height * 0.88);
  }
  // Indicaciones visuales en pantalla
  fill(180);
  textFont(miFuente);
  textSize(16);
  textAlign(LEFT, TOP);

  if (currentTime < 43 || (currentTime >=75 && currentTime <=99)) {
    text("Mueve el mouse para cambiar el color de fondo", 20, 20);
  }

  text("Presiona la barra espaciadora para quitar la letra", 20, 45);

  if (currentTime > 99) {
    text("Presiona el mouse para cambiar la letra de color", 20, 70);
  }
}

// --- FUNCIONES ADICIONALES ---

void dibujarEspiralPsy() {
  noFill();
  strokeWeight(2);
  for (int j = 0; j < 3; j++) {
    stroke(255, 80 + j * 60, 200);
    beginShape();
    for (float a = 0; a < TWO_PI * 10; a += 0.05) {
      float r = a * 8;
      float x = cos(a + angulo + j * 0.5) * r;
      float y = sin(a + angulo + j * 0.5) * r;
      vertex(x, y);
    }
    endShape();
  }
  angulo += 0.01;
}

PImage crearOjoVibrante() {
  PGraphics pg = createGraphics(120, 120);
  pg.beginDraw();
  pg.background(0, 0);
  pg.stroke(255);
  pg.fill(255);
  pg.ellipse(60, 60, 80, 45);
  pg.fill(50, 0, 255);
  pg.ellipse(60, 60, 25, 25);
  pg.fill(0);
  pg.ellipse(60, 60, 12, 12);
  pg.fill(255, 100);
  pg.ellipse(65, 55, 8, 8);
  pg.endDraw();
  return pg.get();
}

void loadImageEvent(int i) {
  switch (i) {
  default:
    image(mom3, width / 2, height / 2, width, height);
  }
}

void keyPressed() {
  if (key == ' ') {
    mostrarTexto = !mostrarTexto;
  }
}

void mouseMoved() {
  fondo = color(230, 200, 255);
  ultimoMovimientoMouse = millis();
}

void mousePressed() {
  // Cambia el color del texto en escena final
  if (tiempo > 99) {
    textoColor = color(random(100, 255), random(100, 255), random(100, 255));
  }
}
