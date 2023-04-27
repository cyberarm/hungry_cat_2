module HungryCatTwo
  class Level
    CAT = 14
    DOG = 0
    TACO = 42
    FLAG = 49

    CAT_HEAD = 27

    TILE_SIZE = 16
    SPRITESHEET = Gosu::Image.load_tiles("#{ROOT_PATH}/media/spritesheet.png", TILE_SIZE, TILE_SIZE, retro: true).freeze

    # Generate bounding boxes for sprites
    sheet_image = Gosu::Image.new("#{ROOT_PATH}/media/spritesheet.png", retro: true)
    blob = sheet_image.to_blob
    i = 0
    # FIXME: Save 400+ ms by generating bounding boxes from sheet_image blob instead of for each sprite image...
    SPRITE_BOUNDING_BOXES = SPRITESHEET.map do |sprite|
      box = CyberarmEngine::BoundingBox.new(CyberarmEngine::Vector.new(TILE_SIZE, TILE_SIZE), CyberarmEngine::Vector.new(0, 0))
      # offset = 15 * 15 * i
      # width = sheet_image.width
      offset = 0
      blob = sprite.to_blob

      TILE_SIZE.times do |y|
        TILE_SIZE.times do |x|
          next unless blob[(offset + (TILE_SIZE * y + x)) * 4 + 3].ord > 0

          box.min.x = x if x < box.min.x
          box.min.y = y if y < box.min.y

          box.max.x = x if x > box.max.x
          box.max.y = y if y > box.max.y
        end
      end

      i += 1

      box.max.x += 1
      box.max.y += 1

      box
    end.freeze

    FIXED_TIMESTEP = 1.0 / 120

    Collision = Struct.new(:sprite, :position)

    attr_reader :window, :lowest_point

    def initialize(tmx:, cat_lives:)
      @width = 0
      @height = 0
      @tiles = []
      @entities = []
      @offset = CyberarmEngine::Vector.new

      @original_entities = []

      @inputs = []

      @replay = false
      @replay_frame = 0

      @window = CyberarmEngine::Window.instance

      @accumulator = 0.0
      @interpolation = 0.0

      @lowest_point = 0

      parsing_tiles = false
      File.read(tmx).lines.each do |line|
        line = line.strip
        parsing_tiles = true  if line[0] =~ /[0-9]/
        parsing_tiles = false if line.start_with?("<")

        next unless parsing_tiles

        list = line.split(",")
        list.map { |j| j.to_i - 1 }.each_with_index do |i, index|
          case i
          when CAT
            i = -1
            @entities << Cat.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE, base_sprite: 14)
            @original_entities << Cat.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE, base_sprite: 14)
          when DOG
            i = -1
            @entities << Dog.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE, base_sprite: 0)
            @original_entities << Dog.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE, base_sprite: 0)
          when TACO
            i = -1
            @entities << Taco.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE, base_sprite: 42)
            @original_entities << Taco.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE, base_sprite: 42)
          when FLAG
            i = -1
            @entities << Flag.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE)
            @original_entities << Flag.new(level: self, x: index * TILE_SIZE, y: @height * TILE_SIZE)
          end

          @lowest_point = @height * TILE_SIZE if i.positive?

          @tiles << i
        end

        @width = list.size
        @height += 1
      end

      cat.lives = cat_lives
      @original_cat_lives = cat_lives

      raise "Cat does not exist!" unless cat
      raise "No tacos to eat!" unless tacos.size.positive?
      raise "No flag to reach!" unless flag
      warn "No dogs to dodge!" unless dogs.size.positive?
    end

    def center_around(entity, lag = CyberarmEngine::Vector.new(0.85, 0.85))
      @offset.x += ((entity.position.x - @window.width  / 2) - @offset.x) * (1.0 - lag.x)
      @offset.y += ((entity.position.y - @window.height / 2) - @offset.y) * (1.0 - lag.y)
    end

    def cat
      @entities.find { |ent| ent.is_a?(Cat) }
    end

    def dogs
      @entities.select { |ent| ent.is_a?(Dog) }
    end

    def tacos
      @entities.select { |ent| ent.is_a?(Taco) }
    end

    def flag
      @entities.find { |ent| ent.is_a?(Flag) }
    end

    def eat_taco(taco)
      @entities.delete(taco)
    end

    def replay!
      @replay_frame = 0
      @entities = []
      @original_entities.each { |e| @entities << e.class.new(level: self, x: e.position.x, y: e.position.y, base_sprite: e.base_sprite) }

      cat.lives = @original_cat_lives
      @replay = true
    end

    def replay?
      @replay
    end

    def update(dt)
      replay! if Gosu.button_down?(Gosu::KB_R) && !replay?
      if Gosu.button_down?(Gosu::KB_F5)
        replay!
        @replay = false
        @inputs = []
      end

      input = Input.new
      input.jump = [Gosu::KB_SPACE, Gosu::KB_W, Gosu::KB_UP, Gosu::GP_DPAD_UP].any? { |key| Gosu.button_down?(key) }
      input.left = [Gosu::KB_A, Gosu::KB_LEFT, Gosu::GP_LEFT].any? { |key| Gosu.button_down?(key) }
      input.right = [Gosu::KB_D, Gosu::KB_RIGHT, Gosu::GP_RIGHT].any? { |key| Gosu.button_down?(key) }

      CyberarmEngine::Stats.frame.start_timing(:custom_physics_timestep)
      physics(dt, input)
      CyberarmEngine::Stats.frame.end_timing(:custom_physics_timestep)

      center_around(cat)
    end

    def draw
      Gosu.draw_rect(0, 0, @window.width, @window.height, 0xff_252525, 0)

      Gosu.scale(@window.scale, @window.scale, @window.width / 2, @window.height / 2) do
        Gosu.translate(-@offset.x, -@offset.y) do
          @height.times do |y|
            @width.times do |x|
              SPRITESHEET[tile(x, y)].draw(x * TILE_SIZE, y * TILE_SIZE, 1)
            end
          end

          @entities.each(&:draw)
          debug_draw if DEBUG
        end
      end
    end

    def debug_draw
      @height.times do |y|
        @width.times do |x|
          tile = tile(x, y)

          next if tile == -1

          draw_bounding_box(tile, CyberarmEngine::Vector.new(x, y) * TILE_SIZE)
        end
      end

      @entities.each { |e| draw_bounding_box(e.sprite, e.position) }
    end

    def draw_bounding_box(sprite_id, position)
      box = SPRITE_BOUNDING_BOXES[sprite_id]

      return unless box

      # TOP
      Gosu.draw_line(
        box.min.x + position.x, box.min.y + position.y, Gosu::Color::RED,
        box.min.x + position.x + box.width, box.min.y + position.y, Gosu::Color::RED,
        Float::INFINITY
      )

      # RIGHT
      Gosu.draw_line(
        box.min.x + position.x + box.width, box.min.y + position.y, Gosu::Color::RED,
        box.min.x + position.x + box.width, box.min.y + position.y + box.height, Gosu::Color::RED,
        Float::INFINITY
      )

      # BOTTOM
      Gosu.draw_line(
        box.min.x + position.x + box.width, box.min.y + position.y + box.height, Gosu::Color::RED,
        box.min.x + position.x, box.min.y + position.y + box.height, Gosu::Color::RED,
        Float::INFINITY
      )

      # LEFT
      Gosu.draw_line(
        box.min.x + position.x, box.min.y + position.y + box.height, Gosu::Color::RED,
        box.min.x + position.x, box.min.y + position.y, Gosu::Color::RED,
        Float::INFINITY
      )
    end

    # REF: https://gafferongames.com/post/fix_your_timestep/
    def physics(dt, input)
      dt = 0.1 if dt > 0.1
      @accumulator += dt

      while @accumulator >= FIXED_TIMESTEP
        @accumulator -= FIXED_TIMESTEP

        if replay?
          input = @inputs[@replay_frame]
          input ||= Input.new

          # puts "REPLAY: #{@replay_frame}: #{input}"
          @replay_frame += 1
        else
          @inputs << input != @inputs.last ? input : nil
        end

        @entities.each { |e| e.update(FIXED_TIMESTEP, input) }
      end
    end

    def tile(x, y)
      @tiles[@width * y + x]
    end

    def sprite_vs_level(sprite_id, position)
      sprite_box = SPRITE_BOUNDING_BOXES[sprite_id]
      sprite_box = CyberarmEngine::BoundingBox.new(
        sprite_box.min + position,
        sprite_box.max + position
      )

      collisions = []
      @height.times do |y|
        @width.times do |x|
          tile = tile(x, y)
          next unless tile.positive? # Using -1 for "air"

          v = CyberarmEngine::Vector.new(x * TILE_SIZE, y * TILE_SIZE)
          other_box = SPRITE_BOUNDING_BOXES[tile]
          other_box = CyberarmEngine::BoundingBox.new(
            other_box.min + v,
            other_box.max + v
          )

          collisions << Collision.new(tile, v) if sprite_box.intersect?(other_box)
        end
      end

      collisions
    end

    def entity_vs_entity(source_entity, target_entity)
      source_position = source_entity.position
      target_position = target_entity.position

      box = SPRITE_BOUNDING_BOXES[source_entity.sprite]
      source_box = CyberarmEngine::BoundingBox.new(
        box.min + source_position,
        box.max + source_position
      )

      box = SPRITE_BOUNDING_BOXES[target_entity.sprite]
      target_box = CyberarmEngine::BoundingBox.new(
        box.min + target_position,
        box.max + target_position
      )

      source_box.intersect?(target_box)
    end

    def colliding_edge(source_entity, target_entity)
      source_position = source_entity.position
      target_position = target_entity.position

      box = SPRITE_BOUNDING_BOXES[source_entity.sprite]
      source_box = CyberarmEngine::BoundingBox.new(
        box.min + source_position,
        box.max + source_position
      )

      box = SPRITE_BOUNDING_BOXES[target_entity.sprite]
      target_box = CyberarmEngine::BoundingBox.new(
        box.min + target_position,
        box.max + target_position
      )

      edges = { top: false, left: false, right: false, bottom: false }

      # https://gamedev.stackexchange.com/a/24091
      wy = (source_box.width + target_box.width) * ((source_position.y - source_box.height) - (target_position.y - target_box.height / 2))
      hx = (source_box.height + target_box.height) * ((source_position.x - source_box.width) - (target_position.x - target_box.height / 2))

      if wy > hx
        if wy > -hx
          edges[:bottom] = true
        else
          edges[:left] = true
        end
      else
        if wy > -hx
          edges[:right] = true
        else
          edges[:top] = true
        end
      end

      return edges
    end
  end
end
