
class WizardHat extends Equipment {
    static final float spawn_chance = 0.10;
    static final int base_buff = 3;

 WizardHat(int x_pos, int y_pos, int item_level) {
    super(x_pos, y_pos, item_level, 0, loadImage("WizardHat.png"));
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
    player.addDex(base_buff * this.getRank());
    player.addInt((base_buff * this.getRank()) / 3);
  }

  // Generic interact method to be overided
  public void removeBuffs(Player player) {
    player.removeDex(base_buff * this.getRank());
    player.removeInt((base_buff * this.getRank()) / 3);
  }
}