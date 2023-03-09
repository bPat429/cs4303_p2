import java.util.Random;

final class DungeonLevelHandler {
    // The current dungeon level
    private int depth;
    // An array representing the contents of each tile in the dungeon.
    // 0 = unpopulated space
    // 1 = room space
    // 2 = wall space (used to draw the border around rooms)
    private int[][] level_tile_map;
    private DungeonPartitionTree partition_tree;
    private Random rand;

    // The size of each tile
    private int tile_size;
    // The increase in dungeon size per level (in number of tiles)
    private int dungeon_dimension_step;
    // Minimum dungeon room size, including walls
    private int dungeon_room_size;

    DungeonLevelHandler(int tile_size, int dungeon_dimension_step, int dungeon_size, Random rand) {
        this.tile_size = tile_size;
        this.depth = 0;
        this.dungeon_dimension_step = dungeon_dimension_step;
        this.dungeon_room_size = dungeon_size / 4;
        this.rand = rand;
        generateLevel(dungeon_size);
    }

    // Generate the dungeon level
    void generateLevel(int dungeon_size) {
        // Increase dungeon size every level
        dungeon_size = dungeon_size + depth * dungeon_dimension_step;
        // Default value is 0
        level_tile_map = new int[dungeon_size+1][dungeon_size+1];
        partition_tree = new DungeonPartitionTree(0, 0, dungeon_size, dungeon_size);
        partition_tree.partition_width(dungeon_room_size, dungeon_room_size, rand);
        partition_tree.create_room(dungeon_room_size, dungeon_room_size, rand);
        partition_tree.apply_to_dungeon(level_tile_map);
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
        int player_x = level_tile_map.length / 2;
        int player_y = level_tile_map.length / 2;
        pushMatrix();
        translate(displayWidth/2 - player_x * tile_size, displayHeight/2 - player_y * tile_size);
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
                    default:
                        fill(0);
                    rect(x * tile_size, y * tile_size, tile_size, tile_size);
                }
            }
        }
        popMatrix();
    }
}
