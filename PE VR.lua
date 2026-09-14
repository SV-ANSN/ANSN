do
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport)
    local checks = {
        { "getrawmetatable",   getrawmetatable   },
        { "setreadonly",       setreadonly       },
        { "newcclosure",       newcclosure       },
        { "getnamecallmethod", getnamecallmethod },
        { "getgc",             getgc             },
        { "queue_on_teleport", qot               },
    }
    local missing, report = {}, "[VR Hands No-VR Pro] UNC test:\n"
    for _, c in ipairs(checks) do
        local ok = type(c[2]) == "function"
        report = report .. ("  [%s] %s\n"):format(ok and "+" or "-", c[1])
        if not ok then table.insert(missing, c[1]) end
    end
    print(report)
    if #missing > 0 then
        warn("[NoVR Pro] 缺少函数: " .. table.concat(missing, ", "))
        warn("[NoVR Pro] 执行器不支持 - 中止。")
        return
    end
    print("[NoVR Pro] UNC 测试通过，启动中...")
end

local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local hrs = [==[
local VRService   = game:GetService("VRService")
local UIS         = game:GetService("UserInputService")
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local identity    = CFrame.identity

do
    local mt = getrawmetatable(game)
    local oldIndex    = mt.__index
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, k)
        if k == "VREnabled" and (self == VRService or self == UIS) then return true end
        return oldIndex(self, k)
    end)
    mt.__namecall = newcclosure(function(self, ...)
        if self == VRService then
            local m = getnamecallmethod()
            if m == "GetUserCFrameEnabled" then return true end
            if m == "GetUserCFrame" then return identity end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

task.spawn(function()
    local function ensureFolder(p, n)
        local f = p:FindFirstChild(n)
        if not f then f = Instance.new("Folder"); f.Name = n; f.Parent = p end
        return f
    end
    local function ensurePart(p, n)
        local x = p:FindFirstChild(n)
        if not x then
            x = Instance.new("Part"); x.Name = n
            x.Anchored = true; x.CanCollide = false; x.Transparency = 1
            x.Size = Vector3.new(1,1,1); x.Parent = p
        end
        return x
    end
    local function populate(cam)
        if not cam then return end
        ensurePart(ensureFolder(cam, "VRCoreEffectParts"), "Cursor")
        ensurePart(ensureFolder(cam, "VRCorePanelParts"), "BottomBar_Part")
    end
    populate(workspace.CurrentCamera)
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        populate(workspace.CurrentCamera)
    end)
    local t0 = os.clock()
    while os.clock() - t0 < 30 do
        populate(workspace.CurrentCamera)
        task.wait(0.1)
    end
end)

task.spawn(function()
    local lp = Players.LocalPlayer
    while not lp do task.wait() lp = Players.LocalPlayer end
    local uid = tostring(lp.UserId)

    local vrPlayers = workspace:WaitForChild("VRPlayers", 60)
    if not vrPlayers then warn("[NoVR] 找不到 VRPlayers 文件夹") return end
    local rig = vrPlayers:WaitForChild(uid, 60)
    if not rig then warn("[NoVR] 服务器没有分配 rig") return end
    rig:WaitForChild("VRHead", 20)
    rig:WaitForChild("LeftHand", 20)
    rig:WaitForChild("RightHand", 20)
    local scaleVal = rig:FindFirstChild("VRScale")
    local cam = workspace.CurrentCamera

    local S = {
        reach  = 0.55, spread = 0.34, height = -0.25,
        sens   = 0.0025, moveK = 0.16, look = true,
        scale  = 10,
    }

    local Gesture = {
        rThumb = 0, rIndex = 0, rMiddle = 0, rRing = 0, rPinky = 0, rFist = 0,
        lThumb = 0, lIndex = 0, lMiddle = 0, lRing = 0, lPinky = 0, lFist = 0,
        presetName = "None",
    }

    -- 手旋转：双手一起、右手单独、左手单独
    local HandRot = {
        both  = { yaw = 0, pitch = 0 },
        right = { yaw = 0, pitch = 0 },
        left  = { yaw = 0, pitch = 0 },
    }
    local middleMouseHeld = false
    local rotTarget = "both" -- "both" | "right" | "left"

    local ok, VRUtils = pcall(function()
        return require(lp.PlayerScripts.ClientLoader.PlayerModule.VRModule.VRUtils)
    end)
    if ok and type(VRUtils) == "table" then
        VRUtils.GetUserCFrame = function(uc, scale)
            scale = scale or cam.HeadScale
            if scale <= 1 then scale = math.max((scaleVal and scaleVal.Value or 1) * 60, 6) end
            local baseCF
            if uc == Enum.UserCFrame.LeftHand then
                local c = CFrame.new(-S.spread, S.height, -S.reach)
                baseCF = c.Rotation + c.Position * scale
            elseif uc == Enum.UserCFrame.RightHand then
                local c = CFrame.new(S.spread, S.height, -S.reach)
                baseCF = c.Rotation + c.Position * scale
            else
                baseCF = identity
            end

            -- 应用旋转：双手基础 + 各自单独
            local rotBoth  = CFrame.Angles(HandRot.both.pitch,  HandRot.both.yaw,  0)
            local rotRight = CFrame.Angles(HandRot.right.pitch, HandRot.right.yaw, 0)
            local rotLeft  = CFrame.Angles(HandRot.left.pitch,  HandRot.left.yaw,  0)

            if uc == Enum.UserCFrame.RightHand then
                return baseCF * rotBoth * rotRight
            elseif uc == Enum.UserCFrame.LeftHand then
                return baseCF * rotBoth * rotLeft
            end
            return baseCF
        end
        print("[NoVR] VRUtils 拦截成功，支持手旋转")
    else
        warn("[NoVR] 拦截 VRUtils 失败，手旋转不可用")
    end

    -- 寻找 Input 对象
    local vrm, Input
    for _ = 1, 250 do
        for _, o in pairs(getgc(true)) do
            if type(o) == "table"
               and rawget(o,"HeadsetPart") ~= nil and rawget(o,"Input") ~= nil
               and rawget(o,"CharacterScale") ~= nil and rawget(o,"DataManager") ~= nil then
                vrm = o; Input = rawget(o,"Input"); break
            end
        end
        if Input then break end
        for _, o in pairs(getgc(true)) do
            if type(o) == "table" and rawget(o,"directionLateral") ~= nil
               and rawget(o,"rFist") ~= nil and rawget(o,"turnDirection") ~= nil then
                Input = o; break
            end
        end
        if Input then break end
        task.wait(0.1)
    end

    if not Input then
        warn("[NoVR] 未找到 Input 对象 - 手势功能不可用")
    else
        print("[NoVR] Input 对象已找到")
    end

    -- 探测 Input 对象实际支持的所有字段
    local Supported = {}
    local SupportedList = {}
    if Input then
        for k, v in pairs(Input) do
            if type(v) == "number" then
                Supported[k] = true
                table.insert(SupportedList, k)
            end
        end
        table.sort(SupportedList)
        print("[NoVR] Input 支持的数字字段: " .. table.concat(SupportedList, ", "))
    end

    local HAS_FULL_FINGERS = Supported.rMiddle == true
    if HAS_FULL_FINGERS then
        print("[NoVR] 检测到完整手指支持")
    else
        print("[NoVR] 检测到简化手指支持，中指/无名指/小指用 Fist 代理")
    end

    local function safeSetInput(key, value)
        if Input and Supported[key] then
            local ok = pcall(function() Input[key] = value end)
            return ok
        end
        return false
    end

    local function applyGesture(g)
        if not Input then return end

        local function calcProxyFist(hand, gTable)
            if HAS_FULL_FINGERS then return nil end
            local fistKey = hand .. "Fist"
            if gTable[fistKey] ~= nil then return nil end
            local middle = gTable[hand .. "Middle"] or 0
            local ring   = gTable[hand .. "Ring"]   or 0
            local pinky  = gTable[hand .. "Pinky"]  or 0
            local bendCount = middle + ring + pinky
            if bendCount > 0 then
                return math.clamp(bendCount / 3, 0.2, 1)
            end
            return nil
        end

        local rProxy = calcProxyFist("r", g)
        local lProxy = calcProxyFist("l", g)

        if g.rThumb  ~= nil then safeSetInput("rThumb",  g.rThumb)  end
        if g.rIndex  ~= nil then safeSetInput("rIndex",  g.rIndex)  end
        if g.rMiddle ~= nil and Supported.rMiddle then safeSetInput("rMiddle", g.rMiddle) end
        if g.rRing   ~= nil and Supported.rRing   then safeSetInput("rRing",   g.rRing)   end
        if g.rPinky  ~= nil and Supported.rPinky  then safeSetInput("rPinky",  g.rPinky)  end
        if g.rFist   ~= nil then safeSetInput("rFist",   g.rFist)
        elseif rProxy then safeSetInput("rFist", rProxy) end

        if g.lThumb  ~= nil then safeSetInput("lThumb",  g.lThumb)  end
        if g.lIndex  ~= nil then safeSetInput("lIndex",  g.lIndex)  end
        if g.lMiddle ~= nil and Supported.lMiddle then safeSetInput("lMiddle", g.lMiddle) end
        if g.lRing   ~= nil and Supported.lRing   then safeSetInput("lRing",   g.lRing)   end
        if g.lPinky  ~= nil and Supported.lPinky  then safeSetInput("lPinky",  g.lPinky)  end
        if g.lFist   ~= nil then safeSetInput("lFist",   g.lFist)
        elseif lProxy then safeSetInput("lFist", lProxy) end

        for k, v in pairs(g) do
            if Gesture[k] ~= nil and type(v) == "number" then
                Gesture[k] = v
            end
        end
        if g.presetName then Gesture.presetName = g.presetName end
    end

    local Presets = {
        ["Open"]     = { rThumb=0, rIndex=0, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=0, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="张开手掌" },
        ["Fist"]     = { rThumb=1, rIndex=1, rMiddle=1, rRing=1, rPinky=1, rFist=1,
                         lThumb=1, lIndex=1, lMiddle=1, lRing=1, lPinky=1, lFist=1, presetName="握拳" },
        ["Point"]    = { rThumb=0, rIndex=1, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=1, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="食指指" },
        ["Peace"]    = { rThumb=0, rIndex=1, rMiddle=1, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=1, lMiddle=1, lRing=0, lPinky=0, lFist=0, presetName="剪刀手" },
        ["ThumbsUp"] = { rThumb=1, rIndex=0, rMiddle=0, rRing=0, rPinky=0, rFist=1,
                         lThumb=1, lIndex=0, lMiddle=0, lRing=0, lPinky=0, lFist=1, presetName="点赞" },
        ["OK"]       = { rThumb=1, rIndex=1, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=1, lIndex=1, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="OK" },
        ["Rock"]     = { rThumb=0, rIndex=1, rMiddle=0, rRing=0, rPinky=1, rFist=0,
                         lThumb=0, lIndex=1, lMiddle=0, lRing=0, lPinky=1, lFist=0, presetName="摇滚" },
        ["Middle"]   = { rThumb=0, rIndex=0, rMiddle=1, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=0, lMiddle=1, lRing=0, lPinky=0, lFist=0, presetName="中指" },
        ["Phone"]    = { rThumb=1, rIndex=0, rMiddle=0, rRing=0, rPinky=1, rFist=0,
                         lThumb=1, lIndex=0, lMiddle=0, lRing=0, lPinky=1, lFist=0, presetName="电话" },
        ["Gun"]      = { rThumb=0, rIndex=1, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=1, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="手枪指" },
        ["PinchR"]   = { rThumb=1, rIndex=1, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=0, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="右手捏取" },
        ["PinchL"]   = { rThumb=0, rIndex=0, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=1, lIndex=1, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="左手捏取" },
        ["GrabR"]    = { rThumb=1, rIndex=1, rMiddle=1, rRing=1, rPinky=1, rFist=1,
                         lThumb=0, lIndex=0, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="右手抓取" },
        ["GrabL"]    = { rThumb=0, rIndex=0, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=1, lIndex=1, lMiddle=1, lRing=1, lPinky=1, lFist=1, presetName="左手抓取" },
        ["Flap"]     = { rThumb=0, rIndex=0, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=0, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="挥手" },
        ["Horns"]    = { rThumb=1, rIndex=1, rMiddle=0, rRing=0, rPinky=1, rFist=0,
                         lThumb=1, lIndex=1, lMiddle=0, lRing=0, lPinky=1, lFist=0, presetName="牛角" },
        ["Shaka"]    = { rThumb=1, rIndex=0, rMiddle=0, rRing=0, rPinky=1, rFist=0,
                         lThumb=1, lIndex=0, lMiddle=0, lRing=0, lPinky=1, lFist=0, presetName="Shaka" },
        ["Salute"]   = { rThumb=0, rIndex=1, rMiddle=0, rRing=0, rPinky=0, rFist=0,
                         lThumb=0, lIndex=0, lMiddle=0, lRing=0, lPinky=0, lFist=0, presetName="敬礼" },
        ["Pray"]     = { rThumb=1, rIndex=1, rMiddle=1, rRing=1, rPinky=1, rFist=1,
                         lThumb=1, lIndex=1, lMiddle=1, lRing=1, lPinky=1, lFist=1, presetName="祈祷" },
        ["Claw"]     = { rThumb=0, rIndex=1, rMiddle=1, rRing=1, rPinky=1, rFist=0.5,
                         lThumb=0, lIndex=1, lMiddle=1, lRing=1, lPinky=1, lFist=0.5, presetName="爪子" },
    }

    local PresetKeys = {
        [Enum.KeyCode.One]   = "Open",
        [Enum.KeyCode.Two]   = "Fist",
        [Enum.KeyCode.Three] = "Point",
        [Enum.KeyCode.Four]  = "Peace",
        [Enum.KeyCode.Five]  = "ThumbsUp",
        [Enum.KeyCode.Six]   = "OK",
        [Enum.KeyCode.Seven] = "Rock",
        [Enum.KeyCode.Eight] = "Middle",
        [Enum.KeyCode.Nine]  = "Phone",
        [Enum.KeyCode.Zero]  = "Gun",
    }

    local PresetKeysCtrl = {
        [Enum.KeyCode.One]   = "PinchR",
        [Enum.KeyCode.Two]   = "GrabR",
        [Enum.KeyCode.Three] = "PinchL",
        [Enum.KeyCode.Four]  = "GrabL",
        [Enum.KeyCode.Five]  = "Flap",
        [Enum.KeyCode.Six]   = "Horns",
        [Enum.KeyCode.Seven] = "Shaka",
        [Enum.KeyCode.Eight] = "Salute",
        [Enum.KeyCode.Nine]  = "Pray",
        [Enum.KeyCode.Zero]  = "Claw",
    }

    local FingerKeys = {
        [Enum.KeyCode.T] = { hand="r", finger="Thumb",  name="右拇指" },
        [Enum.KeyCode.Y] = { hand="r", finger="Index",  name="右食指" },
        [Enum.KeyCode.U] = { hand="r", finger="Middle", name="右中指" },
        [Enum.KeyCode.I] = { hand="r", finger="Ring",   name="右无名指" },
        [Enum.KeyCode.O] = { hand="r", finger="Pinky",  name="右小指" },
        [Enum.KeyCode.P] = { hand="r", finger="Fist",   name="右拳" },
        [Enum.KeyCode.Z] = { hand="l", finger="Thumb",  name="左拇指" },
        [Enum.KeyCode.X] = { hand="l", finger="Index",  name="左食指" },
        [Enum.KeyCode.C] = { hand="l", finger="Middle", name="左中指" },
        [Enum.KeyCode.V] = { hand="l", finger="Ring",   name="左无名指" },
        [Enum.KeyCode.B] = { hand="l", finger="Pinky",  name="左小指" },
        [Enum.KeyCode.N] = { hand="l", finger="Fist",   name="左拳" },
    }

    local heldFingers = {}
    local preFingerState = nil

    local function saveState()
        return {
            rThumb=Gesture.rThumb, rIndex=Gesture.rIndex, rMiddle=Gesture.rMiddle,
            rRing=Gesture.rRing, rPinky=Gesture.rPinky, rFist=Gesture.rFist,
            lThumb=Gesture.lThumb, lIndex=Gesture.lIndex, lMiddle=Gesture.lMiddle,
            lRing=Gesture.lRing, lPinky=Gesture.lPinky, lFist=Gesture.lFist,
        }
    end

    local function loadState(st)
        if not st then return end
        applyGesture(st)
    end

    task.spawn(function()
        for _ = 1, 100 do
            pcall(function() RunService:UnbindFromRenderStep("Inputs") end)
            task.wait(0.1)
        end
    end)

    pcall(function()
        local pmMT = getrawmetatable(vrm.PropManager)
        if pmMT and rawget(pmMT, "GetBestGrabPartInRadius") then
            local orig = pmMT.GetBestGrabPartInRadius
            setreadonly(pmMT, false)
            pmMT.GetBestGrabPartInRadius = function(self, root, prox, radius, scale, ...)
                return orig(self, root, prox, (radius or 0) * 3.5, scale, ...)
            end
            setreadonly(pmMT, true)
        end
        local cmMT = getrawmetatable(vrm.CharacterManager)
        if cmMT and rawget(cmMT, "GetClosestCharacterInRadius") then
            local orig = cmMT.GetClosestCharacterInRadius
            setreadonly(cmMT, false)
            cmMT.GetClosestCharacterInRadius = function(self, pos, radius, ...)
                return orig(self, pos, (radius or 0) * 3.5, ...)
            end
            setreadonly(cmMT, true)
        end
    end)

    local function setScale(n)
        n = math.clamp(math.floor(n + 0.5), 1, 10)
        S.scale = n
        if scaleVal then pcall(function() scaleVal.Value = n / 10 end) end
        if vrm and vrm.DataManager and vrm.DataManager.SettingsManager then
            pcall(function() vrm.DataManager.SettingsManager:SetValue("vrscale", n) end)
        end
    end
    setScale(10)

    cam.HeadLocked = true
    local yaw, pitch
    do
        local lv = cam.CFrame.LookVector
        yaw   = math.atan2(-lv.X, -lv.Z)
        pitch = math.asin(math.clamp(lv.Y, -1, 1))
    end
    local camPos = cam.CFrame.Position
    local keys = {}

    local function setLook(v)
        S.look = v
        UIS.MouseBehavior    = v and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = not v
    end
    setLook(true)

    -- ============================================================
    -- 输入处理
    -- ============================================================
    UIS.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.Keyboard then
            keys[io.KeyCode] = true

            -- F / G 切换旋转目标
            if io.KeyCode == Enum.KeyCode.F then
                rotTarget = "right"
                print("[NoVR] 旋转目标: 右手")
            end
            if io.KeyCode == Enum.KeyCode.G then
                rotTarget = "left"
                print("[NoVR] 旋转目标: 左手")
            end

            if io.KeyCode == Enum.KeyCode.LeftAlt then setLook(not S.look) end
            if io.KeyCode == Enum.KeyCode.Equals  then setScale(S.scale + 1) end
            if io.KeyCode == Enum.KeyCode.Minus   then setScale(S.scale - 1) end

            if Input and io.KeyCode == Enum.KeyCode.E then
                applyGesture({rIndex=1, rFist=0, rThumb=0})
            end
            if Input and io.KeyCode == Enum.KeyCode.Q then
                applyGesture({lIndex=1, lFist=0, lThumb=0})
            end

            local preset = PresetKeys[io.KeyCode]
            if preset and Presets[preset] then
                applyGesture(Presets[preset])
                print("[NoVR] 动作: " .. Presets[preset].presetName)
            end

            if keys[Enum.KeyCode.LeftControl] or keys[Enum.KeyCode.RightControl] then
                local presetCtrl = PresetKeysCtrl[io.KeyCode]
                if presetCtrl and Presets[presetCtrl] then
                    applyGesture(Presets[presetCtrl])
                    print("[NoVR] 动作: " .. Presets[presetCtrl].presetName)
                end
            end

            local fk = FingerKeys[io.KeyCode]
            if fk then
                if not next(heldFingers) then
                    preFingerState = saveState()
                end
                heldFingers[io.KeyCode] = true
                local g = {}
                g[fk.hand .. fk.finger] = 1
                applyGesture(g)
            end

        elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
            if Input then applyGesture({rFist=1, rIndex=1}) end
        elseif io.UserInputType == Enum.UserInputType.MouseButton2 then
            if Input then applyGesture({lFist=1, lIndex=1}) end
        elseif io.UserInputType == Enum.UserInputType.MouseButton3 then
            middleMouseHeld = true
            print("[NoVR] 手旋转模式开启，目标: " .. rotTarget)
        end
    end)

    UIS.InputEnded:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.Keyboard then
            keys[io.KeyCode] = false

            if io.KeyCode == Enum.KeyCode.F or io.KeyCode == Enum.KeyCode.G then
                if not middleMouseHeld then
                    rotTarget = "both"
                    print("[NoVR] 旋转目标恢复: 双手")
                end
            end

            if Input and io.KeyCode == Enum.KeyCode.E then
                applyGesture({rIndex=0})
            end
            if Input and io.KeyCode == Enum.KeyCode.Q then
                applyGesture({lIndex=0})
            end

            local fk = FingerKeys[io.KeyCode]
            if fk then
                heldFingers[io.KeyCode] = nil
                if not next(heldFingers) then
                    loadState(preFingerState)
                    preFingerState = nil
                else
                    local g = {}
                    g[fk.hand .. fk.finger] = 0
                    applyGesture(g)
                end
            end

        elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
            if Input then applyGesture({rFist=0, rIndex=0}) end
        elseif io.UserInputType == Enum.UserInputType.MouseButton2 then
            if Input then applyGesture({lFist=0, lIndex=0}) end
        elseif io.UserInputType == Enum.UserInputType.MouseButton3 then
            middleMouseHeld = false
            rotTarget = "both"
            print("[NoVR] 手旋转模式关闭，目标恢复: 双手")
        end
    end)

    UIS.InputChanged:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseWheel then
            S.reach = math.clamp(S.reach - io.Position.Z * 0.07, 0.15, 2.5)
        end
    end)

    RunService:BindToRenderStep("NoVR_Control", Enum.RenderPriority.Camera.Value + 1, function(dt)
        -- 手旋转模式：鼠标只控制手，不控制视角
        if middleMouseHeld then
            local d = UIS:GetMouseDelta()
            local target = HandRot[rotTarget]
            target.yaw   = target.yaw   - d.X * 0.008
            target.pitch = math.clamp(target.pitch - d.Y * 0.008, -1.5, 1.5)
            -- 锁定鼠标中心，但不转视角
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        else
            -- 正常视角控制
            if S.look then
                local d = UIS:GetMouseDelta()
                yaw   = yaw - d.X * S.sens
                pitch = math.clamp(pitch - d.Y * S.sens, -1.45, 1.45)
                UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            end
        end

        local rot = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)

        -- 移动控制
        local hs  = cam.HeadScale; if hs <= 1 then hs = S.scale * 6 end
        local spd = (10 + S.scale * 4) * hs * S.moveK
        local mv  = Vector3.zero
        if keys[Enum.KeyCode.W] then mv += Vector3.new(0,0,-1) end
        if keys[Enum.KeyCode.S] then mv += Vector3.new(0,0, 1) end
        if keys[Enum.KeyCode.A] then mv += Vector3.new(-1,0,0) end
        if keys[Enum.KeyCode.D] then mv += Vector3.new( 1,0,0) end
        if keys[Enum.KeyCode.Space]     then mv += Vector3.new(0, 1,0) end
        if keys[Enum.KeyCode.LeftShift] then mv += Vector3.new(0,-1,0) end
        if mv.Magnitude > 0 then camPos = camPos + (rot * mv.Unit) * spd * dt end

        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = CFrame.new(camPos) * rot

        if Input then
            Input.directionLateral  = Vector2.zero
            Input.directionVertical = 0
            Input.turnDirection     = 0
        end
    end)

    -- ============================================================
    -- 左下角 HUD
    -- ============================================================
    pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "NoVR_HUD"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
        gui.Parent = lp:WaitForChild("PlayerGui")

        local mainFrame = Instance.new("Frame", gui)
        mainFrame.AnchorPoint = Vector2.new(0,1)
        mainFrame.Position = UDim2.new(0,10,1,-10)
        mainFrame.Size = UDim2.new(0,400,0,195)
        mainFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
        mainFrame.BackgroundTransparency = 0.3
        mainFrame.BorderSizePixel = 0

        local corner = Instance.new("UICorner", mainFrame)
        corner.CornerRadius = UDim.new(0,8)

        local lbl = Instance.new("TextLabel", mainFrame)
        lbl.Size = UDim2.new(1,-10,1,-10)
        lbl.Position = UDim2.new(0,5,0,5)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255,255,255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 13

        local modeText = HAS_FULL_FINGERS and "[全手指]" or "[简化-Fist代理]"

        local function buildHudText()
            local lines = {}
            table.insert(lines, "[VR Hands :: No-VR Pro] " .. modeText)
            table.insert(lines, "鼠标-视角 | WASD-飞行 | 空格/Shift-上/下")
            table.insert(lines, "左键/右键-抓取(右/左) | E/Q-捏玩家(右/左)")
            table.insert(lines, "滚轮-手距离 | +/-体型:" .. math.floor(S.scale) .. "/10 | Alt-鼠标")
            local rotStatus = middleMouseHeld and ("[旋转中 " .. rotTarget .. "]") or ""
            table.insert(lines, "中键-旋转手 | F-只转右手 | G-只转左手 " .. rotStatus)
            table.insert(lines, "当前动作: " .. Gesture.presetName)
            local rHand = string.format("R[%d%d%d%d%d|%d]",
                Gesture.rThumb, Gesture.rIndex, Gesture.rMiddle, Gesture.rRing, Gesture.rPinky, Gesture.rFist)
            local lHand = string.format("L[%d%d%d%d%d|%d]",
                Gesture.lThumb, Gesture.lIndex, Gesture.lMiddle, Gesture.lRing, Gesture.lPinky, Gesture.lFist)
            table.insert(lines, rHand .. "  " .. lHand)
            return table.concat(lines, "\n")
        end

        RunService.Heartbeat:Connect(function()
            lbl.Text = buildHudText()
        end)
    end)

    -- ============================================================
    -- 右上角教程面板
    -- ============================================================
    pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "NoVR_Tutorial"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
        gui.Parent = lp:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame", gui)
        frame.AnchorPoint = Vector2.new(1,0)
        frame.Position = UDim2.new(1,-10,0,10)
        frame.Size = UDim2.new(0,310,0,410)
        frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
        frame.BackgroundTransparency = 0.25
        frame.BorderSizePixel = 0

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0,8)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1,0,0,28)
        title.Position = UDim2.new(0,0,0,0)
        title.BackgroundTransparency = 1
        title.Text = "动作按键教程"
        title.TextColor3 = Color3.fromRGB(0,255,170)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1,-16,1,-36)
        lbl.Position = UDim2.new(0,8,0,32)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255,255,255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 12
        lbl.TextWrapped = true

        local tutorialLines = {
            "--- 数字键 快捷动作 ---",
            "1 = 张开手掌     6 = OK",
            "2 = 握拳         7 = 摇滚",
            "3 = 食指指       8 = 中指",
            "4 = 剪刀手       9 = 电话",
            "5 = 点赞         0 = 手枪指",
            "",
            "--- Ctrl + 数字键 ---",
            "Ctrl+1 = 右手捏取   Ctrl+6 = 牛角",
            "Ctrl+2 = 右手抓取   Ctrl+7 = Shaka",
            "Ctrl+3 = 左手捏取   Ctrl+8 = 敬礼",
            "Ctrl+4 = 左手抓取   Ctrl+9 = 祈祷",
            "Ctrl+5 = 挥手       Ctrl+0 = 爪子",
            "",
            "--- 单根手指 (按住) ---",
            "T = 右拇指    Z = 左拇指",
            "Y = 右食指    X = 左食指",
            "U = 右中指    C = 左中指",
            "I = 右无名指  V = 左无名指",
            "O = 右小指    B = 左小指",
            "P = 右拳      N = 左拳",
            "",
            "--- 手旋转 ---",
            "按住鼠标中键 + 移动 = 旋转双手",
            "按住 F + 中键 = 只旋转右手",
            "按住 G + 中键 = 只旋转左手",
            "旋转时视角锁定不动",
            "",
            "提示: 按住手指键摆出姿势，",
            "松开后自动恢复上一个动作。",
        }

        if not HAS_FULL_FINGERS then
            table.insert(tutorialLines, "")
            table.insert(tutorialLines, "[注意] 此服务器只支持")
            table.insert(tutorialLines, "拇指/食指/握拳，")
            table.insert(tutorialLines, "其它手指自动用握拳度模拟。")
        end

        lbl.Text = table.concat(tutorialLines, "\n")
    end)

    print("[NoVR Pro] 控制已激活。F=右手旋转 G=左手旋转 中键=旋转。按F9查看日志。")
end)
]==]

if queue_on_teleport then
    queue_on_teleport(hrs)
elseif syn and syn.queue_on_teleport then
    syn.queue_on_teleport(hrs)
end

TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)