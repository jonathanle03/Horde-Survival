Bullet = Entity:extend()

function Bullet:new(x, y, size, speed, image, angle, damage)
    self.super.new(self, x, y, size, speed, image, angle)
    self.damage = damage
end

function Bullet:update(dt)
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt

    self:wallCollision(mapSize)
end

function Bullet:draw()
    self.super.draw(self)

    love.graphics.setColor(1, 1, 1, 1)
    if self.image then
        love.graphics.draw(self.image, self.x, self.y, 0, 1/3, 1/3, self.image:getWidth() / 2, self.image:getHeight() / 2)
    end
end

function Bullet:wallCollision(mapSize)
    if self.x - self.size < -mapSize / 2 or self.x + self.size > mapSize / 2 or self.y - self.size < -mapSize / 2 or self.y + self.size > mapSize / 2 then
        return true
    end

    return false
end