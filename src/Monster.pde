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
        return strength() * base_damage;
    }

    // Detection radius (in tiles) for the monster to sense the player
    int detection_radius = 10;
    // If a monster loses contact with the player then they will head towards
    // the last known position. Set to null after a time limit.
    int[] last_player_position;
    // Time of the last player sighting. If more than 3 seconds pass default to roaming
    float player_last_seen;
    // A subtree of the partition tree which contains that monster's home territory
    // While idle the monster will choose a random location from this tree to roam to
    DungeonPartitionTree home_territory;
    // If this is null create a new roam goal. If last_player_position is not null then ignore this.
    int[] roam_goal;
    int[][] current_path;
    // Index representing the current position on the path
    int current_path_index;

    Monster(int spawn_x, int spawn_y, int level, String type) {
        super(spawn_x, spawn_y, level, type);
        super.entity_speed = 2;
    }

    // Default AI decision procedure
    void plan(int[][] level_tile_map, Player player, float frame_duration) {
        // Check if the monster can see the player
        // TODO this is a placeholder method
        if (last_player_position == null || millis() - player_last_seen > 3000) {
            last_player_position = player.getDisplayTileLocation();
        player_last_seen = millis();
        }
        
        // If the player has been spotted, and it's been less than 3 seconds pursue.
        if (last_player_position != null && millis() - player_last_seen < 3000) {
            // Check if we already have a path to that location
            if (current_path == null
                || current_path[current_path.length - 1][0] != last_player_position[0]
                || current_path[current_path.length - 1][1] != last_player_position[1]) {
                    // A new path is needed
                    current_path = navigateAStar(level_tile_map, last_player_position);
            }
            // Move the monster along the path
            // TODO

        }
        pursueGoal(frame_duration, player);
    }

    // Pursue the currently set path. If none is set then do nothing.
    // Note that the A* path uses the tile list as nodes, but the equivalent coordinates point to the corner of the tile rather than the center.
    void pursueGoal(float frame_duration, Player player) {
        // The first node on the path is the current location
        if (current_path != null) {
            PVector current_location = this.getLocation();
            // Try to head straight for the player if we are close, otherwise head for the player last seen location, or amble goal
            float final_loc_x = (millis() - player_last_seen > 3000) ? current_path[current_path.length - 1][0] : player.getLocation().x;
            float final_loc_y = (millis() - player_last_seen > 3000) ? current_path[current_path.length - 1][1] : player.getLocation().y;
            float chase_goal_x = final_loc_x - current_location.x;
            float chase_goal_y = final_loc_y - current_location.y;
            // First check if the goal is very close, if so pursue directly
            if (Math.abs(chase_goal_x) + Math.abs(chase_goal_y) < 3) {
                if (Math.abs(chase_goal_x) + Math.abs(chase_goal_y) < 0.1) {
                    current_path = null;
                    return;
                }
                // Use kinematic motion for movement
                super.movement_vector.set(chase_goal_x, chase_goal_y);
                super.moveEntity(frame_duration);
                return;
            }
            // We don't return paths of length 1, so it's safe to do current_path_index + 1 here
            if (Math.abs(current_path[current_path_index + 1][0] - current_location.x) < 0.1 
                && Math.abs(current_path[current_path_index + 1][1] - current_location.y) < 0.1) {
                // we've moved on to the next tile, update the index
                current_path_index = current_path_index + 1;
                // TODO check if we've somehow gone off the path
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
            if (search_limit > 1000 || frontier.get(best_index).isGoal()) {
                completed_path_node = frontier.get(best_index);
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

    // TODO collide with the player
}