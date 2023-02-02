Player = Entity:extend()

function Player:new(x, y, size, speed, image, angle, health)
    self.super.new(self, x, y, size, speed, image, angle)
    self.maxHealth = health
    self.health = health
end

function Player:update(dt)
    self.super.update(self, dt)

    if love.keyboard.isDown("a") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("d") then
        self.x = self.x + self.speed * dt
    end

    if love.keyboard.isDown("w") then
        self.y = self.y - self.speed * dt
    elseif love.keyboard.isDown("s") then
        self.y = self.y + self.speed * dt
    end
end

function Player:draw()
    self.super.draw(self)

    love.graphics.setColor(1, 1, 1, 1)
    if self.image then
        if math.abs(self.angle) < math.pi / 2 then
            love.graphics.draw(self.image, self.x, self.y, 0, 1/4, 1/4, self.image:getWidth() / 2, self.image:getHeight() / 2)
        else
            love.graphics.draw(self.image, self.x, self.y, 0, -1/4, 1/4, self.image:getWidth() / 2, self.image:getHeight() / 2)
        end
    end
end