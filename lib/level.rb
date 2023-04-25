module HungryCatTwo
  class Level
    CAT = 14
    DOG = 0
    TACO = 42
    FLAG = 49

    TILE_SIZE = 16
    SPRITESHEET = Gosu::Image.load_tiles("#{ROOT_PATH}/media/spritesheet.png", TILE_SIZE, TILE_SIZE, retro: true).freeze

    def initialize(tmx:)
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
            @entities << Cat.new(level: self, x: index, y: @height, base_sprite: 14)
            @original_entities << Cat.new(level: self, x: index, y: @height, base_sprite: 14)
          when DOG
            i = -1
            @entities << Dog.new(level: self, x: index, y: @height, base_sprite: 0)
            @original_entities << Dog.new(level: self, x: index, y: @height, base_sprite: 0)
          when TACO
            i = -1
            @entities << Taco.new(level: self, x: index, y: @height, base_sprite: 42)
            @original_entities << Taco.new(level: self, x: index, y: @height, base_sprite: 42)
          when FLAG
            i = -1
            @entities << Flag.new(level: self, x: index, y: @height)
            @original_entities << Flag.new(level: self, x: index, y: @height)
          end

          @tiles << i
        end

        @width = list.size
        @height += 1
      end
    end

    def center_around(entity, lag = CyberarmEngine::Vector.new(0.85, 0.85))
      @offset.x += (((entity.position.x * TILE_SIZE) - @window.width  / 2) - @offset.x) * (1.0 - lag.x)
      @offset.y += (((entity.position.y * TILE_SIZE) - @window.height / 2) - @offset.y) * (1.0 - lag.y)
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
      @replay = true
    end

    def replay?
      @replay
    end

    def draw
      scaler = HungryCatTwo::DESIGN_RESOLUTION_WIDTH / @window.width.to_f

      Gosu.draw_rect(0, 0, @window.width, @window.height, 0xff_252525, 0)

      Gosu.translate(-@offset.x, -@offset.y) do
        Gosu.scale(4 * scaler, 4 * scaler, 0, 0) do
          @height.times do |y|
            @width.times do |x|
              tile = @tiles[@width * y + x]

              SPRITESHEET[tile].draw(x * TILE_SIZE, y * TILE_SIZE, 1)
            end
          end

          @entities.each(&:draw)
        end
      end
    end

    def update(dt)
      replay! if Gosu.button_down?(Gosu::KB_R) && !replay?

      input = nil

      if replay?
        input = @inputs[@replay_frame]
        # puts "REPLAY: #{@replay_frame}: #{input}"
        @replay_frame += 1
      else
        input = Input.new
        input.jump = Gosu.button_down?(Gosu::KB_SPACE) || Gosu.button_down?(Gosu::KB_W) || Gosu.button_down?(Gosu::KB_UP)
        input.left = Gosu.button_down?(Gosu::KB_A) || Gosu.button_down?(Gosu::KB_LEFT)
        input.right = Gosu.button_down?(Gosu::KB_D) || Gosu.button_down?(Gosu::KB_RIGHT)

        @inputs << input != @inputs.last ? input : nil
      end

      @entities.each { |e| e.update(dt, input) }

      center_around(cat)
    end
  end
end
