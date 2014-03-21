/**
 * Separate Blur Shader
 * 
 * This blur shader works by applying two successive passes, one horizontal
 * and the other vertical.
 * 
 */

PShader blur;
PGraphics src;
PGraphics pass1, pass2;

/*
from: imagemagick.org/Usage/blur
 -blur  {radius}x{sigma} 
The first value radius, is also important as it controls how big an area 
the operator should look at when spreading pixels. This value should 
typically be either '0' or at a minimum double that of the sigma.
*/

int blurSizeX = 48;
float sigmaSizeY = 24.0f;
int blurLimit;


PImage shadowImage;

void setup() {
  size(900, 700, P2D);
  
  blur = loadShader("blur.glsl"); 
  
  src = createGraphics(width, height, P2D); 
  pass1 = createGraphics(width, height, P2D);
  pass1.noSmooth();  
  pass2 = createGraphics(width, height, P2D);
  pass2.noSmooth();
  
  shadowImage = loadImage("shadow.png");
  
  src.beginDraw();
  src.background(255);
    
  src.image(shadowImage, 30, 0);

  //src.fill(255);
  //src.ellipse(width/2, height/2, 100, 100);
  src.endDraw();
}


boolean reverse = false;


void draw() {
  // Applying the blur shader along the vertical direction   
  blur.set("horizontalPass", 0);
  pass1.beginDraw();            
  pass1.shader(blur);  
  pass1.image(src, 0, 0);
  pass1.endDraw();
  
  // Applying the blur shader along the horizontal direction      
  blur.set("horizontalPass", 1);
  pass2.beginDraw();            
  pass2.shader(blur);  
  pass2.image(pass1, 0, 0);
  pass2.endDraw();    
        
  image(pass2, 0, 0);
  

  if(frameCount % 2 == 0) {
    sigmaSizeY = map(mouseY, 0, height, 0, 100);
    blurSizeX = int(sigmaSizeY * map(mouseX, 0, width, 1, 4));
    //blurSizeX = (int) map(mouseX, 0, width, 0, 1000);
    
    
    //textSize(32);
    fill(0, 90, 90);

    //blurSize += 200;
    //sigmaSize += 0.1;
    blur.set("blurSize", blurSizeX);
    blur.set("sigma", sigmaSizeY);
    
  }
  
  text("blurSizeX: " + blurSizeX, 30, 20);
  text("sigmaSizeY: " + sigmaSizeY, 30, 45);
  text(frameRate, 30, height*.97);
}

void mouseMoved() {
  
}

void keyPressed() {
  if (key == '9') {
    blur.set("blurSize", 9);
    blur.set("sigma", 5.0);
  } else if (key == '7') {
    blur.set("blurSize", 7);
    blur.set("sigma", 3.0);
  } else if (key == '5') {
    blur.set("blurSize", 5);
    blur.set("sigma", 2.0);  
  } else if (key == '3') {
    blur.set("blurSize", 5);
    blur.set("sigma", 1.0);  
  }  
} 
