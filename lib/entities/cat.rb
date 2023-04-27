module HungryCatTwo
  class Cat < Entity
    def setup
      @lives = 0
      @jump = 4.0
      @direction = -1

      @invincible_time = 1000
      @last_lost_life = Gosu.milliseconds - @invincible_time

      @flash_time = 75
      @last_flash_at = Gosu.milliseconds - @flash_time
      @visible = true

      @last_touched_tile = nil

      @sounds = {
        stressed: @level.window.current_state.get_sample("#{ROOT_PATH}/media/sfx/stressed.ogg"),
        eat: @level.window.current_state.get_sample("#{ROOT_PATH}/media/sfx/eat.ogg")
      }
    end

    def draw
      if Gosu.milliseconds > @last_lost_life + @invincible_time
        super
      else
        super if flash
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

      tile = ground
      @last_touched_tile = ground if tile

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
      if @position.y > @level.lowest_point + @level.window.height
        @position.y = @last_touched_tile.position.y - (16 * @jump)
        @velocity.y = 0

        lose_life
      end
    end

    def flash
      if Gosu.milliseconds > @last_flash_at + @flash_time
        @last_flash_at = Gosu.milliseconds

        @visible = !@visible
      end

      return @visible
    end

    def lose_life
      return unless Gosu.milliseconds > @last_lost_life + @invincible_time

      @lives -= 1
      @last_lost_life = Gosu.milliseconds
      @last_flash_at = Gosu.milliseconds
      @visible = false

      @sounds[:stressed].play(0.25) unless die?
    end

    def die?
      @lives <= 0
    end
  end
end
