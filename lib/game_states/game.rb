module HungryCatTwo
  class Game < GameState
    attr_reader :current_level, :context, :level

    def initialize(*args)
      super

      @current_level = @options[:current_level] || 1

      @level = Level.new(tmx: "#{ROOT_PATH}/tiled/level_#{@current_level}.tmx", cat_lives: @options[:cat_lives])
    end

    def draw
      super

      return unless @level
      @level.draw

      Gosu.scale(window.scale) do
        @level.cat.lives.times do |i|
          Level::SPRITESHEET[Level::CAT_HEAD].draw(10 * i, 10, 10)
        end

        @level.tacos.size.times do |i|
          Level::SPRITESHEET[Level::TACO].draw(10 * i, 10 + 10, 10)
        end
      end
    end

    def update
      super

      return unless @level

      @level.update(window.dt)

      push_state(HungryCatGameOver) if @level.cat.die?

      next_level?
    end

    def debug_draw
      if @debug
        @context.draw_level_boxes(@current_level)
        @context.draw_sprite_box(@cat.sprite, @cat.position.x, @cat.position.y)
      end
    end

    def next_level?
      return unless @level.tacos.size.zero? && @level.entity_vs_entity(@level.cat, @level.flag)

      puts window.levels

      if @current_level < window.levels
        push_state(HungryCatGameTransition, current_level: @current_level + 1, cat_lives: @level.cat.lives + 1)
      else
        push_state(HungryCatGameComplete)
      end
    end
  end
end
