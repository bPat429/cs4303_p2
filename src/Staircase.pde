// Staircase class
class Staircase extends Interactable {
  private boolean is_down;

  Staircase(int tile_size, int x_pos, int y_pos, boolean is_down) {
    super(tile_size, x_pos, y_pos);
    this.is_down = is_down;
    super.type = 3;
  }

  // Only permit interaction if the staircase leads down
  public boolean checkCollision(Player player) {
    if (is_down) {
      return super.checkCollision(player);
    }
    return false;
  }
  
  // TODO
  public void interact() {
    print("Error, interaction not implemented yet");
  }

  // Generic draw method to be overided
  void draw() {
    if (is_down) {
      fill(255, 0, 0);
    } else {
      fill(0, 255, 0);
    }
    rect(super.location[0] * tile_size, super.location[1] * tile_size, tile_size, tile_size);
  }
}