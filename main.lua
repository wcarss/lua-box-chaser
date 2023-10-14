squares = {}
square_count = 1

function love.load()
  math.randomseed(os.time())
  squares[0] = {
    x = 100,
    y = 100,
    width = 50,
    height = 50,
    angle = 0,
    r = 0,
    g = 1,
    b = 0,
    x_dir = 1,
    x_speed = 2,
    y_dir = -1,
    y_speed = 4
  }
  squares[1] = {
    x = 500,
    y = 500,
    width = 50,
    height = 50,
    angle = 0,
    r = 1,
    g = 0,
    b = 0,
    x_dir = 1,
    x_speed = 5,
    y_dir = 1,
    y_speed = 3
  }
  for square_index = 2, square_count do
  	squares[square_index] = {
      x = math.random(100, 500),
      y = math.random(100, 500),
      width = 10,
      height = 10,
      angle = 0,
      r = math.random(1,255)/255,
      g = math.random(1,255)/255,
      b = math.random(1,255)/255,
      x_dir = 1,
      x_speed = math.random(1,8),
      y_dir = 1,
      y_speed = math.random(1,8)
    }
  end
end

function draw_square(square)
  love.graphics.push()
  love.graphics.translate(square.x, square.y)
  love.graphics.rotate(square.angle)
  love.graphics.setColor(square.r, square.g, square.b)
  love.graphics.rectangle("fill", -square.width/2, -square.height/2, square.width, square.height, 8, 8) -- origin in the middle
  love.graphics.pop()
end

function update_square(square)
  square.angle = square.angle + 0.1
  if square.x > 750 then
    square.x_dir = -1;
  elseif square.x < 50 then
    square.x_dir = 1;
  end
  square.x = square.x + square.x_dir * square.x_speed

  if square.y > 550 then
    square.y_dir = -1;
  elseif square.y < 50 then
    square.y_dir = 1;
  end
  square.y = square.y + square.y_dir * square.y_speed
end

function love.draw()
  for square_index = 0, square_count do
  	draw_square(squares[square_index])
  end
end

function love.update()
  for square_index = 0, square_count do
  	update_square(squares[square_index])
  end
end