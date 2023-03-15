// Spell interactable superclass
// Represented by a book on the ground, when picked up teaches the player a new spell
// Spells are replaced in order of oldest to newest when the number of spells known has
// reached it's limit.
class Spell extends Interactable {
    private int turn_cooldown;
    private int cooldown;
    private String spell_name;
    static final float spawn_chance = 0.20;
    private int default_cooldown_val = -2;
    
    Spell(int x_pos, int y_pos, int item_level, String spell_name) {
        super(x_pos, y_pos, item_level);
        if (item_level == 1) {
            super.item_image = loadImage("SpellPage.png");
        } else if (item_level == 2) {
            super.item_image = loadImage("SpellScroll.png");
        } else {
            super.item_image = loadImage("SpellTome.png");
        }
        super.type = 2;
        this.spell_name = spell_name;
        this.cooldown = item_level;
        this.turn_cooldown = default_cooldown_val;
    }

    // Check if the spell is ready to be used
    public boolean checkCooldown(int turn) {
        return (turn - turn_cooldown >= cooldown);
    }

    // Use this when a spell is cast
    public void updateCooldown(int turn) {
        turn_cooldown = turn;
    }

    // Reset the cooldowns after combat
    // Aim for 2nd level ready immediately, 3rd level ready next turn and 4th level ready in 2 turns
    public void resetCooldown() {
        turn_cooldown = default_cooldown_val;
    }

    public void updateName(String name) {
        this.spell_name = name;
    }

    // Reset the cooldowns after combat
    public String getSpellName() {
        return spell_name;
    }

    // Generic draw method to be overided
    void drawComponent(int tile_size) {
        image(super.item_image, tile_size * super.location[0], tile_size * super.location[1], tile_size , tile_size);
    }
}
