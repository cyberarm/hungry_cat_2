module HungryCatTwo
  class HungryCatGameTransition < GameState
    def setup
      @started_at = Gosu.milliseconds
      @transition_time = 2_000
      @start_animation = 1_000
      @offset = 0

      @current_level = @options[:current_level]
      @new_level = Game.new(current_level: @current_level, cat_lives: @options[:cat_lives])

      @font = Gosu::Font.new((16 * window.scale).ceil)
    end

    def draw
      @new_level.draw if Gosu.milliseconds > @started_at + @start_animation

      Gosu.draw_rect(0, -@offset, window.width, window.height, dark_gray, 16)
      @font.draw_text("Level #{@current_level}", 2 * window.scale, (window.height / 2 - 8 * window.scale) + -@offset, 16)
    end

    def update
      if Gosu.milliseconds > @started_at + @start_animation
        time_elapsed = (Gosu.milliseconds - @started_at) - @start_animation
        animation_time = (@transition_time - @start_animation).to_f

        ratio = time_elapsed / animation_time
        @offset = window.width * ratio

        @new_level.level.center_around(@new_level.level.cat, CyberarmEngine::Vector.new(0.0, 0.0))
      end

      push_state(@new_level) if Gosu.milliseconds > @started_at + @transition_time
    end
  end
end
