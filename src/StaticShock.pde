class StaticShock extends Spell {
  static final float spawn_chance = 0.10;

 StaticShock(int x_pos, int y_pos, int item_level) {
    super(x_pos, y_pos, item_level, "Static Shock");
    super.updateName(getName(item_level));
  }

  private String getName(int item_level) {
    String name = "Static Shock";
    name = (item_level == 2) ? "Lightning Bolt" : name;
    name = (item_level == 3) ? "Lightning Strike" : name;
    name = (item_level == 4) ? "Lightning Storm" : name;
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