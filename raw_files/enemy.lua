Enemy = Entity:extend()

function Enemy:new(x, y, size, speed, image, angle, health, damage)
    self.super.new(self, x, y, size, speed, image, angle)
    self.health = health
    self.damage = damage
end

function Enemy:update(dt)
    self.super.update(self, dt)

    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt
end

function Enemy:draw()
    self.super.draw(self)

    love.graphics.setColor(1, 1, 1, 1)
    if self.image then
        if math.abs(self.angle) < math.pi / 2 then
            love.graphics.draw(self.image, self.x, self.y, 0, 1/6, 1/6, self.image:getWidth() / 2, self.image:getHeight() / 2)
        else
            love.graphics.draw(self.image, self.x, self.y, 0, -1/6, 1/6, self.image:getWidth() / 2, self.image:getHeight() / 2)
        end
    end
end

function Enemy:entityCollision(entity)
    if math.sqrt((self.x - entity.x)^2 + (self.y - entity.y)^2) < self.size + entity.size then
        if not entity:is(Bullet) then
            self.x = self.last_x
            self.y = self.last_y
        end

        return true
    end

    return false
end