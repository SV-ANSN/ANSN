local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local lines = {}
local function add(k, v)
	lines[#lines + 1] = tostring(k) .. ": " .. tostring(v)
end

-- ---------- 1. Roblox 账号身份（最可靠，换号才变） ----------
add("UserName", lp and lp.Name)
add("DisplayName", lp and lp.DisplayName)
add("UserId", lp and lp.UserId)
add("AccountAge(天)", lp and lp.AccountAge)
add("PlaceId", game.PlaceId)
add("JobId", game.JobId)

-- ---------- 2. 注入器 / 执行器名称 ----------
local execName = "未知"
pcall(function()
	if type(identifyexecutor) == "function" then
		execName = tostring(identifyexecutor())
	elseif type(getexecutorname) == "function" then
		execName = tostring(getexecutorname())
	end
end)
add("Executor", execName)

-- ---------- 3. 设备指纹 / HWID：手机注入器函数名五花八门，逐个试 ----------
local hwidCandidates = {
	{ "gethwid",        function() return gethwid() end },
	{ "get_hwid",       function() return get_hwid() end },
	{ "gethuid",        function() return gethuid() end },
	{ "getdeviceid",    function() return getdeviceid() end },
	{ "getdeviceinfo",  function() return getdeviceinfo() end },
	{ "syn.gethwid",    function() return syn.gethwid() end },
	{ "syn.device_id",  function() return syn.device_id end },
}
local foundHWID = nil
for _, c in ipairs(hwidCandidates) do
	local ok, res = pcall(c[2])
	if ok and res ~= nil and tostring(res) ~= "" then
		add("HWID[" .. c[1] .. "]", res)
		if not foundHWID then foundHWID = tostring(res) end
	end
end
if not foundHWID then
	add("HWID", "该注入器未提供任何 HWID 接口（只能按 UserId 锁）")
end

-- ---------- 4. Roblox 客户端 ID（辅助指纹，换机/重装才会变） ----------
pcall(function()
	local ok, as = pcall(game.GetService, game, "RbxAnalyticsService")
	if ok and as then add("ClientId", as:GetClientId()) end
end)

-- ---------- 5. 这个注入器到底提供了哪些接口（方便后续加锁手段） ----------
local probeList = {
	"gethwid", "get_hwid", "gethuid", "getdeviceid", "getdeviceinfo",
	"identifyexecutor", "getexecutorname", "syn", "KRNL_LOADED",
	"is_synapse_function", "getgenv", "request", "http_request",
	"setclipboard", "writefile", "readfile", "isfile",
}
local available = {}
for _, n in ipairs(probeList) do
	local ok, v = pcall(function() return getfenv(0)[n] end)
	if ok and v ~= nil then available[#available + 1] = n end
end
add("可用接口", table.concat(available, ", "))

-- ---------- 6. 输出：通知 + 控制台 + 剪贴板 + 落盘 ----------
local text = "<<<ANSID_BEGIN>>>\n" .. table.concat(lines, "\n") .. "\n<<<ANSID_END>>>"

print("===== ANSN 身份采集 =====")
print(text)

pcall(function()
	if type(setclipboard) == "function" then setclipboard(text) end
end)
pcall(function()
	if type(writefile) == "function" then writefile("ANSN_身份信息.txt", text) end
end)

-- 屏幕显示：手机端没有控制台，不弹窗他根本看不到 → 用纯 Instance 画一个框，
-- 不依赖任何执行器接口（PC/手机都能显示），让他长按全选复制
pcall(function()
	local gui = Instance.new("ScreenGui")
	gui.Name = "AnsIdentityGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(580, 440)
	frame.Position = UDim2.new(0.5, -290, 0.5, -220)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.fromOffset(10, 8)
	title.BackgroundTransparency = 1
	title.Text = "身份采集 —— 长按下面内容全选复制，发给作者"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 15
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 1, -66)
	box.Position = UDim2.fromOffset(10, 52)
	box.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
	box.BorderSizePixel = 0
	box.Text = text
	box.TextEditable = true
	box.ClearTextOnFocus = false
	box.TextWrapped = true
	box.MultiLine = true
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top
	box.TextColor3 = Color3.fromRGB(235, 235, 235)
	box.TextSize = 13
	box.Font = Enum.Font.Code
	box.Parent = frame
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
end)
pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "身份信息已采集",
		Text = "已复制到剪贴板，请整段发给SV",
		Duration = 10,
	})
end)
