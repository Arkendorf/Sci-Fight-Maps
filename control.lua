local control = {}

love.keyboard.setKeyRepeat(true)

control.load = function()
  control.target = {x = 1, y = 1, z = 1}
  control.tile = 1
  control.prop_mode = false
  control.prop = 1
  control.help = true
end

control.update = function(dt)
  if love.keyboard.isDown("right") then
    map.pos.x = map.pos.x + dt * 60 * 4
  end
  if love.keyboard.isDown("left") then
    map.pos.x = map.pos.x - dt * 60 * 4
  end
  if love.keyboard.isDown("down") then
    map.pos.y = map.pos.y + dt * 60 * 4
  end
  if love.keyboard.isDown("up") then
    map.pos.y = map.pos.y - dt * 60 * 4
  end

  if control.prop_mode then
    if love.mouse.isDown(1) then
      local valid = true
      for i, v in ipairs(props) do
        if game.cube_collide({x = v.x, y = v.y, z = v.z, l = prop_info[v.type].l, w = prop_info[v.type].w, h = prop_info[v.type].h}, {x = control.target.x, y = control.target.y, z = control.target.z, l = 1, w = 1, h = 1}) then
          valid = false
          break
        end
      end
      if valid then
        props[#props+1] = {x = control.target.x, y = control.target.y, z = control.target.z, type = prop_names[control.prop]}
        map.draw()
      end
    end
    if love.mouse.isDown(2) then
      for i, v in ipairs(props) do
        if game.cube_collide({x = v.x, y = v.y, z = v.z, l = prop_info[v.type].l, w = prop_info[v.type].w, h = prop_info[v.type].h}, {x = control.target.x, y = control.target.y, z = control.target.z, l = 1, w = 1, h = 1}) then
          props[i] = nil
          map.draw()
        end
      end
    end
  else
    if love.mouse.isDown(1) then
      grid[control.target.z][control.target.y][control.target.x] = control.tile
      map.draw()
    end
    if love.mouse.isDown(2) then
      grid[control.target.z][control.target.y][control.target.x] = 0
      map.draw()
    end
  end
end

control.draw = function()
  if map.lattice then
    map.iterate(game.draw_lattice) -- draw tiles
  end
  love.graphics.setColor(1, 1, 1, .5)
  if control.prop_mode then
    love.graphics.draw(prop_img[prop_names[control.prop]], (control.target.x-1)*tile_size, (control.target.y+control.target.z-2)*tile_size)
  else
    if not map.floor_block(control.target.x, control.target.y, control.target.z) then
      love.graphics.draw(tile_img[control.tile], floor_sample, (control.target.x-1)*tile_size, (control.target.y+control.target.z-2)*tile_size)
    end
    if not map.wall_block(control.target.x, control.target.y, control.target.z) then
      love.graphics.draw(tile_img[control.tile], wall_sample, (control.target.x-1)*tile_size, (control.target.y+control.target.z-1)*tile_size)
    end
  end
  love.graphics.setColor(1, 1, 1)
end

control.keypressed = function(key)
  if key == "=" then
    if love.keyboard.isDown("x") and #grid[1][1] < 100 then
      control.new_x(#grid[1][1]+1)
    elseif love.keyboard.isDown("y") and #grid[1] < 100 then
      control.new_y(#grid[1]+1)
    elseif love.keyboard.isDown("z") and #grid < 100 then
      control.new_z(#grid+1)
    end
    map.canvas_setup()
  elseif key == "-" then
    if love.keyboard.isDown("x") and #grid[1][1] > 1 then
      control.remove_x(#grid[1][1])
    elseif love.keyboard.isDown("y") and #grid[1] > 1 then
      control.remove_y(#grid[1])
    elseif love.keyboard.isDown("z") and #grid > 1 then
      control.remove_z(#grid)
    end
    map.canvas_setup()
  elseif key == "," then
    if love.keyboard.isDown("x") then
      control.remove_x(1)
      control.new_x(#grid[1][1]+1)
      control.shift_props(-1, 0, 0)
    elseif love.keyboard.isDown("y") then
      control.remove_y(1)
      control.new_y(#grid[1]+1)
      control.shift_props(0, -1, 0)
    elseif love.keyboard.isDown("z") then
      control.remove_z(1)
      control.new_z(#grid+1)
      control.shift_props(0, 0, -1)
    end
    map.draw()
  elseif key == "." then
    if love.keyboard.isDown("x") then
      control.remove_x(#grid[1][1])
      control.new_x(1)
      control.shift_props(1, 0, 0)
    elseif love.keyboard.isDown("y") then
      control.remove_y(#grid[1])
      control.new_y(1)
      control.shift_props(0, 1, 0)
    elseif love.keyboard.isDown("z") then
      control.remove_z(#grid)
      control.new_z(1)
      control.shift_props(0, 0, 1)
    end
    map.draw()

  elseif key == "g" then
    map.lattice = not map.lattice

  elseif key == "d" and control.target.x < #grid[1][1] then
    control.target.x = control.target.x + 1
  elseif key == "a" and control.target.x > 1 then
    control.target.x = control.target.x - 1
  elseif key == "s" and control.target.y < #grid[1] then
    control.target.y = control.target.y + 1
  elseif key == "w" and control.target.y > 1 then
    control.target.y = control.target.y - 1
  elseif key == "lshift" and control.target.z < #grid then
    control.target.z = control.target.z + 1
  elseif key == "space" and control.target.z > 1 then
    control.target.z = control.target.z - 1

  elseif key == "t" then
    if control.prop_mode then
      control.prop = control.prop + 1
      if control.prop > #prop_names then
        control.prop = 1
      end
    else
      control.tile = control.tile + 1
      if control.tile > #tile_img then
        control.tile = 1
      end
    end
  elseif key == "r" then
    if control.prop_mode then
      control.prop = control.prop - 1
      if control.prop < 1 then
        control.prop = #prop_names
      end
    else
      control.tile = control.tile - 1
      if control.tile < 1  then
        control.tile = #tile_img
      end
    end

  elseif key == "lctrl" then
    control.prop_mode = not control.prop_mode

  elseif key == "/" then
    control.help = not control.help

  elseif key == "return" then
    control.save()
  end
end

control.new_z = function(pos)
  local a = {}    -- new array
  for i=1, #grid[1] do
    local b = {}    -- new array
    for j=1, #grid[1][1] do
      b[j] = 0
    end
    a[i] = {unpack(b)}
  end
  table.insert(grid, pos, {unpack(a)})
end

control.remove_z = function(pos)
  table.remove(grid, pos)
end

control.new_y = function(pos)
  for z, z_row in ipairs(grid) do
    local a = {}    -- new array
    for i=1, #grid[1][1] do
      a[i] = 0
    end
    table.insert(grid[z], pos, {unpack(a)})
  end
end

control.remove_y = function(pos)
  for z, _ in ipairs(grid) do
    table.remove(grid[z], pos)
  end
end

control.new_x = function(pos)
  for z, _ in ipairs(grid) do
    for y, y_row in ipairs(grid[z]) do
      table.insert(grid[z][y], pos, 0)
    end
  end
end

control.remove_x = function(pos)
  for z, _ in ipairs(grid) do
    for y, y_row in ipairs(grid[z]) do
      table.remove(grid[z][y], pos)
    end
  end
end

control.shift_props = function(x, y, z)
  for i, v in ipairs(props) do
    v.x = v.x + x
    v.y = v.y + y
    v.z = v.z + z
  end
end

control.save = function()
  local str = "return "..tabletostring(grid)..", "..tabletostring(props)
  local icon = map.draw_icon()
  local name = tostring(os.time())
  love.filesystem.write(name..".txt", str)
  icon:newImageData():encode("png", name..".png")
end

return control
