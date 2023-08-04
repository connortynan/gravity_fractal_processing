
int threadNum = Runtime.getRuntime().availableProcessors();

public int threadsDone = 0;

class RaytracingThread extends Thread {
  public void run(int t)
  {
    try {
      int stopI = min(threadSection*(t+1), fractal.width*fractal.height);
      for (int i = threadSection*t; i < stopI; i++) {
        Particle part = new Particle(new PVector(fractal_mult*(i%fractal.width) + fractal_mult*0.5, fractal_mult*int(i/fractal.height)+ fractal_mult*0.5));
        while (!part.collided && part.iterations < max_iterations) {
          part.check_coll();
          part.get_acc();
          part.update_pos();
          if (part.collided) {
            fractal.pixels[i] = part.ending_body.col;
          }
        }
      }
      threadsDone++;
    }
    catch (Exception e) {
      // Throwing an exception
      System.out.println("Exception is caught");
    }
  }
}
