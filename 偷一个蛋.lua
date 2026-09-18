loadstring(game:HttpGet('https://raw.githubusercontent.com/senarblx/sena/refs/heads/main/senav3go'))();
task.spawn(function()
    task.wait(6)
    local hui=gethui and gethui() or game:GetService('CoreGui')
    local u=hui:FindFirstChild('SenaUI')
    local n=hui:FindFirstChild('SenaNotify')
    local t={
        ["Steal Players"]="偷玩家", ["Hatchery"]="孵化场", ["Barn"]="仓库", ["Rift"]="裂隙", ["Partner Fuse"]="伙伴融合", ["Upgrades"]="升级", ["Extras"]="其他", ["Presets"]="预设", ["HATCH & STEAL"]="孵化 & 偷窃", ["HATCHERY"]="孵化场",
        ["BARN"]="仓库", ["RIFT"]="裂隙", ["EXTRAS"]="其他", ["EGG ESP"]="蛋透视", ["PRIORITY"]="优先", ["EGGS"]="蛋", ["Sell"]="出售", ["Auto Steal"]="自动偷窃", ["Egg Checker"]="蛋检查器", ["Anti Hit Guard"]="防击保护",
        ["Drop Before Finish Line"]="终点线前掉落", ["Bat Aura"]="蝙蝠光环", ["Egg Filter"]="蛋筛选", ["Always Grab"]="始终抓取", ["Glide"]="滑翔", ["Fly Speed"]="飞行速度", ["Fly Height"]="飞行高度", ["Glide Speed"]="滑翔速度", ["Match Game Speed"]="匹配游戏速度", ["Movement Guard"]="移动保护",
        ["Movement Mode"]="移动模式", ["Hop When Nothing Matches"]="无匹配时换服", ["Find Private Server"]="找私服", ["Hop If Players Above"]="人数超过时换服", ["Hop Cooldown"]="换服冷却", ["Find Quietest Server"]="找最安静服务器", ["Webhook URL"]="Webhook地址", ["Notify Rarities"]="通知稀有度", ["Notify Species"]="通知物种", ["Hatch Webhook"]="孵化通知",
        ["Egg Spawn Webhook"]="蛋生成通知", ["Egg Collected Webhook"]="蛋收集通知", ["Pets Sold Webhook"]="宠物出售通知", ["Test Webhook"]="测试通知", ["Auto Steal From Players"]="从玩家自动偷窃", ["Rarity Filter"]="稀有度筛选", ["Steal From Specific Player (Teleport Strike)"]="从指定玩家偷窃", ["Players in this server"]="本服务器玩家", ["Steal History"]="偷窃历史", ["Clear History"]="清除历史",
        ["Auto Place"]="自动放置", ["Placement Order"]="放置顺序", ["Species Allowed"]="允许物种", ["Rarities Allowed"]="允许稀有度", ["Mutations Allowed"]="允许变异", ["Place Everything Now"]="立即全部放置", ["Auto Apply Mutation"]="自动应用变异", ["Apply Order"]="应用顺序", ["Select Egg"]="选择蛋", ["Retry Until Mutated"]="重试直到变异",
        ["Apply Mutation Now"]="立即应用变异", ["Auto Hatch"]="自动孵化", ["Hatch Everything Ready"]="孵化所有就绪", ["Auto Equip Best"]="自动装备最佳", ["Collect Offline Income"]="收集离线收入", ["Auto Sell"]="自动出售", ["Rarities to Sell"]="出售稀有度", ["Species to Sell"]="出售物种", ["Sell Pets Now"]="立即出售宠物", ["Auto Sell Eggs"]="自动出售蛋",
        ["Egg Rarities to Sell"]="出售蛋稀有度", ["Egg Species to Sell"]="出售蛋物种", ["Sell Selected Eggs Now"]="立即出售选中的蛋", ["Auto Favorite"]="自动收藏", ["Favorite Rule"]="收藏规则", ["Rarities to Keep"]="保留稀有度", ["Species to Keep"]="保留物种", ["Favorite Matching Now"]="立即收藏匹配", ["Auto Fuse"]="自动融合", ["Fusion Rule"]="融合规则",
        ["Rarities to Fuse"]="融合稀有度", ["Species to Fuse"]="融合物种", ["Fuse One Pair"]="融合一组", ["Auto Trade-In"]="自动交换", ["Auto Add Pets to Rift Slots"]="自动添加宠物到裂隙槽", ["Auto Free Reroll"]="自动免费重随", ["Prioritise Rift Eggs in Auto Steal"]="优先裂隙蛋", ["Steal Rift Eggs Only"]="只偷裂隙蛋", ["Target Banners"]="目标横幅", ["Auto Add Matching Pets Now"]="立即添加匹配宠物",
        ["Trade-In Once"]="交换一次", ["Use Free Reroll"]="使用免费重随", ["Place Recipe Eggs in Pen"]="放置配方蛋", ["Teleport to Rift Machine"]="传送到裂隙机器", ["Refresh Status"]="刷新状态", ["Auto Fight Boss"]="自动打Boss", ["Neutralise Boss Hazards"]="清除Boss危险", ["Hover Fight"]="悬浮战斗", ["Return to Plot After Kill"]="击杀后回基地", ["Arena Travel Speed"]="竞技场移动速度",
        ["Enter Arena Now"]="立即进竞技场", ["Leave Arena"]="离开竞技场", ["Swing Bat Once"]="挥棒一次", ["Auto Buy Rift Shop"]="自动买裂隙商店", ["Rift Shop Item"]="裂隙商店物品", ["Auto Claim Boss Milestones"]="自动领取Boss里程碑", ["Auto Train"]="自动训练", ["Auto Upgrade Treadmill"]="自动升级跑步机", ["Upgrade Treadmill"]="升级跑步机", ["Auto Upgrade Base"]="自动升级基地",
        ["Upgrade Base"]="升级基地", ["Auto Claim Almanac"]="自动领取图鉴", ["Claim Almanac Now"]="立即领取图鉴", ["Noclip"]="穿墙", ["Instant Grab"]="瞬间抓取", ["Waypoint"]="路径点", ["Respawn Point"]="重生点", ["Teleport"]="传送", ["Egg Logs"]="蛋日志", ["Egg Board"]="蛋板",
        ["Inventory & Base"]="背包 & 基地", ["Open Every Window"]="打开所有窗口", ["Botting Mode (Blackscreen)"]="挂机模式(黑屏)", ["Startup Boost"]="启动加速", ["Uncap FPS (240)"]="解锁帧率(240)", ["FPS Boost (Heavy)"]="FPS增强(重)", ["Apply Boost Now"]="立即应用加速", ["Hide All Pets (Max FPS)"]="隐藏所有宠物(最大FPS)", ["Hide Owner Eggs Placed"]="隐藏自己放置的蛋", ["Hide Other Eggs Placed"]="隐藏他人放置的蛋",
        ["Hide All Placed Eggs"]="隐藏所有放置的蛋", ["Hide Plot Visuals & Fences"]="隐藏基地装饰 & 围栏", ["Hide Floating Money Text"]="隐藏浮动金钱文字", ["Hide Treadmill Effects & Popups"]="隐藏跑步机特效 & 弹窗", ["Clean All Visuals Now (Max FPS)"]="立即清理所有特效(最大FPS)", ["Anti AFK"]="防AFK", ["Auto Reconnect"]="自动重连", ["Auto Execute (Global & Rejoin)"]="自动执行(全局 & 重进)", ["Save Settings Now"]="立即保存设置", ["Load Saved Settings"]="加载保存的设置",
        ["Config Name"]="配置名称", ["Saved Configs"]="保存的配置", ["Auto Load"]="自动加载", ["Rejoin This Server"]="重进此服务器", ["Stop & Unload"]="停止 & 卸载", ["Send"]="发送", ["Copy Job ID"]="复制服务器ID", ["How it works"]="如何运作", ["Rarity"]="稀有度", ["Status"]="状态",
        ["Tier"]="层级", ["Your Pet"]="你的宠物", ["Auto Select"]="自动选择", ["Recipes"]="配方", ["Sena - Steal an Egg"]="ANSN - 偷一个蛋", ["Sena"]="ANSN", ["Disabled"]="已禁用", ["Locked"]="已锁定", ["All"]="全部", ["Base"]="基础",
        ["Save"]="保存", ["Load"]="加载", ["Delete"]="删除", ["Refresh"]="刷新", ["Export"]="导出", ["Import"]="导入", ["Import Data"]="导入数据", ["Not broadcasting."]="未广播", ["Nobody else is in this server."]="本服务器没有其他玩家", ["No player steals yet."]="暂无玩家偷窃记录",
        ["Nobody is broadcasting right now."]="当前无人广播", ["No Egg Carried"]="未携带蛋", ["Not spawned"]="未生成", ["Your Shrine Status"]="你的神殿状态", ["Players looking for a partner"]="寻找伙伴的玩家", ["Broadcast: Find Partner"]="广播: 寻找伙伴", ["Steal An Egg"]="偷一个蛋", ["Loaded. Press Right Ctrl to hide or show the panel."]="已加载。按右Ctrl显示/隐藏面板。", ["Sena is free"]="Sena是免费的", ["Rift: Unknown"]="裂隙: 未知",
        ["Recipe  (0/3)"]="配方  (0/3)", ["Live Results"]="实时结果", ["[IDLE]"]="[空闲]", ["Common"]="普通", ["Uncommon"]="罕见", ["Rare"]="稀有", ["Epic"]="史诗", ["Legendary"]="传说", ["Mythic"]="神话", ["Secret"]="秘密",
        ["Godly"]="神级", ["Divine"]="神级", ["Eternal"]="永恒", ["Shiny"]="闪光", ["Safe Zone"]="安全区", ["Server: 5/7"]="服务器: 5/7", ["Server: 4/7"]="服务器: 4/7", ["Keeper"]="管理员", ["Playbook"]="说明", ["Community"]="社区",
        ["Windows"]="窗口", ["Framerate"]="帧率", ["Session"]="会话", ["Saved Setups"]="保存的配置", ["Configuration Notice"]="配置提示", ["Botting Telemetry"]="挂机数据", ["STRIP HEAVY VISUALS"]="移除重特效", ["Auto Reconnect & Execute"]="自动重连 & 执行", ["Getaway"]="移动", ["Server Hop"]="换服",
        ["Steal Webhook"]="偷窃通知", ["Place Eggs"]="放置蛋", ["Incubator"]="孵化器", ["Equip & Collect"]="装备 & 收集", ["Favorite"]="收藏", ["Fuse"]="融合", ["Manual Actions"]="手动操作", ["Rift Status"]="裂隙状态", ["Rift Shop & Mastery"]="裂隙商店 & 精通", ["Partner Shrine"]="伙伴神殿",
        ["Treadmill"]="跑步机", ["Almanac"]="图鉴", ["Roaming"]="漫游", ["Area List"]="区域列表", ["Rarity List"]="稀有度列表", ["Name List"]="名称列表", ["Mutation List"]="变异列表", ["Min Value ($/s)"]="最低价值($/s)", ["Min Weight (Kg)"]="最低重量(Kg)", ["ESP Rarities"]="ESP稀有度",
        ["ESP Species"]="ESP物种", ["ESP Min Value ($/s)"]="ESP最低价值", ["ESP Min Weight (kg)"]="ESP最低重量", ["Support & Donate"]="支持 & 赞助", ["Get Key & Support"]="获取密钥 & 支持", ["Donator Key Activation"]="赞助密钥激活", ["Redeem Key"]="兑换密钥", ["Get Key"]="获取密钥", ["Channels & Rooms"]="频道 & 房间", ["Live Network"]="实时网络",
        ["Rooms"]="房间", ["General"]="综合", ["Indonesian"]="印尼语", ["Philippines"]="菲律宾语", ["Vietnam"]="越南语", ["Brazilian"]="巴西语",
    }
    local done={}
    local function sc(c) if not c then return end
        pcall(function() for _,x in ipairs(c:GetDescendants()) do
            if (x:IsA('TextLabel') or x:IsA('TextButton')) and x.Text and #x.Text<300 and not done[x] then
                local s=x.Text local chg=false
                for e,v in pairs(t) do local ns=s:gsub(e,v) if ns~=s then s=ns chg=true end end
                if chg then x.Text=s done[x]=true end end end end) end
    for i=1,8 do task.wait(2) sc(u) sc(n) end
end)
