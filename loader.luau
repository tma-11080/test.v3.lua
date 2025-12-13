-- UI Library
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

-- Window
local Window = Library:MakeWindow({
    Title = "mac lol Hub : Cool Game",
    SubTitle = "by real_redz",
    ScriptFolder = "redz-library-V5"
})

-- Minimizer
local Minimizer = Window:NewMinimizer({
    KeyCode = Enum.KeyCode.LeftControl
})

local MobileButton = Minimizer:CreateMobileMinimizer({
    Image = "rbxassetid://74521750290358",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Size = UDim2.fromOffset(50, 50)
})

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MobileButton

-- Tabs
local FarmTab = Window:MakeTab({
    Title = "test farm Tab",
    Icon = "Home"
})

local MiscTab = Window:MakeTab({
    Title = "misc Tab",
    Icon = "settings"
})

-- Dropdown（動作確認用）
FarmTab:AddDropdown({
    Name = "Scarlet Tool",
    MultiSelect = false,
    Options = {"Melee", "Blox fruits", "Sword", "gen"},
    Default = "Melee",
    Callback = function(Value)
        print("選択:", Value)
    end
})

        local fastAttack = false  -- ON/OFF 制御用フラグ

MiscTab:AddToggle({
    Name = "Fast attack (kill aura)",
    Default = false,
    Callback = function(Value)
        fastAttack = Value  -- ONならtrue, OFFならfalse
    end
})

-- 攻撃関数（提示コードそのまま）
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function IsEntityAlive(entity)
    if not entity then return false end
    local humanoid = entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetEnemiesInRange(character, range)
    local enemies = game:GetService("Workspace").Enemies:GetChildren()
    local players = game:GetService("Players"):GetPlayers()
    local targets = {}
    local playerPos = character:GetPivot().Position

    for _, enemy in ipairs(enemies) do
        local rootPart = enemy:FindFirstChild("HumanoidRootPart")
        if rootPart and IsEntityAlive(enemy) then
            local distance = (rootPart.Position - playerPos).Magnitude
            if distance <= range then
                table.insert(targets, enemy)
            end
        end
    end

    for _, otherPlayer in ipairs(players) do
        if otherPlayer ~= player and otherPlayer.Character then
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart and IsEntityAlive(otherPlayer.Character) then
                local distance = (rootPart.Position - playerPos).Magnitude
                if distance <= range then
                    table.insert(targets, otherPlayer.Character)
                    return targets
                end
            end
        end
    end

    return targets
end

local function attackNoCoolDown()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local equippedWeapon
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            equippedWeapon = item
            break
        end
    end
    if not equippedWeapon then return end

    local attackRange = 50
    if hrp:FindFirstChild("Buddha") then
        attackRange = 150
    end

    local enemiesInRange = GetEnemiesInRange(character, attackRange)

    if equippedWeapon:FindFirstChild("LeftClickRemote") then
        local attackCount = 1
        for _, enemy in ipairs(enemiesInRange) do
            local rootPart = enemy:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local direction = (rootPart.Position - character:GetPivot().Position).Unit
                equippedWeapon.LeftClickRemote:FireServer(direction, attackCount)
                attackCount = attackCount + 1
            end
        end
    else
        local targets, mainTarget = {}, nil

        for _, enemy in ipairs(enemiesInRange) do
            if not enemy:GetAttribute("IsBoat") then
                local head = enemy:FindFirstChild("Head")
                if head then
                    table.insert(targets, { enemy, head })
                    mainTarget = head
                end
            end
        end

        if mainTarget then
            local attackEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack")
            local hitEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit")

            pcall(function()
                attackEvent:FireServer(0.05)
                hitEvent:FireServer(mainTarget, targets)
            end)
        end
    end
end

-- 無限ループでON/OFFを監視
task.spawn(function()
    while task.wait(0.05) do
        if fastAttack then
            attackNoCoolDown()
        end
    end
end)
local defaultWalkSpeed = 16
local speedValue = 100
local toggleEnabled = false

-- Toggle（上に配置される）
miscTab:AddToggle({
    Name = "Enable Speed",
    Default = false,
    Callback = function(Value)
        toggleEnabled = Value
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            if toggleEnabled then
                player.Character.Humanoid.WalkSpeed = speedValue
            else
                player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
            end
        end
    end
})

-- Slider
miscTab:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 300,
    Increment = 1,
    Default = speedValue,
    Callback = function(Value)
        speedValue = Value
        if toggleEnabled then
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = speedValue
            end
        end
    end
})

-- 毎フレーム更新（念のため）
game:GetService("RunService").RenderStepped:Connect(function()
    if toggleEnabled then
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = speedValue
        end
    end
end)
