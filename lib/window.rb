module HungryCatTwo
  ROOT_PATH = File.expand_path("../..", __FILE__)
  TILE_SIZE = 16

  class Window < CyberarmEngine::Window
    attr_reader :spritesheet

    def setup
      self.caption = "Hungry Cat 2 / Gosu Game Jam 4"

      @spritesheet = Gosu::Image.load_tiles("#{ROOT_PATH}/media/spritesheet.png", TILE_SIZE, TILE_SIZE, retro: true)
      @spritesheet.freeze

      @i = 56
    end

    def draw
      super

      Gosu.draw_rect(0, 0, width, height, 0xff_252525)

      @spritesheet[@i].draw(0, 0, 0, 4, 4)
      @i += 1
      @i = 56 if @i > 58
      sleep 0.1
    end
  end
end
