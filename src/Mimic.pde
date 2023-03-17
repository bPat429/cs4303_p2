// Goblin type monster
class Mimic extends Monster {
    static final float spawn_chance = 0.1;
    private int[] last_pack_position;
    private PImage combat_mimic;

    Mimic(int spawn_x, int spawn_y, DungeonPartitionTree home_territory, int level) {
        super(spawn_x, spawn_y, home_territory, level, "Mimic");
        super.setImage(loadImage("Mimic.png"));
        combat_mimic = loadImage("CombatMimic.png");
        // Mimics are monsters disguised as treasure chests who spawn on top of loot
        // They have high constitution and damage, but low dexterity
        super.base_constitution = super.base_constitution + 2;
        super.base_dexterity = super.base_dexterity - 2;
        super.base_damage = super.base_damage + 2;
        // Mimics cannot move, and have poor senses, relying on the player coming to them
        this.setEntitySpeed(0);
        // Set a large interact radius so the player cannot steal the loot without a fight
        this.doubleEntityInteractRadius();
    }

    PImage getMimicRevealedImage() {
        return combat_mimic;
    }

    // Override the planning procedure to do nothing, we rely on the player either falling for the trap
    // or choosing to fight the mimic for its loot
    void plan(int[][] level_tile_map, Player player, ArrayList<Monster> monsters, Random rand, float frame_duration) {}
}