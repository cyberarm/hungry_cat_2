module HungryCatTwo
  ROOT_PATH = File.expand_path("../..", __FILE__)
  DESIGN_RESOLUTION_WIDTH = 1080

  class Window < CyberarmEngine::Window
    attr_reader :spritesheet, :collision_data

    def setup
      self.caption = "Hungry Cat 2 / Gosu Game Jam 4"

      @level = Level.new(tmx: "#{ROOT_PATH}/tiled/level_1.tmx")
    end

    def draw
      super

      @level.draw
    end

    def update
      super

      @level.update(0.016)
    end
  end
end
