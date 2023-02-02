Textbox = Object:extend()

function Textbox:new(text, x, y, width, height, font)
    self.text = text
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.font = font
end

function Textbox:draw()
    love.graphics.setColor(0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    local margin = self.height / 2 - self.font:getHeight() / 2
    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(self.text, self.x + margin, self.y + margin)
end