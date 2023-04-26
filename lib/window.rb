module HungryCatTwo
  ROOT_PATH = File.expand_path("../..", __FILE__)
  DESIGN_RESOLUTION_WIDTH = 1080

  class Window < CyberarmEngine::Window
    attr_reader :scale, :levels

    def setup
      self.caption = "Hungry Cat 2 / Gosu Game Jam 4"

      @scale = 3 * (width.to_f / HungryCatTwo::DESIGN_RESOLUTION_WIDTH)

      @levels = 1
      while File.exist?("#{ROOT_PATH}/tiled/level_#{@levels}.tmx")
        @levels += 1
      end
      @levels -= 1

      push_state(HungryCatGameTransition, current_level: 1, cat_lives: 3)
    end

    def update
      @scale = 3 * (width.to_f / HungryCatTwo::DESIGN_RESOLUTION_WIDTH)

      super
    end
  end
end
