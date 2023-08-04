
static public float k = 1000000.0;
float dt = 0.01;
int body_num = 10; //MAX OF 10!
static int max_iterations = 50000;
static float fractal_mult = 1;

Particle part = null;
ArrayList<Body> bodies = new ArrayList<Body>();
PImage body_texture;
color[] body_colors = {color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 0), color(255, 0, 255), color(0, 255, 255), color(255, 128, 0), color(255, 0, 128), color(128, 255, 0), color(128, 0, 255), color(0, 128, 256)};
public PGraphics fractal;
int threadSection;

void setup() {
  size(800, 800);
  background(0);
  noSmooth();

  body_texture = loadImage("body_texture.png");

  fractal = createGraphics(int(width/fractal_mult), int(height/fractal_mult));
  threadSection = int(fractal.height*fractal.width/threadNum) + 1;
  for (int i = 0; i < body_num; i++) {
    bodies.add(new Body(new PVector(400 + 200*(cos(2*PI*i/body_num - PI*0.5)), 400 + 200*(sin(2*PI*i/body_num - PI*0.5))), body_colors[i]));
  }

  render();
  fractal.save("fractal.png");
}

void draw() {
  image(fractal, 0, 0, width, height);
  for (Body b : bodies) {
    b.show();
  }

  if (part != null) {
    part.check_coll();
    if (part.collided) {
      part = null;
      return;
    }
    part.get_acc();
    part.update_pos();
    part.show();
  }
}

void mousePressed() {
  part = new Particle(new PVector(mouseX, mouseY));
}

void render() {
  threadsDone = 0;
  fractal.beginDraw();
  fractal.loadPixels();

  for (int t = 0; t < threadNum; t++) {
    RaytracingThread object = new RaytracingThread();
    object.run(t);
  }

  while (threadsDone < threadNum) {
  }

  fractal.updatePixels();
  fractal.endDraw();
}

class Particle {
  PVector starting_pos;
  PVector pos;
  PVector ppos;
  int iterations = 0;
  Body ending_body;
  boolean collided = false;
  PVector acc = new PVector(0, 0);

  Particle(PVector p) {
    starting_pos = p.copy();
    pos = p.copy();
    ppos = p.copy();
  }

  void show() {
    stroke(0);
    strokeWeight(5);
    point(pos.x, pos.y);
  }

  void check_coll() {
    for (Body b : bodies) {
      if ((pos.x - b.pos.x)*(pos.x - b.pos.x) + (pos.y - b.pos.y)*(pos.y - b.pos.y) < b.radius*b.radius) {
        collided = true;
        ending_body = b;
        return;
      }
    }
  }

  void get_acc() {
    for (Body b : bodies) {
      acc.add(b.grav_attraction(pos));
    }
  }

  void update_pos() {
    PVector velocity = PVector.sub(pos, ppos);
    ppos.x = pos.x;
    ppos.y = pos.y;
    pos.add(velocity.add(acc.mult(dt*dt)));
    acc.x = 0;
    acc.y = 0;
    iterations++;
  }
}

class Body {
  PVector pos;
  color col;
  float radius;

  Body(PVector p, color c) {
    pos = p;
    col = c;
    radius = 10;
  }

  void show() {
    fill(col);
    noStroke();
    circle(pos.x, pos.y, radius*2);
    image(body_texture, pos.x - radius, pos.y - radius, radius*2, radius*2);
  }

  PVector grav_attraction(PVector part_pos) {
    PVector result = PVector.sub(pos, part_pos);
    result.setMag(k/((pos.x-part_pos.x)*(pos.x-part_pos.x) + (pos.y-part_pos.y)*(pos.y-part_pos.y)));

    return result;
  }
}
