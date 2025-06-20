-- 🌊 Blox Fruits Leviathan Auto-Hunt Script (Full Version with IDK Check)
-- ✅ Người mua thuyền đầu tiên trong server là Captain
-- ✅ Tự săn boss, bắn tim, kéo về Tiki, bảo vệ thuyền, kiểm tra IDK...

local plr = game.Players.LocalPlayer
local ws = game.Workspace
local rs = game.ReplicatedStorage
local HRP = plr.Character:WaitForChild("HumanoidRootPart")
local isCaptain = false
local boat = nil
local heart = nil
local tiki = CFrame.new(58467, 5, -15585)
_G.CAPTAIN_NAME = _G.CAPTAIN_NAME or nil

-- 📦 Check IDK Leviathan
local function hasIDK()
    local notif = plr.PlayerGui:FindFirstChild("Notification")
    return notif and notif:FindFirstChild("TextLabel") and notif.TextLabel.Text:lower():find("idk leviathan")
end

local function findSeaEventMob()
    for _, mob in pairs(ws:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Name:lower():find("sea") and mob.Humanoid.Health > 0 then
            return mob
        end
    end
    return nil
end

-- 🛶 MUA THUYỀN LEVIATHAN
if not _G.CAPTAIN_NAME then
    rs.Remotes.CommF_:InvokeServer("BuyBoat", "Leviathan")
    _G.CAPTAIN_NAME = plr.Name
    isCaptain = true
else
    isCaptain = (plr.Name == _G.CAPTAIN_NAME)
end

-- 🔍 TÌM THUYỀN LEVIATHAN
repeat
    for _, v in pairs(ws:GetChildren()) do
        if v.Name == "Leviathan" and v:FindFirstChild("BoatOwner") and v.BoatOwner.Value == _G.CAPTAIN_NAME then
            boat = v
        end
    end
    task.wait(1)
until boat and boat:FindFirstChild("Seat")

-- 🪑 NGỒI VÀO THUYỀN
plr.Character:WaitForChild("Humanoid"):Sit()
HRP.CFrame = boat.Seat.CFrame + Vector3.new(0, 5, 0)

-- ⏳ ĐỢI ĐỦ 5 NGƯỜI TRÊN THUYỀN
local function countPlayersOnBoat()
    local count = 0
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local seat = p.Character.Humanoid.SeatPart
            if seat and seat:IsDescendantOf(boat) then
                count += 1
            end
        end
    end
    return count
end
if isCaptain then
    repeat task.wait(1) until countPlayersOnBoat() >= 5
    boat:PivotTo(CFrame.new(55000, 10, -18000)) -- Ra biển zone 6
end

-- 🔁 VÒNG LẶP SĂN BOSS
while task.wait(1) do
    heart = ws:FindFirstChild("LeviathanHeart")
    local boss = ws:FindFirstChild("Leviathan")

    -- 🧊 CHECK IDK
    if hasIDK() then
        rs.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("idk leviathan", "All")
        local mob = findSeaEventMob()
        if mob then
            HRP.CFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
        end
        continue
    end

    -- ❤️ HỒI MÁU NẾU HP < 4000
    if plr.Character.Humanoid.Health < 4000 then
        HRP.CFrame = HRP.CFrame + Vector3.new(0, 100, 0)
        repeat task.wait(1) until plr.Character.Humanoid.Health >= 4000
    end

    -- 💧 KHÔNG RƠI XUỐNG NƯỚC
    if HRP.Position.Y < 2 then
        HRP.CFrame = HRP.CFrame + Vector3.new(0, 100, 0)
    end

    -- ⚔️ ĐÁNH BOSS
    if boss and boss:FindFirstChild("HumanoidRootPart") then
        HRP.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
    end

    -- 🎯 BẮN TIM (CAPTAIN)
    if isCaptain and heart then
        local gun = boat:FindFirstChild("GunSeat", true)
        if gun then
            HRP.CFrame = gun.CFrame + Vector3.new(0, 5, 0)
            task.wait(1)
            gun:Sit(plr.Character.Humanoid)
            task.wait(0.5)
            local vim = game:GetService("VirtualInputManager")
            for i = 1, 3 do
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.2)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(0.2)
            end
            task.wait(1)
            HRP.CFrame = boat.Seat.CFrame + Vector3.new(0, 5, 0)
            gun:Sit(nil)
        end
        boat:PivotTo(tiki)
    end

    -- 🛡 MEMBER BẢO VỆ THUYỀN
    if not isCaptain and heart then
        local enemy = findSeaEventMob()
        if enemy then
            HRP.CFrame = enemy.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
        else
            HRP.CFrame = boat.PrimaryPart.CFrame + Vector3.new(math.random(-30,30), 10, math.random(-30,30))
        end
    end
end