module HungryCatTwo
  class HungryCatGameComplete < HungryCatGameFinished
    def draw
      @context.rect(0, 0, @context.width, @context.height, @context.dark_green)
      @context.text("Cat feed successfully.", 0 , 0, 12)

      @context.sprite(14, @context.width / 2 - 8, @context.height / 2 - 8)

      draw_animated_message("Press 'Y' to play again.")
    end
  end
end
