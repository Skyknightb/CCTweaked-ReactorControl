local reactor = peripheral.wrap("back")
local mon = peripheral.wrap("right")

-- Ensure the monitor was wrapped correctly
if not mon then
    print("Monitor not found!")
    return
end

-- Function to get the dimensions of the monitor
local function getMonitorSize()
    local width, height = mon.getSize()
    return width, height
end

-- Function to draw a centered title with a blue background bar
local function drawCenteredTitleWithBar(title, y, width)
    local barHeight = 3 -- Height of the blue bar
    local titleY = y + math.floor(barHeight / 2)

    -- Draw the blue bar
    mon.setBackgroundColor(colors.blue)
    for i = 0, barHeight - 1 do
        mon.setCursorPos(1, y + i)
        mon.clearLine()
    end

    -- Draw the title
    mon.setCursorPos(math.ceil((width - #title) / 2), titleY)
    mon.setTextColor(colors.white)  -- Title text color
    mon.write(title)

    -- Reset background color
    mon.setBackgroundColor(colors.black)
end

-- Function to draw a colored bar based on fuel percentage
local function drawColorBar(x, y, length, percentage)
    local color
    if percentage > 75 then
        color = colors.green
    elseif percentage > 25 then
        color = colors.yellow
    else
        color = colors.red
    end

    mon.setBackgroundColor(color)
    mon.setCursorPos(x, y)
    mon.write(string.rep(" ", length))

    mon.setBackgroundColor(colors.black)
end

-- Function to draw the reactor status GUI
local function drawReactorStatus()
    local width, height = getMonitorSize()
    mon.clear()

    -- Draw the main title with a blue bar
    local title = "Reactor Status"
    drawCenteredTitleWithBar(title, 1, width)

    -- Draw Fuel Data
    mon.setCursorPos(2, 5) -- Adjusted Y position
    mon.setTextColor(colors.white)
    mon.write("Fuel Data")

    local fuelData = reactor.fuelTank()
    local fuelAmount = fuelData.fuel() or 0
    local maxFuel = fuelData.capacity() or 1
    local fuelPercentage = (fuelAmount / maxFuel) * 100
    local fuelBarLength = width - 4

    drawColorBar(2, 6, fuelBarLength, fuelPercentage)
    mon.setCursorPos(2, 7)
    mon.write(string.format("Fuel: %.1f%%", fuelPercentage))

    local fuelTemperature = reactor.fuelTemperature() or 0
    local stackTemperature = reactor.stackTemperature() or 0

    mon.setCursorPos(2, 8)
    mon.write(string.format("Fuel Temp: %.1f C", fuelTemperature))
    mon.setCursorPos(2, 9)
    mon.write(string.format("Stack Temp: %.1f C", stackTemperature))

    -- Draw horizontal separator line
    mon.setCursorPos(2, 10)
    mon.write(string.rep("-", width - 2))

    -- Draw Battery Data
    mon.setCursorPos(2, 11)
    mon.write("Battery Data")

    local batteryData = reactor.battery()
    local capacity = batteryData.capacity() and batteryData.capacity() or "N/A"
    local stored = batteryData.stored() and batteryData.stored() or "N/A"
    local producedLastTick = batteryData.producedLastTick() and batteryData.producedLastTick() or "N/A"

    mon.setCursorPos(2, 12)
    mon.write("Capacity: " .. capacity .. " RF")
    mon.setCursorPos(2, 13)
    mon.write("Stored: " .. stored .. " RF")
    mon.setCursorPos(2, 14)
    mon.write("Produced: " .. producedLastTick .. " RF/t")

    -- Draw Copyright Note
    mon.setCursorPos(2, height - 1)
    mon.setTextColor(colors.blue)
    mon.write("Made by Skyknightb")
end

-- Main loop to continually update the screen
while true do
    drawReactorStatus()
    sleep(1) -- Update every second
end
