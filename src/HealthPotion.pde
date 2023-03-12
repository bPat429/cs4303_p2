// Health potion class
class HealthPotion extends Interactable {
    private int item_level;
    private PImage potion_img;
    static final float spawn_chance = 0.33;

 HealthPotion(int tile_size, int x_pos, int y_pos, int item_level) {
    super(tile_size, x_pos, y_pos);
    this.item_level = item_level;
    super.type = 1;
    this.potion_img = loadImage("HealthPotion.png");
  }
  
  // TODO
  public boolean interact(Player player) {
    return player.pickupItem(this);
  }

  // Generic draw method to be overided
  void draw() {
    image(potion_img, tile_size * super.location[0], tile_size * super.location[1], super.tile_size , super.tile_size);
  }
}
