class WizardStaff extends Equipment {
    static final float spawn_chance = 0.10;
    static final int base_buff = 3;
    static final int weapon_mod = 1;

 WizardStaff(int x_pos, int y_pos, int item_level) {
    super(x_pos, y_pos, item_level, 2, loadImage("WizardStaff.png"));
  }
  
  public boolean interact(Player player) {
    return player.pickupItem(this);
  }

  public boolean use(Player player) {
    // Do nothing
    return false;
  }
  
  // Generic interact method to be overided
  public void applyBuffs(Player player) {
    player.addInt((base_buff * this.getRank()) / 3);
    player.addWeaponMod(weapon_mod * this.getRank());
  }

  // Generic interact method to be overided
  public void removeBuffs(Player player) {
    player.removeInt((base_buff * this.getRank()) / 3);
    player.removeWeaponMod(weapon_mod * this.getRank());
  }
}