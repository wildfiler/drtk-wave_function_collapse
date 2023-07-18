require 'lib/wfc/wfc.rb'
require 'lib/wfc/cell.rb'
require 'lib/wfc/tile.rb'
require 'lib/wfc/simple_tiled_model.rb'
require 'lib/wfc/overlapping_model.rb'
require 'lib/tiled/tiled.rb'

def tick args
  # args.outputs.labels  << [640, 540, 'Hello World!', 5, 1]
  # args.outputs.labels  << [640, 500, 'Docs located at ./docs/docs.html and 100+ samples located under ./samples', 5, 1]
  # args.outputs.labels  << [640, 460, 'Join the Discord server! https://discord.dragonruby.org', 5, 1]
  #
  # args.outputs.sprites << { x: 576,
  #                           y: 280,
  #                           w: 128,
  #                           h: 101,
  #                           path: 'dragonruby.png',
  #                           angle: args.state.tick_count }
  #
  # args.outputs.labels  << { x: 640,
  #                           y: 60,
  #                           text: './mygame/app/main.rb',
  #                           size_enum: 5,
  #                           alignment_enum: 1 }

  if args.tick_count.zero?
    args.state.tileset = Tiled::Tileset.load('sprites/forest/tileset.tsx')
    tiles = create_tile_array(args.state.tileset)
    args.state.model = Wfc::SimpleTiledModel.new(tiles, 40, 20)
    tiled_map = args.state.model.solve
    args.state.tiled_map = tiled_map
    refresh_target(args, tiled_map)
  end

  if args.inputs.keyboard.i
    tiled_map = args.state.model.iterate
    if tiled_map
      args.state.tiled_map = tiled_map
      refresh_target(args, tiled_map)
    end
  end

  if args.inputs.keyboard.key_down.r
    args.state.tileset = Tiled::Tileset.load('sprites/forest/tileset.tsx')
    tiles = create_tile_array(args.state.tileset)
    args.state.model = Wfc::SimpleTiledModel.new(tiles, 40, 20)
    tiled_map = args.state.model.solve
    args.state.tiled_map = tiled_map
    refresh_target(args, tiled_map)
  end

  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 1040,
    h: 520,
    source_w: 520,
    source_h: 260,
    path: :map,
  }
end

def create_tile_array(tileset)
  tileset.wangsets.last.tiles.map do |id, wangtile|
    Wfc::Tile.new(id, wangtile.wangid4, wangtile.tile.probability.to_f || 1.0)
  end
end

def refresh_target(args, tiled_map)
  target = args.outputs[:map]
  target.width = 520
  target.height = 260
  target.background_color = [0,0,0]
  target.sprites << tiled_map.map_2d do |x, y, wfc_tile|
    next unless wfc_tile

    args.state.tileset.sprite_at(x * 13, y * 13, wfc_tile.identifier)
  end
end
