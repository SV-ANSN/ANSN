local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local _p1="https://raw."
local _p2="githubuser"
local _p3="content.com/SV-ANSN/ANSN/main/ANSN%C3%BDe%C3%BDv9-obfuscated.lua"
local GAME_MAP={[4832438542]={name="VR 手 v3.2",path="SV-ANSN/ANSN/refs/heads/main/PE%20VR.lua"},[16044264830]={name="刀刃球:教程",path="SV-ANSN/ANSN/refs/heads/main/efsdg.lua"},[107778070777162]={name="偷一个蛋",path="__SENA__"},[104841616983113]={name="圣奥里",path=_p1.._p2.._p3},[85050171250159]={name="Po大Po",path="https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/ANSN%20PO%20D%20PO%20.lua"},[80898524797320]={name="画我!",path="https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/hw.lua"},[98502499119821]={name="重型钓鱼",path="https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/zfzf.lua"}}
local MIRRORS={"https://ghproxy.net/","https://gh-proxy.com/","https://cdn.jsdelivr.net/gh/","https://raw.githack.com/",""}
local ANIM_PLAYER_URL="https://raw.githubusercontent.com/SV-ANSN/ANSN/refs/heads/main/%E5%8A%A8%E7%94%BB%E6%92%AD%E6%94%BE%E5%99%A8.lua"
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
    if path:match("^https?://") then return path end
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
    -- 偷一个蛋：直接加载高级版
    if path == "__SENA__" then
        print("[ANSN] 加载高级版 Sena汉化...")
        loadstring(game:HttpGet('https://raw.githubusercontent.com/senarblx/sena/refs/heads/main/senav3go'))();
        task.spawn(function()
            task.wait(6)
            local hui=gethui and gethui() or game:GetService('CoreGui')
            local u=hui:FindFirstChild('SenaUI')
            local n=hui:FindFirstChild('SenaNotify')
            local t={["Steal Players"]="偷玩家",["Hatchery"]="孵化场",["Barn"]="仓库",["Rift"]="裂隙",["Partner Fuse"]="伙伴融合",["Upgrades"]="升级",["Extras"]="其他",["Presets"]="预设",["HATCH & STEAL"]="孵化 & 偷窃",["HATCHERY"]="孵化场",["BARN"]="仓库",["RIFT"]="裂隙",["EXTRAS"]="其他",["EGG ESP"]="蛋透视",["PRIORITY"]="优先",["EGGS"]="蛋",["Sell"]="出售",["Auto Steal"]="自动偷窃",["Egg Checker"]="蛋检查器",["Anti Hit Guard"]="防击保护",["Drop Before Finish Line"]="终点线前掉落",["Bat Aura"]="蝙蝠光环",["Egg Filter"]="蛋筛选",["Always Grab"]="始终抓取",["Glide"]="滑翔",["Fly Speed"]="飞行速度",["Fly Height"]="飞行高度",["Glide Speed"]="滑翔速度",["Match Game Speed"]="匹配游戏速度",["Movement Guard"]="移动保护",["Movement Mode"]="移动模式",["Hop When Nothing Matches"]="无匹配时换服",["Find Private Server"]="找私服",["Hop If Players Above"]="人数超过时换服",["Hop Cooldown"]="换服冷却",["Find Quietest Server"]="找最安静服务器",["Webhook URL"]="Webhook地址",["Notify Rarities"]="通知稀有度",["Notify Species"]="通知物种",["Hatch Webhook"]="孵化通知",["Egg Spawn Webhook"]="蛋生成通知",["Egg Collected Webhook"]="蛋收集通知",["Pets Sold Webhook"]="宠物出售通知",["Test Webhook"]="测试通知",["Auto Steal From Players"]="从玩家自动偷窃",["Rarity Filter"]="稀有度筛选",["Steal From Specific Player (Teleport Strike)"]="从指定玩家偷窃",["Players in this server"]="本服务器玩家",["Steal History"]="偷窃历史",["Clear History"]="清除历史",["Auto Place"]="自动放置",["Placement Order"]="放置顺序",["Species Allowed"]="允许物种",["Rarities Allowed"]="允许稀有度",["Mutations Allowed"]="允许变异",["Place Everything Now"]="立即全部放置",["Auto Apply Mutation"]="自动应用变异",["Apply Order"]="应用顺序",["Select Egg"]="选择蛋",["Retry Until Mutated"]="重试直到变异",["Apply Mutation Now"]="立即应用变异",["Auto Hatch"]="自动孵化",["Hatch Everything Ready"]="孵化所有就绪",["Auto Equip Best"]="自动装备最佳",["Collect Offline Income"]="收集离线收入",["Auto Sell"]="自动出售",["Rarities to Sell"]="出售稀有度",["Species to Sell"]="出售物种",["Sell Pets Now"]="立即出售宠物",["Auto Sell Eggs"]="自动出售蛋",["Egg Rarities to Sell"]="出售蛋稀有度",["Egg Species to Sell"]="出售蛋物种",["Sell Selected Eggs Now"]="立即出售选中的蛋",["Auto Favorite"]="自动收藏",["Favorite Rule"]="收藏规则",["Rarities to Keep"]="保留稀有度",["Species to Keep"]="保留物种",["Favorite Matching Now"]="立即收藏匹配",["Auto Fuse"]="自动融合",["Fusion Rule"]="融合规则",["Rarities to Fuse"]="融合稀有度",["Species to Fuse"]="融合物种",["Fuse One Pair"]="融合一组",["Auto Trade-In"]="自动交换",["Auto Add Pets to Rift Slots"]="自动添加宠物到裂隙槽",["Auto Free Reroll"]="自动免费重随",["Prioritise Rift Eggs in Auto Steal"]="优先裂隙蛋",["Steal Rift Eggs Only"]="只偷裂隙蛋",["Target Banners"]="目标横幅",["Auto Add Matching Pets Now"]="立即添加匹配宠物",["Trade-In Once"]="交换一次",["Use Free Reroll"]="使用免费重随",["Place Recipe Eggs in Pen"]="放置配方蛋",["Teleport to Rift Machine"]="传送到裂隙机器",["Refresh Status"]="刷新状态",["Auto Fight Boss"]="自动打Boss",["Neutralise Boss Hazards"]="清除Boss危险",["Hover Fight"]="悬浮战斗",["Return to Plot After Kill"]="击杀后回基地",["Arena Travel Speed"]="竞技场移动速度",["Enter Arena Now"]="立即进竞技场",["Leave Arena"]="离开竞技场",["Swing Bat Once"]="挥棒一次",["Auto Buy Rift Shop"]="自动买裂隙商店",["Rift Shop Item"]="裂隙商店物品",["Auto Claim Boss Milestones"]="自动领取Boss里程碑",["Auto Train"]="自动训练",["Auto Upgrade Treadmill"]="自动升级跑步机",["Upgrade Treadmill"]="升级跑步机",["Auto Upgrade Base"]="自动升级基地",["Upgrade Base"]="升级基地",["Auto Claim Almanac"]="自动领取图鉴",["Claim Almanac Now"]="立即领取图鉴",["Noclip"]="穿墙",["Instant Grab"]="瞬间抓取",["Waypoint"]="路径点",["Respawn Point"]="重生点",["Teleport"]="传送",["Egg Logs"]="蛋日志",["Egg Board"]="蛋板",["Inventory & Base"]="背包 & 基地",["Open Every Window"]="打开所有窗口",["Botting Mode (Blackscreen)"]="挂机模式(黑屏)",["Startup Boost"]="启动加速",["Uncap FPS (240)"]="解锁帧率(240)",["FPS Boost (Heavy)"]="FPS增强(重)",["Apply Boost Now"]="立即应用加速",["Hide All Pets (Max FPS)"]="隐藏所有宠物(最大FPS)",["Hide Owner Eggs Placed"]="隐藏自己放置的蛋",["Hide Other Eggs Placed"]="隐藏他人放置的蛋",["Hide All Placed Eggs"]="隐藏所有放置的蛋",["Hide Plot Visuals & Fences"]="隐藏基地装饰 & 围栏",["Hide Floating Money Text"]="隐藏浮动金钱文字",["Hide Treadmill Effects & Popups"]="隐藏跑步机特效 & 弹窗",["Clean All Visuals Now (Max FPS)"]="立即清理所有特效(最大FPS)",["Anti AFK"]="防AFK",["Auto Reconnect"]="自动重连",["Auto Execute (Global & Rejoin)"]="自动执行(全局 & 重进)",["Save Settings Now"]="立即保存设置",["Load Saved Settings"]="加载保存的设置",["Config Name"]="配置名称",["Saved Configs"]="保存的配置",["Auto Load"]="自动加载",["Rejoin This Server"]="重进此服务器",["Stop & Unload"]="停止 & 卸载",["Send"]="发送",["Copy Job ID"]="复制服务器ID",["How it works"]="如何运作",["Rarity"]="稀有度",["Status"]="状态",["Tier"]="层级",["Your Pet"]="你的宠物",["Auto Select"]="自动选择",["Recipes"]="配方",["Sena - Steal an Egg"]="ANSN - 偷一个蛋",["Sena"]="ANSN",["Disabled"]="已禁用",["Locked"]="已锁定",["All"]="全部",["Base"]="基础",["Save"]="保存",["Load"]="加载",["Delete"]="删除",["Refresh"]="刷新",["Export"]="导出",["Import"]="导入",["Import Data"]="导入数据",["Not broadcasting."]="未广播",["Nobody else is in this server."]="本服务器没有其他玩家",["No player steals yet."]="暂无玩家偷窃记录",["Nobody is broadcasting right now."]="当前无人广播",["No Egg Carried"]="未携带蛋",["Not spawned"]="未生成",["Your Shrine Status"]="你的神殿状态",["Players looking for a partner"]="寻找伙伴的玩家",["Broadcast: Find Partner"]="广播: 寻找伙伴",["Steal An Egg"]="偷一个蛋",["Loaded. Press Right Ctrl to hide or show the panel."]="已加载。按右Ctrl显示/隐藏面板。",["Sena is free"]="Sena是免费的",["Rift: Unknown"]="裂隙: 未知",["Recipe  (0/3)"]="配方  (0/3)",["Live Results"]="实时结果",["[IDLE]"]="[空闲]",["Common"]="普通",["Uncommon"]="罕见",["Rare"]="稀有",["Epic"]="史诗",["Legendary"]="传说",["Mythic"]="神话",["Secret"]="秘密",["Godly"]="神级",["Divine"]="神级",["Eternal"]="永恒",["Shiny"]="闪光",["Safe Zone"]="安全区",["Server: 5/7"]="服务器: 5/7",["Server: 4/7"]="服务器: 4/7",["Keeper"]="管理员",["Playbook"]="说明",["Community"]="社区",["Windows"]="窗口",["Framerate"]="帧率",["Session"]="会话",["Saved Setups"]="保存的配置",["Configuration Notice"]="配置提示",["Botting Telemetry"]="挂机数据",["STRIP HEAVY VISUALS"]="移除重特效",["Auto Reconnect & Execute"]="自动重连 & 执行",["Getaway"]="移动",["Server Hop"]="换服",["Steal Webhook"]="偷窃通知",["Place Eggs"]="放置蛋",["Incubator"]="孵化器",["Equip & Collect"]="装备 & 收集",["Favorite"]="收藏",["Fuse"]="融合",["Manual Actions"]="手动操作",["Rift Status"]="裂隙状态",["Rift Shop & Mastery"]="裂隙商店 & 精通",["Partner Shrine"]="伙伴神殿",["Treadmill"]="跑步机",["Almanac"]="图鉴",["Roaming"]="漫游",["Area List"]="区域列表",["Rarity List"]="稀有度列表",["Name List"]="名称列表",["Mutation List"]="变异列表",["Min Value ($/s)"]="最低价值($/s)",["Min Weight (Kg)"]="最低重量(Kg)",["ESP Rarities"]="ESP稀有度",["ESP Species"]="ESP物种",["ESP Min Value ($/s)"]="ESP最低价值",["ESP Min Weight (kg)"]="ESP最低重量",["Support & Donate"]="支持 & 赞助",["Get Key & Support"]="获取密钥 & 支持",["Donator Key Activation"]="赞助密钥激活",["Redeem Key"]="兑换密钥",["Get Key"]="获取密钥",["Channels & Rooms"]="频道 & 房间",["Live Network"]="实时网络",["Rooms"]="房间",["General"]="综合",["Indonesian"]="印尼语",["Philippines"]="菲律宾语",["Vietnam"]="越南语",["Brazilian"]="巴西语"}
            local done={}
            local function sc(c) if not c then return end
                pcall(function() for _,x in ipairs(c:GetDescendants()) do
                    if (x:IsA('TextLabel') or x:IsA('TextButton')) and x.Text and #x.Text<300 and not done[x] then
                        local s=x.Text local chg=false
                        for e,v in pairs(t) do local ns=s:gsub(e,v) if ns~=s then s=ns chg=true end end
                        if chg then x.Text=s done[x]=true end end end end) end
            for i=1,8 do task.wait(2) sc(u) sc(n) end
        end)
        return true
    end
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
