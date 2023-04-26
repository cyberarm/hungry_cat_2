module HungryCatTwo
  class HungryCatGameFinished < GameState
    def setup
      @started_at = Gosu.milliseconds
      @transition_time = 3_000
      @start_animation = 1_000
      @end_position = 30

      @offset = 0
    end

    def update
      if Gosu.milliseconds > @started_at + @start_animation
        time_elapsed = (Gosu.milliseconds - @started_at) - @start_animation
        animation_time = (@transition_time - @start_animation).to_f

        ratio = (time_elapsed / animation_time).clamp(0.0, 1.0)
        @offset = @end_position * ratio

        # if @context.button?("y")
        #   @context.game_state = HungryCatGameIntro.new(@context, current_level: 0)
        # end
      end
    end

    def draw_animated_message(message)
      # @context.text(message, 6, @context.height - @offset, 8)
    end
  end
end
