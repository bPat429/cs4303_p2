import java.util.Random;
import java.util.ArrayList;

final class GameOverHandler {
    private Player player;

    GameOverHandler(Player player) {
        this.player = player;
    }

    // Draw game over screen and check if 'R' is pressed
    // When R is pressed return, and start a new game
    boolean run(boolean[] input_array) {
        drawComponent();
        if (input_array[7]) {
            return true;
        }
        return false;
    }

    void drawComponent() {
        background(0);
        int small_step = displayWidth/100;
        fill(255);
        textSize(small_step * 5);
        text("Game Over, you reached level: " + Integer.toString(player.getLevel()), displayWidth/2 - small_step * 30, displayHeight/2 - small_step * 10);
        textSize(small_step * 4);
        text("Press (R) to play again", displayWidth/2 - small_step * 30, displayHeight/2);
    }
}
