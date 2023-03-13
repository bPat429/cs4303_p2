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
    // A subtree of the partition tree which contains that monster's home territory
    // While idle the monster will choose a random location from this tree to roam to
    DungeonPartitionTree home_territory;
    // If this is null create a new roam goal. If last_player_position is not null then ignore this.
    int[] roam_goal;
    int[][] current_path;

    Monster(int spawn_x, int spawn_y, int level, String type) {
        super(spawn_x, spawn_y, level, type);
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
        AStarNode first_node = new AStarNode(null, this.getTileLocation(), goal_pos);
        frontier.add(first_node);
        // At the search limit set the completed path node to the best node in the array
        int search_limit = 100;
        AStarNode completed_path_node = null;
        while(completed_path_node == null) {
            int best_index = getBestNodeInFrontier(frontier);
            // Return the best node if the search limit is reached, or the node has reached the goal
            if (search_limit > 100 || frontier.get(best_index).isGoal()) {
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
        // Build path from the search nodes
        int[][] new_path = new int[completed_path_node.getDepth() + 1][2];
        AStarNode current_node = completed_path_node;
        for (int i = completed_path_node.getDepth(); i >= 0; i--) {
            new_path[i][0] = current_node.getPos()[0];
            new_path[i][1] = current_node.getPos()[1];
            current_node = current_node.getParent();
        } 
        return new_path;
    }

    // TODO collide with the player
}