// Equippable interactable superclass
class Equipment extends Interactable {
    // equipment_type: 0 = head, 1 = chest, 2 = weapon
    private int equipment_type;
    static final float spawn_chance = 0.20;

    Equipment(int x_pos, int y_pos, int item_level, int equipment_type, PImage item_image) {
        super(x_pos, y_pos, item_level);
        super.item_image = item_image;
        super.type = 0;
        this.equipment_type = equipment_type;
    }

    public int get_equipment_type() {
        return equipment_type;
    }
    
    // Generic interact method to be overided
    public void applyBuffs(Player player) {
        print("Error, use not implemented yet");
    }

    // Generic interact method to be overided
    public void removeBuffs(Player player) {
        print("Error, use not implemented yet");
    }

    // Generic draw method to be overided
    void drawComponent(int tile_size) {
        image(super.item_image, tile_size * super.location[0], tile_size * super.location[1], tile_size , tile_size);
    }
}
