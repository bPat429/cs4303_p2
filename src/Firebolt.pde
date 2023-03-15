class Firebolt extends Spell {
  static final float spawn_chance = 0.10;

 Firebolt(int x_pos, int y_pos, int item_level) {
    super(x_pos, y_pos, item_level, "Firebolt");
    super.updateName(getName(item_level));
  }

  private String getName(int level) {
    String name = "Firebolt";
    name = (level == 2) ? "Fireball" : name;
    name = (level == 3) ? "Flame Strike" : name;
    name = (level == 4) ? "Inferno" : name;
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