begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require_relative "lib/window"

# require_relative "lib/entity"
# require_relative "lib/entities/taco"
# require_relative "lib/entities/dog"
# require_relative "lib/entities/cat"

# require_relative "lib/game_state"
# require_relative "lib/game_states/intro"
# require_relative "lib/game_states/transition"
# require_relative "lib/game_states/level"
# require_relative "lib/game_states/win"
# require_relative "lib/game_states/lose"

HungryCatTwo::Window.new(resizable: true).show
