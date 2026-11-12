---------------------------------------------------------------------------
-- SERVICES & LOCAL REFERENCES
---------------------------------------------------------------------------
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local CoreGui             = game:GetService("CoreGui")
local CollectionService   = game:GetService("CollectionService")
local VirtualUser         = game:GetService("VirtualUser")
local HttpService         = game:GetService("HttpService")

local LocalPlayer         = Players.LocalPlayer
local Camera              = workspace.CurrentCamera

---------------------------------------------------------------------------
-- EXECUTOR COMPATIBILITY LAYER
---------------------------------------------------------------------------
local function getGuiParent()
    local success, parent = pcall(function()
        return (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    end)
    return (success and parent) or LocalPlayer:WaitForChild("PlayerGui")
end

local function safeFireProximityPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    local oldDist = prompt.MaxActivationDistance
    local oldLOS  = prompt.RequiresLineOfSight
    pcall(function()
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight   = false
    end)
    
    local fired = false
    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt, 0, false)
            fireproximityprompt(prompt, 0, true)
            task.wait(prompt.HoldDuration or 0)
            fireproximityprompt(prompt, 0, false)
            fired = true
        end)
    end
    
    if not fired and prompt.InputHoldBegin and prompt.InputHoldEnd then
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0)
            prompt:InputHoldEnd()
            fired = true
        end)
    end
    
    pcall(function()
        prompt.MaxActivationDistance = oldDist
        prompt.RequiresLineOfSight   = oldLOS
    end)
    return fired
end

---------------------------------------------------------------------------
-- GAME REMOTES & REFERENCES (Discovered from Client Dump)
---------------------------------------------------------------------------
local CasePlacementFolder   = ReplicatedStorage:WaitForChild("CasePlacement", 10)
local PlaceRemote           = CasePlacementFolder and CasePlacementFolder:WaitForChild("Place", 10)
local BaseUpgradeRequest    = CasePlacementFolder and CasePlacementFolder:WaitForChild("BaseUpgradeRequest", 10)
local HatchPortraitReady    = CasePlacementFolder and CasePlacementFolder:WaitForChild("HatchPortraitReady", 10)

local TreadmillFolder       = ReplicatedStorage:WaitForChild("Treadmill", 10)
local TreadmillUpgradeReq   = TreadmillFolder and TreadmillFolder:WaitForChild("UpgradeRequest", 10)

local BaseMenuFolder        = ReplicatedStorage:WaitForChild("BaseMenu", 10)
local BaseMenuRequest       = BaseMenuFolder and BaseMenuFolder:WaitForChild("Request", 10)

local CardIndexFolder       = ReplicatedStorage:WaitForChild("CardIndex", 10)
local IndexGetProgress      = CardIndexFolder and CardIndexFolder:WaitForChild("GetProgress", 10)
local IndexClaimReward      = CardIndexFolder and CardIndexFolder:WaitForChild("ClaimReward", 10)
local IndexClaimBatLevel    = CardIndexFolder and CardIndexFolder:WaitForChild("ClaimBatLevel", 10)
local IndexMarkViewed       = CardIndexFolder and CardIndexFolder:WaitForChild("MarkViewed", 10)

local DailyRewardsFolder    = ReplicatedStorage:WaitForChild("DailyRewards", 10)
local DailyRemotes          = DailyRewardsFolder and DailyRewardsFolder:WaitForChild("Remotes", 10)
local DailyClaimRemote      = DailyRemotes and DailyRemotes:WaitForChild("Claim", 10)

local TrailsFolder          = ReplicatedStorage:WaitForChild("Trails", 10)
local TrailRequestRemote    = TrailsFolder and TrailsFolder:WaitForChild("TrailRequest", 10)

local FreeGiftFolder        = ReplicatedStorage:WaitForChild("FreeGift", 10)
local FreeGiftClaimRemote   = FreeGiftFolder and FreeGiftFolder:WaitForChild("Claim", 10)

local BatFolder             = ReplicatedStorage:WaitForChild("Bat", 10)
local BatSwingRemote        = BatFolder and BatFolder:WaitForChild("Swing", 10)

local InventoryFolder       = ReplicatedStorage:WaitForChild("Inventory", 10)
local SellRequestRemote     = InventoryFolder and InventoryFolder:WaitForChild("SellRequest", 10)

---------------------------------------------------------------------------
-- GAME CONSTANTS & DEFINITIONS
---------------------------------------------------------------------------
local ZONES = {
    "FOREST",
    "LAKE",
    "DESERT",
    "JUNGLE",
    "SNOW",
    "VOLCANO",
    "ABYSS OCEAN",
    "PREHISTORIC",
    "COSMIC",
    "CHERRYBLOSSOM",
    "GLITCH",
    "CELESTIAL",
    "HARVESTFARM"
}

local RARITIES = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Cosmic",
    "Secret",
    "Eternal",
    "Divine",
    "Exclusive",
    "Admin"
}

local RARITY_TIERS = {
    ["Common"]     = 1,
    ["Uncommon"]   = 2,
    ["Rare"]       = 3,
    ["Epic"]       = 4,
    ["Legendary"]  = 5,
    ["Mythic"]     = 6,
    ["Cosmic"]     = 7,
    ["Secret"]     = 8,
    ["Eternal"]    = 9,
    ["Divine"]     = 10,
    ["Exclusive"]  = 11,
    ["Admin"]      = 12
}

local RARITY_COLORS = {
    ["Common"]     = Color3.fromRGB(205, 208, 220),
    ["Uncommon"]   = Color3.fromRGB(95, 225, 85),
    ["Rare"]       = Color3.fromRGB(60, 145, 255),
    ["Epic"]       = Color3.fromRGB(175, 85, 255),
    ["Legendary"]  = Color3.fromRGB(255, 200, 40),
    ["Mythic"]     = Color3.fromRGB(255, 75, 75),
    ["Cosmic"]     = Color3.fromRGB(255, 95, 225),
    ["Secret"]     = Color3.fromRGB(80, 255, 195),
    ["Eternal"]    = Color3.fromRGB(0, 220, 255),
    ["Divine"]     = Color3.fromRGB(255, 245, 165),
    ["Exclusive"]  = Color3.fromRGB(255, 120, 240),
    ["Admin"]      = Color3.fromRGB(255, 45, 85)
}

local TRAIL_LIST = {
    { Id = "grey",     Cost = 100 },
    { Id = "green",    Cost = 5000 },
    { Id = "blue",     Cost = 75000 },
    { Id = "purple",   Cost = 1500000 },
    { Id = "golden",   Cost = 30000000 },
    { Id = "red",      Cost = 750000000 },
    { Id = "galaxy",   Cost = 15000000000 },
    { Id = "divine",   Cost = 300000000000 }
}

---------------------------------------------------------------------------
-- CONFIGURATION & STATE
---------------------------------------------------------------------------
local Config = {
    -- Auto Steal Eggs
    AutoStealEggs       = false,
    SnipeAdminEggs      = false, -- Dedicated Admin & Exclusive Egg Global Sniper
    StealZoneFilters    = { ["CELESTIAL"] = true, ["COSMIC"] = true },
    StealRarityFilters  = { ["Common"] = true, ["Uncommon"] = true, ["Rare"] = true, ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true, ["Cosmic"] = true, ["Secret"] = true, ["Eternal"] = true, ["Divine"] = true, ["Exclusive"] = true, ["Admin"] = true },
    StealPriority       = "Nearest", -- "Nearest", "Biggest", "Random"
    StealStatus         = "Idle",

    -- Eggs (Plot)
    AutoPlaceEggs       = false,
    PlaceRarityFilters  = { ["Common"] = true, ["Uncommon"] = true, ["Rare"] = true, ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true, ["Cosmic"] = true, ["Secret"] = true, ["Eternal"] = true, ["Divine"] = true, ["Exclusive"] = true, ["Admin"] = true },
    AutoHatch           = false,
    AutoEquipBest       = false,

    -- Treadmill
    AutoGoOnTreadmill   = false,
    AutoUpgradeTreadmill= false,

    -- Progression
    AutoUpgradeBase     = false,
    AutoClaimIndex      = false,
    AutoClaimDaily      = false,
    AutoBuyTrail        = false,
    AutoBuyCosmetics    = false,

    -- Egg ESP
    EggESP              = false,
    ESPRarityFilters    = { ["Common"] = true, ["Uncommon"] = true, ["Rare"] = true, ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true, ["Cosmic"] = true, ["Secret"] = true, ["Eternal"] = true, ["Divine"] = true, ["Exclusive"] = true, ["Admin"] = true },

    -- Extra Systems
    AutoClaimFreeGift   = false,
    AntiRagdoll         = true,
    AutoBatAura         = false,
    InvisibleGhost      = false,
    GuardESP            = false,
    PlayerESP           = false,
    AutoSellJunk        = false,
    WalkSpeedValue      = 16,
    CustomSpeedEnabled  = false,
    InfiniteJump        = false,
    Noclip              = false,
    FlyEnabled          = false,
    AntiAFK             = true,

    -- Anti-Detect & Stealth Settings
    SafeTravelMode      = true, -- Smooth tween movement instead of instant CFrame to bypass server speed checks
    TweenSpeed          = 65,   -- Studs per second (natural speed matching in-game speed buffs)
    HumanizeDelays      = true, -- Add randomized jitter to remote calls to mimic human input

    -- Teleport Target Zone
    SelectedTeleportZone = "FOREST"
}

---------------------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------------------
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getMoney()
    return LocalPlayer:GetAttribute("Money") or 0
end

local function getPlayerPlot()
    local bases = workspace:FindFirstChild("PlayerBases")
    if not bases then return nil end
    local myPlotId = LocalPlayer:GetAttribute("PlotId")
    for _, base in ipairs(bases:GetChildren()) do
        if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId or (myPlotId and base:GetAttribute("BaseId") == myPlotId) then
            return base
        end
    end
    return nil
end

local function getPlotFloorPosition()
    local plot = getPlayerPlot()
    if not plot then return nil end
    local floor = plot:FindFirstChild("Floor")
    local foundation = floor and floor:FindFirstChild("Foundation")
    if foundation then
        return foundation.Position, foundation.CFrame, foundation.Size
    end
    return plot:GetPivot().Position, plot:GetPivot(), Vector3.new(20, 2, 20)
end

local function isCarryingEgg()
    if LocalPlayer:GetAttribute("CloudGuardChasing") == true then return true end
    local char = getCharacter()
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and (item:GetAttribute("IsPhotocard") == true or item:GetAttribute("CasePlacementTool") == true or item:GetAttribute("AlbumZone") ~= nil or item.Name:find("Egg") or item.Name:find("Album")) then
            return true
        end
        if item.Name == "Stolen Egg" or item.Name == "Stolen Album" then
            return true
        end
    end
    return false
end

local function getEggZone(egg)
    local zoneAttr = egg:GetAttribute("AlbumZone") or egg:GetAttribute("Zone") or egg:GetAttribute("ZoneName")
    if zoneAttr then return string.upper(tostring(zoneAttr)) end
    
    local dz = workspace:FindFirstChild("DangerZones")
    if dz then
        for _, z in ipairs(dz:GetChildren()) do
            if egg:IsDescendantOf(z) then
                local zName = z:GetAttribute("ZoneName") or z.Name
                return string.upper(tostring(zName))
            end
        end
    end
    return "UNKNOWN"
end

local function getEggSize(eggObj)
    if not eggObj then return 1 end
    local kg = eggObj:GetAttribute("AlbumWeightKg")
    if type(kg) == "number" then return kg end
    local sz = eggObj:GetAttribute("AlbumSize")
    if type(sz) == "number" then return sz end
    if eggObj:IsA("Model") then
        local cf, size = eggObj:GetBoundingBox()
        return size.X * size.Y * size.Z
    end
    return 1
end

local function getEggRarity(egg)
    -- Check Admin egg
    if egg:GetAttribute("AdminHuntEgg") == true 
       or (egg.Parent and egg.Parent.Name == "AdminEggHuntDrops") 
       or egg.Name == "AdminEgg" 
       or (egg:GetAttribute("SetId") and tostring(egg:GetAttribute("SetId")):lower():find("admin")) then
        return "Admin"
    end
    
    -- Check Exclusive egg
    if egg:GetAttribute("ExclusiveSetId") ~= nil 
       or (egg.Parent and egg.Parent.Name == "ExclusivePlacedEggs") 
       or (egg:GetAttribute("SetId") and tostring(egg:GetAttribute("SetId")):lower():find("exclusive"))
       or egg.Name:find("Exclusive") then
        return "Exclusive"
    end

    local r = egg:GetAttribute("RarityAura") or egg:GetAttribute("AlbumRarity") or egg:GetAttribute("Rarity")
    if r and RARITY_TIERS[r] then return r end
    
    -- Check billboard or title
    local label = egg:FindFirstChild("AlbumWeightLabel", true)
    if label and label:IsA("BillboardGui") then
        local text = label:FindFirstChildWhichIsA("TextLabel", true)
        if text then
            if text.Text:find("ADMIN") then return "Admin" end
            for rarityName in pairs(RARITY_TIERS) do
                if text.Text:find(rarityName) then return rarityName end
            end
        end
    end
    return "Common"
end

local function getAdminAndExclusiveEggs()
    local results = {}
    local seen = {}

    local function addTarget(obj, isAdm)
        if not obj or seen[obj] then return end
        if obj:GetAttribute("OwnerUserId") == LocalPlayer.UserId then return end
        seen[obj] = true

        local pivot = (obj:IsA("Model") and obj:GetPivot()) 
            or (obj:FindFirstChild("Handle") and obj.Handle.CFrame) 
            or (obj:GetAttribute("Ground") and CFrame.new(obj:GetAttribute("Ground"))) 
            or (obj:IsA("BasePart") and obj.CFrame)
            or (obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").CFrame)
            
        if not pivot then return end
        local rName = isAdm and "Admin" or "Exclusive"
        table.insert(results, {
            Object = obj,
            Position = pivot.Position,
            Zone = "GLOBAL",
            Rarity = rName,
            Tier = RARITY_TIERS[rName] or 12,
            Name = isAdm and "Admin Egg" or "Exclusive Egg"
        })
    end

    -- 1. Scan workspace.AdminEggHuntDrops
    local drops = workspace:FindFirstChild("AdminEggHuntDrops")
    if drops then
        for _, drop in ipairs(drops:GetChildren()) do
            addTarget(drop, true)
        end
    end

    -- 2. Scan whole workspace for Admin / Exclusive drops
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("Model") or desc:IsA("Tool") then
            if desc:GetAttribute("AdminHuntEgg") == true or desc.Name == "AdminEgg" then
                addTarget(desc, true)
            elseif desc:GetAttribute("SetId") and tostring(desc:GetAttribute("SetId")):lower():find("admin") then
                addTarget(desc, true)
            elseif desc:GetAttribute("ExclusiveSetId") ~= nil or (desc:GetAttribute("SetId") and tostring(desc:GetAttribute("SetId")):lower():find("exclusive")) then
                addTarget(desc, false)
            end
        end
    end

    return results
end

local function isEggObject(obj)
    if not (obj:IsA("Model") or obj:IsA("Tool")) then return false end
    if obj:GetAttribute("PreviewOnly") == true then return false end
    if obj:GetAttribute("RarityAura") ~= nil or obj:GetAttribute("CasePlacementTool") == true or obj:GetAttribute("AlbumRarity") ~= nil or obj:GetAttribute("AdminHuntEgg") == true then
        return true
    end
    if obj:FindFirstChild("CasePart") ~= nil then return true end
    if obj.Name:find("Egg") or obj.Name:find("Album") then return true end
    return false
end

local function getAllEligibleEggs()
    local results = {}
    local dz = workspace:FindFirstChild("DangerZones")
    local adminDrops = workspace:FindFirstChild("AdminEggHuntDrops")

    local function checkAndAdd(item)
        if isEggObject(item) then
            -- Verify it is not our own incubating egg
            if item:GetAttribute("OwnerUserId") == LocalPlayer.UserId then return end
            
            local zone = getEggZone(item)
            local rarity = getEggRarity(item)
            
            -- Filter check
            local zonePass = false
            if next(Config.StealZoneFilters) == nil then
                zonePass = true
            else
                for z, active in pairs(Config.StealZoneFilters) do
                    if active and (zone:find(z) or z:find(zone)) then
                        zonePass = true
                        break
                    end
                end
            end
            
            local rarityPass = false
            if next(Config.StealRarityFilters) == nil then
                rarityPass = true
            elseif Config.StealRarityFilters[rarity] == true then
                rarityPass = true
            end
            
            if zonePass and rarityPass then
                local pivot = item:IsA("Model") and item:GetPivot() or (item:FindFirstChild("Handle") and item.Handle.CFrame) or item:GetPivot()
                table.insert(results, {
                    Object = item,
                    Position = pivot.Position,
                    Zone = zone,
                    Rarity = rarity,
                    Tier = RARITY_TIERS[rarity] or 1,
                    Name = item:GetAttribute("EggName") or item.Name
                })
            end
        end
    end

    if dz then
        for _, desc in ipairs(dz:GetDescendants()) do
            if desc:IsA("Model") and (desc.Parent.Name == "CloudGuardArea" or desc.Name:find("Egg") or desc.Name:find("Album")) then
                checkAndAdd(desc)
            end
        end
    end

    if adminDrops then
        for _, drop in ipairs(adminDrops:GetChildren()) do
            checkAndAdd(drop)
        end
    end

    return results
end

local function safeWait(baseSec)
    local jitter = Config.HumanizeDelays and (math.random() * 0.12) or 0
    task.wait((baseSec or 0.2) + jitter)
end

local function teleportTo(cframeOrPos, forceInstant)
    local root = getRootPart()
    if not root then return end
    local targetCF = typeof(cframeOrPos) == "CFrame" and cframeOrPos or CFrame.new(cframeOrPos)

    if forceInstant or not Config.SafeTravelMode then
        root.CFrame = targetCF
        return
    end

    -- Safe Mode: Smooth Tween with Collision disabled to pass server checks cleanly
    local dist = (root.Position - targetCF.Position).Magnitude
    if dist <= 8 then
        root.CFrame = targetCF
        return
    end

    local speed = Config.TweenSpeed or 65
    local duration = math.clamp(dist / speed, 0.2, 5.0)
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tween:Play()
    tween.Completed:Wait()
end

---------------------------------------------------------------------------
-- STATUS NOTIFICATION HELPER
---------------------------------------------------------------------------
local updateUIStatus -- Forward declaration

local function setStatus(text)
    Config.StealStatus = text
    if updateUIStatus then
        updateUIStatus(text)
    end
end

---------------------------------------------------------------------------
-- CORE ENGINE THREADS / SERVICES
---------------------------------------------------------------------------

-- 1. AUTO STEAL EGGS SERVICE
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.AutoStealEggs then
            local root = getRootPart()
            if not root then
                task.wait(0.5)
                continue
            end

            -- Check if already holding stolen loot
            if isCarryingEgg() then
                setStatus("Securing Egg: Returning to Plot...")
                local plotPos, plotCF = getPlotFloorPosition()
                if plotCF then
                    teleportTo(plotCF + Vector3.new(0, 3, 0))
                    task.wait(1.2)
                    -- Wait until safe or until egg is dropped / placed
                    for _ = 1, 20 do
                        if not isCarryingEgg() then break end
                        task.wait(0.2)
                    end
                else
                    setStatus("Warning: No owned plot found!")
                    task.wait(1)
                end
            else
                local eggs = {}

                -- Priority Check: Dedicated Admin & Exclusive Global Sniper
                if Config.SnipeAdminEggs then
                    local adminEggs = getAdminAndExclusiveEggs()
                    if #adminEggs > 0 then
                        eggs = adminEggs
                        setStatus("⚡ Admin Egg detected! Sniping...")
                    end
                end

                -- If no admin eggs found, scan standard matching eggs
                if #eggs == 0 then
                    setStatus("Scanning for matching eggs...")
                    eggs = getAllEligibleEggs()
                end

                if #eggs == 0 then
                    setStatus("No matching eggs found. Waiting...")
                    task.wait(1.5)
                else
                    local myPos = root.Position
                    local target = nil

                    -- Sort eggs by Priority: Nearest, Biggest, Random
                    if Config.StealPriority == "Biggest" then
                        table.sort(eggs, function(a, b)
                            local szA = getEggSize(a.Object)
                            local szB = getEggSize(b.Object)
                            if szA == szB then
                                return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
                            end
                            return szA > szB
                        end)
                        target = eggs[1]
                    elseif Config.StealPriority == "Random" then
                        target = eggs[math.random(1, #eggs)]
                    else -- "Nearest"
                        table.sort(eggs, function(a, b)
                            return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
                        end)
                        target = eggs[1]
                    end
                    if target and target.Object and target.Object.Parent then
                        setStatus("Stealing " .. tostring(target.Name) .. " (" .. target.Rarity .. ")...")
                        
                        -- Teleport close to egg
                        teleportTo(target.Position + Vector3.new(0, 2, 0))
                        task.wait(0.15)

                        -- Find ProximityPrompt inside egg
                        local prompt = target.Object:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if not prompt then
                            local casePart = target.Object:FindFirstChild("CasePart")
                            if casePart then
                                prompt = casePart:FindFirstChildWhichIsA("ProximityPrompt", true)
                            end
                        end

                        if prompt then
                            safeFireProximityPrompt(prompt)
                            task.wait(0.3)
                        else
                            -- Touch contact fallback
                            local part = target.Object:FindFirstChildWhichIsA("BasePart", true)
                            if part and root then
                                firetouchinterest(root, part, 0)
                                task.wait(0.1)
                                firetouchinterest(root, part, 1)
                            end
                        end

                        -- Quick check if acquired
                        if isCarryingEgg() then
                            setStatus("Egg acquired! Teleporting home...")
                            local _, plotCF = getPlotFloorPosition()
                            if plotCF then
                                teleportTo(plotCF + Vector3.new(0, 3, 0))
                            end
                            task.wait(1)
                        end
                    end
                end
            end
        else
            if Config.StealStatus ~= "Idle" then
                setStatus("Idle")
            end
        end
    end
end)

-- 2. AUTO PLACE EGGS SERVICE
task.spawn(function()
    while true do
        task.wait(0.8)
        if Config.AutoPlaceEggs then
            local char = getCharacter()
            local hum = getHumanoid()
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if char and hum and backpack then
                -- Look for egg tools in Backpack or Character
                local eggTool = nil
                local targetRarity = "Common"
                
                local candidates = {}
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and (item:GetAttribute("CasePlacementTool") == true or item:GetAttribute("AlbumZone") ~= nil or item.Name:find("Egg") or item.Name:find("Album")) then
                        table.insert(candidates, item)
                    end
                end
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") and (item:GetAttribute("CasePlacementTool") == true or item:GetAttribute("AlbumZone") ~= nil or item.Name:find("Egg") or item.Name:find("Album")) then
                        table.insert(candidates, item)
                    end
                end

                for _, tool in ipairs(candidates) do
                    local r = tool:GetAttribute("RarityAura") or tool:GetAttribute("AlbumRarity") or tool:GetAttribute("Rarity") or "Common"
                    if Config.PlaceRarityFilters[r] == true then
                        eggTool = tool
                        targetRarity = r
                        break
                    end
                end

                if eggTool and PlaceRemote then
                    -- Equip egg tool
                    hum:EquipTool(eggTool)
                    task.wait(0.2)

                    -- Calculate plot open spot
                    local plotPos, plotCF, plotSize = getPlotFloorPosition()
                    if plotPos then
                        local incubatingCount = 0
                        local incCases = workspace:FindFirstChild("IncubatingCases")
                        if incCases then
                            incubatingCount = #incCases:GetChildren()
                        end

                        local row = incubatingCount % 5 - 2
                        local col = math.floor(incubatingCount / 5) - 2
                        local placePos = Vector3.new(plotPos.X + row * 4, plotPos.Y + 0.3, plotPos.Z + col * 4)

                        pcall(function()
                            PlaceRemote:InvokeServer(placePos)
                        end)
                        task.wait(0.4)
                    end
                end
            end
        end
    end
end)

-- 3. AUTO HATCH SERVICE
task.spawn(function()
    while true do
        task.wait(0.6)
        if Config.AutoHatch then
            local function checkFolder(folder)
                if not folder then return end
                for _, eggCase in ipairs(folder:GetChildren()) do
                    if eggCase:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                        local state = eggCase:GetAttribute("State")
                        if state == "Ready" or state == "Finished" then
                            local prompt = eggCase:FindFirstChild("Hatch", true) or eggCase:FindFirstChild("OpenCase", true) or eggCase:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                safeFireProximityPrompt(prompt)
                            end
                            if HatchPortraitReady then
                                local token = eggCase:GetAttribute("PortraitToken")
                                pcall(function()
                                    HatchPortraitReady:FireServer(eggCase, token, true)
                                end)
                            end
                        end
                    end
                end
            end

            checkFolder(workspace:FindFirstChild("IncubatingCases"))
            checkFolder(workspace:FindFirstChild("ExclusivePlacedEggs"))
        end
    end
end)

-- 4. AUTO EQUIP BEST SERVICE
task.spawn(function()
    while true do
        task.wait(3.5)
        if Config.AutoEquipBest and BaseMenuRequest then
            pcall(function()
                BaseMenuRequest:InvokeServer("EquipBest")
            end)
        end
    end
end)

-- 5. AUTO TREADMILL & TREADMILL UPGRADE SERVICE
task.spawn(function()
    while true do
        task.wait(0.5)
        local myTreadmill = nil
        for _, tm in ipairs(CollectionService:GetTagged("Treadmill")) do
            if tm:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                myTreadmill = tm
                break
            end
        end

        if myTreadmill then
            -- Auto Go On Treadmill
            if Config.AutoGoOnTreadmill then
                local conveyor = myTreadmill:FindFirstChild("Conveyor")
                local root = getRootPart()
                if conveyor and root then
                    local dist = (root.Position - conveyor.Position).Magnitude
                    if dist > 8 then
                        root.CFrame = conveyor.CFrame + Vector3.new(0, 2.5, 0)
                        task.wait(0.2)
                    end
                    local ridePrompt = myTreadmill:FindFirstChild("RidePrompt", true)
                    if ridePrompt and ridePrompt.Enabled then
                        safeFireProximityPrompt(ridePrompt)
                    end
                end
            end

            -- Auto Upgrade Treadmill
            if Config.AutoUpgradeTreadmill and TreadmillUpgradeReq then
                local currentLvl = myTreadmill:GetAttribute("Level") or 1
                pcall(function()
                    TreadmillUpgradeReq:FireServer(myTreadmill, currentLvl)
                end)
            end
        end
    end
end)

-- 6. AUTO PROGRESSION SERVICE (Base, Index, Daily, Trails, Cosmetics)
task.spawn(function()
    local dailyTimer = 0
    local indexTimer = 0
    local trailTimer = 0

    while true do
        task.wait(1)

        -- Auto Upgrade Base
        if Config.AutoUpgradeBase and BaseUpgradeRequest then
            local plot = getPlayerPlot()
            if plot then
                local currentLvl = plot:GetAttribute("BaseLevel") or 0
                pcall(function()
                    BaseUpgradeRequest:FireServer(plot, currentLvl)
                end)
            end
        end

        -- Auto Claim Index
        indexTimer = indexTimer + 1
        if Config.AutoClaimIndex and indexTimer >= 4 and IndexGetProgress then
            indexTimer = 0
            task.spawn(function()
                local success, progress = pcall(function()
                    return IndexGetProgress:InvokeServer()
                end)
                if success and type(progress) == "table" then
                    local seen = progress.Seen or {}
                    local rewarded = progress.Rewarded or {}
                    local claims = progress.Claims or {}
                    
                    local rewMap = {}
                    for _, id in ipairs(rewarded) do rewMap[id] = true end
                    for _, id in ipairs(seen) do
                        if not rewMap[id] and IndexClaimReward then
                            pcall(function() IndexClaimReward:InvokeServer(id) end)
                            task.wait(0.1)
                        end
                    end

                    local claimMap = {}
                    for _, lvl in ipairs(claims) do claimMap[lvl] = true end
                    for lvl = 1, 10 do
                        if not claimMap[lvl] and IndexClaimBatLevel then
                            pcall(function() IndexClaimBatLevel:InvokeServer(lvl) end)
                            task.wait(0.1)
                        end
                    end

                    if progress.Revision and IndexMarkViewed then
                        pcall(function() IndexMarkViewed:FireServer(progress.Revision) end)
                    end
                end
            end)
        end

        -- Auto Claim Daily
        dailyTimer = dailyTimer + 1
        if Config.AutoClaimDaily and dailyTimer >= 10 and DailyClaimRemote then
            dailyTimer = 0
            pcall(function()
                DailyClaimRemote:InvokeServer()
            end)
        end

        -- Auto Buy Trail
        trailTimer = trailTimer + 1
        if Config.AutoBuyTrail and trailTimer >= 3 and TrailRequestRemote then
            trailTimer = 0
            task.spawn(function()
                local myMoney = getMoney()
                for _, trail in ipairs(TRAIL_LIST) do
                    if myMoney >= trail.Cost then
                        pcall(function()
                            TrailRequestRemote:InvokeServer("Buy", trail.Id)
                        end)
                        pcall(function()
                            TrailRequestRemote:InvokeServer("Equip", trail.Id)
                        end)
                    end
                end
            end)
        end

        -- Auto Buy Cosmetics
        if Config.AutoBuyCosmetics and TrailRequestRemote then
            pcall(function()
                TrailRequestRemote:InvokeServer("CosmeticBuy", "trail-cosmetic-design-01")
                TrailRequestRemote:InvokeServer("LightstickBuy", "lightstick-aespa")
            end)
        end
    end
end)

-- 7. EXTRA SERVICES: Anti-Ragdoll, Auto Bat Aura, Invisibility, Noclip, Fly
-- Anti-Ragdoll
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AntiRagdoll then
            local hum = getHumanoid()
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
            local char = getCharacter()
            if char then
                local ability = char:FindFirstChild("AbilityManagerActor")
                if ability then
                    local fDown = ability:FindFirstChild("FallingDown", true)
                    if fDown then
                        local sync = fDown:FindFirstChild("SyncedState")
                        if sync then
                            sync:SetAttribute("Enabled", false)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Bat Aura
task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.AutoBatAura and BatSwingRemote then
            local root = getRootPart()
            local char = getCharacter()
            if root and char then
                local bat = char:FindFirstChildWhichIsA("Tool")
                if not (bat and (bat.Name:find("Bat") or bat:GetAttribute("IsBat") == true)) then
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        for _, item in ipairs(bp:GetChildren()) do
                            if item:IsA("Tool") and (item.Name:find("Bat") or item:GetAttribute("IsBat") == true) then
                                getHumanoid():EquipTool(item)
                                bat = item
                                break
                            end
                        end
                    end
                end

                if bat then
                    -- Detect nearby guards
                    local targets = {}
                    local dz = workspace:FindFirstChild("DangerZones")
                    if dz then
                        for _, desc in ipairs(dz:GetDescendants()) do
                            if desc:IsA("Model") and (desc.Name:find("Guard") or desc.Name:find("Chicken") or desc.Name:find("Scorpion") or desc.Name:find("Tiger")) then
                                local gRoot = desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChildWhichIsA("BasePart")
                                if gRoot and (gRoot.Position - root.Position).Magnitude <= 18 then
                                    table.insert(targets, desc)
                                end
                            end
                        end
                    end
                    if #targets > 0 then
                        pcall(function()
                            BatSwingRemote:FireServer(bat, targets)
                        end)
                    end
                end
            end
        end
    end
end)

-- Invisibility / Ghost Mode
task.spawn(function()
    while true do
        task.wait(0.5)
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    if Config.InvisibleGhost then
                        part.LocalTransparencyModifier = 0.8
                    else
                        part.LocalTransparencyModifier = 0
                    end
                end
            end
        end
    end
end)

-- Noclip Service
RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Custom WalkSpeed
task.spawn(function()
    while true do
        task.wait(0.2)
        local hum = getHumanoid()
        if hum and Config.CustomSpeedEnabled then
            hum.WalkSpeed = Config.WalkSpeedValue
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti-AFK
if Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

---------------------------------------------------------------------------
-- EGG ESP SERVICE
---------------------------------------------------------------------------
local ActiveESPs = {}

local function clearESP(obj)
    if ActiveESPs[obj] then
        if ActiveESPs[obj].Highlight then ActiveESPs[obj].Highlight:Destroy() end
        if ActiveESPs[obj].Billboard then ActiveESPs[obj].Billboard:Destroy() end
        ActiveESPs[obj] = nil
    end
end

local function updateEggESP()
    if not Config.EggESP then
        for obj in pairs(ActiveESPs) do
            clearESP(obj)
        end
        return
    end

    local root = getRootPart()
    local myPos = root and root.Position or Vector3.new(0, 0, 0)
    local eggs = getAllEligibleEggs()

    local seen = {}
    for _, eggInfo in ipairs(eggs) do
        local obj = eggInfo.Object
        seen[obj] = true

        if Config.ESPRarityFilters[eggInfo.Rarity] == true then
            local dist = math.floor((eggInfo.Position - myPos).Magnitude)
            local color = RARITY_COLORS[eggInfo.Rarity] or Color3.fromRGB(255, 255, 255)

            if not ActiveESPs[obj] then
                -- Highlight
                local hl = Instance.new("Highlight")
                hl.Name = "Alexandria_EggESP"
                hl.Adornee = obj
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = color
                hl.OutlineColor = color
                hl.FillTransparency = 0.65
                hl.OutlineTransparency = 0
                hl.Parent = obj

                -- BillboardGui
                local bb = Instance.new("BillboardGui")
                bb.Name = "Alexandria_EggLabel"
                bb.Adornee = obj
                bb.Size = UDim2.fromOffset(180, 48)
                bb.StudsOffset = Vector3.new(0, 3.2, 0)
                bb.AlwaysOnTop = true
                bb.Parent = obj

                local frame = Instance.new("Frame")
                frame.Size = UDim2.fromScale(1, 1)
                frame.BackgroundTransparency = 0.4
                frame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
                frame.BorderSizePixel = 0
                frame.Parent = bb

                local uic = Instance.new("UICorner")
                uic.CornerRadius = UDim.new(0, 6)
                uic.Parent = frame

                local uis = Instance.new("UIStroke")
                uis.Color = color
                uis.Thickness = 1.5
                uis.Parent = frame

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "Title"
                nameLabel.Size = UDim2.new(1, -8, 0, 20)
                nameLabel.Position = UDim2.fromOffset(4, 3)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 13
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Text = eggInfo.Name
                nameLabel.Parent = frame

                local infoLabel = Instance.new("TextLabel")
                infoLabel.Name = "Info"
                infoLabel.Size = UDim2.new(1, -8, 0, 18)
                infoLabel.Position = UDim2.fromOffset(4, 23)
                infoLabel.BackgroundTransparency = 1
                infoLabel.Font = Enum.Font.Gotham
                infoLabel.TextSize = 11
                infoLabel.TextColor3 = color
                infoLabel.Text = string.format("[%s] %s • %dm", eggInfo.Zone, eggInfo.Rarity, dist)
                infoLabel.Parent = frame

                ActiveESPs[obj] = { Highlight = hl, Billboard = bb, InfoLabel = infoLabel, Color = color }
            else
                local info = ActiveESPs[obj]
                if info.InfoLabel and info.InfoLabel.Parent then
                    info.InfoLabel.Text = string.format("[%s] %s • %dm", eggInfo.Zone, eggInfo.Rarity, dist)
                end
            end
        else
            clearESP(obj)
        end
    end

    for obj in pairs(ActiveESPs) do
        if not seen[obj] or not obj.Parent then
            clearESP(obj)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Config.EggESP then
        updateEggESP()
    end
end)

---------------------------------------------------------------------------
-- USER INTERFACE: "Alexandria Main"
---------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlexandriaHub_StealKPOPEggs"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 99999
ScreenGui.Parent = getGuiParent()

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(780, 500)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 38, 48)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Draggable Functionality
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Top Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 200, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(16, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 15
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.Text = "◈  Alexandria Main"
HeaderTitle.Parent = Header

-- Floating Circular Minimize Icon Button (Matches user request)
local FloatingIcon = Instance.new("ImageButton")
FloatingIcon.Name = "Alexandria_FloatingIcon"
FloatingIcon.Size = UDim2.fromOffset(50, 50)
FloatingIcon.Position = UDim2.new(0.5, -25, 0, 16)
FloatingIcon.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
FloatingIcon.BorderSizePixel = 0
FloatingIcon.Visible = false
FloatingIcon.Active = true
FloatingIcon.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingIcon

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(99, 102, 241)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatingIcon

local FloatGrad = Instance.new("UIGradient")
FloatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 38, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 18, 26))
})
FloatGrad.Rotation = 45
FloatGrad.Parent = FloatingIcon

local FloatIconLabel = Instance.new("TextLabel")
FloatIconLabel.Size = UDim2.fromScale(1, 1)
FloatIconLabel.BackgroundTransparency = 1
FloatIconLabel.Font = Enum.Font.GothamBold
FloatIconLabel.TextSize = 22
FloatIconLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
FloatIconLabel.Text = "◈"
FloatIconLabel.Parent = FloatingIcon

-- Draggable functionality for Floating Icon
local fDragging, fDragInput, fDragStart, fStartPos
FloatingIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDragging = true
        fDragStart = input.Position
        fStartPos = FloatingIcon.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                fDragging = false
            end
        end)
    end
end)

FloatingIcon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        fDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == fDragInput and fDragging then
        local delta = input.Position - fDragStart
        FloatingIcon.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
    end
end)

-- Click Floating Icon to restore MainFrame
FloatingIcon.MouseButton1Click:Connect(function()
    FloatingIcon.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.fromOffset(780, 500)
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.fromOffset(28, 28)
MinimizeBtn.Position = UDim2.new(1, -38, 0, 7)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
MinimizeBtn.Text = "—"
MinimizeBtn.Parent = Header

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingIcon.Visible = true
end)

-- Sidebar (Left)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -80)
Sidebar.Position = UDim2.fromOffset(10, 42)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local TabButtonsLayout = Instance.new("UIListLayout")
TabButtonsLayout.Padding = UDim.new(0, 6)
TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabButtonsLayout.Parent = Sidebar

-- Content Container (Right)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -180, 1, -80)
ContentContainer.Position = UDim2.fromOffset(170, 42)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Footer (Bottom)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 36)
Footer.Position = UDim2.new(0, 0, 1, -36)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterDiscord = Instance.new("TextLabel")
FooterDiscord.Size = UDim2.new(0, 200, 1, 0)
FooterDiscord.Position = UDim2.fromOffset(16, 0)
FooterDiscord.BackgroundTransparency = 1
FooterDiscord.Font = Enum.Font.Gotham
FooterDiscord.TextSize = 12
FooterDiscord.TextXAlignment = Enum.TextXAlignment.Left
FooterDiscord.TextColor3 = Color3.fromRGB(100, 110, 130)
FooterDiscord.Text = "discord.gg/synapsex"
FooterDiscord.Parent = Footer

local FooterGame = Instance.new("TextLabel")
FooterGame.Size = UDim2.new(0, 200, 1, 0)
FooterGame.Position = UDim2.new(0.5, -100, 0, 0)
FooterGame.BackgroundTransparency = 1
FooterGame.Font = Enum.Font.GothamMedium
FooterGame.TextSize = 12
FooterGame.TextColor3 = Color3.fromRGB(140, 150, 175)
FooterGame.Text = "Steal KPOP Eggs"
FooterGame.Parent = Footer

local FooterBuild = Instance.new("TextLabel")
FooterBuild.Size = UDim2.new(0, 150, 1, 0)
FooterBuild.Position = UDim2.new(1, -166, 0, 0)
FooterBuild.BackgroundTransparency = 1
FooterBuild.Font = Enum.Font.Gotham
FooterBuild.TextSize = 12
FooterBuild.TextXAlignment = Enum.TextXAlignment.Right
FooterBuild.TextColor3 = Color3.fromRGB(100, 110, 130)
FooterBuild.Text = "Build: 0.1  ⤡"
FooterBuild.Parent = Footer

---------------------------------------------------------------------------
-- TAB SYSTEM
---------------------------------------------------------------------------
local Tabs = {}
local TabButtons = {}

local function createTab(tabName, iconText)
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = tabName .. "Tab"
    tabFrame.Size = UDim2.fromScale(1, 1)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 3
    tabFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 85)
    tabFrame.Visible = false
    tabFrame.Parent = ContentContainer

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName .. "Btn"
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    tabBtn.BackgroundTransparency = 0.5
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 13
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.TextColor3 = Color3.fromRGB(150, 155, 175)
    tabBtn.Text = "   " .. (iconText or "•") .. "  " .. tabName
    tabBtn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
            b.TextColor3 = Color3.fromRGB(150, 155, 175)
        end
        tabFrame.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(32, 35, 46)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Tabs[tabName] = tabFrame
    TabButtons[tabName] = tabBtn
    return tabFrame
end

local MainTab     = createTab("Main", "◎")
local ExtraTab    = createTab("Extra", "✦")
local VisualsTab  = createTab("Visuals", "◉")
local TeleportTab = createTab("Teleport", "⚲")
local SettingsTab = createTab("Settings", "⚙")

-- Activate Main Tab by default
Tabs["Main"].Visible = true
TabButtons["Main"].BackgroundColor3 = Color3.fromRGB(32, 35, 46)
TabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)

---------------------------------------------------------------------------
-- UI COMPONENT BUILDERS (Cards, Toggles, Dropdowns, Buttons)
---------------------------------------------------------------------------
local function createCard(parent, title, icon)
    local card = Instance.new("Frame")
    card.Name = title:gsub("%s+", "") .. "Card"
    card.Size = UDim2.new(1, 0, 0, 40) -- Auto calculated
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(32, 35, 46)
    stroke.Thickness = 1
    stroke.Parent = card

    local cardHeader = Instance.new("Frame")
    cardHeader.Size = UDim2.new(1, 0, 0, 36)
    cardHeader.BackgroundTransparency = 1
    cardHeader.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.fromOffset(12, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
    titleLabel.Text = (icon and (icon .. "  ") or "") .. title
    titleLabel.Parent = cardHeader

    local collapseBtn = Instance.new("TextButton")
    collapseBtn.Size = UDim2.fromOffset(24, 24)
    collapseBtn.Position = UDim2.new(1, -30, 0, 6)
    collapseBtn.BackgroundTransparency = 1
    collapseBtn.Font = Enum.Font.GothamBold
    collapseBtn.TextSize = 12
    collapseBtn.TextColor3 = Color3.fromRGB(140, 145, 165)
    collapseBtn.Text = "∧"
    collapseBtn.Parent = cardHeader

    local cardContent = Instance.new("Frame")
    cardContent.Name = "Content"
    cardContent.Size = UDim2.new(1, -20, 0, 0)
    cardContent.Position = UDim2.fromOffset(10, 36)
    cardContent.AutomaticSize = Enum.AutomaticSize.Y
    cardContent.BackgroundTransparency = 1
    cardContent.Parent = card

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = cardContent

    local bottomPad = Instance.new("UIPadding")
    bottomPad.PaddingBottom = UDim.new(0, 10)
    bottomPad.Parent = cardContent

    local collapsed = false
    collapseBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        cardContent.Visible = not collapsed
        collapseBtn.Text = collapsed and "∨" or "∧"
    end)

    return cardContent
end

local function createToggle(parent, text, defaultVal, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 24)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.fromOffset(18, 18)
    box.Position = UDim2.fromOffset(0, 3)
    box.BackgroundColor3 = defaultVal and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(26, 28, 38)
    box.Text = defaultVal and "✓" or ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.Parent = toggleFrame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = defaultVal and Color3.fromRGB(129, 140, 248) or Color3.fromRGB(45, 49, 66)
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -28, 1, 0)
    label.Position = UDim2.fromOffset(26, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(200, 205, 220)
    label.Text = text
    label.Parent = toggleFrame

    local state = defaultVal
    local function toggle()
        state = not state
        box.BackgroundColor3 = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(26, 28, 38)
        boxStroke.Color = state and Color3.fromRGB(129, 140, 248) or Color3.fromRGB(45, 49, 66)
        box.Text = state and "✓" or ""
        if callback then
            callback(state)
        end
    end

    box.MouseButton1Click:Connect(toggle)
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.fromScale(1, 1)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = label
    clickDetector.MouseButton1Click:Connect(toggle)

    return toggleFrame
end

local activeDropdownClose = nil

local function createDropdown(parent, labelText, options, defaultSelected, isMulti, callback)
    local isOpen = false
    local ddFrame = Instance.new("Frame")
    ddFrame.Size = UDim2.new(1, 0, 0, 48)
    ddFrame.BackgroundTransparency = 1
    ddFrame.ClipsDescendants = false
    ddFrame.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 16)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Gotham
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(140, 145, 165)
    title.Text = labelText
    title.Parent = ddFrame

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, 0, 0, 28)
    selectBtn.Position = UDim2.fromOffset(0, 18)
    selectBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 35)
    selectBtn.BorderSizePixel = 0
    selectBtn.Font = Enum.Font.Gotham
    selectBtn.TextSize = 12
    selectBtn.TextXAlignment = Enum.TextXAlignment.Left
    selectBtn.TextColor3 = Color3.fromRGB(210, 215, 230)
    selectBtn.Parent = ddFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = selectBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(38, 42, 56)
    btnStroke.Thickness = 1
    btnStroke.Parent = selectBtn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(20, 28)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.TextColor3 = Color3.fromRGB(140, 145, 165)
    arrow.Text = "∨"
    arrow.Parent = selectBtn

    -- Option List Container (Scrollable)
    local listContainer = Instance.new("ScrollingFrame")
    listContainer.Name = "DropdownList"
    listContainer.Size = UDim2.new(1, 0, 0, 130)
    listContainer.Position = UDim2.fromOffset(0, 50)
    listContainer.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    listContainer.BackgroundTransparency = 0
    listContainer.BorderSizePixel = 0
    listContainer.ScrollBarThickness = 5
    listContainer.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
    listContainer.ScrollBarImageTransparency = 0.2
    listContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    listContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    listContainer.ClipsDescendants = true
    listContainer.Active = true
    listContainer.ZIndex = 80
    listContainer.Visible = false
    listContainer.Parent = ddFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = listContainer

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(48, 52, 70)
    listStroke.Thickness = 1
    listStroke.Parent = listContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listContainer

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 4)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 6)
    listPad.Parent = listContainer

    local selectedState = isMulti and (defaultSelected or {}) or (defaultSelected or options[1])

    local function updateButtonText()
        if isMulti then
            local names = {}
            for k, v in pairs(selectedState) do
                if v then table.insert(names, k) end
            end
            if #names == 0 then
                selectBtn.Text = "  None Selected"
            elseif #names <= 2 then
                selectBtn.Text = "  " .. table.concat(names, ", ")
            else
                selectBtn.Text = "  " .. names[1] .. ", " .. names[2] .. "..."
            end
        else
            selectBtn.Text = "  " .. tostring(selectedState)
        end
    end
    updateButtonText()

    local function setDropdownOpen(open)
        if open and activeDropdownClose and activeDropdownClose ~= setDropdownOpen then
            activeDropdownClose(false)
        end
        isOpen = open
        listContainer.Visible = isOpen
        arrow.Text = isOpen and "∧" or "∨"
        ddFrame.Size = isOpen and UDim2.new(1, 0, 0, 185) or UDim2.new(1, 0, 0, 48)
        if isOpen then
            activeDropdownClose = setDropdownOpen
        elseif activeDropdownClose == setDropdownOpen then
            activeDropdownClose = nil
        end
    end

    for idx, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
        optBtn.BackgroundTransparency = 0
        optBtn.BorderSizePixel = 0
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 12
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.ZIndex = 85
        optBtn.TextColor3 = Color3.fromRGB(210, 215, 230)
        optBtn.LayoutOrder = idx
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        if isMulti then
            optBtn.Text = (selectedState[opt] and "  [✓] " or "  [  ] ") .. opt
            if selectedState[opt] then
                optBtn.TextColor3 = Color3.fromRGB(129, 140, 248)
            end
        else
            optBtn.Text = "  " .. opt
            if selectedState == opt then
                optBtn.TextColor3 = Color3.fromRGB(129, 140, 248)
                optBtn.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
            end
        end
        optBtn.Parent = listContainer

        optBtn.MouseButton1Click:Connect(function()
            if isMulti then
                selectedState[opt] = not selectedState[opt]
                optBtn.Text = (selectedState[opt] and "  [✓] " or "  [  ] ") .. opt
                optBtn.TextColor3 = selectedState[opt] and Color3.fromRGB(129, 140, 248) or Color3.fromRGB(210, 215, 230)
                updateButtonText()
                if callback then callback(selectedState) end
            else
                selectedState = opt
                updateButtonText()
                setDropdownOpen(false)
                if callback then callback(selectedState) end
            end
        end)
    end

    selectBtn.MouseButton1Click:Connect(function()
        setDropdownOpen(not isOpen)
    end)

    return ddFrame
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(235, 240, 255)
    btn.Text = text
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 49, 68)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(45, 49, 68) }):Play()
        task.wait(0.08)
        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(28, 30, 42) }):Play()
        if callback then callback() end
    end)

    return btn
end

---------------------------------------------------------------------------
-- POPULATE MAIN TAB (2-Column Grid Matching Picture)
---------------------------------------------------------------------------
local MainLayoutGrid = Instance.new("Frame")
MainLayoutGrid.Size = UDim2.new(1, -10, 1, 0)
MainLayoutGrid.BackgroundTransparency = 1
MainLayoutGrid.Parent = MainTab

local Col1 = Instance.new("Frame")
Col1.Name = "Column1"
Col1.Size = UDim2.new(0.5, -6, 1, 0)
Col1.Position = UDim2.fromOffset(0, 0)
Col1.BackgroundTransparency = 1
Col1.Parent = MainLayoutGrid

local Col1Layout = Instance.new("UIListLayout")
Col1Layout.Padding = UDim.new(0, 10)
Col1Layout.SortOrder = Enum.SortOrder.LayoutOrder
Col1Layout.Parent = Col1

local Col2 = Instance.new("Frame")
Col2.Name = "Column2"
Col2.Size = UDim2.new(0.5, -6, 1, 0)
Col2.Position = UDim2.new(0.5, 6, 0, 0)
Col2.BackgroundTransparency = 1
Col2.Parent = MainLayoutGrid

local Col2Layout = Instance.new("UIListLayout")
Col2Layout.Padding = UDim.new(0, 10)
Col2Layout.SortOrder = Enum.SortOrder.LayoutOrder
Col2Layout.Parent = Col2

-- COLUMN 1 CARDS:
-- 1. Auto Steal Eggs Card
local StealCard = createCard(Col1, "Auto Steal Eggs", "◎")
createToggle(StealCard, "Auto Steal Eggs", Config.AutoStealEggs, function(v)
    Config.AutoStealEggs = v
end)
createToggle(StealCard, "⚡ Auto Snipe Admin & Exclusive (Global)", Config.SnipeAdminEggs, function(v)
    Config.SnipeAdminEggs = v
end)
createDropdown(StealCard, "Zone Filter", ZONES, Config.StealZoneFilters, true, function(selected)
    Config.StealZoneFilters = selected
end)
createDropdown(StealCard, "Rarity Filter", RARITIES, Config.StealRarityFilters, true, function(selected)
    Config.StealRarityFilters = selected
end)
createDropdown(StealCard, "Priority", { "Nearest", "Biggest", "Random" }, Config.StealPriority, false, function(selected)
    Config.StealPriority = selected
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 140)
StatusLabel.Text = "Status: Idle"
StatusLabel.Parent = StealCard

updateUIStatus = function(txt)
    StatusLabel.Text = "Status: " .. txt
end

-- 2. Treadmill Card
local TreadmillCard = createCard(Col1, "Treadmill", "⚯")
createToggle(TreadmillCard, "Auto Go On Treadmill", Config.AutoGoOnTreadmill, function(v)
    Config.AutoGoOnTreadmill = v
end)
createToggle(TreadmillCard, "Auto Upgrade Treadmill", Config.AutoUpgradeTreadmill, function(v)
    Config.AutoUpgradeTreadmill = v
end)

-- 3. Egg ESP Card
local ESPCard = createCard(Col1, "Egg ESP", "◉")
createToggle(ESPCard, "Egg ESP", Config.EggESP, function(v)
    Config.EggESP = v
end)
createDropdown(ESPCard, "Rarity Filter", RARITIES, Config.ESPRarityFilters, true, function(selected)
    Config.ESPRarityFilters = selected
end)

-- COLUMN 2 CARDS:
-- 1. Eggs Card
local EggsCard = createCard(Col2, "Eggs", "⊞")
createToggle(EggsCard, "Auto Place Eggs", Config.AutoPlaceEggs, function(v)
    Config.AutoPlaceEggs = v
end)
createDropdown(EggsCard, "Rarity Filter", RARITIES, Config.PlaceRarityFilters, true, function(selected)
    Config.PlaceRarityFilters = selected
end)
createToggle(EggsCard, "Auto Hatch", Config.AutoHatch, function(v)
    Config.AutoHatch = v
end)
createToggle(EggsCard, "Auto Equip Best", Config.AutoEquipBest, function(v)
    Config.AutoEquipBest = v
end)

-- 2. Progression Card
local ProgressionCard = createCard(Col2, "Progression", "📈")
createToggle(ProgressionCard, "Auto Upgrade Base", Config.AutoUpgradeBase, function(v)
    Config.AutoUpgradeBase = v
end)
createToggle(ProgressionCard, "Auto Claim Index", Config.AutoClaimIndex, function(v)
    Config.AutoClaimIndex = v
end)
createToggle(ProgressionCard, "Auto Claim Daily", Config.AutoClaimDaily, function(v)
    Config.AutoClaimDaily = v
end)
createToggle(ProgressionCard, "Auto Buy Trail", Config.AutoBuyTrail, function(v)
    Config.AutoBuyTrail = v
end)
createToggle(ProgressionCard, "Auto Buy Cosmetics", Config.AutoBuyCosmetics, function(v)
    Config.AutoBuyCosmetics = v
end)

-- 3. Teleport Card
local TeleportCard = createCard(Col2, "Teleport", "⚲")
createButton(TeleportCard, "Teleport To Plot", function()
    local _, plotCF = getPlotFloorPosition()
    if plotCF then
        teleportTo(plotCF + Vector3.new(0, 3, 0))
    else
        setStatus("Could not locate owned plot!")
    end
end)
createDropdown(TeleportCard, "Zone", ZONES, Config.SelectedTeleportZone, false, function(selected)
    Config.SelectedTeleportZone = selected
    -- Teleport to zone immediately upon selection or use teleport button
    local dz = workspace:FindFirstChild("DangerZones")
    if dz then
        for _, z in ipairs(dz:GetChildren()) do
            local zName = z:GetAttribute("ZoneName") or z.Name
            if string.upper(zName):find(selected) or selected:find(string.upper(zName)) then
                local startX = z:GetAttribute("StartX") or 0
                local endX = z:GetAttribute("EndX") or startX + 50
                local centerZ = dz:GetAttribute("CenterZ") or 0
                teleportTo(Vector3.new((startX + endX) / 2, 8, centerZ))
                break
            end
        end
    end
end)

---------------------------------------------------------------------------
-- POPULATE EXTRA TAB (Combat, Movement & Exploits)
---------------------------------------------------------------------------
local ExtraLayout = Instance.new("UIListLayout")
ExtraLayout.Padding = UDim.new(0, 10)
ExtraLayout.Parent = ExtraTab

local CombatCard = createCard(ExtraTab, "Combat & Survival", "⚔")
createToggle(CombatCard, "Anti-Ragdoll / No Tripping", Config.AntiRagdoll, function(v)
    Config.AntiRagdoll = v
end)
createToggle(CombatCard, "Auto Bat Aura (Anti-Guard)", Config.AutoBatAura, function(v)
    Config.AutoBatAura = v
end)
createToggle(CombatCard, "Invisible / Ghost Mode", Config.InvisibleGhost, function(v)
    Config.InvisibleGhost = v
end)

local AutomationCard = createCard(ExtraTab, "Extra Automation", "⚙")
createToggle(AutomationCard, "Auto Claim Free Group Gift", Config.AutoClaimFreeGift, function(v)
    Config.AutoClaimFreeGift = v
    if v and FreeGiftClaimRemote then
        pcall(function() FreeGiftClaimRemote:InvokeServer() end)
    end
end)
createToggle(AutomationCard, "Anti-AFK (20min Kick Bypass)", Config.AntiAFK, function(v)
    Config.AntiAFK = v
end)

local MovementCard = createCard(ExtraTab, "Movement & Mobility", "⚡")
createToggle(MovementCard, "Custom WalkSpeed (Fast)", Config.CustomSpeedEnabled, function(v)
    Config.CustomSpeedEnabled = v
    Config.WalkSpeedValue = v and 38 or 16
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Config.WalkSpeedValue end
end)
createToggle(MovementCard, "Infinite Jump", Config.InfiniteJump, function(v)
    Config.InfiniteJump = v
end)
createToggle(MovementCard, "Noclip (Walk Through Walls)", Config.Noclip, function(v)
    Config.Noclip = v
end)

---------------------------------------------------------------------------
-- POPULATE VISUALS TAB
---------------------------------------------------------------------------
local VisualsLayout = Instance.new("UIListLayout")
VisualsLayout.Padding = UDim.new(0, 10)
VisualsLayout.Parent = VisualsTab

local VisualCard = createCard(VisualsTab, "ESP Configuration", "👁")
createToggle(VisualCard, "Egg ESP Master Toggle", Config.EggESP, function(v)
    Config.EggESP = v
end)
createDropdown(VisualCard, "Active ESP Rarities", RARITIES, Config.ESPRarityFilters, true, function(selected)
    Config.ESPRarityFilters = selected
end)

---------------------------------------------------------------------------
-- POPULATE TELEPORT TAB
---------------------------------------------------------------------------
local TeleportLayout = Instance.new("UIListLayout")
TeleportLayout.Padding = UDim.new(0, 10)
TeleportLayout.Parent = TeleportTab

local TPQuickCard = createCard(TeleportTab, "Quick Teleports", "🚀")
createButton(TPQuickCard, "Teleport: My Base / Plot", function()
    local _, plotCF = getPlotFloorPosition()
    if plotCF then teleportTo(plotCF + Vector3.new(0, 3, 0)) end
end)
createButton(TPQuickCard, "Teleport: Treadmill Conveyor", function()
    for _, tm in ipairs(CollectionService:GetTagged("Treadmill")) do
        if tm:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            local conveyor = tm:FindFirstChild("Conveyor")
            if conveyor then teleportTo(conveyor.CFrame + Vector3.new(0, 3, 0)) end
            break
        end
    end
end)
createButton(TPQuickCard, "Teleport: Safe Zone", function()
    local safeBoundary = workspace:FindFirstChild("SafeZoneBoundary")
    if safeBoundary then
        teleportTo(safeBoundary:GetPivot().Position + Vector3.new(0, 3, 0))
    else
        local _, plotCF = getPlotFloorPosition()
        if plotCF then teleportTo(plotCF + Vector3.new(0, 3, 0)) end
    end
end)

local TPZoneCard = createCard(TeleportTab, "Teleport to All Danger Zones", "🗺")
for _, zoneName in ipairs(ZONES) do
    createButton(TPZoneCard, "Zone: " .. zoneName, function()
        local dz = workspace:FindFirstChild("DangerZones")
        if dz then
            for _, z in ipairs(dz:GetChildren()) do
                local zName = z:GetAttribute("ZoneName") or z.Name
                if string.upper(zName):find(zoneName) or zoneName:find(string.upper(zName)) then
                    local startX = z:GetAttribute("StartX") or 0
                    local endX = z:GetAttribute("EndX") or startX + 50
                    local centerZ = dz:GetAttribute("CenterZ") or 0
                    teleportTo(Vector3.new((startX + endX) / 2, 8, centerZ))
                    break
                end
            end
        end
    end)
end

---------------------------------------------------------------------------
-- POPULATE SETTINGS TAB
---------------------------------------------------------------------------
local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 10)
SettingsLayout.Parent = SettingsTab

local GeneralSettings = createCard(SettingsTab, "General Settings", "⚙")
createToggle(GeneralSettings, "Safe Travel Mode (Anti-Detect Tween)", Config.SafeTravelMode, function(v)
    Config.SafeTravelMode = v
end)
createToggle(GeneralSettings, "Humanized Delay Jitter (Anti-Spam)", Config.HumanizeDelays, function(v)
    Config.HumanizeDelays = v
end)
createButton(GeneralSettings, "Toggle UI Visibility (or Press RightShift)", function()
    MainFrame.Visible = not MainFrame.Visible
end)
createButton(GeneralSettings, "Unload Script & Destroy GUI", function()
    ScreenGui:Destroy()
    for obj in pairs(ActiveESPs) do
        clearESP(obj)
    end
    print("[Alexandria] Suite cleanly unloaded.")
end)

-- Keybind to toggle UI (RightShift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        if MainFrame.Visible then
            MainFrame.Visible = false
            FloatingIcon.Visible = true
        else
            FloatingIcon.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.fromOffset(780, 500)
        end
    end
end)

print("[Alexandria] Steal KPOP Eggs Suite Loaded Successfully! Press RightShift to toggle UI.")
