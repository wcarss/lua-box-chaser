global_settings = {}
global_state = {
  game_state = "loading",
  active_enemies = 3,
  active_collectables = 10,
}

function love.load()
  math.randomseed(os.time())
  love.window.setFullscreen(true)
  global_settings.max_width, global_settings.max_height, _ = love.window.getMode()
  global_state.player = {
    x = 100,
    y = 100,
    width = 40,
    height = 40,
    angle = 0,
    xr = 4,
    yr = 4,
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
    update = update_player,
    draw = draw_square,
  }
  global_state.enemies = create_enemies(global_state.active_enemies)
  global_state.collectables = create_collectables(global_state.active_collectables)
  global_state.game_state = "running"
  global_state.win_screen = {
    x = 0,
    y = 0,
    width = global_settings.max_width,
    height = global_settings.max_height,
    r = 0,
    g = 0.8,
    b = 0.15,
    update = function(win_screen, dt)
      if love.keyboard.isDown("escape", "q") then
        love.window.close()
      end
    end,
    draw = function(self)
      love.graphics.setColor(self.r, self.g, self.b)
      love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      love.graphics.setColor(0, 0, 0)

      love.graphics.setFont(global_state.big_font)
      love.graphics.print("you win!", self.width/2 - 80, self.height/2 - 40)
      love.graphics.setFont(global_state.small_font)
      love.graphics.print("press q to exit", self.width/ 2 - 50, self.height/2 + 40)
    end,
  }
  global_state.lose_screen = {
    x = 0,
    y = 0,
    width = global_settings.max_width,
    height = global_settings.max_height,
    r = 0.8,
    g = 0,
    b = 0.15,
    update = function(lose_screen, dt)
      if love.keyboard.isDown("escape", "q") then
        love.window.close()
      end
    end,
    draw = function(self)
      love.graphics.setColor(self.r, self.g, self.b)
      love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      love.graphics.setColor(0, 0, 0)

      love.graphics.setFont(global_state.big_font)
      love.graphics.print("you lost", self.width/2 - 80, self.height/2 - 40)
      love.graphics.setFont(global_state.small_font)
      love.graphics.print("press q to exit", self.width/2 - 50, self.height/2 + 40)
    end,
  }
  global_state.error_screen = {
    x = 0,
    y = 0,
    width = global_settings.max_width,
    height = global_settings.max_height,
    r = 1,
    g = 1,
    b = 1,
    update = function(error_screen, dt)
      if love.keyboard.isDown("escape", "q") then
        love.window.close()
      end
    end,
    draw = function(self)
      love.graphics.setColor(self.r, self.g, self.b)
      love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      love.graphics.setColor(0, 0, 0)

      love.graphics.setFont(global_state.big_font)
      love.graphics.print("error", self.width/2 - 60, self.height/2 - 40)
      love.graphics.setFont(global_state.small_font)
      love.graphics.print("press q to exit", self.width/2 - 50, self.height/2 + 40)
    end,
  }
  global_state.big_font = love.graphics.newFont(36)
  global_state.small_font = love.graphics.newFont(12)
end

function create_entities(count, overwrites)
  local entities = {}
  for entity_index = 1, count do
    entities[entity_index] = {
      active = true,
      x = math.random(100, global_settings.max_width),
      y = math.random(100, global_settings.max_height),
      width = 14,
      height = 14,
      angle = 0,
      xr = 8,
      yr = 8,
      r = 0.5,
      g = 0.5,
      b = 0.5,
      x_dir = 1,
      x_speed = math.random(1,8)*14,
      y_dir = 1,
      y_speed = math.random(1,8)*14,
      draw = draw_square,
    }
    for k, v in pairs(overwrites) do
      entities[entity_index][k] = v
    end
  end

  return entities
end

function create_collectables(count)
  return create_entities(count, {
    xr = 4,
    yr = 4,
    r = 0.95,
    g = 0.85,
    b = 0.05,
    update = update_collectable,
  })
end

function create_enemies(count)
  return create_entities(count, {
    r = 1,
    g = 0,
    b = 0,
    x_speed = 200,
    y_speed = 200,
    update = update_enemy,
    width = 60,
    height = 60,
  })
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
  return ((
    (o1_left > o2_left and o1_left < o2_right) or
    (o1_right > o2_left and o1_right < o2_right)
  ) and (
    (o1_top > o2_top and o1_top < o2_bottom) or
    (o1_bottom > o2_top and o1_bottom < o2_bottom)
  )) or ((
    (o2_left > o1_left and o2_left < o1_right) or
    (o2_right > o1_left and o2_right < o1_right)
  ) and (
    (o2_top > o1_top and o2_top < o1_bottom) or
    (o2_bottom > o1_top and o2_bottom < o1_bottom)
  ))
end

function draw_square(square)
  if square.active == false then
    return
  end

  love.graphics.push()
  love.graphics.translate(square.x, square.y)
  love.graphics.rotate(square.angle)
  love.graphics.setColor(square.r, square.g, square.b)
  love.graphics.rectangle("fill", -square.width/2, -square.height/2, square.width, square.height, square.xr, square.yr) -- origin in the middle
  love.graphics.pop()
end

function update_enemy(square, dt)
  if square.active == false then
    return
  end

  square.angle = square.angle + 0.1

  -- give a little breathing room
  if math.random(1,20) == 1 then
    return
  end

  local player = global_state.player
  if player.x < square.x then
    square.x_dir = -1
  else
    square.x_dir = 1
  end

  if player.y < square.y then
    square.y_dir = -1
  else
    square.y_dir = 1
  end

  -- give a little breathing room
  if math.random(1,20) == 1 then
    square.x_dir = square.x_dir * -1
  end
  -- give a little breathing room
  if math.random(1,20) == 1 then
    square.y_dir = square.y_dir * -1
  end

  square.x = square.x + square.x_dir * square.x_speed * dt
  square.y = square.y + square.y_dir * square.y_speed * dt

  if rect_collide(square, global_state.player) then
    player.active = false
    global_state.game_state = "lose"
  end
end

function update_collectable(square, dt)
  if square.active == false then
    return
  end

  square.angle = square.angle + 0.1
  if square.x > global_settings.max_width - 50 then
    square.x_dir = -1;
  elseif square.x < 50 then
    square.x_dir = 1;
  end
  square.x = square.x + square.x_dir * square.x_speed * dt

  if square.y > global_settings.max_height - 50 then
    square.y_dir = -1;
  elseif square.y < 50 then
    square.y_dir = 1;
  end
  square.y = square.y + square.y_dir * square.y_speed * dt

  if rect_collide(square, global_state.player) then
    square.active = false
    global_state.active_collectables = global_state.active_collectables - 1
  end
end

function love.draw()
  if global_state.game_state == "win" then
    global_state.win_screen.draw(global_state.win_screen)
  elseif global_state.game_state == "lose" then
    global_state.lose_screen.draw(global_state.lose_screen)
  elseif global_state.game_state == "running" then
    for collectable_index = 1, #global_state.collectables do
      local elem = global_state.collectables[collectable_index]
      elem.draw(elem)
    end
    for enemy_index = 1, #global_state.enemies do
      local elem = global_state.enemies[enemy_index]
      elem.draw(elem)
    end
    global_state.player.draw(global_state.player)
  else
    global_state.error_screen.draw(global_state.error_screen)
  end
end

function love.update(dt)
  if global_state.game_state == "running" then
    for collectable_index = 1, #global_state.collectables do
      local elem = global_state.collectables[collectable_index]
      elem.update(elem, dt)
    end
    for enemy_index = 1, #global_state.enemies do
      local elem = global_state.enemies[enemy_index]
      elem.update(elem, dt)
    end
    global_state.player.update(global_state.player, dt)

    if global_state.active_collectables == 0 then
      global_state.game_state = "win"
    elseif global_state.active_enemies == 0 then
      global_state.game_state = "lose"
    end
  elseif global_state.game_state == "win" then
    global_state.win_screen.update(global_state.win_screen, dt)
  elseif global_state.game_state == "lose" then
    global_state.lose_screen.update(global_state.lose_screen, dt)
  else
    global_state.error_screen.update(global_state.error_screen, dt)
  end
end

function update_player(player, dt)
  if player.active == false then
    return
  end

  local no_y_acceleration = true
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

  local no_x_acceleration = true
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

  local last_player_x = player.x
  player.x = player.x + player.x_velocity * dt
  if player.x > global_settings.max_width - 50 or player.x < 50 then
    player.x = last_player_x
  end

  local last_player_y = player.y
  player.y = player.y + player.y_velocity * dt
  if player.y > global_settings.max_height - 50 or player.y < 50 then
    player.y = last_player_y
  end
end

-- useful as an update method, for debugging motion and collision:
function be_still(square, dt)
  if square.active == false then
    return
  end

  if rect_collide(square, global_state.player) then
    square.active = false
    global_state.active_collectables = global_state.active_collectables - 1
  end
end