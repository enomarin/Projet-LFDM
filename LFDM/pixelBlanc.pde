class Agent {


  int x;
  int y;

  ArrayList<PVector> trail = new ArrayList();
  PGraphics trailGraphic;

  PVector position;
  PVector forces;
  PVector acceleration;
  PVector vitesse;
  float heading;
  float p;
  PVector otherForces;

  float borderX_0 = width*0.01;
  float borderY_0 = height*0.01;
  float borderX_1 = width - borderX_0;
  float borderY_1 = height - borderY_0;


  PVector goal; // Vecteur du "but" du pixel

  // variable changeant le but (désir) au bout d'une durée d'entre 3 et 10 secondes
  float timerGoal;

  Agent(int _x, int _y) {
    x = _x;
    y = _y;
    vitesse = new PVector(0, 0);
    position = new PVector(x, y);

    forces = new PVector(0, 0);
    float randomAngle = random(TWO_PI);
    forces.x *= cos(randomAngle);
    forces.y *= sin(randomAngle);

    otherForces = new PVector(0, 0);

    goal = new PVector(random(width), random(height));

    trailGraphic = createGraphics(width, height);
    timerGoal = 5;
  }

  void update() {
    constrainToSurface();
    move();
    changeGoal();
  }

  void drawAgent() {
    background(0);
    rectMode(CENTER);
    rect(position.x, position.y, 1, 1);
    drawTrail();
    drawGoal();
    showSurface();
  }
  // MOUVEMENT DU PIXEL
  void move() {
    comportement();
    hesitation();
    forceDuMilieu();
    //println(forces.mag());
    //forces.limit(0.5);
    forces.setMag(1);
    // Application du vecteur forces à la position --> déplacement du point
    position.add(forces);
  }
  //                             INCONSCIENT
  void changeGoal() {
    //println(position.x % goal.x);
    boolean reachedGoal = position.x == goal.x && position.y == goal.y;

    if ( reachedGoal | timerGoal <= 0) {
      goal = new PVector(random(borderX_0, borderX_1), random(borderY_0, borderY_1));
      timerGoal = frameRate * random(5, 20);
    }

    timerGoal -= 1;
  }
  //                   CONSCIENT
  void comportement() {
    // Création d'une force de déplacement du pixel vers un point aléatoire du cadre
    acceleration = PVector.sub(goal, position);
    acceleration.limit(accelerationLevel);
    //Application de cette force au vecteur forces
    forces.add(acceleration);
  }

  //
  void hesitation() {
    float heading = map(noise(p), 0, 1, -TWO_PI, TWO_PI);
    p += 0.04;
    PVector headingVector = new PVector(cos(heading), sin(heading));
    headingVector.setMag(hesitationLevel);

    forces.add(headingVector);
  }
  void forceDuMilieu() {
    boolean pos0 = position.x > 0 || position.y > 0;
    boolean pos1 = position.x < width || position.y < width;
    if (pos0|| pos1) {
      otherForces.add(noise2D[int(position.y)*width+int(position.x)]);
      otherForces.limit(turbulenceLevel);
      // Application de cette force au vecteur forces
      forces.add(otherForces);
    }
  }


  void constrainToSurface() {

    PVector opposedDirection;
    if (position.x < borderX_0) {
      opposedDirection = PVector.mult(forces, -1);
      forces.x *= -1;
    }

    if (position.y < borderY_0) {
      opposedDirection = PVector.mult(forces, -1);
      forces.y *= -1;
    }
    if (position.x > borderX_1) {
      opposedDirection = PVector.mult(forces, -1);
      forces.x *= -1;
    }
    if (position.y > borderY_1) {
      opposedDirection = PVector.mult(forces, -1);
      forces.y *= -1;
    }
  }
  void showSurface() {
    stroke(255);
    line(borderX_0, borderY_0, borderX_0, borderY_1);
    line(borderX_0, borderY_0, borderX_1, borderY_0);
    line(borderX_1, borderY_0, borderX_1, borderY_1);
    line(borderX_0, borderY_1, borderX_1, borderY_1);
    noStroke();
  }
  void drawTrail() {
    // println(trail.size());

    trail.add(new PVector(position.x, position.y));

    if (trail.size() >= 1000) {
      trail.remove(0);
    }

    for (PVector pos : trail) {

      noStroke();
      rectMode(CENTER);
      fill(255, map(trail.indexOf(pos), 0, 999, 120, 255));
      rect(pos.x, pos.y, 2, 2);
    }
  }
  void drawGoal() {
    pushMatrix();
    translate(goal.x, goal.y);
    fill(0, 255, 0);
    ellipse(0, 0, 5, 5);
    popMatrix();
  }
}