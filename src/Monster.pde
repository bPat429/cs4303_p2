import java.util.ArrayList;

// Superclass for all monsters
class Monster extends Entity {
    // Monster only stats
    private int base_strength = 5;
    int strength() {
        return base_strength + level;
    }
    // Calculate damage for a monster's attack
    int calculateDamage() {
        return (strength() * base_damage) / 2;
    }
    private float base_speed;

    // Detection radius (in tiles) for the monster to sense the player
    int detection_radius = 7;
    // If a monster loses contact with the player then they will head towards
    // the last known position. Set to null after a time limit.
    int[] last_player_position;
    // Time of the last player sighting. If more than 3 seconds pass default to roaming
    float player_last_seen;
    // A subtree of the partition tree which contains that monster's home territory
    // While idle the monster will choose a random location from this tree to roam to
    DungeonPartitionTree home_territory;
    // If this is null create a new roam path. If last_player_position is not null then ignore this.
    int[][] current_path;
    // Index representing the current position on the path
    int current_path_index;
    // Boolean used to let monsters opt-out of chasing the player
    boolean hunting_the_player;
    // Cooldowns to reduce computational load of each monster
    float roam_planning_cooldown;
    float planning_cooldown;
    boolean path_leads_to_player;

    Monster(int spawn_x, int spawn_y, DungeonPartitionTree home_territory, int level, String type) {
        super(spawn_x, spawn_y, level, type);
        base_speed = super.entity_speed;
        // The monster should normally be hunting the player, except for when looking for reinforcements
        hunting_the_player = true;
        // The subtree containing the monster's territory. This is used to find where the monster may roam when idle
        this.home_territory = home_territory;
        roam_planning_cooldown = -1000;
        planning_cooldown = -1000;
    }

    int calculateExperience() {
        return this.getLevel();
    }

    void setEntitySpeed(int new_speed) {
        super.entity_speed = new_speed;
    }

    void setFullSpeed() {
        super.entity_speed = base_speed;
    }

    void setRoamSpeed() {
        super.entity_speed = base_speed / 4;
    }

    // Method for doubling interact radius for mosnters with a large reach
    void doubleEntityInteractRadius() {
        super.interact_radius = super.interact_radius * 2;
    }

    // Alert the monster to the player's location
    void alertMonster(int[] player_position) {
        last_player_position = player_position;
        // Give the monster an extra 3 seconds to reach the alert location
        player_last_seen = millis();
    }

    void detectPlayer(Player player) {
        // Check if the monster can see the player
        // If the monster is within detection_radius blocks then the monster detects the player
        // Add a cooldown of 0.2 seconds to reduce unnecessary A* search repetition
        if (this.getDistance(player) < this.detection_radius && millis() - player_last_seen > 200) {
            last_player_position = player.getDisplayTileLocation();
            player_last_seen = millis();
        }
    }

    void updatePlayerPath(int[][] level_tile_map) {
        setFullSpeed();
        if (current_path == null
            || current_path[current_path.length - 1][0] != last_player_position[0]
            || current_path[current_path.length - 1][1] != last_player_position[1]) {
                hunting_the_player = true;
                // A new path is needed
                current_path = navigateAStar(level_tile_map, last_player_position);
                path_leads_to_player = true;
        }
    }

    void updateRoamPath(int[][] level_tile_map, Random rand) {
        setRoamSpeed();
        // Get a random position from one of the rooms in this monster's territory
        int[] roam_goal = home_territory.getRandomPos(level_tile_map, rand);
        // A new path is needed
        current_path = navigateAStar(level_tile_map, roam_goal);
        path_leads_to_player = false;
    }

    // Default AI decision procedure
    // Include the monsters arraylist to allow pack tactics
    void plan(int[][] level_tile_map, Player player, ArrayList<Monster> monsters, Random rand, float frame_duration) {
        if (millis() - planning_cooldown > 100) {
            // Check if the player is detected
            detectPlayer(player);
            // Pathfinding
            // Check if the player is nearby, or if we been alerted to the player's position
            if (last_player_position != null && millis() - player_last_seen < 3000) {
                // If the current path doesn't lead to the player then update the path
                updatePlayerPath(level_tile_map);
            } else {
                // If the alert period has expired then revert to idle behaviour
                // This is important because sometimes monsters think the player is inside a wall, in which case they
                // will never resolve their paths normally
                if (player_last_seen > 6000 && path_leads_to_player) {
                    current_path = null;
                }
                // If the player is not nearby then complete the current path (to their last known position or a roam goal)(if they've been seen at all)
                if (current_path == null && millis() - roam_planning_cooldown > 2000) {
                    // If the path is null then set a roam goal
                    updateRoamPath(level_tile_map, rand);
                    roam_planning_cooldown = millis();
                }
            }
            planning_cooldown = millis();
        }
        // Pursue the goal
        pursueGoal(frame_duration, player);
    }

    // Pursue the currently set path. If none is set then do nothing.
    // Note that the A* path uses the tile list as nodes, but the equivalent coordinates point to the corner of the tile rather than the center.
    void pursueGoal(float frame_duration, Player player) {
        PVector current_location = this.getLocation();
        // Try to head straight for the player if we are close, otherwise head for the player last seen location, or amble goal
        if (hunting_the_player && this.getDistance(player) < 2) {
            // There's an issue where the monster chases the player, but if the player moves away the monster defaults to A* tile based pathing
            // To circumvent this we clear the old navigation path if we're this close
            current_path = null;
            float final_loc_x = player.getLocation().x;
            float final_loc_y = player.getLocation().y;
            float chase_goal_x = final_loc_x - current_location.x;
            float chase_goal_y = final_loc_y - current_location.y;
            super.movement_vector.set(chase_goal_x, chase_goal_y);
            super.moveEntity(frame_duration);
        } else if (current_path != null) {
        // The first node on the path is the current location
            float final_loc_x = current_path[current_path.length - 1][0];
            float final_loc_y = current_path[current_path.length - 1][1];
            float chase_goal_x = final_loc_x - current_location.x;
            float chase_goal_y = final_loc_y - current_location.y;
            // First check if the goal is very close, if so pursue directly
            // This causes more organic pathing, but can't be too far to avoid the monster getting stuck on a wall
            if (Math.abs(chase_goal_x) + Math.abs(chase_goal_y) < 2) {
                if (Math.abs(chase_goal_x) + Math.abs(chase_goal_y) < 0.1) {
                    // Close enough, we can end the path
                    current_path = null;
                    return;
                }
                // Use kinematic motion for movement
                super.movement_vector.set(chase_goal_x, chase_goal_y);
                super.moveEntity(frame_duration);
                return;
            }
            // Check if we've reached the end of the current path, this can trigger if we're chasing the player but player isn't close
            // to the last known position
            if (current_path_index + 1 == current_path.length) {
                current_path = null;
                return;
            }
            // We don't return paths of length 1, so it's safe to do current_path_index + 1 here
            if (Math.abs(current_path[current_path_index + 1][0] - current_location.x) < 0.1 
                && Math.abs(current_path[current_path_index + 1][1] - current_location.y) < 0.1) {
                // we've moved on to the next tile, update the index
                current_path_index = current_path_index + 1;
            }
            if (current_path_index < current_path.length - 1) {
                // Get the movements we need to take to head to the next tile
                float x_move = current_path[current_path_index + 1][0] - current_location.x;
                float y_move = current_path[current_path_index + 1][1] - current_location.y;
                // Use kinematic motion for movement
                super.movement_vector.set(x_move, y_move);
                super.moveEntity(frame_duration);
            }         
        }
    }

    // Find best node and check for any completed path nodes
    int getBestNodeInFrontier(ArrayList<AStarNode> frontier) {
        int best_index = 0;
        for (int i = 1; i < frontier.size(); i++) {
            AStarNode current = frontier.get(i);
            if (current.isGoal()) {
                return i;
            }
            if (current.getCost() < frontier.get(best_index).getCost()) {
                best_index = i;
            }
        }
        return best_index;
    }

    // Check if the new node is a duplicate of a node in the frontier
    boolean checkIsRedundant(ArrayList<AStarNode> frontier, AStarNode new_node) {
        for (int j = 0; j < frontier.size(); j++) {
            if (frontier.get(j).compareNodes(new_node)) {
                return true;
            }
        }
        return false;
    }

    // A star search based navigation
    // Given a goal position try to find a path leading to that position.
    int[][] navigateAStar(int[][] level_tile_map, int[] goal_pos) {
        if (goal_pos == null) {
            return null;
        }
        // The node frontier
        ArrayList<AStarNode> frontier = new ArrayList<AStarNode>();
        // Add the current position to the frontier
        AStarNode first_node = new AStarNode(null, this.getDisplayTileLocation(), goal_pos);
        // If the first node is the goal node return null because we are already at the goal
        frontier.add(first_node);
        // At the search limit set the completed path node to the best node in the array
        int search_limit = 0;
        AStarNode completed_path_node = null;
        while(completed_path_node == null) {
            int best_index = getBestNodeInFrontier(frontier);
            // Return the best node if the search limit is reached, or the node has reached the goal
            if (search_limit > 200 || (frontier.size() > 0 && frontier.get(best_index).isGoal())) {
                if (frontier.size() > 0) {
                    completed_path_node = frontier.get(best_index);
                } else {
                    completed_path_node = new AStarNode(null, this.getDisplayTileLocation(), goal_pos);
                }
            } else {
                AStarNode[] new_nodes = frontier.get(best_index).exploreNode(level_tile_map, goal_pos);
                // Pop explored node from the frontier
                frontier.remove(best_index);
                // Try to add new nodes to the frontier
                for (int i = 0; i < new_nodes.length; i++) {
                    if (new_nodes[i] != null) {
                        if (!checkIsRedundant(frontier, new_nodes[i])) {
                            frontier.add(new_nodes[i]);
                        }
                    }
                }
            }
            search_limit++;
        }
        // If we exited early and the depth = 0 then return null because we have no useful path
        if (completed_path_node.getDepth() == 0) {
            return null;
        }
        // Build path from the search nodes
        int[][] new_path = new int[completed_path_node.getDepth() + 1][2];
        AStarNode current_node = completed_path_node;
        for (int i = completed_path_node.getDepth(); i >= 0; i--) {
            new_path[i][0] = current_node.getPos()[0];
            new_path[i][1] = current_node.getPos()[1];
            current_node = current_node.getParent();
        }
        // Reset the current path index
        current_path_index = 0;
        return new_path;
    }

    // check collision with player
    void checkPlayerEncounter(ArrayList<Monster> combat_queue, Player player) {
        PVector player_location = player.getLocation();
        float d = this.getDistance(player);
        float sum_radius = this.getInteractRadius() + player.getInteractRadius();
        // Make it easier to collide with the player
        if (sum_radius + 0.25 >= d) {
            // Check that this monster isn't already in the queue
            if (!combat_queue.contains(this)) {
                combat_queue.add(this);
            }
        }
    }
}