module HungryCatTwo
  class HungryCatGameComplete < HungryCatGameFinished
    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, dark_green)
      # window.text("Cat feed successfully.", 0 , 0, 12)

      # window.sprite(14, window.width / 2 - 8, window.height / 2 - 8)

      draw_animated_message("Press 'Y' to play again.")
    end
  end
end
