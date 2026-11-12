--[[
    ═══════════════════════════════════════════════════════════════════════════
       ALEXANDRIA MAIN — STEAL KPOP EGGS ULTIMATE AUTOMATION SUITE
       Version: 3.3.0 (Streamlined & Rapid Edition)
       Design: Faithful Recreation of Alexandria Hub Layout & Features
       Target Game: Steal KPOP Eggs
    ═══════════════════════════════════════════════════════════════════════════
]]

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
    local oldHold = prompt.HoldDuration
    pcall(function()
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight   = false
        prompt.HoldDuration          = 0
    end)
    
    local fired = false
    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
            fired = true
        end)
    end
    
    pcall(function()
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
            fired = true
        end
    end)
    
    task.delay(0.5, function()
        pcall(function()
            if prompt and prompt.Parent then
                prompt.MaxActivationDistance = oldDist
                prompt.RequiresLineOfSight   = oldLOS
                prompt.HoldDuration          = oldHold
            end
        end)
    end)
    return fired
end

---------------------------------------------------------------------------
-- GAME REMOTES & REFERENCES
---------------------------------------------------------------------------
local CasePlacementFolder   = ReplicatedStorage:WaitForChild("CasePlacement", 10)
local PlaceRemote           = CasePlacementFolder and CasePlacementFolder:WaitForChild("Place", 10)
local DropAlbumRemote       = CasePlacementFolder and CasePlacementFolder:WaitForChild("DropAlbum", 10)
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
    "HARVESTFARM",
    "MEDIEVALMARKET"
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

-- Default Table Generators
local function getDefaultZoneTable()
    local t = {}
    for _, z in ipairs(ZONES) do t[z] = true end
    return t
end

local function getDefaultRarityTable()
    local t = {}
    for _, r in ipairs(RARITIES) do t[r] = true end
    return t
end

---------------------------------------------------------------------------
-- WEIGHT (KG) FORMATTING HELPER
---------------------------------------------------------------------------
local function formatKg(weight)
    local w = tonumber(weight) or 0
    if w <= 0 then return nil end
    if w < 9.995 then
        return string.format("%.2f kg", w)
    elseif w < 999.95 then
        return string.format("%.1f kg", w)
    else
        local rounded = math.round(w)
        return tostring(rounded):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " kg"
    end
end

local function getEggWeight(egg)
    local w = egg:GetAttribute("AlbumWeightKg") 
           or (egg.Parent and egg.Parent:GetAttribute("AlbumWeightKg"))
           or egg:GetAttribute("Weight")
    if type(w) == "number" and w > 0 then
        return w
    end
    local label = egg:FindFirstChild("AlbumWeightLabel", true)
    if label and label:IsA("BillboardGui") then
        local text = label:FindFirstChildWhichIsA("TextLabel", true)
        if text and text.Text then
            local kgStr = text.Text:match("([%d%,%.]+)%s*[kK][gG]") or text.Text:match("•%s*([%d%,%.]+)")
            if kgStr then
                kgStr = kgStr:gsub(",", "")
                local num = tonumber(kgStr)
                if num and num > 0 then return num end
            end
        end
    end
    local sz = egg:GetAttribute("AlbumSize") or egg:GetAttribute("Size")
    if type(sz) == "number" and sz > 0 then
        local cSz = math.clamp(sz, 0.3, 5)
        local raw = 9999 * (cSz / 5) ^ 3.9
        local rawMin = 9999 * (0.3 / 5) ^ 3.9
        local calculated = 1 + (raw - rawMin) * (9999 - 1) / (9999 - rawMin)
        return calculated
    end
    return nil
end

---------------------------------------------------------------------------
-- CONFIGURATION & STATE
---------------------------------------------------------------------------
local Config = {
    -- Auto Steal Eggs
    AutoStealEggs       = false,
    SnipeAdminEggs      = false, -- Default UNCHECKED as requested
    StealZoneFilters    = getDefaultZoneTable(), -- All zones active by default
    StealRarityFilters  = getDefaultRarityTable(), -- All rarities active by default
    StealPriority       = "Nearest", -- "Nearest", "Biggest", "Random"
    StealStatus         = "Idle",

    -- Eggs (Plot)
    AutoPlaceEggs       = false,
    PlaceRarityFilters  = getDefaultRarityTable(),
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

    -- Egg ESP (Full map range, clean text with KG)
    EggESP              = false,
    ESPRarityFilters    = getDefaultRarityTable(),

    -- Background protections
    AntiRagdoll         = true,
    AntiAFK             = true,

    -- Movement mode
    SafeTravelMode      = false, -- Direct CFrame instant warp
    TweenSpeed          = 80,
    HumanizeDelays      = false,

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
        if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId 
           or base:GetAttribute("Owner") == LocalPlayer.Name 
           or (myPlotId and (base:GetAttribute("BaseId") == myPlotId or base.Name == tostring(myPlotId))) then
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
    if plot.PrimaryPart then
        return plot.PrimaryPart.Position, plot.PrimaryPart.CFrame, plot.PrimaryPart.Size
    end
    return plot:GetPivot().Position, plot:GetPivot(), Vector3.new(20, 2, 20)
end

local function isCarryingEgg()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChild("CarriedAlbum") ~= nil then return true end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and (item:GetAttribute("IsPhotocard") == true 
           or item:GetAttribute("CasePlacementTool") == true 
           or item:GetAttribute("AlbumZone") ~= nil 
           or item.Name:find("Egg") or item.Name:find("Album") 
           or item.Name:find("Stolen")) then
            return true
        end
    end
    return false
end

local function neutralizeNearbyGuards(targetPos, radius)
    radius = radius or 45
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local pName = obj.Name
                local mName = obj.Parent and obj.Parent.Name or ""
                if pName == "GuardRoot" or pName == "RigRoot" or pName:find("Guard") or mName:find("Guard") 
                   or mName == "Chicken" or mName == "Swan" or mName == "Scorpion" or mName == "Tiger" 
                   or mName == "Yeti" or mName == "Hellhound" or mName == "Moby" or mName == "T-Rex" 
                   or mName == "Dragon" or mName:find("fox") or mName:find("Gorilla") or mName:find("Angel") then
                    if (obj.Position - targetPos).Magnitude <= radius then
                        obj.CanTouch = false
                        obj.CanCollide = false
                    end
                end
            end
        end
    end)
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
    if egg:IsDescendantOf(workspace:FindFirstChild("PlayerBases") or workspace) then
        return "BASE"
    end
    return "UNKNOWN"
end

local function getEggSize(eggObj)
    local sz = eggObj:GetAttribute("AlbumSize") or eggObj:GetAttribute("Size")
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
    
    local label = egg:FindFirstChild("AlbumWeightLabel", true)
    if label and label:IsA("BillboardGui") then
        local text = label:FindFirstChildWhichIsA("TextLabel", true)
        if text and text.Text then
            if text.Text:find("ADMIN") then return "Admin" end
            for rarityName in pairs(RARITY_TIERS) do
                if text.Text:find(rarityName) then return rarityName end
            end
        end
    end
    return "Common"
end

local function isEggObject(obj)
    if not (obj:IsA("Model") or obj:IsA("Tool")) then return false end
    if obj:GetAttribute("PreviewOnly") == true then return false end
    if obj:GetAttribute("RarityAura") ~= nil 
       or obj:GetAttribute("CasePlacementTool") == true 
       or obj:GetAttribute("AlbumRarity") ~= nil 
       or obj:GetAttribute("AdminHuntEgg") == true 
       or obj:GetAttribute("ProductionEgg") == true 
       or obj:GetAttribute("EggId") ~= nil then
        return true
    end
    if obj:FindFirstChild("CasePart") ~= nil or obj:FindFirstChild("AlbumWeightLabel") ~= nil then return true end
    if obj.Name:find("Egg") or obj.Name:find("Album") then return true end
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and (prompt.ActionText:find("Steal") or prompt.ActionText:find("Take") or prompt.ActionText:find("Pick") or prompt.ObjectText:find("Egg") or prompt.ObjectText:find("Album")) then
        return true
    end
    return false
end

-- Comprehensive egg discovery across ALL locations with KG extraction
local function getAllEggs()
    local results = {}
    local seen = {}

    local function addTarget(item, zoneOverride, rarityOverride)
        if not item or seen[item] then return end
        if item:GetAttribute("OwnerUserId") == LocalPlayer.UserId then return end
        seen[item] = true

        local pivot = (item:IsA("Model") and item:GetPivot())
            or (item:FindFirstChild("CasePart") and item.CasePart.CFrame)
            or (item:FindFirstChild("Handle") and item.Handle.CFrame)
            or (item:GetAttribute("Ground") and CFrame.new(item:GetAttribute("Ground")))
            or (item:IsA("BasePart") and item.CFrame)
            or (item:FindFirstChildWhichIsA("BasePart") and item:FindFirstChildWhichIsA("BasePart").CFrame)

        if not pivot then return end

        local rarity = rarityOverride or getEggRarity(item)
        local zone = zoneOverride or getEggZone(item)
        local name = item:GetAttribute("EggName") or item:GetAttribute("AlbumType") or item.Name
        local weight = getEggWeight(item)
        local weightFormatted = formatKg(weight)

        table.insert(results, {
            Object          = item,
            Position        = pivot.Position,
            CFrame          = pivot,
            Zone            = zone,
            Rarity          = rarity,
            Tier            = RARITY_TIERS[rarity] or 1,
            Name            = name,
            Weight          = weight,
            WeightFormatted = weightFormatted
        })
    end

    -- 1. Admin Egg Hunt Drops
    local adminDrops = workspace:FindFirstChild("AdminEggHuntDrops")
    if adminDrops then
        for _, drop in ipairs(adminDrops:GetChildren()) do
            addTarget(drop, "GLOBAL", "Admin")
        end
    end

    -- 2. Exclusive Placed Eggs
    local excDrops = workspace:FindFirstChild("ExclusivePlacedEggs")
    if excDrops then
        for _, drop in ipairs(excDrops:GetChildren()) do
            addTarget(drop, "GLOBAL", "Exclusive")
        end
    end

    -- 3. Danger Zones (All zones)
    local dz = workspace:FindFirstChild("DangerZones")
    if dz then
        for _, zoneFolder in ipairs(dz:GetChildren()) do
            local zName = string.upper(tostring(zoneFolder:GetAttribute("ZoneName") or zoneFolder.Name))
            for _, desc in ipairs(zoneFolder:GetDescendants()) do
                if isEggObject(desc) then
                    addTarget(desc, zName)
                end
            end
        end
    end

    -- 4. Other Players' Bases (PlayerBases)
    local bases = workspace:FindFirstChild("PlayerBases")
    if bases then
        for _, base in ipairs(bases:GetChildren()) do
            if base:GetAttribute("OwnerUserId") ~= LocalPlayer.UserId then
                for _, desc in ipairs(base:GetDescendants()) do
                    if isEggObject(desc) then
                        addTarget(desc, "BASE")
                    end
                end
            end
        end
    end

    -- 5. Global workspace scan for admin/exclusive tagged eggs
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("Model") or desc:IsA("Tool") then
            if desc:GetAttribute("AdminHuntEgg") == true or desc.Name == "AdminEgg" then
                addTarget(desc, "GLOBAL", "Admin")
            elseif desc:GetAttribute("ExclusiveSetId") ~= nil then
                addTarget(desc, "GLOBAL", "Exclusive")
            end
        end
    end

    return results
end

local function getAdminAndExclusiveEggs()
    local all = getAllEggs()
    local adminEggs = {}
    for _, egg in ipairs(all) do
        if egg.Rarity == "Admin" or egg.Rarity == "Exclusive" or egg.Zone == "GLOBAL" then
            table.insert(adminEggs, egg)
        end
    end
    return adminEggs
end

local function getAllEligibleEggs()
    local all = getAllEggs()
    local filtered = {}

    for _, egg in ipairs(all) do
        local zonePass = false
        if next(Config.StealZoneFilters) == nil then
            zonePass = true
        elseif egg.Zone == "GLOBAL" or egg.Zone == "BASE" then
            zonePass = true
        else
            for z, active in pairs(Config.StealZoneFilters) do
                if active and (egg.Zone:find(z) or z:find(egg.Zone)) then
                    zonePass = true
                    break
                end
            end
        end

        local rarityPass = false
        if next(Config.StealRarityFilters) == nil then
            rarityPass = true
        elseif Config.StealRarityFilters[egg.Rarity] == true then
            rarityPass = true
        end

        if zonePass and rarityPass then
            table.insert(filtered, egg)
        end
    end

    return filtered
end

local function teleportTo(cframeOrPos, forceInstant)
    local root = getRootPart()
    if not root then return end
    local targetCF = typeof(cframeOrPos) == "CFrame" and cframeOrPos or CFrame.new(cframeOrPos)

    if forceInstant or not Config.SafeTravelMode then
        root.CFrame = targetCF
        return
    end

    local dist = (root.Position - targetCF.Position).Magnitude
    if dist <= 8 then
        root.CFrame = targetCF
        return
    end

    local speed = Config.TweenSpeed or 80
    local duration = math.clamp(dist / speed, 0.2, 4.0)
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tween:Play()
    tween.Completed:Wait()
end

---------------------------------------------------------------------------
-- STATUS NOTIFICATION HELPER
---------------------------------------------------------------------------
local updateUIStatus

local function setStatus(text)
    Config.StealStatus = text
    if updateUIStatus then
        updateUIStatus(text)
    end
end

---------------------------------------------------------------------------
-- CORE ENGINE SERVICES
---------------------------------------------------------------------------

-- 1. AUTO STEAL EGGS SERVICE (Ultra-Fast Snatch & Anti-Guardian Return)
local isStealingActive = false

task.spawn(function()
    while true do
        task.wait(0.04)
        if Config.AutoStealEggs and not isStealingActive then
            local root = getRootPart()
            if not root then
                task.wait(0.5)
                continue
            end

            -- NOTE: Do NOT drop eggs at base! Player keeps holding eggs or safe zone scores automatically.

            local eggs = {}

            -- Dedicated Admin & Exclusive Global Sniper Check (when enabled)
            if Config.SnipeAdminEggs then
                local adminEggs = getAdminAndExclusiveEggs()
                if #adminEggs > 0 then
                    eggs = adminEggs
                    setStatus("⚡ Admin Egg detected! Sniping...")
                end
            end

            if #eggs == 0 then
                eggs = getAllEligibleEggs()
            end

            if #eggs == 0 then
                setStatus("Searching for eggs...")
                task.wait(0.3)
            else
                local myPos = root.Position
                local target = nil

                if Config.StealPriority == "Biggest" then
                    table.sort(eggs, function(a, b)
                        local wA = a.Weight or getEggSize(a.Object)
                        local wB = b.Weight or getEggSize(b.Object)
                        if wA == wB then
                            return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
                        end
                        return wA > wB
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
                    isStealingActive = true
                    local targetLabel = tostring(target.Name) .. " (" .. target.Rarity .. (target.WeightFormatted and (" • " .. target.WeightFormatted) or "") .. ")"
                    setStatus("Snatching " .. targetLabel .. "...")

                    -- Pre-calculate return Plot CFrame BEFORE warp so zero time is wasted
                    local _, plotCF = getPlotFloorPosition()
                    local returnCF = plotCF and (plotCF + Vector3.new(0, 3, 0)) or (root.CFrame)

                    -- Neutralize nearby guardian collision and touch detection
                    neutralizeNearbyGuards(target.Position, 45)

                    -- 1. Instant warp elevated slightly above ground guardian melee reach (HitDistance is 2.5 - 5 studs)
                    root.CFrame = target.CFrame + Vector3.new(0, 3.8, 0)

                    -- 2. Find ProximityPrompt inside egg or touch fallback
                    local prompt = target.Object:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if not prompt then
                        local casePart = target.Object:FindFirstChild("CasePart")
                        if casePart then
                            prompt = casePart:FindFirstChildWhichIsA("ProximityPrompt", true)
                        end
                    end

                    -- 3. Fire prompt interaction instantly (zero hold duration)
                    if prompt then
                        safeFireProximityPrompt(prompt)
                    else
                        local part = target.Object:FindFirstChildWhichIsA("BasePart", true)
                        if part and root and firetouchinterest then
                            pcall(function()
                                firetouchinterest(root, part, 0)
                                task.wait(0.01)
                                firetouchinterest(root, part, 1)
                            end)
                        end
                    end

                    -- 4. Micro-poll (checks every 0.01s up to max 0.06s)
                    -- The instant egg is held, break immediately so player is gone before the guard can wake up (GuardWakeSeconds = 0.63s)
                    for _ = 1, 6 do
                        if isCarryingEgg() then
                            break
                        end
                        if prompt and not prompt.RequiresLineOfSight then
                            safeFireProximityPrompt(prompt)
                        end
                        task.wait(0.01)
                    end

                    -- 5. INSTANT SNAP BACK TO PLOT FLOOR
                    root.CFrame = returnCF

                    -- 6. Yield 0.04s at base for server safe-zone verification (GuardEscapedAt / Egg secured)
                    task.wait(0.04)

                    -- NOTE: As requested by user:
                    -- DO NOT drop egg at base (never call DropAlbumRemote)
                    -- DO NOT check if player is holding egg or wait for hand to clear
                    -- Immediately proceed to snatch next egg!
                    setStatus("Secured at Plot! Warping to next egg...")

                    task.wait(0.02)
                    isStealingActive = false
                end
            end
        else
            if not Config.AutoStealEggs and Config.StealStatus ~= "Idle" then
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
                local eggTool = nil
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
                        break
                    end
                end

                if eggTool and PlaceRemote then
                    hum:EquipTool(eggTool)
                    task.wait(0.2)
                    local plotPos = getPlotFloorPosition()
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

            if Config.AutoUpgradeTreadmill and TreadmillUpgradeReq then
                local currentLvl = myTreadmill:GetAttribute("Level") or 1
                pcall(function()
                    TreadmillUpgradeReq:FireServer(myTreadmill, currentLvl)
                end)
            end
        end
    end
end)

-- 6. AUTO PROGRESSION SERVICE
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
                        pcall(function() TrailRequestRemote:InvokeServer("Buy", trail.Id) end)
                        pcall(function() TrailRequestRemote:InvokeServer("Equip", trail.Id) end)
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

-- 7. PASSIVE BEAR TRAP & RAGDOLL IMMUNITY
local function neutralizeTraps()
    for _, trap in ipairs(workspace:GetDescendants()) do
        if trap:IsA("Model") and (trap.Name:find("BearTrap") or trap.Name:find("Trap") or trap:GetAttribute("BearTrapTool") ~= nil) then
            for _, part in ipairs(trap:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = false
                    part.CanCollide = false
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AntiRagdoll then
            pcall(neutralizeTraps)
        end
    end
end)

workspace.DescendantAdded:Connect(function(desc)
    if Config.AntiRagdoll then
        if desc:IsA("Model") and (desc.Name:find("BearTrap") or desc.Name:find("Trap")) then
            for _, part in ipairs(desc:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = false
                    part.CanCollide = false
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AntiRagdoll then
        local char = getCharacter()
        local hum = getHumanoid()
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown or hum.PlatformStand then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        if char then
            if char:GetAttribute("GuardRagdolled") == true then char:SetAttribute("GuardRagdolled", false) end
            if char:GetAttribute("GuardPlatformStand") == true then char:SetAttribute("GuardPlatformStand", false) end
            if char:GetAttribute("GuardRecovering") == true then char:SetAttribute("GuardRecovering", false) end
            local grc = char:FindFirstChild("GuardRagdollClient")
            if grc and grc:IsA("LocalScript") and grc.Enabled then
                grc.Enabled = false
            end
        end
        LocalPlayer:SetAttribute("GuardStunnedUntil", 0)
    end
end)

-- 8. ANTI-AFK
if Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

---------------------------------------------------------------------------
-- USER INTERFACE: "Alexandria Main"
---------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlexandriaHub_StealKPOPEggs"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = getGuiParent()

---------------------------------------------------------------------------
-- EGG ESP SERVICE (Infinite Range, No Box/Border, No Distance, Shows KG)
---------------------------------------------------------------------------
local ActiveESPs = {}

local function clearESP(obj)
    if ActiveESPs[obj] then
        pcall(function()
            if ActiveESPs[obj].Billboard then ActiveESPs[obj].Billboard:Destroy() end
        end)
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

    local eggs = getAllEggs()
    local seen = {}

    for _, eggInfo in ipairs(eggs) do
        local obj = eggInfo.Object
        seen[obj] = true

        local showRarity = (next(Config.ESPRarityFilters) == nil) or (Config.ESPRarityFilters[eggInfo.Rarity] == true)

        if showRarity then
            local color = RARITY_COLORS[eggInfo.Rarity] or Color3.fromRGB(255, 255, 255)

            if not ActiveESPs[obj] then
                local adorneePart = (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChild("CasePart") or obj:FindFirstChildWhichIsA("BasePart"))) 
                    or (obj:IsA("Tool") and (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))) 
                    or (obj:IsA("BasePart") and obj)

                local bb = nil
                local infoLabel = nil
                if adorneePart then
                    pcall(function()
                        bb = Instance.new("BillboardGui")
                        bb.Name = "Alexandria_EggLabel"
                        bb.Adornee = adorneePart
                        bb.Size = UDim2.fromOffset(180, 36)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        bb.MaxDistance = math.huge -- Infinite view distance
                        bb.LightInfluence = 0
                        bb.Active = false
                        bb.Parent = ScreenGui

                        -- Borderless, transparent container (No Highlight box, No border)
                        local container = Instance.new("Frame")
                        container.Size = UDim2.fromScale(1, 1)
                        container.BackgroundTransparency = 1
                        container.BorderSizePixel = 0
                        container.Parent = bb

                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Name = "Title"
                        nameLabel.Size = UDim2.new(1, 0, 0, 18)
                        nameLabel.Position = UDim2.fromOffset(0, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.TextSize = 13
                        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        nameLabel.TextStrokeTransparency = 0.2
                        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                        nameLabel.Text = eggInfo.Name
                        nameLabel.Parent = container

                        infoLabel = Instance.new("TextLabel")
                        infoLabel.Name = "Info"
                        infoLabel.Size = UDim2.new(1, 0, 0, 16)
                        infoLabel.Position = UDim2.fromOffset(0, 18)
                        infoLabel.BackgroundTransparency = 1
                        infoLabel.Font = Enum.Font.GothamMedium
                        infoLabel.TextSize = 11
                        infoLabel.TextColor3 = color
                        infoLabel.TextStrokeTransparency = 0.3
                        infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                        if eggInfo.WeightFormatted then
                            infoLabel.Text = string.format("[%s] %s • %s", eggInfo.Zone, eggInfo.Rarity, eggInfo.WeightFormatted)
                        else
                            infoLabel.Text = string.format("[%s] %s", eggInfo.Zone, eggInfo.Rarity)
                        end
                        infoLabel.Parent = container
                    end)
                end

                ActiveESPs[obj] = { Billboard = bb, InfoLabel = infoLabel, Color = color }
            else
                local info = ActiveESPs[obj]
                if info.InfoLabel and info.InfoLabel.Parent then
                    if eggInfo.WeightFormatted then
                        info.InfoLabel.Text = string.format("[%s] %s • %s", eggInfo.Zone, eggInfo.Rarity, eggInfo.WeightFormatted)
                    else
                        info.InfoLabel.Text = string.format("[%s] %s", eggInfo.Zone, eggInfo.Rarity)
                    end
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

-- Main Frame (780 x 500)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(780, 500)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 38, 52)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Dragging Behavior for MainFrame
local isDragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.Y - MainFrame.AbsolutePosition.Y <= 42 then
            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 240, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(16, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 15
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.Text = "◈  Alexandria Main"
HeaderTitle.Parent = Header

-- Floating Circular Minimize Icon Button
local FloatingIcon = Instance.new("ImageButton")
FloatingIcon.Name = "Alexandria_FloatingIcon"
FloatingIcon.Size = UDim2.fromOffset(50, 50)
FloatingIcon.Position = UDim2.new(0.5, -25, 0, 18)
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

local FloatInnerIcon = Instance.new("TextLabel")
FloatInnerIcon.Size = UDim2.fromScale(1, 1)
FloatInnerIcon.BackgroundTransparency = 1
FloatInnerIcon.Font = Enum.Font.GothamBold
FloatInnerIcon.TextSize = 22
FloatInnerIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatInnerIcon.Text = "◈"
FloatInnerIcon.Parent = FloatingIcon

-- Draggable Floating Icon
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

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.PaddingLeft = UDim.new(0, 4)
SidebarPad.PaddingRight = UDim.new(0, 4)
SidebarPad.Parent = Sidebar

-- Content Container (Right)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -182, 1, -80)
ContentContainer.Position = UDim2.fromOffset(172, 42)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = false
ContentContainer.Parent = MainFrame

-- Footer (Status Bar)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 36)
Footer.Position = UDim2.new(0, 0, 1, -36)
Footer.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 10)
FooterCorner.Parent = Footer

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(0.65, 0, 1, 0)
FooterText.Position = UDim2.fromOffset(16, 0)
FooterText.BackgroundTransparency = 1
FooterText.Font = Enum.Font.Gotham
FooterText.TextSize = 11
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.TextColor3 = Color3.fromRGB(120, 125, 145)
FooterText.Text = "Status: Idle | Anti-Detect Safe | Ready"
FooterText.Parent = Footer

updateUIStatus = function(txt)
    FooterText.Text = "Status: " .. txt .. " | Anti-Detect Safe"
end

local FooterBuild = Instance.new("TextLabel")
FooterBuild.Size = UDim2.new(0.3, 0, 1, 0)
FooterBuild.Position = UDim2.new(0.7, -16, 0, 0)
FooterBuild.BackgroundTransparency = 1
FooterBuild.Font = Enum.Font.Gotham
FooterBuild.TextSize = 11
FooterBuild.TextXAlignment = Enum.TextXAlignment.Right
FooterBuild.TextColor3 = Color3.fromRGB(80, 85, 105)
FooterBuild.Text = "Alexandria v3.3"
FooterBuild.Parent = Footer

---------------------------------------------------------------------------
-- TAB SYSTEM (Main & Settings ONLY — Exactly matching picture-1.png)
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
    tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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
local SettingsTab = createTab("Settings", "⚙")

Tabs["Main"].Visible = true
TabButtons["Main"].BackgroundColor3 = Color3.fromRGB(32, 35, 46)
TabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)

---------------------------------------------------------------------------
-- UI COMPONENT BUILDERS
---------------------------------------------------------------------------
local function createCard(parent, title, icon)
    local card = Instance.new("Frame")
    card.Name = title:gsub("%s+", "") .. "Card"
    card.Size = UDim2.new(1, 0, 0, 40)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.BorderSizePixel = 0
    card.ClipsDescendants = false
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(32, 35, 46)
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingTop = UDim.new(0, 10)
    cardPad.PaddingBottom = UDim.new(0, 12)
    cardPad.PaddingLeft = UDim.new(0, 12)
    cardPad.PaddingRight = UDim.new(0, 12)
    cardPad.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.Padding = UDim.new(0, 8)
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Parent = card

    local cardHeader = Instance.new("TextLabel")
    cardHeader.Name = "CardHeader"
    cardHeader.Size = UDim2.new(1, 0, 0, 20)
    cardHeader.BackgroundTransparency = 1
    cardHeader.Font = Enum.Font.GothamBold
    cardHeader.TextSize = 13
    cardHeader.TextXAlignment = Enum.TextXAlignment.Left
    cardHeader.TextColor3 = Color3.fromRGB(240, 242, 250)
    cardHeader.Text = (icon and (icon .. "  ") or "") .. title
    cardHeader.LayoutOrder = 0
    cardHeader.Parent = card

    return card
end

local function createToggle(parent, labelText, defaultValue, callback)
    local state = defaultValue or false
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(200, 205, 220)
    label.Text = labelText
    label.Parent = container

    local toggleTrack = Instance.new("TextButton")
    toggleTrack.Size = UDim2.fromOffset(40, 20)
    toggleTrack.Position = UDim2.new(1, -40, 0.5, -10)
    toggleTrack.BackgroundColor3 = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 44, 58)
    toggleTrack.BorderSizePixel = 0
    toggleTrack.Text = ""
    toggleTrack.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = toggleTrack

    local toggleThumb = Instance.new("Frame")
    toggleThumb.Size = UDim2.fromOffset(16, 16)
    toggleThumb.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleThumb.BorderSizePixel = 0
    toggleThumb.Parent = toggleTrack

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = toggleThumb

    toggleTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 44, 58)
        TweenService:Create(toggleThumb, TweenInfo.new(0.18), { Position = targetPos }):Play()
        TweenService:Create(toggleTrack, TweenInfo.new(0.18), { BackgroundColor3 = targetColor }):Play()
        if callback then callback(state) end
    end)

    return container
end

local activeDropdownClose = nil

local function createDropdown(parent, labelText, options, defaultSelected, isMulti, callback)
    local isOpen = false
    local ddFrame = Instance.new("Frame")
    ddFrame.Size = UDim2.new(1, 0, 0, 48)
    ddFrame.BackgroundTransparency = 1
    ddFrame.ClipsDescendants = false
    ddFrame.ZIndex = 75
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
    selectBtn.ZIndex = 76
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
    arrow.ZIndex = 77
    arrow.Parent = selectBtn

    local listContainer = Instance.new("ScrollingFrame")
    listContainer.Name = "DropdownList"
    listContainer.Size = UDim2.new(1, 0, 0, 150)
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
    local optionButtons = {}

    local function updateButtonText()
        if isMulti then
            local count = 0
            local names = {}
            for _, opt in ipairs(options) do
                if selectedState[opt] then
                    count = count + 1
                    table.insert(names, opt)
                end
            end
            if count == 0 then
                selectBtn.Text = "  None Selected"
            elseif count == #options then
                selectBtn.Text = "  All Selected (" .. #options .. ")"
            elseif count <= 2 then
                selectBtn.Text = "  " .. table.concat(names, ", ")
            else
                selectBtn.Text = "  " .. names[1] .. ", " .. names[2] .. "... (" .. count .. ")"
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
        ddFrame.Size = isOpen and UDim2.new(1, 0, 0, 205) or UDim2.new(1, 0, 0, 48)
        if isOpen then
            activeDropdownClose = setDropdownOpen
        elseif activeDropdownClose == setDropdownOpen then
            activeDropdownClose = nil
        end
    end

    -- Top Action Row for Multi-Select: [ Select All ] [ Deselect All ]
    if isMulti then
        local actionRow = Instance.new("Frame")
        actionRow.Name = "ActionRow"
        actionRow.Size = UDim2.new(1, 0, 0, 24)
        actionRow.BackgroundTransparency = 1
        actionRow.LayoutOrder = 0
        actionRow.ZIndex = 82
        actionRow.Parent = listContainer

        local actLayout = Instance.new("UIListLayout")
        actLayout.FillDirection = Enum.FillDirection.Horizontal
        actLayout.Padding = UDim.new(0, 4)
        actLayout.Parent = actionRow

        local selectAllBtn = Instance.new("TextButton")
        selectAllBtn.Name = "SelectAllBtn"
        selectAllBtn.Size = UDim2.new(0.5, -2, 1, 0)
        selectAllBtn.BackgroundColor3 = Color3.fromRGB(32, 38, 55)
        selectAllBtn.BorderSizePixel = 0
        selectAllBtn.Font = Enum.Font.GothamMedium
        selectAllBtn.TextSize = 11
        selectAllBtn.TextColor3 = Color3.fromRGB(129, 140, 248)
        selectAllBtn.Text = "✓ Select All"
        selectAllBtn.ZIndex = 86
        selectAllBtn.Parent = actionRow

        local selCorner = Instance.new("UICorner")
        selCorner.CornerRadius = UDim.new(0, 4)
        selCorner.Parent = selectAllBtn

        local deselectAllBtn = Instance.new("TextButton")
        deselectAllBtn.Name = "DeselectAllBtn"
        deselectAllBtn.Size = UDim2.new(0.5, -2, 1, 0)
        deselectAllBtn.BackgroundColor3 = Color3.fromRGB(38, 30, 36)
        deselectAllBtn.BorderSizePixel = 0
        deselectAllBtn.Font = Enum.Font.GothamMedium
        deselectAllBtn.TextSize = 11
        deselectAllBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
        deselectAllBtn.Text = "✕ Deselect All"
        deselectAllBtn.ZIndex = 86
        deselectAllBtn.Parent = actionRow

        local deselCorner = Instance.new("UICorner")
        deselCorner.CornerRadius = UDim.new(0, 4)
        deselCorner.Parent = deselectAllBtn

        local function refreshMultiButtons()
            for opt, btn in pairs(optionButtons) do
                btn.Text = (selectedState[opt] and "  [✓] " or "  [  ] ") .. opt
                btn.TextColor3 = selectedState[opt] and Color3.fromRGB(129, 140, 248) or Color3.fromRGB(210, 215, 230)
            end
            updateButtonText()
            if callback then callback(selectedState) end
        end

        selectAllBtn.MouseButton1Click:Connect(function()
            for _, opt in ipairs(options) do
                selectedState[opt] = true
            end
            refreshMultiButtons()
        end)

        deselectAllBtn.MouseButton1Click:Connect(function()
            for _, opt in ipairs(options) do
                selectedState[opt] = false
            end
            refreshMultiButtons()
        end)
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
        optBtn.LayoutOrder = idx + 1
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        if isMulti then
            optionButtons[opt] = optBtn
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
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(30, 33, 45)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(230, 235, 245)
    btn.Text = text
    btn.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(45, 50, 68)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(42, 46, 62) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(30, 33, 45) }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

---------------------------------------------------------------------------
-- POPULATE MAIN TAB (2-Column Layout Matching picture-1.png)
---------------------------------------------------------------------------
local ColumnsContainer = Instance.new("Frame")
ColumnsContainer.Size = UDim2.new(1, 0, 0, 0)
ColumnsContainer.AutomaticSize = Enum.AutomaticSize.Y
ColumnsContainer.BackgroundTransparency = 1
ColumnsContainer.Parent = MainTab

local ColumnsLayout = Instance.new("UIListLayout")
ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
ColumnsLayout.Padding = UDim.new(0, 10)
ColumnsLayout.Parent = ColumnsContainer

-- Left Column
local Col1 = Instance.new("Frame")
Col1.Name = "Col1"
Col1.Size = UDim2.new(0.5, -5, 0, 0)
Col1.AutomaticSize = Enum.AutomaticSize.Y
Col1.BackgroundTransparency = 1
Col1.ClipsDescendants = false
Col1.Parent = ColumnsContainer

local Col1Layout = Instance.new("UIListLayout")
Col1Layout.Padding = UDim.new(0, 10)
Col1Layout.Parent = Col1

-- Right Column
local Col2 = Instance.new("Frame")
Col2.Name = "Col2"
Col2.Size = UDim2.new(0.5, -5, 0, 0)
Col2.AutomaticSize = Enum.AutomaticSize.Y
Col2.BackgroundTransparency = 1
Col2.ClipsDescendants = false
Col2.Parent = ColumnsContainer

local Col2Layout = Instance.new("UIListLayout")
Col2Layout.Padding = UDim.new(0, 10)
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

local prevUpdateUIStatus = updateUIStatus
updateUIStatus = function(txt)
    StatusLabel.Text = "Status: " .. txt
    if prevUpdateUIStatus then prevUpdateUIStatus(txt) end
end

-- 2. Treadmill Card
local TreadmillCard = createCard(Col1, "Treadmill", "⚯")
createToggle(TreadmillCard, "Auto Go On Treadmill", Config.AutoGoOnTreadmill, function(v)
    Config.AutoGoOnTreadmill = v
end)
createToggle(TreadmillCard, "Auto Upgrade Treadmill", Config.AutoUpgradeTreadmill, function(v)
    Config.AutoUpgradeTreadmill = v
end)

-- 3. Egg ESP Card (Infinite Range, No Box, Shows KG)
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

-- 3. Teleport Card (With dedicated Teleport To Plot and Teleport To Zone button)
local TeleportCard = createCard(Col2, "Teleport", "⚲")
createButton(TeleportCard, "Teleport To Plot", function()
    local _, plotCF = getPlotFloorPosition()
    if plotCF then
        teleportTo(plotCF + Vector3.new(0, 3, 0), true)
        setStatus("Teleported to Plot!")
    else
        setStatus("Could not locate owned plot!")
    end
end)

createDropdown(TeleportCard, "Zone", ZONES, Config.SelectedTeleportZone, false, function(selected)
    Config.SelectedTeleportZone = selected
end)

createButton(TeleportCard, "Teleport To Zone", function()
    local selected = Config.SelectedTeleportZone or ZONES[1]
    local dz = workspace:FindFirstChild("DangerZones")
    local found = false
    if dz then
        for _, z in ipairs(dz:GetChildren()) do
            local zName = z:GetAttribute("ZoneName") or z.Name
            if string.upper(zName):find(selected) or selected:find(string.upper(zName)) then
                local startX = z:GetAttribute("StartX") or 0
                local endX = z:GetAttribute("EndX") or startX + 50
                local centerZ = dz:GetAttribute("CenterZ") or 0
                teleportTo(Vector3.new((startX + endX) / 2, 8, centerZ), true)
                setStatus("Teleported to Zone: " .. selected)
                found = true
                break
            end
        end
    end
    if not found then
        setStatus("Zone " .. tostring(selected) .. " not found!")
    end
end)

createButton(TeleportCard, "Teleport: Treadmill Conveyor", function()
    for _, tm in ipairs(CollectionService:GetTagged("Treadmill")) do
        if tm:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            local conveyor = tm:FindFirstChild("Conveyor")
            if conveyor then
                teleportTo(conveyor.CFrame + Vector3.new(0, 3, 0), true)
                setStatus("Teleported to Treadmill!")
            end
            break
        end
    end
end)

createButton(TeleportCard, "Teleport: Safe Zone", function()
    local safeBoundary = workspace:FindFirstChild("SafeZoneBoundary")
    if safeBoundary then
        teleportTo(safeBoundary:GetPivot().Position + Vector3.new(0, 3, 0), true)
        setStatus("Teleported to Safe Zone!")
    else
        local _, plotCF = getPlotFloorPosition()
        if plotCF then
            teleportTo(plotCF + Vector3.new(0, 3, 0), true)
        end
    end
end)

---------------------------------------------------------------------------
-- POPULATE SETTINGS TAB (Configuration Presets & General Settings)
---------------------------------------------------------------------------
local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 10)
SettingsLayout.Parent = SettingsTab

local PresetCard = createCard(SettingsTab, "Configuration Presets", "💾")
local PRESET_FILE = "Alexandria_StealKPOPEggs_Config.json"

local function savePreset()
    local success, err = pcall(function()
        local data = HttpService:JSONEncode(Config)
        if writefile then
            writefile(PRESET_FILE, data)
        else
            getgenv().AlexandriaSavedPreset = data
        end
    end)
    if success then
        setStatus("Preset Saved successfully to file!")
    else
        setStatus("Failed to save preset: " .. tostring(err))
    end
end

local function loadPreset()
    local success, content = pcall(function()
        if readfile and isfile and isfile(PRESET_FILE) then
            return readfile(PRESET_FILE)
        elseif getgenv and getgenv().AlexandriaSavedPreset then
            return getgenv().AlexandriaSavedPreset
        end
        error("No preset file found!")
    end)
    if success and content then
        local decodeSuccess, loadedConfig = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if decodeSuccess and type(loadedConfig) == "table" then
            for k, v in pairs(loadedConfig) do
                Config[k] = v
            end
            setStatus("Preset Loaded successfully!")
        else
            setStatus("Failed: Preset data corrupted!")
        end
    else
        setStatus("No saved preset file found!")
    end
end

local function resetDefaults()
    Config.AutoStealEggs = false
    Config.SnipeAdminEggs = false
    Config.StealZoneFilters = getDefaultZoneTable()
    Config.StealRarityFilters = getDefaultRarityTable()
    Config.StealPriority = "Nearest"
    Config.AutoPlaceEggs = false
    Config.PlaceRarityFilters = getDefaultRarityTable()
    Config.AutoHatch = false
    Config.AutoEquipBest = false
    Config.AutoGoOnTreadmill = false
    Config.AutoUpgradeTreadmill = false
    Config.AutoUpgradeBase = false
    Config.AutoClaimIndex = false
    Config.AutoClaimDaily = false
    Config.AutoBuyTrail = false
    Config.AutoBuyCosmetics = false
    Config.EggESP = false
    Config.ESPRarityFilters = getDefaultRarityTable()
    Config.AntiRagdoll = true
    Config.SafeTravelMode = false
    setStatus("Settings reset to defaults.")
end

createButton(PresetCard, "💾 Save Current Preset", savePreset)
createButton(PresetCard, "📂 Load Saved Preset", loadPreset)
createButton(PresetCard, "🔄 Reset to Default Settings", resetDefaults)

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
    Config.EggESP = false
    for obj in pairs(ActiveESPs) do clearESP(obj) end
    ScreenGui:Destroy()
end)

-- Keybind: RightShift to toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        if FloatingIcon.Visible then
            FloatingIcon.Visible = false
        end
    end
end)

---------------------------------------------------------------------------
-- STARTUP NOTIFICATION
---------------------------------------------------------------------------
print([[
    ╔═══════════════════════════════════════════════════════════╗
    ║       ALEXANDRIA MAIN — STEAL KPOP EGGS LOADED!           ║
    ║       UI Hotkey: RightShift                               ║
    ║       Version: 3.3.0 (Streamlined & Rapid)                ║
    ╚═══════════════════════════════════════════════════════════╝
]])

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Alexandria Main",
        Text = "Loaded successfully! Press RightShift or use floating icon.",
        Duration = 5
    })
end)
