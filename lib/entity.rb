module HungryCatTwo
  class Entity
    GRAVITY = 9.8
    MIN_VELOCITY = 0.05

    attr_reader :position, :velocity, :speed, :sprites, :base_sprite
    def initialize(level:, x: 0, y: 0, z: 0, speed: 10.0, base_sprite: 0)
      @level = level
      @speed = speed
      @position = CyberarmEngine::Vector.new(x, y, z)
      @velocity = CyberarmEngine::Vector.new(0, 0)

      @base_sprite = base_sprite

      @drag = 0.9

      i = base_sprite
      r = i + 1
      l = r + 3
      j = l + 3
      f = j + 1
      a = i
      @sprites = {
        idle:      [i],
        right:     [r, r + 1, r + 2, r + 1],
        left:      [l, l + 1, l + 2, l + 1],
        jumping:   [j],
        falling:   [f],
        attacking: [a],
      }

      @animation_index = 0
      @frame_time = 100
      @last_frame = Gosu.milliseconds

      @collisions = []

      setup
    end

    def setup
    end

    def sprite
      @animation_index = 0 if @animation_index > @sprites[current_action].size - 1

      @sprites[current_action][@animation_index]
    end

    def current_action
      if on_ground?
        if @velocity.x > 0
          :right
        elsif @velocity.x < 0
          :left
        else
          :idle
        end

      else
        if @velocity.y > 0
          :jumping
        elsif @velocity.y < 0
          :falling
        else
          :idle
        end
      end
    end

    def draw
      Level::SPRITESHEET[sprite].draw(@position.x, @position.y, @position.z)
    end

    def update(dt, input)
      collision_detector

      unless @static
        @position.x += @velocity.x
        @position.y -= @velocity.y

        @velocity.x *= @drag
        @velocity.x = 0 if @velocity.x.abs < MIN_VELOCITY

        if on_ground?
          @position.y = ground.position.y - Level::TILE_SIZE
          @velocity.y = 0
        else
          @velocity.y -= GRAVITY * dt
          @velocity.y = GRAVITY if @velocity.y > GRAVITY
          @velocity.y = -GRAVITY if @velocity.y < -GRAVITY
        end
      end

      animate
    end

    def animate
      if Gosu.milliseconds >= @last_frame + @frame_time
        @last_frame = Gosu.milliseconds

        @animation_index += 1
        @animation_index = 0 if @animation_index > @sprites[current_action].size - 1
      end
    end

    def on_ground?
      return false unless (floor = ground)

      @position.y >= floor.position.y - Level::TILE_SIZE
    end

    def ground(ground_sprite_start = 56, ground_sprite_end = 58)
      @collisions.find { |intersect| intersect.sprite.between?(ground_sprite_start, ground_sprite_end) }
    end

    def collision_detector
      ground_tiles = [56, 57, 58]
      pos = @position + CyberarmEngine::Vector.new(0, 1) # project down 1 pixel so that box will intersect terrain

      # FIXME: Check that bounding boxes are calculated correctly.
      #        Transitioning to moving from idle sprite causes a cyclic fall while moving.
      @collisions = @level.sprite_vs_level(sprite, pos).select do |collision|
        collision.sprite.between?(ground_tiles.first, ground_tiles.last)
      end
    end
  end
end
