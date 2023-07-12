module HungryCatTwo
  class Entity
    GRAVITY = 9.8
    MIN_VELOCITY = 0.05

    attr_reader :position, :velocity, :last_position, :speed, :sprites, :base_sprite
    def initialize(level:, x: 0, y: 0, z: 0, speed: 10.0, base_sprite: 0)
      @level = level
      @speed = speed
      @position = CyberarmEngine::Vector.new(x, y, z)
      @velocity = CyberarmEngine::Vector.new(0, 0)
      @last_position = CyberarmEngine::Vector.new(@position.x, @position.y)

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
      @last_frame = milliseconds

      @collisions = []

      setup
    end

    def setup
    end

    def milliseconds
      @level.milliseconds
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

    def draw(alpha)
      # Don't lerp Taco here, it jerks if you do
      lerp_pos = sprite == Level::TACO ? @position : @position * alpha + @last_position * (1.0 - alpha)

      Level::SPRITESHEET[sprite].draw(lerp_pos.x, lerp_pos.y, @position.z)
    end

    def update(dt, input)
      collision_detector

      @last_position = CyberarmEngine::Vector.new(@position.x, @position.y)

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
      if milliseconds >= @last_frame + @frame_time
        @last_frame = milliseconds

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
      pos = @position + CyberarmEngine::Vector.new(0, 1) # project down 1 pixel so that box will intersect terrain

      @collisions = @level.sprite_vs_level(sprite, pos)
    end
  end
end
