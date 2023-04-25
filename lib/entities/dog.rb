module HungryCatTwo
  class Dog < Entity
    def setup
      @speed = 3.5
      @direction = 1

      @sat_at = Gosu.milliseconds
      @sit_time = 750
    end

    def update(dt)
      super

      return

      if Gosu.milliseconds > @sat_at + @sit_time
        @velocity.x += (@speed * dt) * @direction

        change_direction?
      end
    end

    def change_direction?
      unless ground_ahead?
        @direction *= -1

        @velocity.x = 0
        @sat_at = Gosu.milliseconds
      end
    end

    def ground_ahead?
      x = @velocity.x > 0 ? @position.x.floor / 16 + 1 : @position.x.floor / 16

      floor = @game_state.level.find do |sprite|
        (sprite.x.floor / 16).floor == x.floor &&
        (sprite.y.floor / 16).floor == (@position.y.floor / 16 + 1).floor
      end

      return floor
    end
  end
end
