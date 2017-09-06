debug = false

createEnemy1TimerMax = 1
createEnemy1Timer = createEnemy1TimerMax

createPowerupTimerMax = math.random(20,60)
createPowerupTimer = createPowerupTimerMax

canShoot = true
canShootTimerMax = 0.6
canShootTimer = canShootTimerMax

player = { x = 200, y = 710, img = nil }
bullets = {}
enemies = {}
scene = { x = 0, y = 0, img = nil}
scenes = {}
cloud = { x = 0, y = 0, img = nil}
clouds = {}
isAlive = true
score = 0
best = 0
explosionTime = 0
powerups = {}
poweruped1 = 0
poweruped2 = 0
poweruped3 = 0
playerSpeed = 150
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
		return 	x1 < x2+w2 and
				x2 < x1+w1 and
				y1 < y2+h2 and
				y2 < y1+h1
end
	
function love.load(arg)
	scene.img = love.graphics.newImage('assets/water_texture.jpg')
	cloud.img = love.graphics.newImage('assets/clouds.png')
	player.Img = love.graphics.newImage('assets/Aircraft_03.png')
	bulletImg = love.graphics.newImage('assets/bullet_2_blue.png')
	enemyImg = love.graphics.newImage('assets/Aircraft_02.png')
	explosion = love.graphics.newImage('assets/exp.png')
	powerupImg1 = love.graphics.newImage('assets/powerupimg1.png')
	powerupImg2 = love.graphics.newImage('assets/powerupimg2.png')
	powerupImg3 = love.graphics.newImage('assets/powerupimg3.png')
	pow = love.audio.newSource('sounds/Powerup.ogg', 'static')
	hit = love.audio.newSource('sounds/Explosion.ogg', 'static')
	hit:setVolume(0.1)
	hit:setPitch(2)
	boom = love.audio.newSource('sounds/Explosion1.ogg', 'static')
	boom:setVolume(0.2)
	pew = love.audio.newSource('sounds/Laser_Shoot4.wav', 'static')
	pew:setVolume(0.1)
	pew:setPitch(1)
	theme = love.audio.newSource('sounds/theme.mp3')
	theme:setVolume(0.05)
end

function love.update(dt)

	if next(scenes) == nil then
		newScene = {x = scene.x , y = -scene.img:getHeight(), img = scene.img}
		table.insert(scenes, newScene)
		newScene = {x = scene.x , y = 0, img = scene.img}
		table.insert(scenes, newScene)
	end
	for i, scene in ipairs(scenes) do
		scene.y = (scene.y + (30*dt))
		if scene.y > love.graphics.getHeight() then
			table.remove(scenes, i)
			newScene = {x = scene.x , y = (2+(love.graphics.getHeight()-(2 * scene.img:getHeight()))), img = scene.img}
			table.insert(scenes, newScene)
		end
	end
	
	if next(clouds) == nil then
		newCloud = {x = cloud.x , y = -cloud.img:getHeight(), img = cloud.img, i = 0}
		table.insert(clouds, newCloud)
		newCloud = {x = cloud.x , y = -120, img = cloud.img, i = 0}
		table.insert(clouds, newCloud)
	end
	for i, cloud in ipairs(clouds) do
		cloud.y = (cloud.y + (100*dt))
		if cloud.y > love.graphics.getHeight() then
			table.remove(clouds, i)
			newCloud = {x = cloud.x , y = -cloud.img:getHeight(), img = cloud.img, i = 0}
			table.insert(clouds, newCloud)
		end
	end
	
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	if isAlive then
		if love.keyboard.isDown('up','w') then
			if player.y > (love.graphics.getHeight()/2) then
				player.y = player.y - (playerSpeed*dt)
			end
		end
		if love.keyboard.isDown('down','s') then
			if player.y < (love.graphics.getHeight()-player.Img:getHeight()) then
				player.y = player.y + (playerSpeed*dt)
			end
		end
		if love.keyboard.isDown('left','a') then
			if player.x > 0 then
				player.x = player.x - (playerSpeed*dt)
			end
		elseif love.keyboard.isDown('right','d') then
			if player.x < (love.graphics.getWidth() - player.Img:getWidth()) then
				player.x = player.x + (playerSpeed*dt)
			end
		end
		if love.keyboard.isDown('space') and canShoot then
			pew:play()
			newBullet = {x = player.x + (player.Img:getWidth()/2), y = player.y, img = bulletImg}
			table.insert(bullets, newBullet)
			canShoot = false
			canShootTimer = canShootTimerMax
		end
		if shootRow then
			posy = player.y
			posx = 10
			for posx = 10, (love.graphics.getWidth() - 10),10
			do
				newBullet = {x = posx , y = posy, img = bulletImg}
				table.insert(bullets, newBullet)
				posy = posy - 1
			end
			shootRow = false
		end
		--Wrog podstawowy
		createEnemy1Timer = createEnemy1Timer - (1 * dt)
		if createEnemy1Timer < 0 then
			createEnemy1Timer = createEnemy1TimerMax	
			randomNumber = math.random(10, love.graphics.getWidth() - enemyImg:getWidth())
			newEnemy = { x = randomNumber, y = -enemyImg:getHeight(), img = enemyImg }
			table.insert(enemies, newEnemy)
		end
		
		--Powerupy
		createPowerupTimer = createPowerupTimer - (1 * dt)
		if createPowerupTimer < 0 then
			createPowerupTimer = createPowerupTimerMax
			randomNumber = math.random(10, love.graphics.getWidth() - powerupImg1:getWidth())
			powerType = math.random(1,3)
			if powerType == 1 then
				newPowerup = { x = randomNumber, y = -powerupImg1:getHeight(), img = powerupImg1, e = 1}
			elseif powerType == 2 then
				newPowerup = { x = randomNumber, y = -powerupImg2:getHeight(), img = powerupImg2, e = 2}
			elseif powerType == 3 then
				newPowerup = { x = randomNumber, y = -powerupImg3:getHeight(), img = powerupImg3, e = 3}
			end
			table.insert(powerups, newPowerup)
		end
	end
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end
	
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)
		if bullet.y < 0 then
			table.remove(bullets, i)
		end
	end
	
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)
		if enemy.y > 850 then
			table.remove(enemies, i)
			if isAlive == true then
				score = score - 1
			end
		end
	end
	
	for i, powerup in ipairs(powerups) do
		powerup.y = powerup.y + (400 * dt)
		if CheckCollision(powerup.x, powerup.y, powerup.img:getWidth(), powerup.img:getHeight(), player.x, player.y, player.Img:getWidth(), player.Img:getHeight()) 
		and isAlive then
			table.remove(powerups, i)
			pow:play()
			if powerup.e == 1 then
				poweruped1 = 10
			elseif powerup.e == 2 then
				poweruped2 = 10
			elseif powerup.e == 3 then
				shootRow = true
			end
		end
		if powerup.y > love.graphics.getHeight() then
			table.remove(powerups, i)
		end
	end
	if poweruped1 > 0 then 
		poweruped1 = poweruped1 - (1*dt)
		canShootTimerMax = 0.1
		theme:setPitch(1.25)
	elseif poweruped2 > 0 then
		poweruped2 = poweruped2 - (1*dt)
		playerSpeed = 450 
		theme:setPitch(1.25)
	else
		canShootTimerMax = 0.6
		playerSpeed = 150
		theme:setPitch(1)
	end
	if isAlive == true then
		for i, enemy in ipairs(enemies) do
			for j, bullet in ipairs(bullets) do
				if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
					table.remove(bullets, j)
					table.remove(enemies, i)
					score = score + 1
					hit:play()
					if score > best then
						best = score
					end
				end
			end

			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.Img:getWidth(), player.Img:getHeight()) 
				and isAlive then
					table.remove(enemies, i)
					isAlive = false
					explosionTime = 1
					boom:play()
			end
		end
	end
	if not isAlive and love.keyboard.isDown('r') then
		bullets = {}
		enemies = {}
	
		canShootTimer = canShootTimerMax
		createEnemy1Timer = createEnemy1TimerMax
	
		player.x = ((love.graphics.getWidth() / 2)-(player.Img:getWidth() / 2))
		player.y = 710
	
		score = 0
		isAlive = true
	end
	if explosionTime > 0 then 
		explosionTime = explosionTime - (1*dt)
	end
	numSources = love.audio.getSourceCount()
	if numSources == 0 then
		theme:play()
	end
end
function love.draw(dt)

	for i, scene in ipairs(scenes) do
		love.graphics.draw(scene.img, scene.x, scene.y)
	end
	
	for i, cloud in ipairs(clouds) do
		love.graphics.draw(cloud.img, cloud.x, cloud.y)
	end
	
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end
	
	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end
	
	for i, powerup in ipairs(powerups) do
		love.graphics.draw(powerup.img, powerup.x, powerup.y)
	end
	
	if isAlive then
		love.graphics.draw(player.Img, player.x, player.y)
	else
		if explosionTime > 0 then
			love.graphics.draw(explosion, (player.x-25), (player.y-explosion:getHeight()/2))
		end
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("SCORE: " .. tostring(score), 400, 10)
	love.graphics.print("BEST: " .. tostring(best), 10, 10)
end
