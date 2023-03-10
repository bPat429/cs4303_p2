import java.util.Random;

final class DungeonLevelHandler {
    // The current dungeon level
    private int depth;
    // An array representing the contents of each tile in the dungeon.
    // 0 = unpopulated space
    // 1 = room space
    // 2 = wall space (used to draw the border around rooms)
    // 3 = occupied room space, used to avoid placing multiple spawns in same space
    private int[][] level_tile_map;
    private int[] entry_staircase;
    private int[] exit_staircase;
    private DungeonPartitionTree partition_tree;
    private Random rand;

    // The size of each tile
    private int tile_size;
    // The increase in dungeon size per level (in number of tiles)
    private int dungeon_dimension_step;
    // Minimum dungeon room size, including walls
    private int dungeon_room_size;
    private int dungeon_min_partition_size;

    DungeonLevelHandler(int tile_size, int dungeon_dimension_step, int dungeon_size, Random rand) {
        this.tile_size = tile_size;
        this.depth = 0;
        this.dungeon_dimension_step = dungeon_dimension_step;
        // Constant found by testing different room sizes
        this.dungeon_min_partition_size = 7;
        this.dungeon_room_size = 6;
        this.rand = rand;
        generateLevel(dungeon_size);
    }

    // Generate the dungeon level
    void generateLevel(int dungeon_size) {
        // Increase dungeon size every level
        dungeon_size = dungeon_size + depth * dungeon_dimension_step;
        // Default value is 0
        level_tile_map = new int[dungeon_size][dungeon_size];
        partition_tree = new DungeonPartitionTree(0, 0, dungeon_size, dungeon_size);
        partition_tree.partitionWidth(dungeon_min_partition_size, dungeon_min_partition_size, rand);
        partition_tree.createRoom(dungeon_room_size, dungeon_room_size, rand);
        partition_tree.drawRooms(level_tile_map);
        partition_tree.drawCorridors(level_tile_map);
        // Use left and right children to star the spawnStaircases to try and ensure staircases aren't in the same room, and are some distance apart
        partition_tree.getLeftChild().spawnStaircases(level_tile_map, rand);
        partition_tree.getRightChild().spawnStaircases(level_tile_map, rand);
        printLevel();
    }

    // Error checking method
    void printLevel() {
        print("\n");
        for (int i = 0; i < level_tile_map.length; i++) {
            for (int j = 0; j < level_tile_map.length; j++) {
                switch (level_tile_map[j][i]) {
                    case 0:
                        print(" ");
                        break;
                    case 1:
                        print("o");
                        break;
                    case 2:
                        print("x");
                        break;
                    case 3:
                        print("z");
                        break;
                }
            }
            print("\n");
        }
    }

    // Main method used to run the gameloop while the player is exploring a dungeon level.
    void run() {
        // Handle character Movement
        // Transform so camera tracks player
        // Get Monster goal locations
        // Calculate Monster pathfinding
        // Move monsters
        // draw level
        draw();
    }

    void draw() {
        // TODO fix this
        int player_x = tile_size * level_tile_map.length / 2;
        int player_y = tile_size * level_tile_map.length / 2;
        pushMatrix();
        translate(displayWidth/2 - player_x, displayHeight/2 - player_y);
        // Draw the level_tile_map
        for (int x = 0; x < level_tile_map.length; x++) {
            for (int y = 0; y < level_tile_map[x].length; y++) {
                switch (level_tile_map[x][y]) {
                    case 1:
                        fill(209);
                        break;
                    case 2:
                        fill(50);
                        break;
                    case 3:
                    // Used for debugging
                        fill(0);
                        break;
                    default:
                        fill(0);
                }
                rect(x * tile_size, y * tile_size, tile_size, tile_size);
            }
        }
        popMatrix();
    }
}
