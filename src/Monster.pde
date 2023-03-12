// Superclass for all monsters
class Monster extends Entity {
    // Monster only stats
    private int base_strength = 5;
    int strength() {
        return base_strength + level;
    }
    // Calculate damage for a monster's attack
    int calculateDamage() {
        return strength() * base_damage;
    }

    // Detection radius (in tiles) for the monster to sense the player
    int detection_radius = 10;
    // If a monster loses contact with the player then they will head towards
    // the last known position. Set to null after a time limit.
    int[] last_player_position;
    // A subtree of the partition tree which contains that monster's home territory
    // While idle the monster will choose a random location from this tree to roam to
    DungeonPartitionTree home_territory;
    // If this is null create a new roam goal. If last_player_position is not null then ignore this.
    int[] roam_goal;

    Monster(int spawn_x, int spawn_y, int tile_size, int level, String type) {
        super(spawn_x, spawn_y, tile_size, level, type);
    }

    // TODO collide with the player
}