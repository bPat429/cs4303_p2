import java.util.Random;

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

    // If the node's width >= 2*min_width, and height >= min_height then allow partitioning.
    // Else set this as a leaf node and create a room
    void partition_width(int min_height, int min_width, Random rand) {
        if (part_width >= min_width * 2 && part_height >= min_height) {
            // Find the range of values which result in a valid split (rooms maintain the min_height/min_width values)
            // TODO fix this
            int min_split = min_width;
            int max_split = part_width - min_width;
            print("Splits");
            print(min_split);
            print(max_split);
            int split_point = rand.nextInt((max_split - min_split) + 1) + min_split;
            // Initialise child nodes
            l_child = new DungeonPartitionTree(bottom_left_coordinates[0], bottom_left_coordinates[1], split_point, part_height);
            r_child = new DungeonPartitionTree(bottom_left_coordinates[0] + split_point, bottom_left_coordinates[1], width - split_point, part_height);
            // Partition children, alternate partitioning by width and height
            l_child.partition_height(min_height, min_width, rand);
            r_child.partition_height(min_height, min_width, rand);
        }
    }

    void partition_height(int min_height, int min_width, Random rand) {
        if (part_width >= min_width && height >= min_height * 2) {
            // Find the range of values which result in a valid split (rooms maintain the min_height/min_width values)
            int min_split = min_height;
            int max_split = part_height - min_height;
            print("Splits");
            print(min_split);
            print(max_split);
            int split_point = rand.nextInt((max_split - min_split) + 1) + min_split;
            // Initialise child nodes
            l_child = new DungeonPartitionTree(bottom_left_coordinates[0], bottom_left_coordinates[1], part_width, split_point);
            r_child = new DungeonPartitionTree(bottom_left_coordinates[0], bottom_left_coordinates[1] + split_point, part_width, part_height - split_point);
            // Partition children, alternate partitioning by width and height
            l_child.partition_width(min_height, min_width, rand);
            r_child.partition_width(min_height, min_width, rand);
        }
    }

    // Let min_room_width and min_room_height include the tiles necessary to wall off the room
    void create_room(int min_room_height, int min_room_width, Random rand) {
        if (l_child != null && r_child != null) {
            l_child.create_room(min_room_height, min_room_width, rand);
            r_child.create_room(min_room_height, min_room_width, rand);
        } else {
            // Find the max width and height offset we can have from the bottom left corner to generate a valid bottom left corner for the room in this partition
            int max_x = part_width - min_room_width;
            int max_y = part_height - min_room_height;
            // Generate bottom left corner for the room
            int bl_x = rand.nextInt((max_x) + 1);
            int bl_y = rand.nextInt((max_y) + 1);
            int max_room_width = part_width - bl_x;
            int max_room_height = part_height - bl_y;
            // Generate top right corner for the room
            int tr_x = rand.nextInt((max_room_width - min_room_width) + 1) + min_room_width;
            int tr_y = rand.nextInt((max_room_height - min_room_height) + 1) + min_room_height;
            room_bl_corner =  new int[]{bottom_left_coordinates[0] + bl_x, bottom_left_coordinates[1] + bl_y};
            room_tr_corner =  new int[]{bottom_left_coordinates[0] + tr_x, bottom_left_coordinates[1] + tr_y};

            room_bl_corner =  new int[]{bottom_left_coordinates[0], bottom_left_coordinates[1]};
            room_tr_corner =  new int[]{bottom_left_coordinates[0] + part_width, bottom_left_coordinates[1] + part_height};
        }
    }

    void apply_to_dungeon(int[][] level_tile_map) {
        if (l_child != null && r_child != null) {
            l_child.apply_to_dungeon(level_tile_map);
            r_child.apply_to_dungeon(level_tile_map);
        } else {
            for (int x = room_bl_corner[0]; x <= (room_tr_corner[0]); x++) {
                for (int y = room_bl_corner[1]; y <= (room_tr_corner[1]); y++) {
                    if (x == room_bl_corner[0] || x == room_tr_corner[0] || y == room_bl_corner[1] || y == room_tr_corner[1]) {
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
}
