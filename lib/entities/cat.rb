module HungryCatTwo
  class Cat < Entity
    def setup
      @lives = 0
      @jump = 2.75
      @direction = -1

      @invincible_time = 1000
      @last_lost_life = milliseconds - @invincible_time

      @flash_time = 75
      @last_flash_at = milliseconds - @flash_time
      @visible = true

      @last_touched_position = nil

      @sounds = {
        stressed: @level.window.current_state.get_sample("#{ROOT_PATH}/media/sfx/stressed.ogg"),
        eat: @level.window.current_state.get_sample("#{ROOT_PATH}/media/sfx/eat.ogg")
      }
    end

    def draw(alpha)
      if milliseconds > @last_lost_life + @invincible_time
        super
      elsif flash
        super
      end
    end

    def update(dt, input)
      @direction = @velocity.x > 0 ? 1 : -1

      super

      if input
        @velocity.x += @speed * dt if input.right?
        @velocity.x -= @speed * dt if input.left?
      end

      @velocity.y = @jump if input.jump? && on_ground?

      @last_touched_position = CyberarmEngine::Vector.new(@position.x, @position.y) if ground

      evade_dogs
      collect_tacos

      fell_out_of_level?
      die?
    end

    def lives
      @lives
    end

    def lives=(n)
      @lives = n
    end

    def evade_dogs
      @level.dogs.find do |dog|
        next unless @level.entity_vs_entity(self, dog)

        edges = @level.colliding_edge(self, dog)
        lose_life if (edges[:left] || edges[:right]) && @position.y >= dog.position.y

        @velocity.y = @jump
        return true
      end
    end

    def collect_tacos
      @level.tacos.each do |taco|
        next unless @level.entity_vs_entity(self, taco)

        @level.eat_taco(taco)
        @sounds[:eat].play(0.5)
      end
    end

    def fell_out_of_level?
      return unless @position.y > @level.lowest_point + Level::TILE_SIZE * 8

      @position.x = @last_touched_position.x
      @position.y = @last_touched_position.y - (Level::TILE_SIZE * @jump)
      @velocity.x = 0
      @velocity.y = 0

      lose_life
    end

    def flash
      if milliseconds > @last_flash_at + @flash_time
        @last_flash_at = milliseconds

        @visible = !@visible
      end

      return @visible
    end

    def lose_life
      return unless milliseconds > @last_lost_life + @invincible_time

      @lives -= 1
      @last_lost_life = milliseconds
      @last_flash_at = milliseconds
      @visible = false

      @sounds[:stressed].play(0.25) unless die?
    end

    def die?
      @lives < 1
    end
  end
end
