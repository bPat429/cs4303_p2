// Health potion class
class HealthPotion extends Interactable {
    static final float spawn_chance = 0.5;

 HealthPotion(int x_pos, int y_pos, int item_level) {
    super(x_pos, y_pos, item_level);
    super.type = 1;
    super.item_image = loadImage("HealthPotion.png");
  }
  
  public boolean interact(Player player) {
    return player.pickupItem(this);
  }

  public boolean use(Player player) {
    player.restoreHealth(0.25 * this.getRank());
    return true;
  }

  // Generic draw method to be overided
  void drawComponent(int tile_size) {
    image(super.item_image, tile_size * super.location[0], tile_size * super.location[1], tile_size , tile_size);
  }
}
