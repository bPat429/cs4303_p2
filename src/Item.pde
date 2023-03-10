// Superclass for all items
// Inherits from Interactable to show that the Items and staircases have common methods
class Item implements Interactable {
  // The tile on which this is placed
  private int[] location;
  private int tile_size;
  // Type of the item
  // 0 = equippable
  // 1 = consumable
  // 2 = spell tome (learned on interact)
  private int type;
  // Radius used to tune how far the player may be and still interact
  private float interact_radius;

  Item(int tile_size, int x_pos, int y_pos) {
    this.location = new int[]{x_pos, y_pos};
    this.tile_size = tile_size;
  }

  float getInteractRadius() {
      return interact_radius;
  }

  int getType() {
    return type;
  }

  // Check if the player is colliding with an object, and therefore if they can interact
  public boolean checkCollision(Player player) {
    float[] player_location = player.getLocation();
    float d = (float) Math.sqrt(Math.pow(player_location[0] - location[0], 2) + Math.pow(player_location[0] - location[0], 2));
    float sum_radius = this.getInteractRadius() + player.getInteractRadius();
    //float d = this.get_centre_mass().dist(other_object.get_centre_mass());
    // Check if the combined radii of the circles is greater than the distance between centres. If so then there is not collision, otherwise there may be a collision.
    return (sum_radius >= d);
  }
  
  // Generic interact method to be overided
  // This represents interacting with the object while in the dungeon level screen
  public void interact() {
    print("Error, interaction not implemented yet");
  }

  // Generic interact method to be overided
  // This represents interacting with the object while in the inventory screen
  public void use() {
    print("Error, use not implemented yet");
  }

  // Generic draw method to be overided
  void draw() {
    fill(0, 255, 0);
    rect(location[0] * tile_size, location[1] * tile_size, tile_size, tile_size);
  }
}
