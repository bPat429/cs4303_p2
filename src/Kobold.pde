// Goblin type monster
class Kobold extends Monster {
    static final float spawn_chance = 0.33;
    private float alert_cooldown = 0;
    private float pack_behaviour_cooldown = 0;
    private int[] last_pack_position;

    Kobold(int spawn_x, int spawn_y, int level) {
        super(spawn_x, spawn_y, level, "Kobold");
        super.setImage(loadImage("kobold.png"));
    }

    void updateRegroupPath(int[][] level_tile_map) {
        if (current_path == null
            || current_path[current_path.length - 1][0] != last_pack_position[0]
            || current_path[current_path.length - 1][1] != last_pack_position[1]) {
                // A new path is needed
                current_path = navigateAStar(level_tile_map, last_pack_position);
                super.hunting_the_player = false;
        }
    }

    // Default AI decision procedure
    // Include the monsters arraylist to allow pack tactics
    void planComplex(int[][] level_tile_map, Player player, ArrayList<Monster> monsters, float frame_duration) {
        // If the player is far away then run the normal planning procedure
        if (this.getDistance(player) > this.detection_radius) {
            if (millis() - player_last_seen < 3000) {
                // We've been alerted, the player has run away or 
                super.hunting_the_player = true;
                updatePlayerPath(level_tile_map);
                pursueGoal(frame_duration, player);
            } else {
                super.plan(level_tile_map, player, monsters, frame_duration);
                return;
            }
        }
        detectPlayer(player);
        // If the player has been spotted, and it's been less than 3 seconds pursue.
        // Added a pack behaviour cooldown to avoid monsters appearing too indecisive
        if (last_player_position != null && millis() - player_last_seen < 3000 && millis() - pack_behaviour_cooldown > 1000) {
            boolean alert_sounded = false;
            boolean kobold_nearby = false;
            boolean kobold_distant = false;
            // Count the nearby kobolds
            for (int i = 0; i < monsters.size(); i++) {
                Monster current_monster = monsters.get(i);
                if (current_monster != this && current_monster.getType() == "Kobold") {
                    // Check if the other kobold is in range
                    if (this.getDistance(current_monster) < 100) {
                        if (millis() - alert_cooldown < 100) {
                            current_monster.alertMonster(last_player_position);
                            print("Kobold alerted");
                            alert_sounded = true;
                        }
                        if (!kobold_nearby && this.getDistance(current_monster) < 5) {
                            kobold_nearby = true;
                        } else if (!kobold_distant && this.getDistance(current_monster) < 10) {
                            kobold_distant = true;
                            last_pack_position = current_monster.getDisplayTileLocation();
                        }
                    }
                }
            }
            if (!kobold_nearby && kobold_distant && last_pack_position != null) {
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
        pursueGoal(frame_duration, player);
    }
}