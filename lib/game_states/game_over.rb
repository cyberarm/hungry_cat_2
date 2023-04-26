module HungryCatTwo
  class HungryCatGameOver < HungryCatGameFinished
    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, dark_purple)
      # @context.text("Here there be dragons...", 0, 0, 11)

      Gosu.scale(window.scale, window.scale, window.width / 2, window.height / 2) do
        Level::SPRITESHEET[18].draw(window.width / 2 - 28, window.height / 2 - 8)
        Level::SPRITESHEET[4].draw(window.width / 2 - 8, window.height / 2 - 5)
        Level::SPRITESHEET[4].draw(window.width / 2 + 9, window.height / 2 - 7)
      end

      draw_animated_message("Press 'Y' to try again.")
    end
  end
end
