// Spell interactable superclass
// Represented by a book on the ground, when picked up teaches the player a new spell
// Spells are replaced in order of oldest to newest when the number of spells known has
// reached it's limit.
class Spell extends Interactable {
    private int turn_cooldown;
    private int cooldown;
    private String spell_name;
    Spell(int x_pos, int y_pos, int item_level, String spell_name) {
        super(x_pos, y_pos, item_level);
        super.item_image = loadImage("SpellTome.png");
        super.type = 2;
        this.spell_name = spell_name;
        this.cooldown = item_level;
        this.turn_cooldown = -10;
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
    public void resetCooldown() {
        turn_cooldown = -10;
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