Button = Textbox:extend()

function Button:new(text, x, y, width, height, font)
    Button.super.new(self, text, x, y, width, height, font)
    self.now = love.mouse.isDown(1)
end

function Button:update(mouse_x, mouse_y, fn)
    local last = self.now
    self.now = love.mouse.isDown(1)
    if self.now and not last then
        if mouse_x > self.x and mouse_x < self.x + self.width and mouse_y > self.y and mouse_y < self.y + self.height then
            fn()
        end
    end
end

function Button:draw()
    love.graphics.setColor(0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(self.text, self.x + self.width / 2 - self.font:getWidth(self.text) / 2, self.y + self.height / 2 - self.font:getHeight() / 2)
end