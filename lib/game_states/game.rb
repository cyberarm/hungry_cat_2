class HungryCatGame < GameState
  attr_reader :current_level, :context, :level

  def setup
    @current_level = @options[:current_level]

    @level = @context.levels[@current_level].sort_by {|sprite| sprite.z}.map do |sprite|
      if RUBY_ENGINE == "opal"
        # Struct.dup is broken it seems...
        AuthorEngine::Sprite.new(sprite.sprite, sprite.x, sprite.y, sprite.z)
      else
        sprite.dup
      end
    end

    @offset = Entity::Vector.new(0, 0)

    @entities = []
    @cat = Cat.new(game_state: self, base_sprite: 14)
    @cat.lives = @options[:cat_lives]

    setup_level
  end

  def draw
    @context.rect(0, 0, @context.width, @context.height, @context.light_gray)

    @context.translate(-@offset.x, -@offset.y) do
      @level.each do |sprite|
        @context.sprite(sprite.sprite, sprite.x, sprite.y, sprite.z)
      end

      @entities.each(&:draw)
      @cat.draw

      debug_draw
    end

    tacos.size.times do |i|
      @context.sprite(42, -3 + (9 * i), -3)
    end

    @cat.lives.times do |i|
      @context.sprite(27, -4 + (6 * i), 8)
    end
    @context.text("levels: #{@current_level + 1} of #{@context.levels.size} fps: #{@context.fps}, delta time: #{@context.dt}", 1, 1, 6, 0, @context.dark_gray)
  end

  def update(dt)
    @entities.each { |entity| entity.update(dt) }
    @cat.update(dt)

    center_around(@cat)

    next_level?
  end

  def dogs
    @entities.select { |ent| ent.is_a?(Dog) }
  end

  def tacos
    @entities.select { |ent| ent.is_a?(Taco) }
  end

  def flag
    @entities.find { |ent| ent.is_a?(Flag) }
  end

  def eat_taco(taco)
    @entities.delete(taco)
  end

  def setup_level
    @entities.clear
    create_and_position_entities(Flag, 49) # Flags
    create_and_position_entities(Taco, 42) # Tacos
    create_and_position_entities(Dog,  00) # Dogs
    position_cat
  end

  def next_level?
    if tacos.size == 0 && @context.sprite_vs_sprite(@cat.sprite, @cat.position.x, @cat.position.y, flag.sprite, flag.position.x, flag.position.y)
      if @current_level < @context.levels.size - 1
        @context.game_state = HungryCatGameTransition.new(@context, current_level: @current_level + 1, cat_lives: @cat.lives + 1)
      else
        @context.game_state = HungryCatGameComplete.new(@context)
      end
    end
  end

  def create_and_position_entities(klass, sprite_id)
    entity = @level.select { |sprite| sprite.sprite == sprite_id}

    entity.each do |spawner|
      @level.delete(spawner) # Remove spawner

      @entities << klass.new(game_state: self, x: spawner.x, y: spawner.y, z: spawner.z)
    end
  end

  def position_cat
    cat = @level.detect { |sprite| sprite.sprite == 14}

    @level.delete(cat) # Remove cat spawner

    @cat.position.x = cat.x
    @cat.position.y = cat.y
  end

  def center_around(entity, lag = Entity::Vector.new(0.9, 0.9))
    @offset.x += ((entity.position.x - @context.width  / 2) - @offset.x) * (1.0 - lag.x)
    @offset.y += ((entity.position.y - @context.height / 2) - @offset.y) * (1.0 - lag.y)
  end

  def debug_draw
    if @debug
      @context.draw_level_boxes(@current_level)
      @context.draw_sprite_box(@cat.sprite, @cat.position.x, @cat.position.y)
    end
  end
end
