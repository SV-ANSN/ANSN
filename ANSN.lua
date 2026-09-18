local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- 游戏 PlaceId 映射表
-- ============================================================
local GAME_MAP = {
    [4832438542] = {
        name = "VR 手 v3.2",
        path = "SV-ANSN/ANSN/refs/heads/main/PE%20VR.lua",
    },
    [16044264830] = {
        name = "刀刃球:教程",
        path = "SV-ANSN/ANSN/refs/heads/main/efsdg.lua",
    },
    [107778070777162] = {
        name = "偷一个蛋",
        path = "SV-ANSN/ANSN/refs/heads/main/偷一个蛋.lua",
    },
    [104841616983113] = {
        name = "圣奥里",
        path = "https://raw.githubusercontent.com/jdnfkf/U00pkid/main/%E5%8A%A0%E8%BD%BD%E5%99%A8.lua",
    },
    [85050171250159] = {
        name = "Po大Po",
        path = "https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/ANSN%20PO%20D%20PO%20.lua",
    },
    [80898524797320] = {
        name = "画我!",
        path = "https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/hw.lua",
    },
    [98502499119821] = {
        name = "重型钓鱼",
        path = "https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/zfzf.lua",
    },
}

-- ============================================================
-- 镜像列表
-- ============================================================
local MIRRORS = {
    "https://ghproxy.net/",
    "https://gh-proxy.com/",
    "https://cdn.jsdelivr.net/gh/",
    "https://raw.githack.com/",
    "",
}

-- 动画播放器地址（不支持服务器时的备选加载项）
local ANIM_PLAYER_URL = "https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/%E5%8A%A8%E7%94%BB%E6%92%AD%E6%94%BE%E5%99%A8.lua"

-- ============================================================
-- 工具函数
-- ============================================================
local function urlEncode(s)
    return (tostring(s):gsub("([^%w%-%.%_%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

local function encodeUrlPath(url)
    local base, path = url:match("^(https?://[^/]+)(/.*)$")
    if not base then return url end
    return base .. path:gsub("([^/]+)", function(seg)
        if seg:find("%%") then return seg end
        return urlEncode(seg)
    end)
end

local function parsePath(path)
    if path:match("^https?://") then return encodeUrlPath(path) end
    local parts = {}
    for seg in path:gmatch("[^/]+") do table.insert(parts, seg) end
    if #parts < 2 then return nil end
    local user, repo = parts[1], parts[2]
    local branch = "main"
    local filePath = ""
    if parts[3] == "refs" and parts[4] == "heads" then
        branch = parts[5] or "main"
        for i = 6, #parts do filePath = filePath .. "/" .. parts[i] end
    else
        for i = 3, #parts do filePath = filePath .. "/" .. parts[i] end
    end
    filePath = filePath:gsub("^/", "")
    return encodeUrlPath(string.format(
        "https://raw.githubusercontent.com/%s/%s/%s/%s",
        user, repo, branch, filePath))
end

local function download(rawUrl)
    for _, prefix in ipairs(MIRRORS) do
        local ok, res = pcall(game.HttpGet, game, prefix .. rawUrl)
        if ok and res and #res > 200 then
            print("[ANSN] ✅ 下载成功 (" .. (prefix ~= "" and prefix or "直连") .. ")")
            return res
        end
        task.wait(0.1)
    end
    return nil
end

local function cleanup()
    local removed = 0
    for _, g in ipairs(CoreGui:GetChildren()) do
        if g:IsA("ScreenGui") and (g.Name:find("ANSN") or g.Name:find("AUTH")) then
            g:Destroy()
            removed = removed + 1
        end
    end
    if PlayerGui then
        for _, g in ipairs(PlayerGui:GetChildren()) do
            if g:IsA("ScreenGui") and (g.Name:find("ANSN") or g.Name:find("AUTH")) then
                g:Destroy()
                removed = removed + 1
            end
        end
    end
    if removed > 0 then
        print("[ANSN] 清理旧界面 " .. removed .. " 个")
    end
end

local function showUnsupportedUI()
    local old = CoreGui:FindFirstChild("ANSN_Unsupported")
    if old then old:Destroy() end
    local old2 = PlayerGui:FindFirstChild("ANSN_Unsupported")
    if old2 then old2:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ANSN_Unsupported"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok or not gui.Parent then gui.Parent = PlayerGui end

    local dim = Instance.new("Frame")
    dim.Parent = gui
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 0.4
    dim.BorderSizePixel = 0
    dim.Size = UDim2.new(1, 0, 1, 0)

    local panel = Instance.new("Frame")
    panel.Parent = gui
    panel.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    panel.BorderSizePixel = 0
    panel.Position = UDim2.new(0.5, -180, 0.5, -135)
    panel.Size = UDim2.new(0, 360, 0, 270)
    panel.Active = true
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 12)
    pc.Parent = panel

    local bar = Instance.new("Frame")
    bar.Parent = panel
    bar.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, 0, 0, 4)
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 12)
    bc.Parent = bar

    local title = Instance.new("TextLabel")
    title.Parent = panel
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 20)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "ANSN HUB"
    title.TextColor3 = Color3.fromRGB(245, 240, 255)
    title.TextSize = 20

    local icon = Instance.new("TextLabel")
    icon.Parent = panel
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 0, 0, 55)
    icon.Size = UDim2.new(1, 0, 0, 40)
    icon.Font = Enum.Font.GothamBold
    icon.Text = "⚠"
    icon.TextColor3 = Color3.fromRGB(255, 90, 90)
    icon.TextSize = 36

    local msg1 = Instance.new("TextLabel")
    msg1.Parent = panel
    msg1.BackgroundTransparency = 1
    msg1.Position = UDim2.new(0, 0, 0, 100)
    msg1.Size = UDim2.new(1, 0, 0, 26)
    msg1.Font = Enum.Font.GothamBold
    msg1.Text = "ANSN 不支持该服务器"
    msg1.TextColor3 = Color3.fromRGB(255, 90, 90)
    msg1.TextSize = 16

    local msg2 = Instance.new("TextLabel")
    msg2.Parent = panel
    msg2.BackgroundTransparency = 1
    msg2.Position = UDim2.new(0, 20, 0, 130)
    msg2.Size = UDim2.new(1, -40, 0, 40)
    msg2.Font = Enum.Font.Gotham
    msg2.Text = string.format("当前游戏: %s\nPlaceId: %d", tostring(game.Name), game.PlaceId)
    msg2.TextColor3 = Color3.fromRGB(170, 160, 190)
    msg2.TextSize = 12
    msg2.TextWrapped = true

    -- 左按钮：取消
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Name = "CancelBtn"
    cancelBtn.Parent = panel
    cancelBtn.BackgroundColor3 = Color3.fromRGB(80, 70, 100)
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Position = UDim2.new(0, 20, 1, -60)
    cancelBtn.Size = UDim2.new(0.5, -25, 0, 40)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.Text = "取消"
    cancelBtn.TextColor3 = Color3.fromRGB(220, 215, 235)
    cancelBtn.TextSize = 14
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 8)
    cancelCorner.Parent = cancelBtn
    cancelBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- 右按钮：加载动画播放器
    local animBtn = Instance.new("TextButton")
    animBtn.Name = "AnimPlayerBtn"
    animBtn.Parent = panel
    animBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    animBtn.BorderSizePixel = 0
    animBtn.Position = UDim2.new(0.5, 5, 1, -60)
    animBtn.Size = UDim2.new(0.5, -25, 0, 40)
    animBtn.Font = Enum.Font.GothamBold
    animBtn.Text = "加载动画播放器"
    animBtn.TextColor3 = Color3.fromRGB(245, 240, 255)
    animBtn.TextSize = 14
    local animCorner = Instance.new("UICorner")
    animCorner.CornerRadius = UDim.new(0, 8)
    animCorner.Parent = animBtn
    animBtn.MouseButton1Click:Connect(function()
        print("[ANSN] 用户选择加载动画播放器...")
        gui:Destroy()
        local src = game:HttpGet(ANIM_PLAYER_URL)
        local fn, err = loadstring(src)
        if fn then
            pcall(fn)
            print("[ANSN] ✅ 动画播放器已加载")
        else
            warn("[ANSN] ❌ 动画播放器编译失败: " .. tostring(err))
        end
    end)

    print("[ANSN] 已弹出不支持提示（含动画播放器选项）")
end

local function loadScript(path)
    local raw = parsePath(path)
    if not raw then warn("[ANSN] 路径解析失败"); return false end
    print("[ANSN] 下载: " .. raw)
    local src = download(raw)
    if not src then warn("[ANSN] ❌ 所有镜像下载失败"); return false end
    print("[ANSN] 编译 " .. #src .. " 字节...")
    local fn, err = loadstring(src)
    if not fn then warn("[ANSN] ❌ 编译失败: " .. tostring(err)); return false end
    print("[ANSN] 执行...")
    local ok, runErr = pcall(fn)
    if not ok then warn("[ANSN] ❌ 运行错误: " .. tostring(runErr)); return false end
    print("[ANSN] ✅ 加载成功")
    return true
end

-- ============================================================
-- 主流程
-- ============================================================
print("===========================================")
print("[ANSN] 检测当前游戏...")
print("[ANSN] PlaceId: " .. tostring(game.PlaceId))
print("[ANSN] GameId: " .. tostring(game.GameId))
local gameInfo = GAME_MAP[game.PlaceId]
-- 竞争对手(RIVALS)用GameId匹配，覆盖所有子服
if not gameInfo and game.GameId == 6035872082 then
    gameInfo = {
        name = "竞争对手",
        path = "https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/%E7%AB%9E%E4%BA%89%E5%AF%B9%E6%89%8B.lua",
    }
end
if not gameInfo then
    warn("[ANSN] ❌ 当前游戏未注册: " .. tostring(game.PlaceId))
    print("[ANSN] 已注册的游戏:")
    for id, info in pairs(GAME_MAP) do
        print(string.format("  %d  =>  %s", id, info.name))
    end
    print("===========================================")
    showUnsupportedUI()
    return
end
print("[ANSN] ✅ 识别为: " .. gameInfo.name)
print("[ANSN] 加载路径: " .. gameInfo.path)
print("===========================================")
cleanup()
if loadScript(gameInfo.path) then
    print("===========================================")
    print("[ANSN] 🎉 " .. gameInfo.name .. " 脚本加载完成")
    print("===========================================")
else
    warn("===========================================")
    warn("[ANSN] ❌ 加载失败")
    warn("===========================================")
end
