module HungryCatTwo
  ROOT_PATH = File.expand_path("../..", __FILE__)
  DESIGN_RESOLUTION_WIDTH = 1080
  DEBUG = ARGV.join.include?("--debug")

  FONT = "#{ROOT_PATH}/media/fonts/Connection.otf".freeze
  BOLD_FONT = "#{ROOT_PATH}/media/fonts/ConnectionBold.otf".freeze

  class Window < CyberarmEngine::Window
    attr_reader :scale, :levels, :debug

    def setup
      @debug = DEBUG
      self.show_stats_plotter = @debug
      self.caption = "Hungry Cat 2 / Gosu Game Jam 4"

      @scale = 3 * (width.to_f / HungryCatTwo::DESIGN_RESOLUTION_WIDTH)

      @levels = 1
      while File.exist?("#{ROOT_PATH}/tiled/level_#{@levels}.tmx")
        @levels += 1
      end
      @levels -= 1

      push_state(HungryCatGameIntro)

      song = get_song("#{ROOT_PATH}/media/music/caller.mp3")
      song.volume = 0.25
      song.play(true)
    end

    def update
      @scale = 3 * (width.to_f / HungryCatTwo::DESIGN_RESOLUTION_WIDTH)

      super
    end

    def button_down(id)
      super

      return unless id == Gosu::KB_TAB

      @debug = !@debug
      self.show_stats_plotter = @debug
    end
  end
end
