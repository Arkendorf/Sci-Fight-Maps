local graphics = {}

love.graphics.setDefaultFilter("nearest", "nearest")

graphics.load = function()
  -- load tile images
tile_img = graphics.load_folder("art/tiles")
tile_quad = graphics.load_tile_quad(tile_size)
floor_sample = love.graphics.newQuad(64, 0, 32, 32, tile_img[1]:getDimensions())
wall_sample = love.graphics.newQuad(64, 32, 32, 32, tile_img[1]:getDimensions())


-- load props
prop_img = graphics.load_folder("art/props")
end

graphics.load_doublefolder = function(str, tw, th, quadfunc)
  local img = {}
  local quad = {}
  local info = {}
  local files = love.filesystem.getDirectoryItems(str)
  for i, v in ipairs(files) do
    img[tonumber(v)], quad[tonumber(v)], info[tonumber(v)] = graphics.load_folder(str.."/"..v, tw, th, quadfunc)
  end
  return img, quad, info
end

graphics.load_folder = function(str, tw, th, quadfunc)
  local img = {}
  local quad = {}
  local info = {}
  local files = love.filesystem.getDirectoryItems(str)
  for i, v in ipairs(files) do
    if string.sub(v, -4, -1) == ".png" then
      local name = string.sub(v, 1, -5)
      if tonumber(name) then
        name = tonumber(name)
      end
      img[name] = love.graphics.newImage(str.."/"..v)
      if tx or th then
        if not quadfunc then
          quadfunc = graphics.load_quad
        end
        quad[name] = quadfunc(img[name], tw, th)
      end
      local info_name = str.."/"..name.."_info.txt"
      if love.filesystem.getInfo(info_name) then
        info[name] = love.filesystem.load(info_name)()
      end
    end
  end
  return img, quad, info
end

graphics.load_quad = function(img, tw, th)
  local quad = {}
  local iw, ih = img:getDimensions()
  for h = 0, math.floor(ih/th)-1 do
    for w = 0, math.floor(iw/tw)-1 do
      quad[#quad+1] = love.graphics.newQuad(w*tw, h*th, tw, th, iw, ih)
    end
  end
  return quad
end

graphics.load_face_quad = function(img, tw, th)
  local quad = {}
  local iw, ih = img:getDimensions()
  for h = 0, 3 do
    quad[h+1] = {}
    for w = 0, math.floor(iw/tw)-1 do
      quad[h+1][w+1] = love.graphics.newQuad(w*tw, h*th, tw, th, iw, ih)
    end
  end
  return quad
end

graphics.load_tile_quad = function(t)
  local x, y = tile_img[1]:getDimensions()
  local tile = {{{}, {}, {}, {}}, {{}, {}, {}, {}}}
  for i = 0, 1 do
    for j = 0, 4 do
      tile[i+1][1][j+1] = love.graphics.newQuad(j*t, t*i, t/2, t/2, x, y)
      tile[i+1][2][j+1] = love.graphics.newQuad(t/2+j*t, t*i, t/2, t/2, x, y)
      tile[i+1][3][j+1] = love.graphics.newQuad(j*t, t*i+t/2, t/2, t/2, x, y)
      tile[i+1][4][j+1] = love.graphics.newQuad(t/2+j*t, t*i+t/2, t/2, t/2, x, y)
    end
  end
  return tile
end

graphics.draw_floor = function(x, y, z, tile)
  for w = 0, 1 do
    for h = 0, 1 do
      local corner = w+h*2+1
      love.graphics.draw(tile_img[tile], tile_quad[1][corner][graphics.bitmask_tile(x, y, z, w, h, tile, graphics.floor_func)], (x-1+w/2)*tile_size, (y+z-2+h/2)*tile_size)
    end
  end
end
graphics.draw_wall = function(x, y, z, tile)
  for w = 0, 1 do
    for h = 0, 1 do
      local corner = w+h*2+1
      love.graphics.draw(tile_img[tile], tile_quad[2][corner][graphics.bitmask_tile(x, y, z, w, h, tile, graphics.wall_func)], (x-1+w/2)*tile_size, (y+z-1+h/2)*tile_size)
    end
  end
end
graphics.floor_func = function(x, y, z, ox, oy, tile)
  return (map.in_bounds(x+ox, y+oy, z) and grid[z][y+oy][x+ox] == tile)
end

graphics.wall_func = function(x, y, z, ox, oy, tile)
  return (map.in_bounds(x+ox, y, z+oy) and grid[z+oy][y][x+ox] == tile)
end

graphics.border_func = function(x, y, z, ox, oy, tile)
  return (not map.in_bounds(x+ox, y+oy, z) or not map.floor_block(x+ox, y+oy, z))
end
graphics.bitmask_tile = function(x, y, z, w, h, tile, func)
  -- determine value
  local value = 3
  local right = (w > 0)
  local left = (w < 1)
  local down = (h > 0)
  local up = (h < 1)
  local side_type = 4
  -- direct sides
  if (right and func(x, y, z, 1, 0, tile)) or (left and func(x, y, z, -1, 0, tile)) then
    value = value + 2
  else -- for resolving type conflict
    side_type = 5
  end
  if (down and func(x, y, z, 0, 1, tile)) or (up and func(x, y, z, 0, -1, tile)) then
    value = value + 2
  end
  -- diagonals
  if (right and down and func(x, y, z, 1, 1, tile)) or (right and up and func(x, y, z, 1, -1, tile)) or (left and up and func(x, y, z, -1, -1, tile)) or (left and down and func(x, y, z, -1, 1, tile)) then
    value = value + 1
  end

  -- translate value
  if value < 5 then
    return 2
  elseif value < 7 then
    return side_type
  elseif value < 8 then
    return 1
  else
    return 3
  end
end

return graphics
