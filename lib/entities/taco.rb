
class Taco
  attr_reader :sprite, :position
  def initialize(game_state:, x:, y:, z:, sprite: 42)
    @game_state = game_state
    @context = game_state.context
    @position = Entity::Vector.new(x, y, z)
    @sprite = sprite

    @offset_range = 2.0
    @offset = 0
    @limiter = 250.0
  end

  def draw
    @context.sprite(sprite, @position.x, @position.y + @offset, @position.z)
  end

  def update(dt)
    @offset = Math.cos(@context.milliseconds / @limiter) * @offset_range
  end
end
