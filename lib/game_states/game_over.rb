module HungryCatTwo
  class HungryCatGameOver < HungryCatGameFinished
    def setup
      super

      @message = "Here there be dragons..."
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, dark_purple)
      @font.draw_text(@message, window.width / 2 - @font.text_width(@message) / 2, Level::TILE_SIZE * 4, 11)

      Gosu.scale(window.scale, window.scale, window.width / 2, window.height / 2) do
        Level::SPRITESHEET[18].draw(window.width / 2 - 28, window.height / 2 - 8)
        Level::SPRITESHEET[4].draw(window.width / 2 - 8, window.height / 2 - 5)
        Level::SPRITESHEET[4].draw(window.width / 2 + 9, window.height / 2 - 7)
      end

      draw_animated_message("Press 'Y' to try again.")
    end
  end
end
