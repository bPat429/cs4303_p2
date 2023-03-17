// Goblin type monster
class Kobold extends Monster {
    static final float spawn_chance = 0.33;
    private float alert_cooldown = -10000;
    private float pack_behaviour_cooldown = 0;
    private int[] last_pack_position;

    Kobold(int spawn_x, int spawn_y, DungeonPartitionTree home_territory, int level) {
        super(spawn_x, spawn_y, home_territory, level, "Kobold");
        super.setImage(loadImage("kobold.png"));
    }

    void updateRegroupPath(int[][] level_tile_map) {
        if (current_path == null
            || current_path[current_path.length - 1][0] != last_pack_position[0]
            || current_path[current_path.length - 1][1] != last_pack_position[1]) {
                super.setFullSpeed();
                // A new path is needed
                current_path = navigateAStar(level_tile_map, last_pack_position);
                super.hunting_the_player = false;
        }
    }

    // Default AI decision procedure
    // Include the monsters arraylist to allow pack tactics
    // This is the same as the Goblin planning function
    void plan(int[][] level_tile_map, Player player, ArrayList<Monster> monsters, Random rand, float frame_duration) {
        if (millis() - planning_cooldown > 100) {
            // If the player is far away then run the normal planning procedure
            if (this.getDistance(player) > this.detection_radius) {
                super.plan(level_tile_map, player, monsters, rand, frame_duration);
                return;
            }
            // We know that the player is detected and close
            detectPlayer(player);
            // Added a pack behaviour cooldown to avoid monsters appearing too indecisive
            if (millis() - pack_behaviour_cooldown > 1000) {
                boolean alert_sounded = false;
                boolean reinforcements_nearby = false;
                boolean reinforcements_distant = false;
                // Count the nearby kobolds
                for (int i = 0; i < monsters.size(); i++) {
                    Monster current_nearby_monster = monsters.get(i);
                    if (current_nearby_monster != this && current_nearby_monster.getType() == this.getType()) {
                        // Check if the other kobold is in range
                        if (this.getDistance(current_nearby_monster) < 10) {
                            // Assert a cooldown of 10 seconds
                            if (millis() - alert_cooldown > 10000) {
                                current_nearby_monster.alertMonster(last_player_position);
                                alert_sounded = true;
                            }
                            if (!reinforcements_nearby && this.getDistance(current_nearby_monster) < 5) {
                                reinforcements_nearby = true;
                            } else if (!reinforcements_distant && this.getDistance(current_nearby_monster) < 10) {
                                reinforcements_distant = true;
                                last_pack_position = current_nearby_monster.getDisplayTileLocation();
                            }
                        }
                    }
                }
                if (!reinforcements_nearby && reinforcements_distant && last_pack_position != null) {
                    // If a kobold is nearby then run to the other kobold for emotional support
                    updateRegroupPath(level_tile_map);
                } else {
                    // If a kobold is very close, or no reinforcements to regroup with just run at the player
                    // Hunt the player
                    super.hunting_the_player = true;
                    updatePlayerPath(level_tile_map);
                }
                if (alert_sounded) {
                    alert_cooldown = millis();
                }
                pack_behaviour_cooldown = millis();
            }
            planning_cooldown = millis();
        }
        pursueGoal(frame_duration, player);
    }
}