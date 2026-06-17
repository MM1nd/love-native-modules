local hello = require("hello")
local message = hello.message()
local sum = hello.add(20, 22)

print(message)
print("20 + 22 = " .. tostring(sum))

function love.draw()
	love.graphics.print(message, 20, 20)
	love.graphics.print("20 + 22 = " .. tostring(sum), 20, 44)
end
