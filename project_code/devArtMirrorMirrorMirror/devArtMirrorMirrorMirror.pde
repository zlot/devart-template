import processing.video.*;

Capture video;

PImage lastView;

//float swidth = 640;
//float sheight = 480;

void setup() {
  size(1024, 768);

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, 640, 480);

  // Start capturing the images from the camera
  video.start();
}

void draw() {
  if (video.available()) {
    video.read();
  }
  background(0);

  image(video, 0, 0, width, height);


  if (lastView!=null) {
    pushMatrix();
    pushStyle();
    translate(width/2,height/2);
    scale(0.95);
    tint(255,177);
    image(lastView,-width/2,-height/2,width,height);
    popStyle();
    popMatrix();

    int r = 2;

//    blend(lastView, 0, 0, width, height, r, r, width-r*2, height-r*2, BLEND);
//    blend(lastView, 0, 0, width, height, r, r, width-r*2, height-r*2, DODGE);
//    blend(lastView, 0, 0, width, height, r, r, width-r*2, height-r*2, EXCLUSION);
    filter(BLUR,3);
  }


  lastView = get();
}

