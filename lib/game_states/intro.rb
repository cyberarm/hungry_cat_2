class HungryCatGameIntro < GameState
  def setup
    @ground = [
      58, 57, 57, 56, 57, 57, 58
    ]

    @cat_lives = 3
  end

  def draw
    @context.rect(0, 0, @context.width, @context.height, @context.light_gray)
    @context.text("Hungry Cat", 32, 0, 12, 0 , @context.dark_gray)
    @context.text("Press 'Y' to start", 30, 32, 8, 0, @context.black)

    @context.text("'X' -> X     'Y' -> C", 35, 56, 6, 0, @context.black)
    @context.text("On US Keyboard", 42, 64, 6, 0, @context.black)

    x = 0
    @ground.each_with_index do |tile|
      @context.sprite(tile, x, @context.height - 32)
      x += 16
    end

    @context.sprite(14, 16 * 1, @context.height - 47)
    @context.sprite(42, 16 * 4, @context.height - 47)
    @context.sprite(00, 16 * 3, @context.height - 47)
    @context.sprite(49, 16 * 6, @context.height - 47)
  end

  def update(dt)
    @context.game_state = HungryCatGameTransition.new(@context, current_level: @options[:current_level], cat_lives: @cat_lives) if @context.button?("y")
  end
end
