-- =====================================================
-- PO大PO + 全部出售
-- =====================================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua"))()

local RS = game:GetService("ReplicatedStorage")
local Remote = RS:WaitForChild("Packets"):WaitForChild("Packet"):WaitForChild("RemoteEvent")

-- ============ 状态 ============
local poInterval = 0.5
local sellInterval = 0.5
local poRunning = false
local sellRunning = false

-- ============ 发送函数 ============
local function firePO()
    pcall(function()
        Remote:FireServer(buffer.fromstring("\000\000\000\000"))
    end)
end

local function fireSell()
    pcall(function()
        Remote:FireServer(buffer.fromstring("\003\000"))
    end)
end

local function startPOLoop()
    if poRunning then return end
    poRunning = true
    task.spawn(function()
        while poRunning do
            firePO()
            task.wait(poInterval)
        end
    end)
end

local function stopPOLoop() poRunning = false end

local function startSellLoop()
    if sellRunning then return end
    sellRunning = true
    task.spawn(function()
        while sellRunning do
            fireSell()
            task.wait(sellInterval)
        end
    end)
end

local function stopSellLoop() sellRunning = false end

-- ============ UI ============
local Window = WindUI:CreateWindow({
    Title = "ANSN PO 面板",
    Icon = "zap",
    Author = "ANSN",
    Folder = "ANSN_PO",
    Size = UDim2.fromOffset(360, 460),
    Theme = "Pink",
})

Window:Tag({ Title = "PO", Color = Color3.fromHex("#FF6B6B") })
Window:Tag({ Title = "Sell", Color = Color3.fromHex("#7FDBFF") })

Window:EditOpenButton({
    Title = "ANSN PO",
    Icon = "zap",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

local function notify(t, c) WindUI:Notify({ Title = t, Content = c, Duration = 2 }) end

-- ============ Tab: PO大PO ============
local TabPO = Window:Tab({ Title = "PO大PO", Icon = "zap" })

TabPO:Section({ Title = "PO大PO" })
TabPO:Paragraph({
    Title = "参数",
    Desc = "buffer \\000\\000\\000\\000"
})

TabPO:Toggle({
    Title = "自动循环 PO",
    Default = false,
    Callback = function(v)
        if v then startPOLoop() else stopPOLoop() end
    end,
})

TabPO:Button({
    Title = "单次触发",
    Callback = function()
        firePO()
        notify("PO", "已触发")
    end,
})

TabPO:Input({
    Title = "间隔（秒）",
    Placeholder = "0.5",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            poInterval = n
            notify("PO", "间隔 = " .. n .. "s")
        end
    end,
})

TabPO:Button({ Title = "0.1 秒", Callback = function() poInterval = 0.1; notify("PO", "0.1s") end })
TabPO:Button({ Title = "0.5 秒", Callback = function() poInterval = 0.5; notify("PO", "0.5s") end })
TabPO:Button({ Title = "1 秒", Callback = function() poInterval = 1; notify("PO", "1s") end })

-- ============ Tab: 全部出售 ============
local TabSell = Window:Tab({ Title = "全部出售", Icon = "shopping-cart" })

TabSell:Section({ Title = "全部出售" })
TabSell:Paragraph({
    Title = "参数",
    Desc = "buffer \\003\\000"
})

TabSell:Toggle({
    Title = "自动循环 出售",
    Default = false,
    Callback = function(v)
        if v then startSellLoop() else stopSellLoop() end
    end,
})

TabSell:Button({
    Title = "单次出售",
    Callback = function()
        fireSell()
        notify("出售", "已触发")
    end,
})

TabSell:Input({
    Title = "间隔（秒）",
    Placeholder = "0.5",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            sellInterval = n
            notify("出售", "间隔 = " .. n .. "s")
        end
    end,
})

TabSell:Button({ Title = "0.1 秒", Callback = function() sellInterval = 0.1; notify("出售", "0.1s") end })
TabSell:Button({ Title = "0.5 秒", Callback = function() sellInterval = 0.5; notify("出售", "0.5s") end })
TabSell:Button({ Title = "1 秒", Callback = function() sellInterval = 1; notify("出售", "1s") end })

TabSell:Section({ Title = "一键" })

TabSell:Button({
    Title = "⚡ PO + 出售 同时开",
    Callback = function()
        startPOLoop()
        startSellLoop()
        notify("一键", "PO + 出售 已开启")
    end,
})

TabSell:Button({
    Title = "🛑 全部停止",
    Callback = function()
        stopPOLoop()
        stopSellLoop()
        notify("一键", "全部停止")
    end,
})

WindUI:Notify({
    Title = "ANSN PO 面板已加载",
    Content = "PO大PO + 全部出售",
    Duration = 4,
})
