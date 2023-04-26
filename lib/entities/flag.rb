module HungryCatTwo
  class Flag < Entity
    def setup
      @static = true

      @sprites[:idle] = [49, 50, 51, 50]
      @sprites[:jumping] = [49]
    end
  end
end
