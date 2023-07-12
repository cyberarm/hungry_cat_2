module HungryCatTwo
  class Dog < Entity
    def setup
      @speed = 7.5
      @direction = 1

      @sat_at = milliseconds
      @sit_time = 750
    end

    def update(dt, input)
      super

      return unless milliseconds > @sat_at + @sit_time

      @velocity.x += (@speed * dt) * @direction

      change_direction?
    end

    def change_direction?
      return if ground_ahead?

      @direction *= -1

      @velocity.x = 0
      @sat_at = milliseconds
    end

    def ground_ahead?
      x = @velocity.x.positive? ? @position.x.floor / Level::TILE_SIZE + 1 : @position.x.floor / Level::TILE_SIZE

      @level.tile(x, position.y.floor / Level::TILE_SIZE + 1)
    end
  end
end
