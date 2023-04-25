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
          when DOG
            i = -1
            @entities << Dog.new(level: self,x: index, y: @height, base_sprite: 0)
          when TACO
            i = -1
            @entities << Taco.new(level: self,x: index, y: @height, base_sprite: 42)
          when FLAG
            i = -1
            @entities << Flag.new(level: self,x: index, y: @height)
          end

          @tiles << i
        end

        @width = list.size
        @height += 1
      end
    end

    def draw
      Gosu.draw_rect(0, 0, @window.width, @window.height, 0xff_252525, 0)

      Gosu.scale(3, 3, 0, 0) do
        @height.times do |y|
          @width.times do |x|
            tile = @tiles[@width * y + x]

            SPRITESHEET[tile].draw(x * TILE_SIZE, y * TILE_SIZE, 1)
          end
        end

        @entities.each(&:draw)
      end
    end

    def update(dt)
      @entities.each { |e| e.update(dt) }
    end
  end
end
