// Staircase class
class Staircase extends Interactable {
  private boolean is_down;

  Staircase(int x_pos, int y_pos, boolean is_down) {
    super(x_pos, y_pos, 0);
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
  
  // The functionality of the staircase is implemented in the DungeonLevelHandler
  public boolean interact() {
    return false;
  }

  // Generic draw method to be overided
  void drawComponent(int tile_size) {
    if (is_down) {
      fill(255, 0, 0);
    } else {
      fill(0, 255, 0);
    }
    rect(super.location[0] * tile_size, super.location[1] * tile_size, tile_size, tile_size);
  }
}
