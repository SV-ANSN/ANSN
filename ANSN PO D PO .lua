local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua"))()

local RS = game:GetService("ReplicatedStorage")
local remote = RS:WaitForChild("Packets"):WaitForChild("Packet"):WaitForChild("RemoteEvent")

local PO = { buffer.fromstring("\000\000\000\000") }
local SellAll = { buffer.fromstring("\003\000") }

local poOn = false
local sellOn = false

local function fire(args)
    pcall(function()
        remote:FireServer(table.unpack(args))
    end)
end

local Window = WindUI:CreateWindow({
    Title = "ANSN PO大PO",
    Icon = "sparkles",
    Author = "无名",
    Folder = "ANSN",
    Size = UDim2.fromOffset(400, 400),
    Theme = "Pink",
    HideSearchBar = false,
})

local TimeTag = Window:Tag({ Title = "00:00", Color = Color3.fromRGB(255,255,255) })
task.spawn(function()
    while true do
        local t = os.date("*t")
        TimeTag:SetTitle(string.format("%02d:%02d", t.hour, t.min))
        TimeTag:SetColor(Color3.fromHSV((os.clock()*0.02)%1, 1, 1))
        task.wait(0.06)
    end
end)

Window:Tag({ Title = "ANSN", Color = Color3.fromHex("#7FDBFF") })

Window:EditOpenButton({
    Title = "ANSN",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

local Main = Window:Tab({ Title = "主页", Icon = "home" })

Main:Section({ Title = "PO大PO" })
Main:Paragraph({ Title = "PO大PO 循环", Desc = "每 0.5 秒触发一次" })

Main:Toggle({
    Title = "PO大PO 自动",
    Default = false,
    Callback = function(v)
        poOn = v
        if v then
            task.spawn(function()
                while poOn do
                    fire(PO)
                    task.wait(0.5)
                end
            end)
            WindUI:Notify({ Title = "PO大PO", Content = "已开启", Duration = 2 })
        else
            WindUI:Notify({ Title = "PO大PO", Content = "已关闭", Duration = 2 })
        end
    end
})

Main:Button({
    Title = "PO大PO 单次",
    Callback = function()
        fire(PO)
        WindUI:Notify({ Title = "PO大PO", Content = "已触发", Duration = 1 })
    end
})

Main:Section({ Title = "全部出售" })
Main:Paragraph({ Title = "全部出售", Desc = "参数 \\003\\000" })

Main:Button({
    Title = "出售一次",
    Callback = function()
        fire(SellAll)
        WindUI:Notify({ Title = "出售", Content = "已出售", Duration = 1 })
    end
})

Main:Toggle({
    Title = "自动出售",
    Default = false,
    Callback = function(v)
        sellOn = v
        if v then
            task.spawn(function()
                while sellOn do
                    fire(SellAll)
                    task.wait(0.5)
                end
            end)
            WindUI:Notify({ Title = "出售", Content = "自动出售开启", Duration = 2 })
        else
            WindUI:Notify({ Title = "出售", Content = "自动出售关闭", Duration = 2 })
        end
    end
})

WindUI:Notify({ Title = "ANSN", Content = "脚本加载完成", Duration = 3 })