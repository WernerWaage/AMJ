-- =================================================== LOAD (Start) ===========================================================
function love.load()
 ---- Global variables:
  love.physics.setMeter(64) --Height of a meter in world 64px
  world = love.physics.newWorld(0, 6.0*64, true) --create a world for the bodies to exist hor/vert grav
  meWidth = 800
  meHeight = 600
  stime = 0 -- keypress cooldown
    jtime = 0 -- keypress cooldown jump
  objects = {} -- table to hold all our physical objects
  users = {} -- cannonballs, arrows etc..
	resetcooldown = love.timer.getTime()
	stimes = love.timer.getMicroTime()
   alive = true
  contX = -200 -- text offset
  contY = -200 -- text offset
	wallthickness = 10
  text = "" 
  textsuccess = ""
  score = 0
  timeused = 0
  besttimeused = 0
  playerenergy = 100
  persisting = 0
  gamestarted = false
   
  playerspeed = 0
	playerjump = 0
  -- Load Graphics:
  gfxCannonball = love.graphics.newImage("gfx/cannonball.png")

  LoadMap(1)
	
  --initial graphics setup
  love.graphics.setBackgroundColor(200, 200, 148)
  love.graphics.setMode(meWidth, meHeight, false, true, 0)
	MapStartX = 20
	MapStartY = 30
 create_player(20,30,"Player1") -- Initialize player 1
 
-- Callback (physics)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

-- =================================================== UPDATE (Start) ===========================================================
function love.update(dt)
	world:update(dt)

	
-- Keyboard events
	if alive == true then
		  if love.keyboard.isDown(" ") then -- Jump
			Jump()
		  end
		  if love.keyboard.isDown("w") then  -- Jump
			Jump()
		  end
		  if love.keyboard.isDown("s") then
			Stop()
		  end
		  if love.keyboard.isDown("d") then -- make me a new one oy!
			Move(1)
		  end
		  if love.keyboard.isDown("a") then -- make me a new one oy!
			Move(-1)
		  end
	end
  if love.keyboard.isDown("r") then 
	Reset()
  end
  if love.keyboard.isDown("x") then 
	love.exit()
  end
end
-- =================================================== DRAW (Start) ===========================================================
function love.draw()
	-- Draw a bunch of niceties:
	love.graphics.setColor(0, 144, 0) 
 
	--love.graphics.polygon("line", objects.towerwall.body:getWorldPoints(objects.towerwall.shape:getPoints()))
	--love.graphics.polygon("line", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
	
 	for i = #objects, 1, -1 do	
		if objects[i].visible == true then
			love.graphics.setColor(objects[i].color[1], objects[i].color[2], objects[i].color[3])
			love.graphics.polygon("fill", objects[i].body:getWorldPoints(objects[i].shape:getPoints())) 
		end 
	end

	DisplayText()
	drawtime = love.timer.getTime()

  -- Can i haz loop of all items in users table plx:
	love.graphics.setColor(255, 255, 255)
	for key, player in ipairs(users) do 
		if users[key].visible == true then
			love.graphics.circle("fill", users[key].body:getX(), users[key].body:getY(), users[key].shape:getRadius())
			users[key].body:applyForce(playerspeed*0.4, 0) 
			player = love.graphics.draw(gfxCannonball, users[key].body:getX()-12, users[key].body:getY()-12, 0,1)	
		end
	end
end
-- =================================================== DRAW (end) ===========================================================


-- =================================================== FUNCTIONS ===========================================================
function Move(value)
	nowtimeo = love.timer.getMicroTime()
	if (nowtimeo - stime)>0.01 then
		if playerspeed + value <= 20  and playerspeed + value >= -20 then -- max speed +/-
			playerspeed= playerspeed + value
			stime = love.timer.getMicroTime()
		end 
	end
end
function Jump()
	nowtimej = love.timer.getMicroTime()
	if (nowtimej - jtime)>0.02 then
		if playerenergy >=1 then
			gamestarted = true
			users[1].body:applyForce(0, -100) 
			playerenergy = playerenergy -5
			jtime = love.timer.getMicroTime()
		end
	end
end
 
function Stop()
	nowtimes = love.timer.getMicroTime()
	if (nowtimes - stimes)>0.01 then
		playerspeed = 0
		x, y = users[1].body:getLinearVelocity()
		a = users[1].body:getAngularVelocity()
		if a >= 1 then
			--users[1].body:setLinearVelocity(x-1, y-1)
		 	users[1].body:setAngularVelocity(a-1)
		end
	stimes = love.timer.getMicroTime()
	end
end
 
function create_player(x, y, playername)
   local player = {}
   player.name = playername
   player.body = love.physics.newBody(world, x, y, "dynamic")
   --player.body:setMass(10)
   player.shape = love.physics.newCircleShape(10)
   player.visible = true
   player.shapetype = "fill"
   player.color= {math.random(255), math.random(255), math.random(255)}
   player.created = love.timer.getTime()
   player.fixture = love.physics.newFixture(player.body , player.shape, 1 )
   player.fixture:setRestitution(0.1) 
   player.fixture:setUserData("player")
   player.body:applyForce(0, 0)  
   table.insert(users, player)
end


function DisplayText()
	love.graphics.setColor(193, 0, 0) 
	
	if gamestarted == false then
		love.graphics.print('Space to Jump! WASD to move', 200, 50)
	end
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )) .. "\n" , 10, 10)
	love.graphics.print('Score: ' .. score, 10, 30)
	love.graphics.print('Energy: ' .. playerenergy, 10, 50)
	love.graphics.print('Speed: ' .. playerspeed, 10, 70)
	love.graphics.print(textsuccess, 300, 130)
	
	love.graphics.print('Hit this', 696, 510)
	
end

function beginContact(a, b, coll)
	-- Oh hi, nice looking object seeking similar object. You have to be good looking, please write me. Sincerely a.
    x,y = coll:getNormal()
	if a:getUserData() then
		if b:getUserData() then 
			if a:getUserData() == "goal" then
				if  b:getUserData() == "player" then
					MapGoal()
				end
			end
			
			if b:getUserData() == "player" then
				if  a:getUserData() == "goal" then
					MapGoal()
				end
			end
			-- dis cant be good:
			if a:getUserData() == "ground" then
				if  b:getUserData() == "player" then
					iDie()
				end
			end
		end
	end
end

function endContact(a, b, coll)
    persisting = 0
end

function preSolve(a, b, coll)
    if persisting == 0 then
      --  text.."\n"..a:getUserData().." touching "..b:getUserData()
    end
    persisting = persisting + 1
end

function postSolve(a, b, coll)
    
end

function MapGoal()
	textsuccess = "Yay you won! \n \n Press R to reset"
	users[1].body:setLinearVelocity(0, 0)
	users[1].body:setAngularVelocity(0)
	-- Reset()
	
end
function iDie()
	textsuccess = "U HAS HITTED THE GROWNS, U R DEDD; \n PRESS R TO UNDEADD YOURSELF!"
	alive = false
	-- Reset()
end

-- ============== MAPS:
function Reset()
	if resetcooldown+2<love.timer.getTime() then
	-- Clear items table
	--	for i = #objects, 1, -1 do	
	--		objects[i].visible = false
	--		objects[i].fixture:destroy()
	--
	--	end
	-- Reload Map
	--	LoadMap(1)
	-- Reset energy and player pos
		textsuccess = ""
		playerenergy = 100
		playerscore = 0
		playerspeed = 0 
		alive = true
		users[1].body:setLinearVelocity(0, 0)
		users[1].body:setAngularVelocity(0)
		if users[1] then
		 	users[1].body:setPosition(MapStartX,MapStartY)
		end
		resetcooldown = love.timer.getTime()
	end 
end

function LoadMap(MapID)
	MapRectangle("top",		meWidth/2,	0,							meWidth,		wallthickness,"platform")
	MapRectangle("ground",	meWidth/2,	meHeight-wallthickness/2,	meWidth,		wallthickness,"ground")
	MapRectangle("left",	0,			meHeight/2,					wallthickness,	meHeight,"platform")
	MapRectangle("right",	meWidth,	meHeight/2,					wallthickness,	meHeight,"ground")
	
	-- Map one!
	if(MapID == 1) then
		MapStartX = 20
		MapStartY = 20
		MapRectangle("M1_1",0,		90,								220,		wallthickness,"wall")
		MapRectangle("M1_2",300,	90,								100,		wallthickness,"wall")
		MapRectangle("M1_3",500,	80,								80,			wallthickness,"wall")
		MapRectangle("M1_4",600,	meHeight-wallthickness/2-100,	100,		600,"wall")			
		MapRectangle("M1_5",220,	244,							80,			80,"wall")
		
		MapRectangle("M1_5",720,	meHeight-wallthickness/2-100,						30,		30,"goal")
		
	end	
end
function MapRectangle(itemname,xstart,ystart,width,height,property)
   local newobject = {}
   newobject.name = itemname
   newobject.property = property
   newobject.visible = true
   newobject.shapetype = "line"
   newobject.color= {math.random(255), math.random(255), math.random(255)}
   newobject.body = love.physics.newBody(world, xstart, ystart, "fixed")
   newobject.shape =  love.physics.newRectangleShape(width, height) 
   newobject.fixture = love.physics.newFixture(newobject.body, newobject.shape, 1 )
   newobject.fixture:setUserData(property)
   table.insert(objects, newobject)
end
