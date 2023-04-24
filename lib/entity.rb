class Entity
  Vector = Struct.new(:x, :y, :z)
  GRAVITY = 9.8

  attr_reader :position, :velocity, :speed, :sprite, :sprites
  def initialize(game_state:, x: 0, y: 0, z: 0, speed: 10, base_sprite: 0)
    @game_state = game_state
    @context = game_state.context
    @speed = speed
    @position = Vector.new(x, y, z)
    @velocity = Vector.new(0, 0)

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
    @last_frame = @context.milliseconds

    @collisions = []

    setup if defined?(setup)
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
    @context.sprite(sprite, @position.x, @position.y, @position.z)
  end

  def update(dt)
    collision_detector

    @position.x += @velocity.x
    @position.y -= @velocity.y

    @velocity.x *= @drag
    @velocity.x = 0 if @velocity.x.abs < 0.05

    if on_ground?
      @position.y = ground.y - 15
      @velocity.y = 0
    else
      @velocity.y -= GRAVITY * dt
      @velocity.y = GRAVITY if @velocity.y > GRAVITY
      @velocity.y = -GRAVITY if @velocity.y < -GRAVITY
    end

    animate
  end

  def animate
    if @context.milliseconds >= @last_frame + @frame_time
      @last_frame = @context.milliseconds

      @animation_index += 1
      @animation_index = 0 if @animation_index > @sprites[current_action].size - 1
    end
  end

  def on_ground?
    if floor = ground
      @position.y >= floor.y - 15
    end
  end

  def ground(ground_sprite_start = 56, ground_sprite_end = 58)
    @collisions.find { |intersect| intersect.sprite.between?(ground_sprite_start, ground_sprite_end) }
  end

  def collision_detector
    ground_tiles = [56, 57, 58]

    @collisions = @context.sprite_vs_level(sprite, @position.x, @position.y, @game_state.current_level).select do |collision|
      collision.sprite.between?(ground_tiles.first, ground_tiles.last)
    end
  end
end
