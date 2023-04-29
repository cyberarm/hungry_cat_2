if RUBY_ENGINE == "mruby"
  def require_relative(path)
    require "./#{path}"
  end

  def warn(message)
    puts message
  end
else
  begin
    require_relative "../cyberarm_engine/lib/cyberarm_engine"
  rescue LoadError
    require "cyberarm_engine"
  end
end

require_relative "lib/window"
require_relative "lib/level"
require_relative "lib/input"
require_relative "lib/colors"

require_relative "lib/entity"
require_relative "lib/entities/flag"
require_relative "lib/entities/taco"
require_relative "lib/entities/dog"
require_relative "lib/entities/cat"

require_relative "lib/game_state"
require_relative "lib/game_states/intro"
require_relative "lib/game_states/game"
require_relative "lib/game_states/game_finished"
require_relative "lib/game_states/game_over"
require_relative "lib/game_states/game_won"
require_relative "lib/game_states/transition"

if HungryCatTwo::DEBUG
  HungryCatTwo::Window.new(resizable: true, width: 1280, height: 720).show
else
  HungryCatTwo::Window.new(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true).show
end
