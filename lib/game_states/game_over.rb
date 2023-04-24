class HungryCatGameOver < HungryCatGameFinished
  def draw
    @context.rect(0, 0, @context.width, @context.height, @context.dark_purple)
    @context.text("Here there be dragons...", 0 , 0, 11)

    @context.sprite(18, @context.width / 2 - 28, @context.height / 2 - 8)
    @context.sprite(4, @context.width / 2 - 8, @context.height / 2 - 5)
    @context.sprite(4, @context.width / 2 + 9, @context.height / 2 - 7)

    draw_animated_message("Press 'Y' to try again.")
  end
end

class HungryCatGameTransition < GameState
  def setup
    @started_at = @context.milliseconds
    @transition_time = 2_000
    @start_animation = 1_000
    @offset = 0

    @current_level = @options[:current_level]
    @new_level = HungryCatGame.new(@context, current_level: @current_level, cat_lives: @options[:cat_lives])
  end

  def draw
    if @context.milliseconds > @started_at + @start_animation
      @new_level.draw
    end

    @context.rect(0, -@offset, @context.width, @context.height, @context.dark_gray)
    @context.text("Level #{@current_level + 1}", 0, (@context.height / 2 - 8) + -@offset, 16)
  end

  def update(dt)
    if @context.milliseconds > @started_at + @start_animation
      time_elapsed = (@context.milliseconds - @started_at) - @start_animation
      animation_time = (@transition_time - @start_animation).to_f

      ratio = time_elapsed / animation_time
      @offset = @context.width * ratio
    end

    if @context.milliseconds > @started_at + @transition_time
      @context.game_state = @new_level
    end
  end
end
