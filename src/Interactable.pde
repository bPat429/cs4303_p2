// Superclass for all items and staircases
class Interactable {
  // The tile on which this is placed
  private int[] location;
  // Type of the item
  // 0 = equippable
  // 1 = consumable
  // 2 = spell tome (learned on interact)
  // 3 = staircase
  private int type;
  private PImage item_image;
  private int rank;
  // Radius used to tune how far the player may be and still interact
  private float interact_radius;
  static final float spawn_chance = 0.1;

  Interactable(int x_pos, int y_pos, int rank) {
    this.location = new int[]{x_pos, y_pos};
    this.rank = rank;
    // Set default interact_radius to slightly smaller than a tile
    this.interact_radius = 0.4;
  }

  float getInteractRadius() {
      return interact_radius;
  }

  int getType() {
    return type;
  }

  int getRank() {
    return rank;
  }

  int[] getLocation() {
    return location;
  }

  PImage getImage() {
    return item_image;
  }

  // Check if the player is colliding with an object, and therefore if they can interact
  public boolean checkCollision(Player player) {
    PVector player_location = player.getLocation();
    float d = (float) Math.sqrt(Math.pow(player_location.x - location[0], 2) + Math.pow(player_location.y - location[1], 2));
    float sum_radius = this.getInteractRadius() + player.getInteractRadius();
    return (sum_radius >= d);
  }
  
  // Generic interact method to be overided
  // This represents interacting with the object while in the dungeon level screen
  // Returns true if the item should be removed from the interactables list.
  public boolean interact(Player player) {
    print("Error, interaction not implemented yet");
    return false;
  }

  // Generic interact method to be overided
  // This represents interacting with the object while in the inventory screen
  // Return true if consumable
  public boolean use(Player player) {
    print("Error, use not implemented yet");
    return false;
  }

  // Generic draw method to be overided
  void drawComponent(int tile_size) {
    fill(0, 255, 0);
    rect(location[0] * tile_size, location[1] * tile_size, tile_size, tile_size);
  }
}
