local game = {}

game.draw_tiles = function(x, y, z, tile)
  if tile > 0 and (not map.only_z or z == control.target.z) then
    -- floor
    if not map.floor_block(x, y, z) then
      graphics.draw_floor(x, y, z, tile)
    end

    -- wall
    if not map.wall_block(x , y, z) then
      graphics.draw_wall(x, y, z, tile)
    end
  end
end

game.draw_lattice = function(x, y, z)
    if z == 1 or (map.only_z and z == control.target.z) then
      love.graphics.setColor(0, 1, 0)
      love.graphics.rectangle("line", (x-1)*tile_size, (y+z-2)*tile_size, tile_size, tile_size)
    end
    if y == #grid[1] and (not map.only_z or z == control.target.z) then
      love.graphics.setColor(1, 0, 0)
      love.graphics.rectangle("line", (x-1)*tile_size, (y+z-1)*tile_size, tile_size, tile_size)
    end
    love.graphics.setColor(1, 1, 1)
end

game.draw_layer_mask = function(x, y, z, tile)
  if tile > 0 and (not map.only_z or z == control.target.z) then
    love.graphics.setColor(0, 1.01 - 0.01*y, 1.01 - 0.01*z)
    if not map.floor_block(x, y, z) then
      love.graphics.rectangle("fill", (x-1)*tile_size, (y+z-2)*tile_size, tile_size, tile_size)
    end
    if not map.wall_block(x , y, z) then
      love.graphics.rectangle("fill", (x-1)*tile_size, (y+z-1)*tile_size, tile_size, tile_size)
    end
  end
end

game.draw_props = function(shade, mask, shadow)
  if mask then
    shader[shade]:send("mask", mask)
    shader[shade]:send("mask_size", {mask:getWidth(), mask:getHeight()})
    shader[shade]:send("tile_size", tile_size)
    shader[shade]:send("offset", {0, 0})
  end
  for i, v in ipairs(props) do
    if not map.only_z or (control.target.z >= v.z and control.target.z < v.z+prop_info[v.type].h) then
      if not shadow or prop_info[v.type].shadow then
        if mask then
          shader[shade]:send("w", prop_info[v.type].w)
          shader[shade]:send("coords", {v.x, v.y, v.z})
        end
        love.graphics.setShader(shader[shade])
        love.graphics.draw(prop_img[prop_info[v.type].img], (v.x-1)*tile_size, (v.y+v.z-2)*tile_size)
        love.graphics.setShader()
      end
    end
  end
end

game.cube_collide = function(a, b)
  return (a.x+a.l > b.x and a.x < b.x+b.l and a.y+a.w > b.y and a.y < b.y+b.w and a.z+a.h > b.z and a.z < b.z+b.h)
end

return game
