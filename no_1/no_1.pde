PGraphics circle;

int[] mask;

int circleSize = 600;

int lineSize = 50;

void setup() {
  size(1920, 1080);
  smooth(8);

  circle = createGraphics(circleSize, circleSize);
  circle.beginDraw();
  circle.loadPixels();
  for (int y = 0; y < circle.height; y++) {
    color lineColor = lerpColor(color(255, 113, 206), color(1, 205, 254), (float)y/circle.height);
    for (int x = 0; x < circle.width; x++) {
      if (pow(x - circle.width/2, 2) + pow(y - circle.height/2, 2) < pow(circleSize/2, 2)) circle.pixels[x + y*circle.width] = lineColor; 
      else circle.pixels[x + y*circle.width] = color(0, 0);
    }
  }
  circle.updatePixels();
  circle.endDraw();

  int maskWidth = circleSize;
  int maskHeight = circleSize + lineSize * 2;

  mask = new int[maskWidth * maskHeight];

  for (int y = 0; y < maskHeight; y++) {
    for (int x = 0; x < maskWidth; x++) {
      mask[x + y*maskWidth] = (y % (lineSize * 2) < lineSize) ? 255 : 0;
    }
  }
}

void draw() {
  background(10);

  mask(circle, subset(mask, (lineSize * 2 * circleSize) - (frameCount * circleSize) % (lineSize * 2 * circleSize), circleSize * circleSize), 0);

  translate(width/2, height/2);
  image(circle, -circle.width/2, -circle.height/2);

  filter(BLUR, 8);

  image(circle, -circle.width/2, -circle.height/2);

  chromaticAberration(0);

  stroke(255);
}

void mask(PGraphics image, int[] mask, color ignore) {
  image.loadPixels();
  for (int i = 0; i < image.pixels.length; i++) {
    if (image.pixels[i] == ignore) continue;

    image.pixels[i] = (image.pixels[i] & 0xffffff) | (mask[i] << 24);
  }
  image.updatePixels();
}

void chromaticAberration(int dist) {
  loadPixels();
  int[] origColours = pixels.clone();
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      int i = x+y*width;

      int red = ((origColours[i] >> 16) & 0xff) / 2;
      if(x + 1 < width) red += ((origColours[i + 1] >> 16) & 0xff)/4;
      if(x + 2 < width) red += ((origColours[i + 2] >> 16) & 0xff)/8;
      if(x + 3 < width) red += ((origColours[i + 3] >> 16) & 0xff)/16;
      if(x + 4 < width) red += ((origColours[i + 4] >> 16) & 0xff)/32;

      
      int blue = ((origColours[i]) & 0xff) / 2;
      if(x > 0) blue += ((origColours[i - 1]) & 0xff)/4;
      if(x > 1) blue += ((origColours[i - 2]) & 0xff)/8;
      if(x > 2) blue += ((origColours[i - 3]) & 0xff)/16;
      if(x > 3) blue += ((origColours[i - 4]) & 0xff)/32;
      
      pixels[i] = color(red, (origColours[i] << 8) & 0xff, blue);
    }
  }
  
  updatePixels();
}

color blendColors(color c1, color c2) {
  int a1 = (int)alpha(c1);
  int a2 = (int)alpha(c2);
  
  int div = a1 + a2*(1-a1);
  
  int r = (int)((red(c1)*a1+red(c2)*a2*(1-a1))/div);
  int g = (int)((green(c1)*a1+green(c2)*a2*(1-a1))/div);
  int b = (int)((blue(c1)*a1+blue(c2)*a2*(1-a1))/div);
  
  return color(r,g,b);
}

int blendChannel(int c1, int c2, int alpha1, int alpha2) {
  return (int)((c1*alpha1+c2*alpha2*(1-alpha1))/(alpha1+alpha2*(1-alpha1)));
}
