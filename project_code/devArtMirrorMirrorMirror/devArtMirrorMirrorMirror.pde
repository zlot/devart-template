import processing.video.*;

// ScreenCapturer Library by OnFormative found here: http://www.onformative.com/lab/screencapturer/
// Note - There may be an issue running this library off Processing 2.1.1. Works with 2.0.3.
import com.onformative.screencapturer.*;

/* Authors: Mark C Mitchell and Hanley Weng
 * DevArt 2014
 * This is set to test mode, with a single, static image.
 * There is much structure in place here ready for 8 cameras and 
 * a hack for Google Hangouts.
 * Hope you enjoy our work! :)
 */

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

// x, y, width, height of gHangout feed
// Adjust appropriately!
int gHangoutX = 216;
int gHangoutY = 110;
int gHangoutWidth = 1490;
int gHangoutHeight = 890;

PImage testImage;
PImage[] cameraImages;

boolean HOLD_BLUR_TOGGLE = true;
boolean DRAW_DEBUG = false;
boolean LIVE_TEST = false; // run only when we have a real google hangouts + 8 cameras running!


void setup() {
  size(1920, 1080, P2D);

  cameraImages = new PImage[8];
  
  // ScreenCapturer - Initiate
  if (scrnCapturerOn)
    capturer = new ScreenCapturer(gHangoutWidth, gHangoutHeight, 30);
  
  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, 640/4, 480/4);

  // Start capturing the images from the camera
  video.start();
  
  
  setupBlur();

  // Vignette - Load Image
  if (vignetteOn) vignette = loadImage(vignetteFile);
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
  
  if(frameCount < 60 && scrnCapturerOn)
    capturer.setLocation(gHangoutX, gHangoutY);
  
  if(video.available())
    video.read();

  background(0);
  
  // process each camera feed
  processCameraFeeds();
  integrateAndDrawCameraFeeds();
  

  if (lastView!=null) {
    //    pushStyle();
    camPGraphic.scale(0.97);
    camPGraphic.tint(255, 177);
    camPGraphic.image(lastView, -width/2, -height/2, width, height);
    camPGraphic.shader(blur);
    camPGraphic.popStyle();
    camPGraphic.endDraw();

    image(camPGraphic, 0, 0);

    pushStyle();
    tintTheta = (tintTheta > 360) ? 1 : ++tintTheta;
    tint(255, map(sin(radians(tintTheta)), -1, 1, 0, 203));
    // playing with the optimum tint between blur/slitscreen, might be 35?
    //tint(255, 35);

    // this is surprisingly important to the aesthetics of the captured blurs!
    image(bgCloudsImage, 0, 0, width, height);
    popStyle();

    if (!HOLD_BLUR_TOGGLE && frameCount % 8 == 0) {
      /* from: imagemagick.org/Usage/blur
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

  blendMode(BLEND);
  // Draw Vignette
  if (vignetteOn) image(vignette, 0, 0, width, height);
    
  // Draw Debug
  if(DRAW_DEBUG) drawDebug();
}


void processCameraFeeds() {
  int leftMargin = 1022;
  int feedWidth = 96;
  int gap = 25;
  PImage googleHangout = capturer.getImage();
  
  for(int i=0;i<cameraImages.length;i++) {
    int y = i < 4 ? 644 : 644+gap+feedWidth;
    cameraImages[i] = googleHangout.get(leftMargin + i*(feedWidth+gap), y, feedWidth, feedWidth);
    if(DRAW_DEBUG) rect(leftMargin + i*(feedWidth+gap), y, feedWidth, feedWidth);
  }
}

void integrateAndDrawCameraFeeds() {
 blur.set("horizontalPass", 1);

  camPGraphic.beginDraw();
  camPGraphic.translate(width/2, height/2);
  camPGraphic.pushStyle();
  camPGraphic.blendMode(BLEND);
  camPGraphic.image(video, -width/2, -height/2, width, height);
  camPGraphic.image(bgCloudsImage, -width/2, -height/2, width, height);
  if (scrnCapturerOn) {
    camPGraphic.blendMode(LIGHTEST); // Creates the best Ganzfield-type effect!
    // Also gives interesting effects: EXCLUSION.
    pushMatrix();
    // scale up the camera feeds to reallife size
    scale(7); // this is to be tweaked!
    for(PImage img : cameraImages) {
      if(LIVE_TEST) camPGraphic.image(img, -width/2, -height/2, width, height);
      // TODO:: give each feed a unique x-value, so they can spread out around the installation.
    }
    popMatrix();
    if(!LIVE_TEST) camPGraphic.image(testImage, -width/2, -height/2, width, height);
  }
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
  HOLD_BLUR_TOGGLE = !HOLD_BLUR_TOGGLE;
}
