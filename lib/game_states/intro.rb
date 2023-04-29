module HungryCatTwo
  class HungryCatGameIntro < GameState
    def setup
      @ground = [
        58, 57, 57, 56, 57, 57, 58
      ]

      @cat_lives = 3

      @font = Gosu::Font.new((16 * window.scale).ceil, name: BOLD_FONT)
      @small_font = Gosu::Font.new((12 * window.scale).ceil, name: FONT)

      @title = "Hungry Cat 2"
      @instructions = "Feed Cattingo tacos, and stay away from the dogs.\nPress JUMP to begin."
      @start_instructions = "Controls:\n"\
                            "Left  → A, Left, Gamepad D-Left, and Gamepad Left Stick -X\n"\
                            "Right → D, Right, Gamepad D-Right, and Gamepad Left Stick +X\n"\
                            "Jump → Spacebar, W, Up, Gamepad D-Up, and Gamepad A"
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, light_gray)
      @font.draw_text(@title, window.width / 2 - @font.text_width(@title) / 2, 10 + @font.height,  10, 1.0, 1.0, dark_gray)
      @small_font.draw_text(@instructions, window.width / 2 - @small_font.text_width(@instructions) / 2, 10 + @font.height * 2, 10, 1.0, 1.0, black)

      @small_font.draw_text(@start_instructions, window.width / 2 - @small_font.text_width(@start_instructions) / 2, window.height - (@small_font.height * 6 + 10), 10, 1.0, 1.0, black)

      Gosu.scale(window.scale, window.scale, window.width / 2, window.height / 2) do
        Gosu.translate(-Level::TILE_SIZE * @ground.size / 2, 0) do
          x = 0
          @ground.each do |tile|
            Level::SPRITESHEET[tile].draw(x + window.width / 2, window.height * 0.5, 10)
            x += Level::TILE_SIZE
          end

          Level::SPRITESHEET[14].draw(Level::TILE_SIZE * 1 + window.width / 2, window.height * 0.5 - Level::TILE_SIZE, 10)
          Level::SPRITESHEET[00].draw(Level::TILE_SIZE * 3 + window.width / 2, window.height * 0.5 - Level::TILE_SIZE, 10)
          Level::SPRITESHEET[42].draw(Level::TILE_SIZE * 4 + window.width / 2, window.height * 0.5 - Level::TILE_SIZE, 10)
          Level::SPRITESHEET[49].draw(Level::TILE_SIZE * 6 + window.width / 2, window.height * 0.5 - Level::TILE_SIZE, 10)
        end
      end
    end

    def button_down(id)
      super

      push_state(HungryCatGameTransition, current_level: 1, cat_lives: 3) if Level::JUMP_KEYS.include?(id)
      close if id == Gosu::KB_ESCAPE
    end
  end
end
