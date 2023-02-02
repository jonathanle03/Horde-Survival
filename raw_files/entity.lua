Entity = Object:extend()

function Entity:new(x, y, size, speed, image, angle)
    self.x = x
    self.y = y
    self.size = size
    self.speed = speed
    self.angle = angle

    if love.filesystem.getInfo(image) then
        self.image = love.graphics.newImage(image)
    end

    self.last_x = x
    self.last_y = y
end

function Entity:update(dt)
    self.last_x = self.x
    self.last_y = self.y
end

function Entity:draw()
    love.graphics.setColor(1, 1, 1, 0)
    love.graphics.circle("fill", self.x, self.y, self.size) -- collision check
end

function Entity:wallCollision(mapSize)
    if self.x - self.size < -mapSize / 2 or self.x + self.size > mapSize / 2 then
        self.x = self.last_x
    end

    if self.y - self.size < -mapSize / 2 or self.y + self.size > mapSize / 2 then
        self.y = self.last_y
    end

    return false
end