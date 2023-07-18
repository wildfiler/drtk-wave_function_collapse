module Wfc
  class Cell
    attr_reader :available_tiles
    attr_reader :x, :y, :collapsed, :grid, :tile_probabilities

    # x: the x coord of this cell in the cell array
    # y: the y coord of this cell in the cell array
    # available_tiles: an array of Tile objects with their rules attached
    def initialize(x, y, available_tiles)
      @available_tiles = available_tiles.flatten
      @collapsed = false
      @x = x
      @y = y
      refresh_tiles_propapilities
    end

    def refresh_tiles_propapilities
      probs = @available_tiles.map(&:probability)
      probs_sum = probs.sum
      tile_ids = @available_tiles.map(&:identifier)
      normilized_probs = probs.map {|prob| prob / probs_sum}
      @tile_probabilities = tile_ids.zip(normilized_probs)
    end

    def update
      @collapsed = @available_tiles.size == 1
    end

    def available_tiles=(new)
      @available_tiles = new
      refresh_tiles_propapilities
      @available_tiles
    end

    def collapse
      return if @available_tiles.nil?

      random = rand

      offset = 0.0
      selected_id = @tile_probabilities.detect do |id, weight|
        puts "#{id} => #{random} - #{offset} - #{weight} - [#{offset}, #{offset + weight}) #{(offset >= random)} #{((offset + weight) < random)}"
        res = (random >= offset ) && (random < offset + weight)
        offset += weight
        res
      end.first

      # selected_id = @tile_probabilities.max_by { |_, weight| rand ** (1.0 / weight) }.first
      new_tile = @available_tiles.detect{ |t| t.identifier == selected_id }
      self.available_tiles = [new_tile]
      @collapsed = true
    end

    def entropy
      @available_tiles.length
    end

    def neighbors(grid)
      return if grid.nil?

      @neighbors ||= begin
        up = grid[@x][@y + 1] if grid[@x] && @y < grid[0].length - 1
        down = grid[@x][@y - 1] if grid[@x] && @y.positive?
        right = grid[@x + 1][@y] if @x < grid.length - 1
        left = grid[@x - 1][@y] if @x.positive?
        { up: up, down: down, right: right, left: left }
      end
    end
  end
end
