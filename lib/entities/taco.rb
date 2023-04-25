
module HungryCatTwo
  class Taco < Entity
    def setup
      @sprite = 42
      @offset = 0
      @offset_range = 0.005
      @limiter = 200.0
    end

    def sprite
      @sprite
    end

    def update(dt)
      @offset = Math.cos(Gosu.milliseconds / @limiter) * @offset_range
      @position.y += @offset
    end
  end
end
