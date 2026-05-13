    launchBtn.MouseButton1Click:Connect(function() StartScript() end)
    stopBtn.MouseButton1Click:Connect(function() StopScript() end)
end
-- â”€â”€ LOGS PANEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
do
    local lp = Frame(LogPanel, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.Panel, 12); Stroke(lp, C.Border, 1)
    local lScroll = Instance.new("ScrollingFrame"); lScroll.Size = UDim2.new(1, -24, 1, -24); lScroll.Position = UDim2.new(0, 12, 0, 12); lScroll.BackgroundTransparency = 1; lScroll.BorderSizePixel = 0; lScroll.ScrollBarThickness = 3; lScroll.ScrollBarImageColor3 = C.Accent; lScroll.CanvasSize = UDim2.new(0, 0, 0, 0); lScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; lScroll.Parent = lp
    local lLayout = Instance.new("UIListLayout"); lLayout.Padding = UDim.new(0, 8); lLayout.Parent = lScroll
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  RUNTIME LOGIC
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local IsRunning = false
local SellerRunning, SniperRunning = false, false
local SellerThread, SniperThread
local function RunSeller()
    SellerRunning = true
    AddLog("Booth seller loop started.", C.Accent)
    while SellerRunning and IsRunning do
        -- Claim booth
        local function Claim()
            if ClaimedBooths[LocalPlayer] then return true end
            for id, b in pairs(BoothsInteractive) do
                if not ClaimedBooths[id] then
                    if Library.Network.Invoke("Booths_ClaimBooth", id) then return true end
                end
            end
            return false
        end
        if Claim() then
            -- List items
            for _, item in pairs(Cfg.SellerItems or {}) do
                local uid, data = FindItem(item)
                if uid then
                    Library.Network.Invoke("Booths_AddListing", uid, item.Price, item.Amount or data.Amount)
                    local priceText = type(item.Price) == "number" and AddSuffix(item.Price) or tostring(item.Price)
                    AddLog("Listed " .. item.Name .. " for " .. priceText, C.Green)
                end
            end
        end
        task.wait(60)
    end
end
local function RunSniper()
    SniperRunning = true
    AddLog("Sniper loop started.", C.Yellow)
    while SniperRunning and IsRunning do
        -- Scan booths
        for _, users in pairs(Booths) do
            for user, booth in pairs(users) do
                if booth.Listings then
                    for uid, info in pairs(booth.Listings) do
                        for _, target in pairs(Cfg.SniperItems or {}) do
                            local priceVal = type(target.Price)=="string" and RemoveSuffix(target.Price) or target.Price
                            if info.Item._data.id == target.Name and info.DiamondCost <= priceVal then
                                Library.Network.Invoke("Booths_RequestPurchase", booth.PlayerID, {[uid]=1})
                                AddLog("SNIPED " .. target.Name .. " for " .. AddSuffix(info.DiamondCost), C.Green)
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end
-- â”€â”€ AUTO-BUY ON ARRIVAL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
task.spawn(function()
    local pending = Cfg.PendingTerminalBuy
    if not pending or pending.JobID ~= game.JobId then return end
    AddLog("Terminal teleport arrival! Buying "..pending.Name, C.Yellow)
    task.wait(5)
    -- Purchase logic (same as sniper)
    Cfg.PendingTerminalBuy = nil; SaveCfg()
end)
-- â”€â”€ RUNTIME CONTROLS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function StartScript()
    if IsRunning then return end
    local mode = Cfg.Mode or "Seller"
    if (mode == "Seller" or mode == "Both") and #(Cfg.SellerItems or {}) == 0 then AddLog("Add items to Seller tab first!", C.Red); return end
    if (mode == "Sniper" or mode == "Both") and #(Cfg.SniperItems or {}) == 0 and #(Cfg.TerminalItems or {}) == 0 then AddLog("Add targets to Sniper tab first!", C.Red); return end
    IsRunning = true; AddLog("Bot started in " .. mode .. " mode.", C.Green)
    if mode == "Seller" or mode == "Both" then SellerThread = task.spawn(RunSeller) end
    if mode == "Sniper" or mode == "Both" then SniperThread = task.spawn(RunSniper) end
    if Cfg.SwitchServers then task.spawn(function() task.wait(Cfg.Delay * 60); GrabIDs(); Serverhop() end) end
end
function StopScript()
    IsRunning = false; SellerRunning = false; SniperRunning = false
    if SellerThread then task.cancel(SellerThread) end
    if SniperThread then task.cancel(SniperThread) end
    AddLog("Bot stopped by user.", C.Red)
end
-- â”€â”€ DRAG + TOGGLE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
do
    local drag, ds, sp = false, nil, nil
    Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; ds = i.Position; sp = Win.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - ds; Win.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
end
MinBtn.MouseButton1Click:Connect(function() Win.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
UserInputService.InputBegan:Connect(function(i, gpe) if not gpe and i.KeyCode == Enum.KeyCode.RightShift then Win.Visible = not Win.Visible end end)
if not table.find({PS99.Normal, PS99.Pro, PETSGO.Normal, PETSGO.Pro}, game.PlaceId) then
    AddLog("Wrong game! Join Trading Plaza.", C.Red)
end
print("[Plaza Plus GUI]: Premium GUI Ready! Press RightShift to toggle.")
