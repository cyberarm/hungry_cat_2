module HungryCatTwo
  class Input
    attr_accessor :jump, :left, :right

    def initialize
      @jump = false
      @left = false
      @right = false
    end

    def jump?
      @jump
    end

    def left?
      @left
    end

    def right?
      @right
    end

    def ==(other)
      if other.is_a?(Input)
        jump == other.jump && left == other.left && right == other.right
      elsif other == nil
        !jump && !left && !right
      else
        super
      end
    end
  end
end
