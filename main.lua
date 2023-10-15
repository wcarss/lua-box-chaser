globalSettings = {}
squares = {}
square_count = 100

function love.load()
  math.randomseed(os.time())
  love.window.setFullscreen(true)
  globalSettings.maxWidth, globalSettings.maxHeight, _ = love.window.getMode()
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
    x_acceleration = 2000,
    x_velocity = 0,
    max_x_velocity = 500,
    y_dir = -1,
    y_acceleration = 2000,
    y_velocity = 0,
    max_y_velocity = 500,
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
    x_speed = 200,
    y_dir = 1,
    y_speed = 200
  }
  for square_index = 2, square_count do
  	squares[square_index] = {
      x = math.random(100, 500),
      y = math.random(100, 500),
      width = 14,
      height = 14,
      angle = 0,
      r = 0.95,
      g = 0.85,
      b = 0.05,
      x_dir = 1,
      x_speed = math.random(1,8)*14,
      y_dir = 1,
      y_speed = math.random(1,8)*14
    }
  end
end

function old_rect_collide(o1, o2)
  return (
  	(o1.x > o2.x and o1.x < o2.x + o2.width) or
  	(o1.x + o1.width > o2.x and o1.x + o1.width < o2.x + o2.width)
  ) and (
    (o1.y > o2.y and o1.y < o2.y + o2.height) or
    (o1.y + o1.height > o2.y and o1.y + o1.height < o2.y + o2.height)
  )
end

function rect_collide(o1, o2)
  o1_left = o1.x - o1.width/2
  o1_right = o1.x + o1.width/2
  o1_top = o1.y - o1.height/2
  o1_bottom = o1.y + o1.height/2
  o2_left = o2.x - o2.width/2
  o2_right = o2.x + o2.width/2
  o2_top = o2.y - o2.height/2
  o2_bottom = o2.y + o2.height/2
  return (
  	(o1_left > o2_left and o1_right < o2_right) or
  	(o1_right > o2_left and o1_right < o2_right)
  ) and (
    (o1_top > o2_top and o1_top < o2_bottom) or
    (o2_bottom > o2_top and o2_bottom < o2_bottom)
  )
end

function draw_square(square)
  if square.active == false then
  	return
  end

  love.graphics.push()
  love.graphics.translate(square.x, square.y)
  love.graphics.rotate(square.angle)
  love.graphics.setColor(square.r, square.g, square.b)
  love.graphics.rectangle("fill", -square.width/2, -square.height/2, square.width, square.height, 8, 8) -- origin in the middle
  love.graphics.pop()
end

function update_square(square, dt)
  if square.active == false then
  	return
  end

  square.angle = square.angle + 0.1
  if square.x > globalSettings.maxWidth - 50 then
    square.x_dir = -1;
  elseif square.x < 50 then
    square.x_dir = 1;
  end
  square.x = square.x + square.x_dir * square.x_speed * dt

  if square.y > globalSettings.maxHeight - 50 then
    square.y_dir = -1;
  elseif square.y < 50 then
    square.y_dir = 1;
  end
  square.y = square.y + square.y_dir * square.y_speed * dt

  if rect_collide(square, squares[0]) then
  	square.active = false
  end
end

function love.draw()
  for square_index = 0, square_count do
  	draw_square(squares[square_index])
  end
end

function love.update(dt)
  update_player(squares[0], dt)
  for square_index = 1, square_count do
  	update_square(squares[square_index], dt)
  end
end

function update_player(player, dt)

  no_y_acceleration = true
  if love.keyboard.isDown("up") then
  	no_y_acceleration = false
  	player.y_velocity = player.y_velocity - player.y_acceleration * dt;
  	if player.y_velocity < -player.max_y_velocity then
  	  player.y_velocity = -player.max_y_velocity
  	end
  end

  if love.keyboard.isDown("down") then
  	no_y_acceleration = false
    player.y_velocity = player.y_velocity + player.y_acceleration * dt;
  	if player.y_velocity > player.max_y_velocity then
  	  player.y_velocity = player.max_y_velocity
  	end
  end

  no_x_acceleration = true
  if love.keyboard.isDown("left") then
  	no_x_acceleration = false
  	player.x_velocity = player.x_velocity - player.x_acceleration * dt;
  	if player.x_velocity < -player.max_x_velocity then
  	  player.x_velocity = -player.max_x_velocity
  	end
  end

  if love.keyboard.isDown("right") then
  	no_x_acceleration = false
  	player.x_velocity = player.x_velocity + player.x_acceleration * dt;
  	if player.x_velocity > player.max_x_velocity then
  	  player.x_velocity = player.max_x_velocity
  	end
  end

  if no_x_acceleration and player.x_velocity ~= 0 then
    if player.x_velocity > 1 then
  	  player.x_velocity = player.x_velocity - player.x_acceleration * dt
    elseif player.x_velocity < -1 then
      player.x_velocity = player.x_velocity + player.x_acceleration * dt
    else
      player.x_velocity = 0
    end
  end

  if no_y_acceleration and player.y_velocity ~= 0 then
    if player.y_velocity > 1 then
  	  player.y_velocity = player.y_velocity - player.y_acceleration * dt
    elseif player.y_velocity < -1 then
      player.y_velocity = player.y_velocity + player.y_acceleration * dt
    else
      player.y_velocity = 0
    end
  end

  last_player_x = player.x
  player.x = player.x + player.x_velocity * dt
  if player.x > globalSettings.maxWidth - 50 or player.x < 50 then
    player.x = last_player_x
  end

  last_player_y = player.y
  player.y = player.y + player.y_velocity * dt
  if player.y > globalSettings.maxHeight - 50 or player.y < 50 then
    player.y = last_player_y
  end

  if love.keyboard.isDown("escape", "q") then
  	love.window.close()
  end
end