graphics = require "graphics"
map = require "map"
shader = require "shader"
game = require "game"
control = require "control"
tabletostring = require "tabletostring"

love.load = function()
  graphics.load()
  map.load()
  control.load()
end

love.update = function(dt)
  control.update(dt)
end

love.draw = function(dt)
  love.graphics.push()
  love.graphics.translate(-map.pos.x, -map.pos.y)
  love.graphics.draw(map_canvas)
  control.draw()
  love.graphics.pop()
  love.graphics.print("Map Size: "..tostring(#grid[1][1])..", "..tostring(#grid[1])..", "..tostring(#grid))
  love.graphics.print("Current Space: "..tostring(control.target.x)..", "..tostring(control.target.y)..", "..tostring(control.target.z), 0, 12)
  if control.prop_mode then
    love.graphics.print("Selected Prop: "..tostring(prop_names[control.prop]), 0, 24)
    love.graphics.print("Total Props: "..tostring(#props), 0, 36)
  else
    love.graphics.print("Selected Tile: "..tostring(control.tile), 0, 24)
  end
  if control.help then
    love.graphics.print("Controls:\n"..
                         "W, A, S, D, Space, Shift: Change current space\n"..
                         "Right, Left, Up, Down: Pan camera\n"..
                         "+ and x, y, or z: Increase map dimension\n"..
                         "- and x, y, or z: Decrease map dimension\n"..
                         "< or > and x, y, or z: Shift map\n"..
                         "R and T: Change selected tile/prop\n"..
                         "Ctrl: Toggle prop mode\n"..
                         "G: Toggle grid\n"..
                         "H: Only show current z level\n"..
                         "Enter: Save map to love2d default directory\n"..
                         "N: New map\n"..
                         "?: Toggle control help", 0, 60)
  end
end

love.keypressed = function(key)
  control.keypressed(key)
end
