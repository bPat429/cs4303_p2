class Firebolt extends Spell {
  static final float spawn_chance = 0.10;

 Firebolt(int x_pos, int y_pos, int item_level) {
    super(x_pos, y_pos, item_level, "Firebolt");
  }
  
  public boolean interact(Player player) {
    return player.pickupItem(this);
  }

  public boolean use(Player player) {
    // Do nothing
    return false;
  }
}