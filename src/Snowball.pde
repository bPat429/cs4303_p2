class Snowball extends Spell {
  static final float spawn_chance = 0.10;

 Snowball(int x_pos, int y_pos, int item_level) {
    super(x_pos, y_pos, item_level, "Snowball");
    super.updateName(getName(item_level));
  }

  private String getName(int item_level) {
    String name = "Snowball";
    name = (item_level == 2) ? "Ice Spike" : name;
    name = (item_level == 3) ? "Ray of Frost" : name;
    name = (item_level == 4) ? "Polar Ray" : name;
    return name;
  }
  
  public boolean interact(Player player) {
    return player.pickupItem(this);
  }

  public boolean use(Player player) {
    // Do nothing
    return false;
  }
}