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
      @lowest_point = -Float::INFINITY

      # @game_state.level.each do |tile|
        # @lowest_point = tile.y if @lowest_point < tile.y
      # end
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

      return

      if on_ground?
        @velocity.y = @jump if @context.button?("up") or @context.button?("x")
      end

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
      @game_state.dogs.find do |dog|
        if @context.sprite_vs_sprite(sprite, @position.x, @position.y, dog.sprite, dog.position.x, dog.position.y)
          edges = @context.colliding_edge(sprite, @position.x, @position.y, dog.sprite, dog.position.x, dog.position.y)
          unless edges[:top] && @position.y <= dog.position.y + 4
            lose_life
          end

          @velocity.y = @jump
          return true
        end
      end
    end

    def collect_tacos
      @game_state.tacos.each do |taco|
        @game_state.eat_taco(taco) if @context.sprite_vs_sprite(sprite, @position.x, @position.y, taco.sprite, taco.position.x, taco.position.y)
      end
    end

    def fell_out_of_level?
      if @position.y > @lowest_point + @context.height
        @position.y = @last_touched_tile.y - (16 * @jump)
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
    end

    def die?
      @context.game_state = HungryCatGameOver.new(@context) if @lives <= 0
    end
  end
end
