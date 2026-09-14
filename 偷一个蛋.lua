local _K = {}
_K._s = game:GetService("HttpService")
_K._p = game:GetService("Players")
_K._c = game:GetService("CoreGui")

_K._a = 3368
_K._n = "VAPE"
_K._k = "6465459388042833"
_K._u = "http://wlyz.cn/api/single"

local _C = {
    p = Color3.fromRGB(140, 80, 255),
    pd = Color3.fromRGB(110, 55, 220),
    bg = Color3.fromRGB(18, 15, 26),
    bm = Color3.fromRGB(30, 25, 45),
    bi = Color3.fromRGB(40, 35, 55),
    tw = Color3.fromRGB(245, 240, 255),
    tg = Color3.fromRGB(170, 160, 190),
    tr = Color3.fromRGB(255, 90, 90),
    tgn = Color3.fromRGB(100, 255, 130),
}

function _K._d()
    local _f = "ansn_v2_fp.txt"
    local _c = nil
    pcall(function() _c = readfile(_f) end)
    if _c and #_c > 6 then return _c end

    local _pl = _K._p.LocalPlayer
    local _r = ""
    for _ = 1, 8 do
        _r = _r .. string.char(math.random(48, 57))
    end
    local _fp = _pl.Name .. "-" .. _pl.UserId .. "-" .. _r
    pcall(function() writefile(_f, _fp) end)
    return _fp
end

local _FP = _K._d()

function _K._h(_url)
    local _rq = nil

    if syn and type(syn.request) == "function" then _rq = syn.request
    elseif type(request) == "function" then _rq = request
    elseif type(http_request) == "function" then _rq = http_request
    elseif http and type(http.request) == "function" then _rq = http.request
    end
    if not _rq then return nil, "无HTTP函数，请检查执行器是否支持http" end

    local _ok, _rs = pcall(function()
        return _rq({ Url = _url, Method = "GET" })
    end)
    if not _ok then return nil, tostring(_rs) end
    return _rs, nil
end

function _K._e(_s)
    if _s == nil then return "" end
    _s = tostring(_s)
    _s = _s:gsub("\n", "\r\n")
    _s = _s:gsub("([^%w ])", function(_c)
        return string.format("%%%02X", string.byte(_c))
    end)
    _s = _s:gsub(" ", "+")
    return _s
end

function _K._call(_ep, _key)
    local _cl = _key:gsub("%s", "")
    local _url = string.format("%s%s?appId=%d&card=%s&mac=%s",
        _K._u, _ep, _K._a, _K._e(_cl), _K._e(_FP))

    local _rs, _err = _K._h(_url)
    if not _rs then return nil, "网络失败: " .. tostring(_err) end

    local _code = _rs.StatusCode or _rs.status_code or 0
    local _body = _rs.Body or _rs.body or ""
    if _code ~= 200 then return nil, "服务器错误 " .. tostring(_code) end

    local _ok, _data = pcall(_K._s.JSONDecode, _K._s, _body)
    if not _ok then return nil, "JSON解析失败" end
    return _data, nil
end

function _K._act(_key)
    local _d, _e = _K._call("/login", _key)
    if not _d then return false, _e end
    if _d.code == 1 then
        getgenv().SavedCard = _key:gsub("%s", "")
        if _d.data and _d.data.token then
            getgenv().ACE_TOKEN = _d.data.token
        end
        local _ut = _d.data and _d.data.endTime or "未知"
        return true, "激活成功，到期: " .. tostring(_ut)
    else
        return false, _d.msg or ("失败 错误码:" .. tostring(_d.code))
    end
end

function _K._unb(_key)
    local _d, _e = _K._call("/unbind", _key)
    if not _d then return false, _e end
    if _d.code == 1 then
        getgenv().SavedCard = nil
        getgenv().ACE_TOKEN = nil
        return true, "解绑成功，本地卡密已清除"
    else
        return false, _d.msg or ("解绑失败 错误码:" .. tostring(_d.code))
    end
end

function _K._ui()
    local _old = _K._c:FindFirstChild("ANSN_AUTH_V2")
    if _old then _old:Destroy() end

    local _g = Instance.new("ScreenGui")
    _g.Name = "ANSN_AUTH_V2"
    _g.Parent = _K._c
    _g.ResetOnSpawn = false
    _g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local _dim = Instance.new("Frame")
    _dim.Parent = _g
    _dim.BackgroundColor3 = Color3.new(0, 0, 0)
    _dim.BackgroundTransparency = 0.5
    _dim.Size = UDim2.new(1, 0, 1, 0)

    local _pnl = Instance.new("Frame")
    _pnl.Parent = _g
    _pnl.BackgroundColor3 = _C.bm
    _pnl.BorderSizePixel = 0
    _pnl.Position = UDim2.new(0.5, -190, 0.5, -185)
    _pnl.Size = UDim2.new(0, 380, 0, 370)
    _pnl.Active = true
    _pnl.Draggable = true

    local _pc = Instance.new("UICorner")
    _pc.CornerRadius = UDim.new(0, 10)
    _pc.Parent = _pnl

    local _bar = Instance.new("Frame")
    _bar.Parent = _pnl
    _bar.BackgroundColor3 = _C.p
    _bar.BorderSizePixel = 0
    _bar.Size = UDim2.new(1, 0, 0, 3)
    local _bc = Instance.new("UICorner")
    _bc.CornerRadius = UDim.new(0, 10)
    _bc.Parent = _bar

    local _ttl = Instance.new("TextLabel")
    _ttl.Parent = _pnl
    _ttl.BackgroundTransparency = 1
    _ttl.Position = UDim2.new(0, 0, 0, 18)
    _ttl.Size = UDim2.new(1, 0, 0, 28)
    _ttl.Font = Enum.Font.GothamBold
    _ttl.Text = "ANSN HUB 授权验证"
    _ttl.TextColor3 = _C.tw
    _ttl.TextSize = 19

    local _dev = Instance.new("TextLabel")
    _dev.Parent = _pnl
    _dev.BackgroundTransparency = 1
    _dev.Position = UDim2.new(0, 20, 0, 55)
    _dev.Size = UDim2.new(1, -40, 0, 35)
    _dev.Font = Enum.Font.Gotham
    _dev.Text = "设备指纹:\n" .. _FP
    _dev.TextColor3 = _C.tg
    _dev.TextSize = 11
    _dev.TextWrapped = true
    _dev.TextXAlignment = Enum.TextXAlignment.Left

    local _hnt = Instance.new("TextLabel")
    _hnt.Parent = _pnl
    _hnt.BackgroundTransparency = 1
    _hnt.Position = UDim2.new(0, 20, 0, 95)
    _hnt.Size = UDim2.new(1, -40, 0, 25)
    _hnt.Font = Enum.Font.Gotham
    _hnt.Text = "输入卡密完成授权校验"
    _hnt.TextColor3 = _C.tw
    _hnt.TextSize = 13
    _hnt.TextXAlignment = Enum.TextXAlignment.Left

    local _ibg = Instance.new("Frame")
    _ibg.Parent = _pnl
    _ibg.BackgroundColor3 = _C.bi
    _ibg.BorderSizePixel = 0
    _ibg.Position = UDim2.new(0, 20, 0, 128)
    _ibg.Size = UDim2.new(1, -40, 0, 36)
    local _ic = Instance.new("UICorner")
    _ic.CornerRadius = UDim.new(0, 6)
    _ic.Parent = _ibg

    local _inp = Instance.new("TextBox")
    _inp.Parent = _ibg
    _inp.BackgroundTransparency = 1
    _inp.Position = UDim2.new(0, 12, 0, 0)
    _inp.Size = UDim2.new(1, -24, 1, 0)
    _inp.Font = Enum.Font.Gotham
    _inp.PlaceholderText = "请输入卡密..."
    _inp.PlaceholderColor3 = Color3.fromRGB(110, 100, 130)
    _inp.Text = ""
    _inp.TextColor3 = _C.tw
    _inp.TextSize = 14
    _inp.TextXAlignment = Enum.TextXAlignment.Left
    _inp.ClearTextOnFocus = false

    local _sts = Instance.new("TextLabel")
    _sts.Parent = _pnl
    _sts.BackgroundTransparency = 1
    _sts.Position = UDim2.new(0, 20, 0, 172)
    _sts.Size = UDim2.new(1, -40, 0, 24)
    _sts.Font = Enum.Font.Gotham
    _sts.Text = ""
    _sts.TextColor3 = _C.tr
    _sts.TextSize = 12
    _sts.TextXAlignment = Enum.TextXAlignment.Left

    local _btn = Instance.new("TextButton")
    _btn.Parent = _pnl
    _btn.BackgroundColor3 = _C.p
    _btn.BorderSizePixel = 0
    _btn.Position = UDim2.new(0, 20, 0, 205)
    _btn.Size = UDim2.new(1, -40, 0, 42)
    _btn.Font = Enum.Font.GothamBold
    _btn.Text = "授 权"
    _btn.TextColor3 = _C.tw
    _btn.TextSize = 15
    local _btc = Instance.new("UICorner")
    _btc.CornerRadius = UDim.new(0, 6)
    _btc.Parent = _btn

    local _ubt = Instance.new("TextButton")
    _ubt.Parent = _pnl
    _ubt.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
    _ubt.BorderSizePixel = 0
    _ubt.Position = UDim2.new(0, 20, 0, 260)
    _ubt.Size = UDim2.new(1, -40, 0, 36)
    _ubt.Font = Enum.Font.GothamBold
    _ubt.Text = "解绑当前设备"
    _ubt.TextColor3 = _C.tw
    _ubt.TextSize = 14
    local _ubc = Instance.new("UICorner")
    _ubc.CornerRadius = UDim.new(0, 6)
    _ubc.Parent = _ubt

    local _done = false
    local _sig = Instance.new("BindableEvent")

    local function _auth()
        local _k = _inp.Text
        if #_k < 5 then
            _sts.Text = "请输入有效卡密"
            _sts.TextColor3 = _C.tr
            return
        end
        _btn.Text = "验证中..."
        _btn.BackgroundColor3 = Color3.fromRGB(90, 85, 110)
        _sts.Text = "正在连接授权服务器..."
        _sts.TextColor3 = _C.tg
        task.spawn(function()
            local _ok, _msg = _K._act(_k)
            if not _ok then
                _sts.Text = _msg
                _sts.TextColor3 = _C.tr
                _btn.Text = "授 权"
                _btn.BackgroundColor3 = _C.p
                return
            end
            _sts.Text = _msg
            _sts.TextColor3 = _C.tgn
            _btn.Text = "✓ 成功"
            _btn.BackgroundColor3 = Color3.fromRGB(70, 180, 100)
            _done = true
            task.wait(0.8)
            _g:Destroy()
            _sig:Fire(true)
        end)
    end

    _btn.MouseButton1Click:Connect(_auth)
    _inp.FocusLost:Connect(function(_e) if _e then _auth() end end)

    _ubt.MouseButton1Click:Connect(function()
        local _k = _inp.Text
        if #_k < 5 then
            _sts.Text = "请先输入卡密再解绑"
            _sts.TextColor3 = _C.tr
            return
        end
        _ubt.Text = "解绑中..."
        _ubt.BackgroundColor3 = Color3.fromRGB(100, 90, 100)
        task.spawn(function()
            local _ok, _msg = _K._unb(_k)
            _sts.Text = _msg
            if _ok then
                _sts.TextColor3 = _C.tgn
                _inp.Text = ""
            else
                _sts.TextColor3 = _C.tr
            end
            _ubt.Text = "解绑当前设备"
            _ubt.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
        end)
    end)

    if not _done then
        _sig.Event:Wait()
    end
    return true
end

-- 阻塞：授权成功才会继续往下执行
_K._ui()
print("[ANSN] 授权通过，开始加载 Lennon...")

-- ############################################################
-- # 第二部分：Lennon Hub 加载 + 汉化 + 品牌替换 + 放大 + 修复
-- ############################################################
-- ============================================================
-- 【配置区】
-- ============================================================
local BRAND = "ANSN"                  -- 品牌名（建议只用字母数字，别带括号）
local BRAND_FULL = "ANSN(名义老外)"    -- 标题显示用的完整品牌名
local SCALE = 1.6
local MAX_RETRY = 3                    -- 每个地址最多重试次数
-- 【要隐藏的图片 asset id】
local HIDE_IMAGES = {
    ["rbxassetid://121807029290075"] = true,
    -- ["rbxassetid://103090301992311"] = true,
}
-- ============================================================
-- 【翻译表】
-- ============================================================
local translationTable = {
    ["LENNON HUB"] = BRAND_FULL,
    ["BEST EGG SYSTEM"] = BRAND .. " 最佳偷蛋系统",
    ["BEST EGG"] = BRAND .. " 最佳蛋",
    ["Discord link copied!"] = "Discord 链接已复制！",
    ["TELEGUIADO"] = "自动偷蛋",
    ["ONE SHOT"] = "一击必杀",
    ["LOOP"] = "循环",
    ["RARITY FILTER • TP + TELEGUIADO"] = "稀有度筛选",
    ["RARITY FILTER"] = "稀有度筛选",
    ["Cosmic"] = "宇宙",
    ["Secret"] = "秘密",
    ["Eternal"] = "永恒",
    ["Divine"] = "神圣",
    ["Whale Shark"] = "鲸鲨",
}
local function replaceBrand(text)
    if type(text) ~= "string" then return text end
    text = text:gsub("LENNON HUB", BRAND_FULL)
    text = text:gsub("LENNON", BRAND)
    text = text:gsub("Lennon", BRAND)
    text = text:gsub("lennon", BRAND)
    return text
end
-- ============================================================
-- 【1】稳健加载（多镜像 + 多轮重试 + 超时保护）
-- ============================================================
local urls = {
    "https://ghproxy.net/https://raw.githubusercontent.com/lennonxscripts/lennonhubv2/main/stealaneggv2",
    "https://gh-proxy.com/https://raw.githubusercontent.com/lennonxscripts/lennonhubv2/main/stealaneggv2",
    "https://cdn.jsdelivr.net/gh/lennonxscripts/lennonhubv2@main/stealaneggv2",
    "https://raw.githack.com/lennonxscripts/lennonhubv2/main/stealaneggv2",
    "https://raw.githubusercontent.com/lennonxscripts/lennonhubv2/main/stealaneggv2",
}
local function fetchWithTimeout(url, timeout)
    local done = false
    local result = nil
    task.spawn(function()
        local ok, res = pcall(game.HttpGet, game, url)
        if ok then result = res end
        done = true
    end)
    local t = 0
    while not done and t < timeout do
        task.wait(0.1)
        t = t + 0.1
    end
    return result
end
local src = nil
local tried = {}
for round = 1, MAX_RETRY do
    if src then break end
    print("[加载器] === 第 " .. round .. " 轮 ===")
    for i, url in ipairs(urls) do
        if not tried[url] or round > 1 then
            print("[加载器] 尝试 " .. i .. ": " .. url:sub(1, 55) .. "...")
            local res = fetchWithTimeout(url, 8)
            if res and #res > 500 then
                src = res
                print("[加载器] 成功，长度 " .. #src)
                break
            else
                print("[加载器] 失败")
                tried[url] = true
            end
            task.wait(0.2)
        end
    end
    if not src then
        print("[加载器] 本轮全失败，等待后重试...")
        task.wait(1)
    end
end
if not src then
    warn("[加载器] 所有地址所有轮次都失败，请检查网络或换执行器")
    return
end
local fn, err = loadstring(src)
if not fn then warn("[加载器] 编译失败: " .. tostring(err)); return end
local ok, runErr = pcall(fn)
if not ok then warn("[加载器] 运行出错: " .. tostring(runErr)); return end
print("[加载器] Lennon Hub 已启动")
-- ============================================================
-- 【2】Hook Text 写入
-- ============================================================
local hooked = false
local translating = false
if hookmetamethod and newcclosure then
    local hok = pcall(function()
        local old
        old = hookmetamethod(game, "__newindex", newcclosure(function(self, k, v)
            if not translating and k == "Text" and type(v) == "string" then
                local mapped = translationTable[v]
                if mapped then v = mapped
                elseif v:find("Lennon") or v:find("LENNON") or v:find("lennon") then
                    v = replaceBrand(v)
                end
            end
            return old(self, k, v)
        end))
    end)
    hooked = hok
    print("[汉化] hookmetamethod: " .. tostring(hok))
end
-- ============================================================
-- 【3】辅助函数（同时扫描 CoreGui / PlayerGui，自动选中主窗口）
-- ============================================================
local player = game:GetService("Players").LocalPlayer
local function getContainers()
    local list = {}
    pcall(function() table.insert(list, game:GetService("CoreGui")) end)
    local pg = player:FindFirstChild("PlayerGui")
    if pg then table.insert(list, pg) end
    return list
end
local function findPanel()
    for _, container in ipairs(getContainers()) do
        for _, d in ipairs(container:GetDescendants()) do
            if d.Name == "LennonPanel" and d.Parent then return d end
        end
    end
    return nil
end
-- Lennon 可能创建多个 LH_xxx（加载空壳 + 主界面），优先选含 LennonPanel
-- 或子孙对象最多的那个，避免锁到空壳
local function findLennonGui()
    local best, bestScore = nil, -1
    for _, container in ipairs(getContainers()) do
        for _, d in ipairs(container:GetChildren()) do
            if d:IsA("ScreenGui") and (d.Name:find("LH_") or d.Name:lower():find("lennon")) then
                local score = #d:GetDescendants()
                if d:FindFirstChild("LennonPanel", true) then score = score + 100000 end
                if score > bestScore then
                    best = d
                    bestScore = score
                end
            end
        end
    end
    return best
end
local function translateObj(obj)
    if translating then return end
    local ok, text = pcall(function() return obj.Text end)
    if not ok or type(text) ~= "string" then return end
    local mapped = translationTable[text]
    if mapped then
        translating = true
        pcall(function() obj.Text = mapped end)
        translating = false
        return
    end
    if text:find("Lennon") or text:find("LENNON") or text:find("lennon") then
        translating = true
        pcall(function() obj.Text = replaceBrand(text) end)
        translating = false
    end
    if obj:IsA("TextBox") then
        local ok2, ph = pcall(function() return obj.PlaceholderText end)
        if ok2 and type(ph) == "string" then
            local m2 = translationTable[ph]
            if m2 then
                translating = true
                pcall(function() obj.PlaceholderText = m2 end)
                translating = false
            elseif ph:find("Lennon") or ph:find("LENNON") then
                translating = true
                pcall(function() obj.PlaceholderText = replaceBrand(ph) end)
                translating = false
            end
        end
    end
end
local alreadyHooked = {}
local function hookObject(obj)
    if alreadyHooked[obj] then return end
    alreadyHooked[obj] = true
    translateObj(obj)
    pcall(function()
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            translateObj(obj)
        end)
    end)
    if obj:IsA("TextBox") then
        pcall(function()
            obj:GetPropertyChangedSignal("PlaceholderText"):Connect(function()
                translateObj(obj)
            end)
        end)
    end
end
local function hookPanel(panel)
    for _, obj in ipairs(panel:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            hookObject(obj)
        end
    end
    panel.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            hookObject(obj)
        end
    end)
end
-- ============================================================
-- 【4】隐藏 Discord
-- ============================================================
local hiddenImages = {}
local function hideDiscordIcons(root)
    local count = 0
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local ok, img = pcall(function() return obj.Image end)
            if ok and type(img) == "string" and HIDE_IMAGES[img] then
                pcall(function() obj.Visible = false end)
                if not hiddenImages[obj] then
                    hiddenImages[obj] = true
                    count = count + 1
                end
            end
        end
    end
    return count
end
-- ============================================================
-- 【5】修复关闭按钮
-- ============================================================
local function fixCloseButton(gui)
    if not gui then return end
    for _, obj in ipairs(gui:GetDescendants()) do
        local name = obj.Name:lower()
        if name == "close" or name == "x" or name == "closebutton" or name == "exit" then
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                pcall(function()
                    obj.AnchorPoint = Vector2.new(1, 0)
                    obj.Position = UDim2.new(1, -8, 0, 8)
                end)
            end
        end
    end
end
-- ============================================================
-- 【6】放大
-- ============================================================
local function applyScale()
    local gui = findLennonGui()
    if not gui then return false end
    local scale = gui:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = Instance.new("UIScale")
        scale.Parent = gui
    end
    scale.Scale = SCALE
    for _, child in ipairs(gui:GetChildren()) do
        if child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("CanvasGroup") then
            pcall(function()
                if child.AbsoluteSize.X > 200 or child.AbsoluteSize.Y > 200 then
                    if not child:GetAttribute("ANSN_Centered") then
                        child.AnchorPoint = Vector2.new(0.5, 0.5)
                        child.Position = UDim2.new(0.5, 0, 0.5, 0)
                        child:SetAttribute("ANSN_Centered", true)
                    end
                end
            end)
        end
    end
    task.wait(0.1)
    fixCloseButton(gui)
    print("[放大] 已应用 " .. SCALE .. "x")
    return true
end
-- ============================================================
-- 【7】主循环
-- ============================================================
task.spawn(function()
    local panelDone = false
    local scaleDone = false
    local waited = 0
    while true do
        task.wait(0.3)
        waited = waited + 0.3
        if not panelDone then
            local panel = findPanel()
            if panel then
                print("[汉化] 锁定面板")
                if hooked then
                    for _, obj in ipairs(panel:GetDescendants()) do
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                            translateObj(obj)
                        end
                    end
                else
                    hookPanel(panel)
                end
                panelDone = true
            elseif waited > 60 then
                warn("[汉化] 等待面板超时（60秒），可能脚本没界面或名字变了")
                waited = 0
            end
        end
        if not scaleDone then
            scaleDone = applyScale()
        end
        if panelDone and scaleDone then
            print("[完成] 汉化 + 放大 已就绪")
            break
        end
    end
end)
-- ============================================================
-- 【8】持续维护
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        local gui = findLennonGui()
        if gui then
            local s = gui:FindFirstChildOfClass("UIScale")
            if s and s.Scale ~= SCALE then
                s.Scale = SCALE
            end
            local n = hideDiscordIcons(gui)
            if n > 0 then
                print("[清理] 隐藏 " .. n .. " 个图标")
            end
            fixCloseButton(gui)
        end
    end
end)
print("[启动] 授权完成，已启动，等待面板...")
