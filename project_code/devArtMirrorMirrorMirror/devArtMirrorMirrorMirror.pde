import processing.video.*;

Capture video;

PImage lastView;

PShader blur;
PGraphics src;
PGraphics pass1, pass2;

PGraphics camPGraphic;

int blurSizeX = 48;
float sigmaSizeY = 24.0f;
int blurLimit;

PImage shadowImage, bgImage, bgCloudsImage;
PImage camImage;

int tintTheta = 0;

void setup() {
  size(1024, 768, P2D);

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, 640/4, 480/4);

  // Start capturing the images from the camera
  video.start();

  setupBlur();
}

void setupBlur() {
  blur = loadShader("blur.glsl"); 

  src = createGraphics(width, height, P2D); 
  pass1 = createGraphics(width, height, P2D);
  pass1.noSmooth();  
  pass2 = createGraphics(width, height, P2D);
  pass2.noSmooth();

  camPGraphic = createGraphics(width, height, P2D);

  shadowImage = loadImage("shadow.png");

  bgCloudsImage = loadImage("bg_clouds.jpg");
  src.beginDraw();
  src.background(0, 0);
  makeBackgroundTransparent(src);
  src.image(shadowImage, 30, 0);
  src.endDraw();
}

void draw() {
  if (video.available()) {
    video.read();
  }
  background(0);

  blur.set("horizontalPass", 1);

  camPGraphic.beginDraw();
  camPGraphic.translate(width/2, height/2);
  camPGraphic.pushStyle();
  camPGraphic.scale(-1, 1);
  camPGraphic.image(video, -width/2, -height/2, width, height);

  if (lastView!=null) {
    //    pushStyle();
    camPGraphic.scale(-0.97, 1);
    camPGraphic.tint(255, 177);
    camPGraphic.image(lastView, -width/2, -height/2, width, height);
    camPGraphic.shader(blur);
    camPGraphic.popStyle();
    camPGraphic.endDraw();

    image(camPGraphic, 0, 0);

    int r = 2;

    //    blend(lastView, 0, 0, width, height, r, r, width-r*2, height-r*2, BLEND);
    //    blend(lastView, 0, 0, width, height, r, r, width-r*2, height-r*2, DODGE);
    //    blend(lastView, 0, 0, width, height, r, r, width-r*2, height-r*2, EXCLUSION);
    //    filter(BLUR, 1);


    pushStyle();
    tintTheta = (tintTheta > 360) ? 1 : ++tintTheta;

    //    tint(255, map(sin(radians(tintTheta)), -1, 1, 0, 255));
    //    println(map(sin(radians(tintTheta)), -1, 1, 0, 255));

    // playing with the optimum tint between blur/slitscreen, might be 35?
    tint(255, 35);

    //    blend(bgCloudsImage, 0, 0, width, height, r, r, width-r*2, height-r*2, HARD_LIGHT);
    image(bgCloudsImage, 0, 0, width, height);
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


    if (frameCount % 8 == 0) {
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
  }

  camPGraphic.beginDraw();
  lastView = get();
  //  lastView = camPGraphic.get();
  camPGraphic.endDraw();

  drawDebug();
}

/*
  Little trick from http://forum.processing.org/one/topic/pgraphics-transparency.html
 must be called from within a PGraphics beginDraw()/endDraw()
 */
void makeBackgroundTransparent(PGraphics pg) {
  pg.background(255, 255, 0);
  pg.clear();
}

void drawDebug() {
  pushStyle();
  fill(0, 90, 90);
  text("blurSizeX: " + blurSizeX, 30, 20);
  text("sigmaSizeY: " + sigmaSizeY, 30, 45);
  text(frameRate, 30, height*.97);
  popStyle();
}

