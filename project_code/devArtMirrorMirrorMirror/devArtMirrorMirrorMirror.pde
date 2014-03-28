import processing.video.*;

// ScreenCapturer Library by OnFormative found here: http://www.onformative.com/lab/screencapturer/
// Note - There may be an issue running this library off Processing 2.1.1 , 2.0.3 does appear to work though.
import com.onformative.screencapturer.*;

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

// Vignette Controls
PImage vignette;
boolean vignetteOn = false;
String vignetteFile = "vignette3.png";

// ScreenCapturer
ScreenCapturer capturer;
boolean scrnCapturerOn = true;

void setup() {
  size(1024, 768, P2D);
boolean holdBlurToggle = false;

boolean drawDebug = false;
  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, 640/4, 480/4);

  // Start capturing the images from the camera
  video.start();

  setupBlur();

  // Vignette - Load Image
  if (vignetteOn) vignette = loadImage(vignetteFile);

  // ScreenCapturer - Initiate
  if (scrnCapturerOn) { 
    capturer = new ScreenCapturer(width, height, 30);
//    capturer.setLocation(x,y);
  }
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
  testImage = loadImage("testImage.jpg");
  
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
  camPGraphic.blendMode(BLEND);
  camPGraphic.image(video, -width/2, -height/2, width, height);
  camPGraphic.image(bgCloudsImage, -width/2, -height/2, width, height);
  if (scrnCapturerOn) {
    camPGraphic.blendMode(LIGHTEST);
//    camPGraphic.image(capturer.getImage(), -width/2, -height/2, width, height);
    camPGraphic.image(testImage, -width/2, -height/2, width, height);
  }

  if (lastView!=null) {
    //    pushStyle();
    camPGraphic.scale(0.97);
    camPGraphic.tint(255, 177);
    camPGraphic.image(lastView, -width/2, -height/2, width, height);
    camPGraphic.shader(blur);
    camPGraphic.popStyle();
    camPGraphic.endDraw();

    image(camPGraphic, 0, 0);

    int r = 2;

    pushStyle();
    tintTheta = (tintTheta > 360) ? 1 : ++tintTheta;
    tint(255, map(sin(radians(tintTheta)), -1, 1, 0, 103));
    // playing with the optimum tint between blur/slitscreen, might be 35?
    //tint(255, 35);

    // this is surprisingly important to the aesthetics of the captured blurs!
    image(bgCloudsImage, 0, 0, width, height);
    popStyle();


    if (!holdBlurToggle && frameCount % 8 == 0) {
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
  else {
    // completing the camPGraphic.beginDraw();
    camPGraphic.endDraw();
  }

  lastView = get();

  // Draw Vignette
  if (vignetteOn) image(vignette, 0, 0, width, height);

  // Draw Debug
  if(drawDebug) drawDebug();
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
  fill(50, 50, 50);
  text("blurSizeX: " + blurSizeX, 30, 20);
  text("sigmaSizeY: " + sigmaSizeY, 30, 45);
  text(frameRate, 30, height*.97);
  popStyle();
}

void mouseClicked() {
  holdBlurToggle = !holdBlurToggle;
}
