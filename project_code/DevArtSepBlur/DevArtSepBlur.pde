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


int blurSizeX = 48;
float sigmaSizeY = 24.0f;
int blurLimit;


PImage shadowImage, bgImage, bgCloudsImage;

PGraphics testPGraphics;

void setup() {
  size(900, 700, P2D);
  
  blur = loadShader("blur.glsl"); 
  
  src = createGraphics(width, height, P2D); 
  pass1 = createGraphics(width, height, P2D);
  pass1.noSmooth();  
  pass2 = createGraphics(width, height, P2D);
  pass2.noSmooth();
  
  shadowImage = loadImage("shadow.png");
  
  bgCloudsImage = loadImage("bg_clouds.jpg");
  src.beginDraw();
  src.background(0, 0);
  makeBackgroundTransparent(src);
  src.image(shadowImage, 30, 0);
  src.endDraw();
  
}

int tintTheta = 0;

void draw() {
  background(255);
  pushStyle();
  tintTheta = (tintTheta > 360) ? 1 : ++tintTheta;
  tint(255, map(sin(radians(tintTheta)), -1, 1, 0, 255));
  image(bgCloudsImage, 0, 0);
  popStyle();
   
   
  // Applying the blur shader along the vertical direction   
  blur.set("horizontalPass", 0);
  pass1.beginDraw(); 
  makeBackgroundTransparent(pass1);  
  pass1.shader(blur);  
  pass1.image(src, 0, 0);
  pass1.endDraw();
  
  // Applying the blur shader along the horizontal direction      
  blur.set("horizontalPass", 1);
  pass2.beginDraw();            
  makeBackgroundTransparent(pass2);
  pass2.shader(blur);  
  pass2.image(pass1, 0, 0);
  pass2.endDraw();    

  image(pass2, 0, 0);
  

  if(frameCount % 8 == 0) {
    /*
      from: imagemagick.org/Usage/blur
       -blur  {radius}x{sigma} 
      The first value radius, is also important as it controls how big an area 
      the operator should look at when spreading pixels. This value should 
      typically be either '0' or at a minimum double that of the sigma.
    */
    sigmaSizeY = map(mouseY, 0, height, 0, 80);
    blurSizeX = int(sigmaSizeY * map(mouseX, 0, width, 1, 6));    
    
    blur.set("blurSize", blurSizeX);
    blur.set("sigma", sigmaSizeY);
  }
  
  drawDebug();
  
}

void drawDebug() {
  pushStyle();
  fill(0, 90, 90);
  text("blurSizeX: " + blurSizeX, 30, 20);
  text("sigmaSizeY: " + sigmaSizeY, 30, 45);
  text(frameRate, 30, height*.97);
  popStyle();
}

/*
  Little trick from http://forum.processing.org/one/topic/pgraphics-transparency.html
  must be called from within a PGraphics beginDraw()/endDraw()
*/
void makeBackgroundTransparent(PGraphics pg) {
  pg.background(255, 255, 0);
  pg.clear();
}
