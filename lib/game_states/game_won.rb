module HungryCatTwo
  class HungryCatGameComplete < HungryCatGameFinished
    def setup
      super

      @message = "Cat  fed  successfully."
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, dark_green)
      @font.draw_text(@message, window.width / 2 - @font.text_width(@message) / 2, Level::TILE_SIZE * 4, 12)

      Gosu.scale(window.scale, window.scale, window.width / 2, window.height / 2) do
        Level::SPRITESHEET[14].draw(window.width / 2 - Level::TILE_SIZE / 2, window.height / 2 - Level::TILE_SIZE / 2, 10)
      end

      draw_animated_message("Press 'Y' to play again.")
    end
  end
end
