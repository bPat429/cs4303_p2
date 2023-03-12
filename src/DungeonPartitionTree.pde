import java.util.Random;
import java.util.ArrayList;

// Class used to recursively generate and store the partitions used for procedurally generating the dungeon
// First create the root node, then call partition_width or partition_height on it. This will start the recursive
// process of building the tree, alternating splitting by width and height.
public class DungeonPartitionTree {
    private int part_width;
    private int part_height;
    private int[] bottom_left_coordinates;
    private int[] room_bl_corner;
    private int[] room_tr_corner;
    private DungeonPartitionTree l_child;
    private DungeonPartitionTree r_child;

    // Create node
    DungeonPartitionTree(int bottom_left_x, int bottom_left_y, int part_width, int part_height) {
        this.bottom_left_coordinates = new int[]{bottom_left_x, bottom_left_y};
        this.part_width = part_width;
        this.part_height = part_height;
    }

    int[] getRoomCenter() {
        if (l_child == null && r_child == null) {
            // Divide and round down
            int x_center = ((room_tr_corner[0] - room_bl_corner[0]) - (room_tr_corner[0] - room_bl_corner[0])%2) / 2;
            int y_center = ((room_tr_corner[1] - room_bl_corner[1]) - (room_tr_corner[1] - room_bl_corner[1])%2) / 2;
            return new int[]{x_center + room_bl_corner[0], y_center + room_bl_corner[1]};
        } else {
            return l_child.getRoomCenter();
        }
    }

    DungeonPartitionTree getLeftChild() {
        return l_child;
    }

    DungeonPartitionTree getRightChild() {
        return r_child;
    }

    // If the node's width >= 2*min_width, and height >= min_height then allow partitioning.
    // Else set this as a leaf node and create a room
    void partitionWidth(int min_height, int min_width, Random rand) {
        if (part_width >= min_width * 2 && part_height >= min_height) {
            // Find the range of values which result in a valid split (rooms maintain the min_height/min_width values)
            // TODO fix this
            int min_split = min_width;
            int max_split = part_width - min_width;
            // This is the offset of the start of the second partition
            int split_point = rand.nextInt((max_split - min_split) + 1) + min_split;
            // Initialise child nodes
            // Width = split_point + 1 due to 0 indexing
            l_child = new DungeonPartitionTree(bottom_left_coordinates[0], bottom_left_coordinates[1], split_point, part_height);
            r_child = new DungeonPartitionTree(bottom_left_coordinates[0] + split_point, bottom_left_coordinates[1], part_width - (split_point), part_height);
            // Partition children, alternate partitioning by width and height
            l_child.partitionHeight(min_height, min_width, rand);
            r_child.partitionHeight(min_height, min_width, rand);
        }
    }

    void partitionHeight(int min_height, int min_width, Random rand) {
        if (part_width >= min_width && part_height >= min_height * 2) {
            // Find the range of values which result in a valid split (rooms maintain the min_height/min_width values)
            int min_split = min_height;
            int max_split = part_height - min_height;
            int split_point = rand.nextInt((max_split - min_split) + 1) + min_split;
            // Initialise child nodes
            l_child = new DungeonPartitionTree(bottom_left_coordinates[0], bottom_left_coordinates[1], part_width, split_point);
            r_child = new DungeonPartitionTree(bottom_left_coordinates[0], bottom_left_coordinates[1] + split_point, part_width, part_height - (split_point));
            // Partition children, alternate partitioning by width and height
            l_child.partitionWidth(min_height, min_width, rand);
            r_child.partitionWidth(min_height, min_width, rand);
        }
    }

    // Let min_room_width and min_room_height include the tiles necessary to wall off the room
    void createRoom(int min_room_height, int min_room_width, Random rand) {
        if (l_child != null && r_child != null) {
            l_child.createRoom(min_room_height, min_room_width, rand);
            r_child.createRoom(min_room_height, min_room_width, rand);
        } else {
            // Find the max width and height offset we can have from the bottom left corner to generate a valid bottom left corner for the room in this partition
            int max_x = part_width - min_room_width;
            int max_y = part_height - min_room_height;
            // Generate bottom left corner for the room
            int bl_x = rand.nextInt((max_x) + 1);
            int bl_y = rand.nextInt((max_y) + 1);
            int max_room_width_variability = part_width - (min_room_width + bl_x);
            int max_room_height_variability = part_height - (min_room_height + bl_y);
            // Generate top right corner for the room
            int tr_x = rand.nextInt((max_room_width_variability) + 1) + min_room_width + bl_x;
            int tr_y = rand.nextInt((max_room_height_variability) + 1) + min_room_height + bl_y;
            room_bl_corner =  new int[]{bottom_left_coordinates[0] + bl_x, bottom_left_coordinates[1] + bl_y};
            room_tr_corner =  new int[]{bottom_left_coordinates[0] + tr_x, bottom_left_coordinates[1] + tr_y};
        }
    }

    // Doesn't actually draw, instead applies the data to the tile map which is then drawn by the DungeonlevelHandler
    void drawRooms(int[][] level_tile_map) {
        if (l_child != null && r_child != null) {
            l_child.drawRooms(level_tile_map);
            r_child.drawRooms(level_tile_map);
        } else {
            for (int x = room_bl_corner[0]; x < (room_tr_corner[0]); x++) {
                for (int y = room_bl_corner[1]; y < (room_tr_corner[1]); y++) {
                    if (x == room_bl_corner[0] || x == room_tr_corner[0] - 1 || y == room_bl_corner[1] || y == room_tr_corner[1] - 1) {
                        // Set tile to a wall
                        level_tile_map[x][y] = 2;
                    } else {
                        // Set tile to room space
                        level_tile_map[x][y] = 1;
                    }
                }
            }
        }
    }

    // Method used to fill in non-room space surrounding corridors with walls to ensure corners are present
    void fillCorridorCorners(int[][] level_tile_map, int x_center, int y_center) {
        if (x_center + 1 < level_tile_map.length) {
            if (y_center + 1 < level_tile_map.length && level_tile_map[x_center + 1][y_center + 1] != 1) {
                level_tile_map[x_center + 1][y_center + 1] = 2;
            }
            if (y_center - 1 >= 0 && level_tile_map[x_center + 1][y_center - 1] != 1) {
                level_tile_map[x_center + 1][y_center - 1] = 2;
            }
        }
        if (x_center - 1 >= 0) {
            if (y_center + 1 < level_tile_map.length && level_tile_map[x_center - 1][y_center + 1] != 1) {
                level_tile_map[x_center - 1][y_center + 1] = 2;
            }
            if (y_center - 1 >= 0 && level_tile_map[x_center - 1][y_center - 1] != 1) {
                level_tile_map[x_center - 1][y_center - 1] = 2;
            }
        }
    }

    // Doesn't actually draw, instead applies the data to the tile map which is then drawn by the DungeonlevelHandler
    void drawCorridors(int[][] level_tile_map) {
        // Only use for non-leaf nodes
        if (l_child != null && r_child != null) {
            l_child.drawCorridors(level_tile_map);
            r_child.drawCorridors(level_tile_map);

            // Draw a corridor between the two children
            int[] l_center = l_child.getRoomCenter();
            int[] r_center = r_child.getRoomCenter();
            
            int corridor_width = r_center[0] - l_center[0];
            int[] leftmost_point = corridor_width > 0 ? l_center : r_center;
            corridor_width = (corridor_width > 0) ? corridor_width : corridor_width * -1;
            int corridor_height = r_center[1] - l_center[1];
            int[] lowest_point = corridor_height > 0 ? l_center : r_center;
            corridor_height = (corridor_height > 0) ? corridor_height : corridor_height * -1;
            for (int x = leftmost_point[0]; x < leftmost_point[0] + corridor_width; x++) {
                // Set tile along corridor path to room space
                level_tile_map[x][leftmost_point[1]] = 1;
                // If the neighbouring tiles in the y axis are not room space set to walls
                if (leftmost_point[1] + 1 < level_tile_map[x].length && level_tile_map[x][leftmost_point[1] + 1] != 1) {
                    level_tile_map[x][leftmost_point[1] + 1] = 2;
                }
                if (leftmost_point[1] - 1 >= 0 && level_tile_map[x][leftmost_point[1] - 1] != 1) {
                    level_tile_map[x][leftmost_point[1] - 1] = 2;
                }
            }
            // We've drawn the x component of the path between the rooms, we need to continue the y component from where this path
            // left off
            int x_path_end = leftmost_point[0] + corridor_width - 1;
            // Fill in corners when we change from moving in the x axis to y axis by filling in all non-room space points surrounding (x_path_end, leftmost_point[0])
            // with walls. Because of the path already filling in walls we only need to consider corners
            fillCorridorCorners(level_tile_map, x_path_end, leftmost_point[1]);
            // Draw y axis corridor component
            for (int y = lowest_point[1]; y <= lowest_point[1] + corridor_height; y++) {
                // Set tile along corridor path to room space
                level_tile_map[x_path_end][y] = 1;
                // If the neighbouring tiles in the y axis are not room space set to walls
                if (x_path_end + 1 < level_tile_map.length && level_tile_map[x_path_end + 1][y] != 1) {
                    level_tile_map[x_path_end + 1][y] = 2;
                }
                if (x_path_end - 1 >= 0 && level_tile_map[x_path_end - 1][y] != 1) {
                    level_tile_map[x_path_end - 1][y] = 2;
                }
            }
        }
    }

    // Try to find an unoccupied space in a room
    int[] getRandomUnoccupiedSpace(int[][] level_tile_map, Random rand) {
        int empty_spaces = 0;
        for (int x = room_bl_corner[0] + 1; x < (room_tr_corner[0] - 1); x++) {
            for (int y = room_bl_corner[1] + 1; y < (room_tr_corner[1] - 1); y++) {
                if (level_tile_map[x][y] == 1) {
                    empty_spaces++;
                }
            }
        }
        if (empty_spaces == 0) {
            return null;
        } else {
            int space = rand.nextInt(empty_spaces);
            for (int x = room_bl_corner[0] + 1; x < (room_tr_corner[0] - 1); x++) {
                for (int y = room_bl_corner[1] + 1; y < (room_tr_corner[1] - 1); y++) {
                    if (level_tile_map[x][y] == 1) {
                        if (space > 1) {
                            space--;
                        } else {
                            // Mark point as occupied on the level_tile_map
                            level_tile_map[x][y] = 3;
                            return new int[]{x, y};
                        }
                    }
                }
            }
            print("Error, this shouldn't have happened");
            print("\n");
            print(empty_spaces);
            print("\n");
            print(space);
            return null;
        }
    }

    // Randomly choose between left and right children until a leaf node is found
    // At the leaf choose a random square in the room
    int[] spawnStaircases(int[][] level_tile_map, Random rand) {
        if (l_child != null && r_child != null) {
            if (rand.nextInt(2) == 0) {
                return l_child.spawnStaircases(level_tile_map, rand);
            } else {
                return r_child.spawnStaircases(level_tile_map, rand);
            }
        } else {
            // Choose an unoccupied point in the room
            return getRandomUnoccupiedSpace(level_tile_map, rand);
        }
    }

    // Spawn items for the player to interact with in each room
    // Use random probability for deciding whether an item should be spawned
    // Base spawn probability on how frequently the items should apper
    // e.g. healing potions are important, so spawn them ~ once every 4 rooms.
    // zone_type is used to pass the area type to all children in a tree, this allows creating different zones in the level
    void spawnItems(int[][] level_tile_map, ArrayList<Interactable> level_interactables, Random rand, int tile_size, int zone_type) {
        if (l_child != null && r_child != null) {
            l_child.spawnItems(level_tile_map, level_interactables, rand, tile_size, zone_type);
            r_child.spawnItems(level_tile_map, level_interactables, rand, tile_size, zone_type);
        } else {
            int item_level;
            int[] item_location;
            // Try to spawn a healing potion
            if (rand.nextFloat() <= HealthPotion.spawn_chance) {
                item_level = rand.nextInt(4);
                item_location = getRandomUnoccupiedSpace(level_tile_map, rand);
                level_interactables.add(new HealthPotion(tile_size, item_location[0], item_location[1], item_level));
            }
            // Try to spawn an equippable item

            // Try to spawn a spell
            
        }

    }
}
