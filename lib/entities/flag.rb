module HungryCatTwo
  class Flag < Entity
    def setup
      @sprites[:idle] = [49, 50, 51, 50]
      @sprites[:jumping] = [49]
    end
  end
end
