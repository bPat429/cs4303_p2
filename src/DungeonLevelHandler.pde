import java.util.Random;
import java.util.ArrayList;

final class DungeonLevelHandler {
    // The current dungeon level
    private int depth;
    // An array representing the contents of each tile in the dungeon.
    // 0 = unpopulated space
    // 1 = room space
    // 2 = wall space (used to draw the border around rooms)
    // 3 = occupied room space, used to avoid placing multiple spawns in same space
    private int[][] level_tile_map;
    private DungeonPartitionTree partition_tree;
    private Random rand;
    private Player player;
    private ArrayList<Interactable> level_interactables;
    private ArrayList<Monster> monsters;
    // A cooldown used to avoid unnecessarily repeating the search action due to high framerate
    private float search_cooldown;

    // The size of each tile
    private int tile_size;
    // The increase in dungeon size per level (in number of tiles)
    private int dungeon_dimension_step;
    private int dungeon_size; 
    // Minimum dungeon room size, including walls
    private int dungeon_room_size;
    private int dungeon_min_partition_size;

    DungeonLevelHandler(int tile_size, int dungeon_dimension_step, int dungeon_size, Random rand, Player player) {
        this.tile_size = tile_size;
        this.depth = 0;
        this.dungeon_dimension_step = dungeon_dimension_step;
        // Constant found by testing different room sizes
        this.dungeon_min_partition_size = 7;
        this.dungeon_room_size = 6;
        this.rand = rand;
        this.dungeon_size = dungeon_size;
        this.player = player;
        generateNextLevel();
        this.search_cooldown = millis();
    }

    // Generate the dungeon level
    int[] generateLevel() {
        level_interactables = new ArrayList<Interactable>();
        monsters = new ArrayList<Monster>();
        // Increase dungeon size every level
        dungeon_size = dungeon_size + depth * dungeon_dimension_step;
        // Default value is 0
        level_tile_map = new int[dungeon_size][dungeon_size];
        partition_tree = new DungeonPartitionTree(0, 0, dungeon_size, dungeon_size, null, rand);
        partition_tree.partitionWidth(dungeon_min_partition_size, dungeon_min_partition_size, rand);
        partition_tree.createRoom(dungeon_room_size, dungeon_room_size, rand);
        partition_tree.drawRooms(level_tile_map);
        partition_tree.drawCorridors(level_tile_map);
        // Use left and right children to star the spawnStaircases to try and ensure staircases aren't in the same room, and are some distance apart
        int[] entry_staircase_pos = partition_tree.getLeftChild().spawnStaircases(level_tile_map, rand);
        int[] exit_staircase_pos = partition_tree.getRightChild().spawnStaircases(level_tile_map, rand);
        level_interactables.add(new Staircase(entry_staircase_pos[0], entry_staircase_pos[1], false));
        level_interactables.add(new Staircase(exit_staircase_pos[0], exit_staircase_pos[1], true));
        partition_tree.spawnItems(level_tile_map, level_interactables, rand, 0);
        partition_tree.spawnMonsters(level_tile_map, monsters, level_interactables, depth, rand);
        // Force at least {depth} monsters to spawn
        while(monsters.size() < depth + 1) {
            partition_tree.spawnMonsters(level_tile_map, monsters, level_interactables, depth, rand);
        }
        return entry_staircase_pos;
    }

    void generateNextLevel() {
        int[] entry_staircase_pos = generateLevel();
        this.player.setLocation(entry_staircase_pos[0], entry_staircase_pos[1]);
        depth = depth + 1;
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

    // Return the index of the first object which is close enough to interact with
    // -1 if none are close
    int checkInteractablessProximity() {
        // First check if any items are spawned on the current tile
        if (level_tile_map[player.getDisplayTileLocation()[0]][player.getDisplayTileLocation()[1]] == 3) {
            // check in backwards order because the staircases are at the start of the list, we don't
            // want the player to miss an item because it's too close to the staircase
            for (int i = level_interactables.size() - 1; i >=0; i--) {
                if (level_interactables.get(i).checkCollision(player)) {
                    return i;
                }
            }
        }
        return -1;
    }

    // Main method used to run the gameloop while the player is exploring a dungeon level.
    void run(ArrayList<Monster> combat_queue, boolean[] input_array, float frame_duration) {
        // Handle character Movement
        player.handleInput(input_array, frame_duration);
        player.handleWallCollisions(level_tile_map);
        // Check if the player is trying to interact with an item
        // Impose a cooldown because the player doesn't need to search the same place several times
        if (input_array[6] && (millis() - search_cooldown) > 500) {
            search_cooldown = millis();
            // Check if any items are close
            int index = checkInteractablessProximity();
            if (index > 0) {
                if (index == 1) {
                    // Handle interacting with the down staircase
                    generateNextLevel();
                    drawComponent();
                    return;
                } else {
                    if (level_interactables.get(index).interact(player)) {
                        level_interactables.remove(index);
                    };
                }
            }
        }
        // Get Monster goal locations, Calculate Monster pathfinding, Move monsters
        for (int i = 0; i < monsters.size(); i++) {
            Monster current_monster = monsters.get(i);
            if (current_monster != null) {
                current_monster.plan(level_tile_map, player, monsters, rand, frame_duration);
                current_monster.handleWallCollisions(level_tile_map);
                current_monster.checkPlayerEncounter(combat_queue, player);
            }
        }
        // draw level
        drawComponent();
        // If a monster is in combat with the player remove them from the dungeon monsters list
        for (int i = 0; i < combat_queue.size(); i++) {
            if (combat_queue.get(i) != null) {
                monsters.remove(combat_queue.get(i));
            }
        }
    }

    void drawComponent() {
        background(125);
        pushMatrix();
        PVector player_location = player.getLocation();
        translate((displayWidth/2) - tile_size * player_location.x, (displayHeight/2) - tile_size * player_location.y);
        // Draw the level_tile_map
        for (int x = 0; x < level_tile_map.length; x++) {
            for (int y = 0; y < level_tile_map[x].length; y++) {
                int fill_val = 0;
                switch (level_tile_map[x][y]) {
                    case 1:
                        fill_val = ((x+y) % 2 == 0) ? 159 : 169;
                        break;
                    case 2:
                        fill_val = 50;
                        break;
                    case 3:
                        // Used for room tiles which are occupied
                        fill_val = ((x+y) % 2 == 0) ? 159 : 169;
                        break;
                    default:
                        fill_val = 125;
                }
                fill(fill_val);
                rect(x * tile_size, y * tile_size, tile_size, tile_size);
            }
        }
        // Draw all interactables
        for (int i = 0; i < level_interactables.size(); i++) {
            if (level_interactables.get(i) != null) {
                level_interactables.get(i).drawComponent(tile_size);
            }
        }
        // Draw all monsters
        for (int i = 0; i < monsters.size(); i++) {
            if (monsters.get(i) != null) {
                monsters.get(i).drawComponent(tile_size);
            }
        }
        // Draw the player
        player.drawComponent(tile_size);
        popMatrix();
    }
}
