class AStarNode {
    int[] current_pos;
    AStarNode prev_node;
    int depth;
    float total_cost;
    boolean is_goal;
    AStarNode(AStarNode prev_node, int[] current_pos, int[] goal_pos) {
        // Calculate depth
        if (prev_node == null) {
            this.depth = 0;
        } else {
            this.depth = prev_node.getDepth() + 1;
        }
        this.current_pos = current_pos;
        this.prev_node = prev_node;
        if (current_pos[0] == goal_pos[0] && current_pos[1] == goal_pos[1]) {
            is_goal = true;

        } else {
            is_goal = false;
            // Calculate Euclidean distance as heuristic
            float euclidean_distance = (float) Math.sqrt((current_pos[0] - goal_pos[0]) * (current_pos[0] - goal_pos[0]) + (current_pos[1] - goal_pos[1]) * (current_pos[1] - goal_pos[1]));
            this.total_cost = this.depth + euclidean_distance;
        }
    }

    float getCost() {
        return total_cost;
    }

    int getDepth() {
        return depth;
    }

    // Returns the latest point in the path history
    int[] getPos() {
        return current_pos;
    }

    boolean isGoal() {
        return is_goal;
    }

    AStarNode getParent() {
        return prev_node;
    }

    // Check if this node leads to a node already in the frontier (if so this is a less efficient path)
    // Returns true if matching
    boolean compareNodes(AStarNode other_node) {
        return (other_node.getPos()[0] == this.getPos()[0] && other_node.getPos()[1] == this.getPos()[1]);
    }


    AStarNode[] exploreNode(int[][] level_tile_map, int[] goal_pos) {
        // Up to 8 valid children (1 will be a repeat of the path node). Set to null if invalid.
        AStarNode[] valid_nodes = new AStarNode[8];
        // Array index
        int i = 0;
        for (int x = current_pos[0] - 1; x <= current_pos[0] + 1; x++) {
            for (int y = current_pos[1] - 1; y <= current_pos[1] + 1; y++) {
                // Ignore the current square as a future node
                if (current_pos[0] != x || current_pos[1] != y) {
                    // Because of the offset of the actual character position and the tile they appear to be on (due to drawing tiles from their corner, not their center)
                    // we add an early escape if the player is near a wall and seems to be inside it. This avoids impossible paths caused by the AI thinking the player
                    // is in an unreachable location
                    if (goal_pos[0] == x && goal_pos[1] == y) {
                        valid_nodes[i] = new AStarNode(this, new int[]{x, y}, goal_pos);
                        return valid_nodes;
                    }
                    // Check if the current square represents a diagonal movement
                    if (current_pos[0] != x && current_pos[1] != y) {
                        // If so we need to check that a wall tile isn't in the way of the diagonal movement
                        if (x >= 0 && y >= 0 && x < level_tile_map.length && y < level_tile_map[x].length
                                && (level_tile_map[current_pos[0]][y] == 1 || level_tile_map[current_pos[0]][y] == 3)
                            && (level_tile_map[x][current_pos[1]] == 1 || level_tile_map[x][current_pos[1]] == 3)) {
                            // Check we're not out of bounds, and that the tile is accessible
                            if (level_tile_map[x][y] == 1 || level_tile_map[x][y] == 3) {
                                valid_nodes[i] = new AStarNode(this, new int[]{x, y}, goal_pos);
                            }
                        }
                    } else {
                        // Check we're not out of bounds, and that the tile is accessible
                        // When passing to the next level an index out of bounds error has occurred here, but not sure why
                        // Also before the crash the screen became darker and darker
                        if (x >= 0 && y >= 0 && x < level_tile_map.length && y < level_tile_map[x].length
                            && (level_tile_map[x][y] == 1 || level_tile_map[x][y] == 3)) {
                            // The movement is not diagonal, and to a valid room space so add the node
                            valid_nodes[i] = new AStarNode(this, new int[]{x, y}, goal_pos);
                        }
                    }
                    i++;
                }
            }
        }
        return valid_nodes;
    }
}