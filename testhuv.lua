-- ╔══════════════════════════════════════════╗
-- ║        PLAZA PLUS — GUI EDITION          ║
-- ║   Full seller + sniper with in-game UI   ║
-- ╚══════════════════════════════════════════╝

-- ══════════════════════════════════════════
--  KEY AUTHENTICATION (KeyAuth)
-- ══════════════════════════════════════════
local function VerifyKey(key)
    if not key or key == "" then
        return false, "No key provided"
    end

    local HttpService = game:GetService("HttpService")

    local KEYAUTH_NAME    = "PlazaPlus"
    local KEYAUTH_OWNERID = "Ml4HvNU82d"
    local KEYAUTH_SECRET  = "008d11bc9d49ef832360277619c494e033e77ecffb08b03d4979525597a9c15f"
    local KEYAUTH_VERSION = "1.0"

    -- Step 1: Initialize session
    local initURL = "https://keyauth.win/api/1.2/?" .. 
        "type=init" ..
        "&name=" .. KEYAUTH_NAME ..
        "&ownerid=" .. KEYAUTH_OWNERID ..
        "&ver=" .. KEYAUTH_VERSION

    local ok1, initResp = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(initURL))
    end)

    if not ok1 or type(initResp) ~= "table" then
        return false, "Could not reach auth server"
    end

    if not initResp.sessionid then
        local msg = initResp.message or "Session init failed"
        warn("[Plaza Plus KeyAuth]: Init response: " .. game:HttpGet(initURL))
        return false, msg
    end

    local sessionID = initResp.sessionid

    -- Step 2: Verify license
    local licURL = "https://keyauth.win/api/1.2/?" ..
        "type=license" ..
        "&name=" .. KEYAUTH_NAME ..
        "&ownerid=" .. KEYAUTH_OWNERID ..
        "&key=" .. HttpService:UrlEncode(key) ..
        "&sessionid=" .. sessionID

    local ok2, licResp = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(licURL))
    end)

    if not ok2 or type(licResp) ~= "table" then
        return false, "License check failed"
    end

    if licResp.success == true then
        return true, licResp.message or "Authenticated"
    else
        return false, licResp.message or "Invalid key"
    end
end

-- Read key from getgenv
local script_key = getgenv().script_key or ""
if script_key == "" then
    -- No key set — show key input GUI then halt
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local LP = Players.LocalPlayer

    if CoreGui:FindFirstChild("PlazaPlusKeyGUI") then
        CoreGui:FindFirstChild("PlazaPlusKeyGUI"):Destroy()
    end

    local KeyGui = Instance.new("ScreenGui"); KeyGui.Name="PlazaPlusKeyGUI"; KeyGui.ResetOnSpawn=false; KeyGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; KeyGui.Parent=CoreGui
    local Bg = Instance.new("Frame"); Bg.Size=UDim2.new(1,0,1,0); Bg.BackgroundColor3=Color3.fromRGB(0,0,0); Bg.BackgroundTransparency=0.4; Bg.BorderSizePixel=0; Bg.Parent=KeyGui
    local Box = Instance.new("Frame"); Box.Size=UDim2.new(0,420,0,220); Box.Position=UDim2.new(0.5,-210,0.5,-110); Box.BackgroundColor3=Color3.fromRGB(10,10,16); Box.BorderSizePixel=0; Box.Parent=KeyGui
    local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,14); bc.Parent=Box
    local bs=Instance.new("UIStroke"); bs.Color=Color3.fromRGB(99,102,241); bs.Thickness=1; bs.Parent=Box

    local tl=Instance.new("TextLabel"); tl.Text="PLAZA PLUS"; tl.TextSize=18; tl.Font=Enum.Font.GothamBold; tl.TextColor3=Color3.fromRGB(235,235,250); tl.BackgroundTransparency=1; tl.Position=UDim2.new(0,0,0,18); tl.Size=UDim2.new(1,0,0,28); tl.TextXAlignment=Enum.TextXAlignment.Center; tl.Parent=Box
    local sl=Instance.new("TextLabel"); sl.Text="Enter your license key to continue"; sl.TextSize=12; sl.Font=Enum.Font.Gotham; sl.TextColor3=Color3.fromRGB(130,130,165); sl.BackgroundTransparency=1; sl.Position=UDim2.new(0,0,0,48); sl.Size=UDim2.new(1,0,0,18); sl.TextXAlignment=Enum.TextXAlignment.Center; sl.Parent=Box

    local keyBox=Instance.new("TextBox"); keyBox.Size=UDim2.new(1,-40,0,36); keyBox.Position=UDim2.new(0,20,0,82); keyBox.BackgroundColor3=Color3.fromRGB(18,18,28); keyBox.TextColor3=Color3.fromRGB(235,235,250); keyBox.PlaceholderColor3=Color3.fromRGB(80,80,110); keyBox.PlaceholderText="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"; keyBox.Text=""; keyBox.TextSize=12; keyBox.Font=Enum.Font.Gotham; keyBox.BorderSizePixel=0; keyBox.ClearTextOnFocus=false; keyBox.Parent=Box
    local kc=Instance.new("UICorner"); kc.CornerRadius=UDim.new(0,8); kc.Parent=keyBox
    local ks=Instance.new("UIStroke"); ks.Color=Color3.fromRGB(50,50,75); ks.Thickness=1; ks.Parent=keyBox
    keyBox.Focused:Connect(function() TweenService:Create(ks,TweenInfo.new(0.15),{Color=Color3.fromRGB(99,102,241)}):Play() end)
    keyBox.FocusLost:Connect(function() TweenService:Create(ks,TweenInfo.new(0.15),{Color=Color3.fromRGB(50,50,75)}):Play() end)

    local authBtn=Instance.new("TextButton"); authBtn.Size=UDim2.new(1,-40,0,36); authBtn.Position=UDim2.new(0,20,0,132); authBtn.BackgroundColor3=Color3.fromRGB(99,102,241); authBtn.TextColor3=Color3.fromRGB(255,255,255); authBtn.Text="Authenticate"; authBtn.TextSize=13; authBtn.Font=Enum.Font.GothamBold; authBtn.BorderSizePixel=0; authBtn.AutoButtonColor=false; authBtn.Parent=Box
    local ac=Instance.new("UICorner"); ac.CornerRadius=UDim.new(0,8); ac.Parent=authBtn

    local statusL=Instance.new("TextLabel"); statusL.Text=""; statusL.TextSize=11; statusL.Font=Enum.Font.Gotham; statusL.TextColor3=Color3.fromRGB(239,68,68); statusL.BackgroundTransparency=1; statusL.Position=UDim2.new(0,20,0,178); statusL.Size=UDim2.new(1,-40,0,18); statusL.TextXAlignment=Enum.TextXAlignment.Center; statusL.Parent=Box

    local function TryAuth()
        local key = keyBox.Text:match("^%s*(.-)%s*$")
        if key == "" then statusL.TextColor3=Color3.fromRGB(239,68,68); statusL.Text="Please enter your key"; return end
        authBtn.Text="Verifying..."; authBtn.BackgroundColor3=Color3.fromRGB(60,63,160)
        statusL.Text=""
        task.spawn(function()
            local success, msg = VerifyKey(key)
            if success then
                statusL.TextColor3=Color3.fromRGB(52,211,153); statusL.Text="✓ "..msg
                authBtn.Text="✓ Authenticated!"
                authBtn.BackgroundColor3=Color3.fromRGB(30,140,90)
                getgenv().script_key = key
                task.wait(1)
                KeyGui:Destroy()
                -- Continue loading the main script
                loadstring(game:HttpGet(getgenv()._PlazaPlusURL or ""))()
            else
                statusL.TextColor3=Color3.fromRGB(239,68,68); statusL.Text="✗ "..msg
                authBtn.Text="Authenticate"; authBtn.BackgroundColor3=Color3.fromRGB(99,102,241)
            end
        end)
    end

    authBtn.MouseButton1Click:Connect(TryAuth)
    keyBox.FocusLost:Connect(function(enter) if enter then TryAuth() end end)
    return -- stop here, key GUI handles the rest
end

-- Key is set, verify it before loading
do
    local ok, msg = VerifyKey(script_key)
    if not ok then
        -- Show error and stop
        local Players = game:GetService("Players")
        local CoreGui = game:GetService("CoreGui")
        local LP = Players.LocalPlayer
        local eg = Instance.new("ScreenGui"); eg.Name="PlazaPlusKeyError"; eg.ResetOnSpawn=false; eg.Parent=CoreGui
        local eb = Instance.new("Frame"); eb.Size=UDim2.new(0,360,0,120); eb.Position=UDim2.new(0.5,-180,0.5,-60); eb.BackgroundColor3=Color3.fromRGB(10,10,16); eb.BorderSizePixel=0; eb.Parent=eg
        Instance.new("UICorner").Parent=eb; local es=Instance.new("UIStroke"); es.Color=Color3.fromRGB(239,68,68); es.Thickness=1; es.Parent=eb
        local el=Instance.new("TextLabel"); el.Text="🔑 PLAZA PLUS — AUTH FAILED\n\n"..msg; el.TextSize=13; el.Font=Enum.Font.GothamBold; el.TextColor3=Color3.fromRGB(239,68,68); el.BackgroundTransparency=1; el.Size=UDim2.new(1,-20,1,0); el.Position=UDim2.new(0,10,0,0); el.TextXAlignment=Enum.TextXAlignment.Center; el.TextWrapped=true; el.Parent=eb
        task.delay(5, function() eg:Destroy() end)
        warn("[Plaza Plus]: Auth failed — "..msg)
        return
    end
    warn("[Plaza Plus]: ✓ Authenticated successfully")
end

local timer = tick()
if not game:IsLoaded() then game.Loaded:Wait() end

local PS99  = {Pro = 15588442388,    Normal = 15502339080}
local PETSGO = {Pro = 133783083257328, Normal = 19006211286}

local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService     = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
repeat task.wait()
    LocalPlayer = Players.LocalPlayer
until LocalPlayer and LocalPlayer.GetAttribute and LocalPlayer:GetAttribute("__LOADED")
if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
local PlayerScripts = LocalPlayer.PlayerScripts.Scripts

-- ══════════════════════════════════════════
--  GAME LIBRARIES
-- ══════════════════════════════════════════
local NLibrary      = ReplicatedStorage.Library
local PlayerSave    = require(NLibrary.Client.Save)
local TradingPlazaCmds = require(NLibrary.Client.TradingPlazaCmds)
local Mailbox       = require(NLibrary.Types.Mailbox)
local Rarities      = table.clone(require(NLibrary.Directory.Rarity))

local CanUsePro = false
local Constants, UpgradeCmds, Variables

if table.find({PS99.Normal, PS99.Pro}, game.PlaceId) then
    if #TradingPlazaCmds.GetAvailable() > 1 then CanUsePro = true end
    Constants = require(NLibrary.Balancing.Constants)
end
if table.find({PETSGO.Normal, PETSGO.Pro}, game.PlaceId) then
    UpgradeCmds = require(NLibrary.Client.UpgradeCmds)
    Variables   = require(NLibrary.Shared.Variables)
end

if not getgenv().Library then
    getgenv().Library = {}
    local function LoadModules(Path, T)
        for _,v in next, Path:GetChildren() do
            if v:IsA("ModuleScript") and not v:GetAttribute("NOLOAD") then
                local ok, m = pcall(require, v)
                if ok then T[v.Name] = m end
            end
        end
    end
    LoadModules(NLibrary.Client, getgenv().Library)
    LoadModules(NLibrary,        getgenv().Library)
end
local Library = getgenv().Library

local Booths, ClaimedBooths, BoothsInteractive
if table.find({PS99.Pro, PS99.Normal, PETSGO.Normal, PETSGO.Pro}, game.PlaceId) then
    local Interacts
    repeat task.wait()
        Booths = getsenv(NLibrary.Client:FindFirstChild("BoothCmds") or PlayerScripts.Game["Trading Plaza"]["Booths Frontend"]).getState
    until Booths
    Booths = getupvalues(Booths)
    repeat task.wait()
        Interacts = getsenv(NLibrary.Client:FindFirstChild("BoothCmds") or PlayerScripts.Game["Trading Plaza"]["Booths Frontend"]).updateAllInteracts
    until Interacts
    ClaimedBooths    = getupvalues(Interacts)[1]
    BoothsInteractive = getupvalues(Interacts)[3]
end

-- Disable idle / server-closing scripts
pcall(function() PlayerScripts.Core["Server Closing"].Enabled = false end)
pcall(function() PlayerScripts.Core["Idle Tracking"].Enabled  = false end)
pcall(function() Library.Network.Fire("Idle Tracking: Stop Timer") end)
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),   workspace.CurrentCamera.CFrame)
end)

-- ══════════════════════════════════════════
--  FILE PERSISTENCE
-- ══════════════════════════════════════════
local FolderPath = "System Exodus/" .. (table.find({PETSGO.Normal,PETSGO.Pro},game.PlaceId) and "PETS GO" or "Pet Simulator 99")
local FileName   = FolderPath .. "/" .. LocalPlayer.Name .. " PlazaPlus.cfg"
if not isfolder("System Exodus") then makefolder("System Exodus") end
if not isfolder(FolderPath)      then makefolder(FolderPath) end

local DefaultCfg = {
    SellerItems  = {},
    SniperItems  = {},
    TerminalItems = {},
    WebhookURL   = "",
    SwitchServers = false,
    Delay        = 20,
    Mode         = "Seller",  -- default to Seller
    OnlyPro      = false,
}
local Cfg = {}
pcall(function()
    if isfile(FileName) then
        local d = HttpService:JSONDecode(readfile(FileName))
        if type(d) == "table" then for k,v in pairs(d) do DefaultCfg[k] = v end end
    end
end)
for k,v in pairs(DefaultCfg) do Cfg[k] = v end

local function SaveCfg()
    pcall(function() writefile(FileName, HttpService:JSONEncode(Cfg)) end)
end

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local SuffLo = {"k","m","b","t"}
local SuffUp = {"K","M","B","T"}
local function AddSuffix(n)
    if not n or type(n)~="number" then return "?" end
    if n==0 then return "0" end
    local neg = n<0; n=math.abs(n)
    local a = math.floor(math.log(n,1e3))
    local b = math.pow(10,a*3)
    return (neg and "-" or "")..("%.2f"):format(n/b):gsub("%.?0+$","")..(SuffLo[a] or "")
end
local function RemoveSuffix(s)
    if type(s)=="number" then return s end
    local n,suf = s:gsub("%a",""), s:match("%a")
    local t = table.find(SuffUp,suf) or table.find(SuffLo,suf) or 0
    return tonumber(n)*math.pow(10,t*3)
end
local function AddCommas(s)
    local r=s; local b
    repeat r,b=r:gsub("^(-?%d+)(%d%d%d)","%1,%2") until b==0; return r
end

local RN={I=1,V=5,X=10,L=50,C=100,D=500,M=1000}
local function ToRoman(n)
    local r,sorted="",{}
    for k,v in pairs(RN) do table.insert(sorted,{v,k}) end
    table.sort(sorted,function(a,b) return a[1]>b[1] end)
    for _,v in ipairs(sorted) do while n>=v[1] do r=r..v[2]; n=n-v[1] end end
    return r
end
local function FromRoman(s)
    local t,ov=0,0
    for i=#s,1,-1 do local cv=RN[s:sub(i,i)]; if cv<ov then t=t-cv else t=t+cv end; ov=cv end
    return t
end

-- ══════════════════════════════════════════
--  ITEM LIST BUILD
-- ══════════════════════════════════════════
local ItemList = {}
do
    local TempClasses = require(NLibrary.Items.Types).Types
    local Classes, DirClasses = {}, {}
    for Name in next, TempClasses do Classes[Name] = {} end
    Classes.Currency, Classes.Page = nil, nil
    for Name in next, Classes do
        ItemList[Name] = {}
        local found = false
        for _,C in next, NLibrary.Directory:GetChildren() do
            if tostring(C):find(Name) then found=true end
        end
        if not found then Classes[Name]=nil; continue end
        if Name=="Misc" or Name=="Card" then DirClasses[Name]=Name.."Items"
        elseif Name=="Lootbox" or Name=="Box" then DirClasses[Name]=Name.."es"
        else DirClasses[Name]=Name.."s" end
    end
    for Class in next, Classes do
        pcall(function()
            for Item, Info in next, require(NLibrary.Directory[DirClasses[Class]]) do
                if Info.DisplayName and type(Info.DisplayName)=="function" then
                    for i=Info.BaseTier,Info.MaxTier do
                        ItemList[Class][Info.DisplayName(i)] = {ID=Item,Display=Info.DisplayName(i),Power=Info.Power(i),Rarity=Info.Rarity(i),Tier=i,Icon=type(Info.Icon)=="function" and Info.Icon(i) or Info.Icon}
                    end
                elseif Info.Tiers then
                    for i=1,#Info.Tiers do
                        local Disp,Icon,Rar,Pow
                        if Info.Tiers[i].Effect and Info.Tiers[i].Effect.Type.Tiers[i] then
                            local T=Info.Tiers[i].Effect.Type.Tiers[i]
                            Disp=T.Name or (Info.DisplayName or Info.name or Info.Name or "")
                            Icon,Rar,Pow=T.Icon,T.Rarity,T.Power
                        else
                            Disp=Info.DisplayName or Info.name or Info.Name or ""
                            if type(Disp)=="function" then Disp=Disp(i) end
                        end
                        if Disp and #Info.Tiers>1 and not tostring(Disp):find("%d") then Disp=Disp.." "..ToRoman(i) end
                        if Disp then
                            ItemList[Class][tostring(Disp)]={ID=Item,Display=Disp,Tier=i,Icon=Info.Tiers[i].Icon or Icon,Power=Info.Tiers[i].Power or Pow,Rarity=Info.Tiers[i].Rarity or Rar}
                        end
                    end
                else
                    if Info.instant_purchase then return end
                    local DN=Info.DisplayName or Info.name or Info.Name
                    if type(DN)=="function" then DN=DN(1) end
                    if DN then ItemList[Class][DN]={ID=Item,Display=DN,Tier=Info.Tier,Icon=Info.Icon or Info.thumbnail,Power=Info.Power,Rarity=Info.Rarity} end
                end
            end
        end)
    end
end

-- ══════════════════════════════════════════
--  CORE LOGIC FUNCTIONS
-- ══════════════════════════════════════════
local function CalcPercent(rap,cost)
    local w=((cost-rap)/rap)*100
    w=math.floor(w*2+0.5)/2
    return w<0 and math.abs(w) or w*-1
end
local function GetDiamonds(retUID)
    for i,v in next, PlayerSave.Get()["Inventory"].Currency do
        if v.id=="Diamonds" then return retUID and i or (v._am or 0) end
    end
    return 0
end

local function GenerateFindInfo(Name, Data)
    local F={}
    F.ID=Name; F.AllTypes=Data and Data.AllTypes or nil; F.AllTiers=Data and Data.AllTiers or nil
    if not Name:find("Board") and not Name:find("Gem") then
        local rp,hp=Name:find("Rainbow"),Name:find("Huge")
        F.Rainbow=(rp and (not hp or rp<hp)) and true
        F.Golden=Name:find("Golden") and true
        F.Shiny=Name:find("Shiny") and true
        Name=F.ID:gsub((F.Rainbow and "Rainbow " or F.Golden and "Golden ") or "",""):gsub(F.Shiny and "Shiny " or "","")
    end
    if Name:find("RAP Above") or Name:find("Difficulty Above") then return F end
    if Data and Data.Class then F.Class=Data.Class end

    -- Extract tier number (supports both "Hype Egg 3" and "Hype Egg III")
    local Main, NumTier = Name:match("(.+)%s+(%d+)%s*$")
    local RomanName = nil
    if NumTier then
        F.Tier = tonumber(NumTier)
        RomanName = Main .. " " .. ToRoman(F.Tier)
        -- Try original name with number first, then Roman version
    elseif Name:find("(%u+)%s*$") then
        local roman = Name:match("(%u+)%s*$")
        local conv = FromRoman(roman)
        if conv and conv > 0 and conv < 200 then
            F.Tier = conv
        end
    end

    F.Display = Name
    -- Search ItemList trying both the original name AND Roman numeral version
    local namesToTry = {Name, RomanName}
    for _, tryName in ipairs(namesToTry) do
        if not tryName then continue end
        for Class, List in next, ItemList do
            if ItemList[Class][tryName] then
                local D = ItemList[Class][tryName]
                F.Class = F.Class or Class
                F.ID    = D.ID
                F.Icon  = D.Icon
                F.Display = tryName
                if Class~="Pet" and Class~="Hoverboard" and Class~="Card" and Class~="Fruit" then
                    F.Rainbow, F.Golden, F.Shiny = nil, nil, nil
                    if D.Tier and not F.Tier then F.Tier = D.Tier end
                end
                return F -- found, return immediately
            end
        end
    end
    return F
end

local function ValidateItem(Item, Want)
    if Want.ID:find("All Huges") then if not Item.IsHuge then return false end
    elseif Want.ID:find("All Titanics") then if not Item.IsTitanic then return false end
    elseif Want.ID:find("All Exclusives") then if (not Item.IsExclusive or Item.IsHuge or Item.IsTitanic) or Item.Class~="Pet" then return false end
    end
    if Want.ID:find("All Rarity") then
        if not Item.Rarity or Item.Rarity:gsub(" ","")~=Want.ID:split(":")[2]:gsub(" ","") or Item.IsHuge or Item.IsTitanic or Item.Class~="Pet" then return false end
    elseif Want.ID:find("All Class") then
        if not Item.Class or Item.Class~=Want.ID:split(":")[2]:gsub(" ","") then return false end
    elseif Want.ID:find("RAP Above") then
        if not Item.RAP or tonumber(Item.RAP)<tonumber(RemoveSuffix(Want.ID:split(":")[2]:gsub(" ",""))) then return false end
    elseif Want.ID:find("Difficulty Above") then
        if not Item.Difficulty or tonumber(Item.Difficulty)<tonumber(RemoveSuffix(Want.ID:split(":")[2]:gsub(" ",""))) then return false end
    elseif Want.ID:find("Name Find") then
        if not Item.ID:find(Want.ID:split(": ")[2]) then return false end
    elseif Want.ID~=Item.ID and not Want.ID:find("All ") then return false end
    if Want.Class~=nil and Want.Class~=Item.Class then return false end
    if not Want.AllTypes then
        if (Want.Shiny and not Item.Shiny) or (not Want.Shiny and Item.Shiny) then return false end
        if (Want.Rainbow and not Item.Rainbow) or (Item.Rainbow and not Want.Rainbow) then return false end
        if (Want.Golden and not Item.Golden) or (Item.Golden and not Want.Golden) then return false end
    end
    if not Want.AllTiers and Want.Tier and Item.Tier then
        if tonumber(Want.Tier)~=tonumber(Item.Tier) then return false end
    end
    return true
end

local function FindItemsInBooth(Name,Class)
    local ic,bc=0,0
    for _,Users in next, Booths do
        for Username,Booth in next, Users do
            for BI,IV in next, Booth do
                if BI=="Listings" and tostring(Username):find(LocalPlayer.Name) then
                    for _ in next, IV do bc=bc+1 end
                    if Name and Class then
                        for _,PI in next, IV do
                            local PD=PI.Item._data
                            if PD["id"]==Name and PI.Item.Class.Name==Class then
                                ic=ic+(PD["_am"] or 1)
                            end
                        end
                    end
                    return bc,ic
                end
            end
        end
    end
    return nil
end

local LastUIDs={}
local BlacklistedUIDs={}
local function FindItem(Data, ReturnAmount)
    local Count=0
    local Invs={}
    if Data.ID:find("All Huges") or Data.ID:find("All Titanics") then
        table.insert(Invs, Library.InventoryCmds.State().container._store._byType["Pet"])
    elseif Data.Class then
        table.insert(Invs, Library.InventoryCmds.State().container._store._byType[Data.Class])
    else
        for cls in pairs(Library.InventoryCmds.State().container._store._byType) do
            table.insert(Invs, Library.InventoryCmds.State().container._store._byType[cls])
        end
    end
    for _,Inv in pairs(Invs) do
        if not Inv or not Inv._byUID then continue end
        for UID,IT in pairs(Inv._byUID) do
            if not ReturnAmount then
                if table.find(LastUIDs,UID) then
                    local _,ic=FindItemsInBooth(IT.GetId and IT:GetId(), IT.GetClass and IT:GetClass() or (IT.Class and IT.Class.Name) or Data.Class or "Pet")
                    if ic and ic>=1 then continue else table.remove(LastUIDs,table.find(LastUIDs,UID)) end
                    task.wait(0.1)
                end
            end
            local II={
                UID=UID, ID=IT.GetId and IT:GetId() or nil,
                Class=IT.GetClass and IT:GetClass() or (IT.Class and IT.Class.Name) or Data.Class or "Pet",
                Rainbow=IT.IsRainbow and IT:IsRainbow() or false,
                Golden=IT.IsGolden and IT:IsGolden() or false,
                Shiny=IT.IsShiny and IT:IsShiny() or false,
                IsHuge=IT.IsHuge and IT:IsHuge() or false,
                IsTitanic=IT.IsTitanic and IT:IsTitanic() or false,
                IsExclusive=IT.GetRarity and IT:GetRarity()._id=="Exclusive" or false,
                NotTradeable=(IT.AbstractIsTradable and IT:AbstractIsTradable()==false),
                IsLocked=IT._data["_lk"],
                Amount=IT._data["_am"] or 1,
                Tier=IT._data["tn"],
                Color=IT.GetColorVariant and IT:GetColorVariant() or nil,
                Difficulty=IT.GetDifficulty and IT:GetDifficulty(),
                Rarity=IT.GetRarity and IT:GetRarity()._id,
                Display="",
            }
            if II.Shiny then II.Display="Shiny" end
            if II.Rainbow then II.Display=(II.Display~="" and II.Display.." " or "").."Rainbow" end
            if II.Golden  then II.Display=(II.Display~="" and II.Display.." " or "").."Golden"  end
            II.Display=(II.Display~="" and II.Display.." " or "")..II.ID
            if II.IsLocked or II.NotTradeable or BlacklistedUIDs[UID] or not UID then continue end
            if ReturnAmount then
                if ValidateItem(II,Data) then Count=II.Amount+Count end
            elseif ValidateItem(II,Data) then
                table.insert(LastUIDs,UID); return UID,II
            end
        end
    end
    return ReturnAmount and Count or nil
end

-- ══════════════════════════════════════════
--  SERVER HOP
-- ══════════════════════════════════════════
local StartingTime=os.time()
local IDs={}

local function DisableAntiScam()
    pcall(function()
        for _,v in next, PlayerScripts.Core:GetChildren() do
            if v.Name=="Server Closing" or v.Name=="Anti Scam" then v.Enabled=false end
        end
    end)
end

local function GrabIDs()
    local PlaceId
    if Cfg.OnlyPro and CanUsePro then
        PlaceId = table.find({PETSGO.Pro,PETSGO.Normal},game.PlaceId) and PETSGO.Pro or PS99.Pro
    else
        PlaceId = table.find({PETSGO.Pro,PETSGO.Normal},game.PlaceId) and (CanUsePro and PETSGO[math.random(1,2)] or PETSGO.Normal) or (CanUsePro and PS99[math.random(1,2)] or PS99.Normal)
    end
    local Url=string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100",PlaceId)
    local ok,resp=pcall(function() return HttpService:JSONDecode(game:HttpGet(Url)) end)
    if not ok or not resp then task.wait(5); return GrabIDs() end
    if resp.data then
        for _,S in next, resp.data do
            if S.maxPlayers>S.playing and S.id~=game.JobId and S.playing>=5 then
                table.insert(IDs,{PlaceID=PlaceId,JobID=S.id})
            end
        end
    elseif resp.errors and resp.errors[1] and resp.errors[1].message=="Too many requests" then
        task.wait(15); return GrabIDs()
    end
end

local function Serverhop()
    repeat task.wait() until #IDs>=1
    while task.wait() do
        local S=IDs[Random.new():NextInteger(1,#IDs)]
        if not Cfg.LastServers then Cfg.LastServers={} end
        if table.find(Cfg.LastServers,S.JobID) then continue end
        if #Cfg.LastServers>=7 then table.remove(Cfg.LastServers,1) end
        table.insert(Cfg.LastServers,S.JobID)
        SaveCfg()
        DisableAntiScam()
        local ok,err=pcall(function() TeleportService:TeleportToPlaceInstance(S.PlaceID, S.JobID, LocalPlayer) end)
        if not ok then warn("[Plaza Plus]: Teleport failed: "..tostring(err)); task.wait(3); continue end
        task.wait(1.5)
    end
end

-- ══════════════════════════════════════════
--  WEBHOOK
-- ══════════════════════════════════════════
local function SendWebhook(payload)
    if not Cfg.WebhookURL or Cfg.WebhookURL=="" then return end
    pcall(function()
        request({
            Url=Cfg.WebhookURL, Method="POST",
            Headers={["Content-Type"]="application/json"},
            Body=HttpService:JSONEncode(payload)
        })
    end)
end

local function SniperWebhook(info, percent)
    local rarityColor = Rarities[info.Rarity] and tonumber("0x"..Rarities[info.Rarity].Color:ToHex()) or 6316273
    local profitAmt = (info.Bought * info.RAP) - (info.Bought * info.Cost)
    local perText = info.Bought > 1 and " ("..AddSuffix(info.Cost).." per)" or ""
    local description =
        "<:Box:1239350602413375591> **Received:** `"..info.Display.." x"..info.Bought.."`\n"..
        "<:Diamond:1235403834969296896> **Spent:** `"..AddSuffix(info.Bought*info.Cost)..perText.."`\n"..
        "<:Money:1295946554338705438> **RAP:** `"..AddSuffix(info.RAP).." ("..tostring(math.abs(percent)).."% below)`\n"..
        "<:Profit:1295945416273301576> **Profit:** `"..AddSuffix(profitAmt).."`\n"..
        "<:Bank:1295944894698754102> **Diamonds Left:** `"..AddSuffix(GetDiamonds()).."`"
    SendWebhook({
        username = "Plaza Plus",
        avatar_url = "https://i.gyazo.com/dbefd0df338c7ff9c08fc85ecea0df94.png",
        embeds = {{
            color = rarityColor,
            title = "||"..LocalPlayer.Name.."|| has sniped an item!",
            description = description,
            thumbnail = {url = info.Icon and ("https://biggamesapi.io/image/"..tostring(info.Icon)) or nil},
            footer = {text = "@"..LocalPlayer.Name.." · Plaza Plus", icon_url = "https://i.gyazo.com/784ff41bd2b15e0046c8b621fab31990.png"},
            timestamp = DateTime.now():ToIsoDate(),
        }}
    })
end

local function SellerWebhook(info)
    local _,ic = FindItemsInBooth(info.ID, info.Class)
    local perText = info.Amount > 1 and " ("..AddSuffix(info.Spent / info.Amount).." per)" or ""
    local description =
        "<:Box:1239350602413375591> **Sold:** `"..info.Name.." x"..info.Amount.."`\n"..
        "<:Diamond:1235403834969296896> **Gained:** `"..AddSuffix(info.Spent)..perText.."`\n"..
        "<:Booth:1239350605294604378> **Booth Count:** `"..(ic and tostring(ic) or "?").."`\n"..
        "<:Bank:1295944894698754102> **Current Diamonds:** `"..AddSuffix(GetDiamonds()).."`"
    SendWebhook({
        username = "Plaza Plus",
        avatar_url = "https://i.gyazo.com/dbefd0df338c7ff9c08fc85ecea0df94.png",
        embeds = {{
            color = 1150279, -- green teal matching screenshot
            title = "||"..LocalPlayer.Name.."|| has sold an item!",
            description = description,
            thumbnail = {url = info.Icon and ("https://biggamesapi.io/image/"..tostring(info.Icon)) or nil},
            footer = {text = "@"..LocalPlayer.Name.." · Plaza Plus", icon_url = "https://i.gyazo.com/784ff41bd2b15e0046c8b621fab31990.png"},
            timestamp = DateTime.now():ToIsoDate(),
        }}
    })
end

-- ══════════════════════════════════════════
--  MAILBOX LOOP
-- ══════════════════════════════════════════
task.spawn(function()
    while task.wait(30) do
        pcall(function() Library.Network.Invoke("Mailbox: Claim All") end)
    end
end)

        end
        local priceVal = tonumber(price) or price
        local limit = sLimitIn.Text ~= "" and tonumber(sLimitIn.Text) or nil
        local allTypes = getAllTypes()
        local detect = getDetect()
        local item = { Name = name, Price = priceVal, InventoryLimit = limit, AllTypes = allTypes, DetectManipulation = detect }
        SniperItemData[name] = item
        local ext = (limit and "limit:" .. limit or "") .. (allTypes and " all-types" or "") .. (detect and " anti-manip" or "")
        ItemCard(bScroll, name, priceVal, ext, function()
            SniperItemData[name] = nil
            local t = {}
            for _, v in pairs(SniperItemData) do table.insert(t, v) end
            Cfg.SniperItems = t
            SaveCfg()
        end)
        sNameIn.Text = ""
        sPriceIn.Text = ""
        sLimitIn.Text = ""
        setAllTypes(false)
        setDetect(false)
        sStatusL.TextColor3 = IsRunning and C.Yellow or C.Green
        sStatusL.Text = IsRunning and "Added live" or "Added"
        task.delay(2, function() sStatusL.Text = "" end)
        local t = {}
        for _, v in pairs(SniperItemData) do table.insert(t, v) end
        Cfg.SniperItems = t
        SaveCfg()
    end)

    local function TLabel(p, txt, y)
        local f = Frame(p, UDim2.new(1, -16, 0, 13), UDim2.new(0, 8, 0, y), C.Panel, 0)
        f.BackgroundTransparency = 1
        Label(f, txt, 10, C.Sub, Enum.Font.Gotham)
        return f
    end

    local infoBox = Frame(termForm, UDim2.new(1, -16, 0, 36), UDim2.new(0, 8, 0, 4), Color3.fromRGB(17, 28, 24), 8)
    Stroke(infoBox, C.Green, 1)
    local infoL = Label(infoBox, "Terminal searches all servers for cheapest listings", 10, C.Green, Enum.Font.Gotham)
    infoL.Position = UDim2.new(0, 8, 0, 0)
    infoL.Size = UDim2.new(1, -16, 1, 0)

    TLabel(termForm, "Item Name", 46)
    local tNameIn = Input(termForm, "e.g. Huge Night Terror Cat", UDim2.new(1, -16, 0, 26), UDim2.new(0, 8, 0, 61))
    TLabel(termForm, "Max Price", 93)
    local tPriceIn = Input(termForm, "e.g. 15m or 50%", UDim2.new(1, -16, 0, 26), UDim2.new(0, 8, 0, 108))
    TLabel(termForm, "Class", 140)
    local tClassIn = Input(termForm, "e.g. Pet or Lootbox", UDim2.new(1, -16, 0, 26), UDim2.new(0, 8, 0, 155))
    TLabel(termForm, "Inventory Limit", 187)
    local tLimitIn = Input(termForm, "e.g. 50", UDim2.new(1, -16, 0, 26), UDim2.new(0, 8, 0, 202))
    local cvRow = Frame(termForm, UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 187), C.Panel, 0)
    cvRow.BackgroundTransparency = 1
    Label(cvRow, "Use Cosmic Values", 11, C.Text, Enum.Font.Gotham)
    local _, getCosmicVal, _, setCosmicVal = Toggle(cvRow, UDim2.new(1, -46, 0.5, -11), false)
    local tAddBtn = Btn(termForm, "+ Add Terminal Target", UDim2.new(1, -16, 0, 28), UDim2.new(0, 8, 0, 218), C.Yellow, Color3.fromRGB(30, 20, 5))
    tAddBtn.TextSize = 11
    tAddBtn.TextColor3 = Color3.fromRGB(40, 28, 5)
    local tStatusL = Label(termForm, "", 10, C.Green, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    tStatusL.Size = UDim2.new(1, -16, 0, 16)
    tStatusL.Position = UDim2.new(0, 8, 0, 252)

    tAddBtn.MouseButton1Click:Connect(function()
        local name = tNameIn.Text:match("^%s*(.-)%s*$")
        local price = tPriceIn.Text:match("^%s*(.-)%s*$")
        if name == "" or price == "" then
            tStatusL.TextColor3 = C.Red
            tStatusL.Text = "Name and price required"
            task.delay(2, function() tStatusL.Text = "" end)
            return
        end
        if TerminalItemData[name] then
            tStatusL.TextColor3 = C.Red
            tStatusL.Text = "Already in list"
            task.delay(2, function() tStatusL.Text = "" end)
            return
        end
        local priceVal = tonumber(price) or price
        local limit = tLimitIn.Text ~= "" and tonumber(tLimitIn.Text) or nil
        local cls = tClassIn.Text ~= "" and tClassIn.Text or nil
        local cosmic = getCosmicVal()
        local item = { Name = name, Price = priceVal, InventoryLimit = limit, Class = cls, UseCosmicValues = cosmic }
        TerminalItemData[name] = item
        local ext = (cls and cls .. " - " or "") .. (limit and "limit:" .. limit or "") .. (cosmic and " cosmic" or "")
        ItemCard(tScroll, name, priceVal, ext, function()
            TerminalItemData[name] = nil
            local t = {}
            for _, v in pairs(TerminalItemData) do table.insert(t, v) end
            Cfg.TerminalItems = t
            SaveCfg()
        end)
        tNameIn.Text = ""
        tPriceIn.Text = ""
        tLimitIn.Text = ""
        tClassIn.Text = ""
        setCosmicVal(false)
        tStatusL.TextColor3 = IsRunning and C.Yellow or C.Green
        tStatusL.Text = IsRunning and "Added live - searching now" or "Added"
        task.delay(2, function() tStatusL.Text = "" end)
        local t = {}
        for _, v in pairs(TerminalItemData) do table.insert(t, v) end
        Cfg.TerminalItems = t
        SaveCfg()
    end)
end

-- Settings panel
do
    local sf = Frame(CfgPanel, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.Panel, 10)
    local function Row(label, y)
        local r = Frame(sf, UDim2.new(1, -16, 0, 38), UDim2.new(0, 8, 0, y), C.Card, 8)
        Stroke(r, C.Border, 1)
        local l = Label(r, label, 12, C.Text, Enum.Font.GothamBold)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.Size = UDim2.new(0.55, 0, 1, 0)
        return r
    end

    local sl = Label(sf, "GENERAL", 10, C.Sub, Enum.Font.GothamBold)
    sl.Position = UDim2.new(0, 8, 0, 8)
    sl.Size = UDim2.new(1, 0, 0, 16)

    local modeRow = Row("Mode  (what to run)", 28)
    local modeOptions = { "Seller", "Sniper", "Both" }
    local modeIdx = 1
    for i, v in ipairs(modeOptions) do if v == Cfg.Mode then modeIdx = i end end
    local modeLabel = Label(modeRow, modeOptions[modeIdx], 12, C.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    modeLabel.Size = UDim2.new(0, 90, 0, 26)
    modeLabel.Position = UDim2.new(1, -100, 0.5, -13)
    modeLabel.BackgroundTransparency = 0
    modeLabel.BackgroundColor3 = C.Accent
    Corner(modeLabel, 6)
    local mBtn2 = Instance.new("TextButton")
    mBtn2.Size = UDim2.new(1, 0, 1, 0)
    mBtn2.BackgroundTransparency = 1
    mBtn2.Text = ""
    mBtn2.Parent = modeLabel
    mBtn2.MouseButton1Click:Connect(function()
        modeIdx = modeIdx % #modeOptions + 1
        modeLabel.Text = modeOptions[modeIdx]
        Cfg.Mode = modeOptions[modeIdx]
        SaveCfg()
    end)

    local ssRow = Row("Switch Servers", 74)
    local _, getSS, onSS, setSS = Toggle(ssRow, UDim2.new(1, -56, 0.5, -11), Cfg.SwitchServers or false)
    setSS(Cfg.SwitchServers or false)
    onSS(function(v) Cfg.SwitchServers = v; SaveCfg() end)

    local delRow = Row("Switch Delay  (minutes)", 118)
    local delIn = Input(delRow, "20", UDim2.new(0, 80, 0, 24), UDim2.new(1, -90, 0.5, -12))
    delIn.Text = tostring(Cfg.Delay or 20)
    delIn.FocusLost:Connect(function() Cfg.Delay = tonumber(delIn.Text) or 20; SaveCfg() end)

    local proRow = Row("Only Pro Servers", 162)
    local _, getPro, onPro, setPro = Toggle(proRow, UDim2.new(1, -56, 0.5, -11), Cfg.OnlyPro or false)
    setPro(Cfg.OnlyPro or false)
    onPro(function(v) Cfg.OnlyPro = v; SaveCfg() end)

    local wl = Label(sf, "WEBHOOK", 10, C.Sub, Enum.Font.GothamBold)
    wl.Position = UDim2.new(0, 8, 0, 210)
    wl.Size = UDim2.new(1, 0, 0, 16)

    local whRow = Frame(sf, UDim2.new(1, -16, 0, 38), UDim2.new(0, 8, 0, 230), C.Card, 8)
    Stroke(whRow, C.Border, 1)
    local whLabel = Label(whRow, "Discord URL", 12, C.Text, Enum.Font.GothamBold)
    whLabel.Position = UDim2.new(0, 12, 0, 0)
    whLabel.Size = UDim2.new(0, 80, 1, 0)
    local whIn = Input(whRow, "https://discord.com/api/webhooks/...", UDim2.new(1, -105, 0, 24), UDim2.new(0, 95, 0.5, -12))
    whIn.Text = Cfg.WebhookURL or ""
    whIn.FocusLost:Connect(function() Cfg.WebhookURL = whIn.Text; SaveCfg() end)
end

local BBar = Frame(Win, UDim2.new(1, -190, 0, 48), UDim2.new(0, 190, 1, -48), C.Header, 0)
local launchBtn = Btn(BBar, ">  START", UDim2.new(0, 140, 0, 32), UDim2.new(0, 12, 0.5, -16), C.Green, Color3.fromRGB(5, 30, 18))
launchBtn.TextColor3 = Color3.fromRGB(5, 40, 22)
local stopBtn = Btn(BBar, "[] STOP", UDim2.new(0, 120, 0, 32), UDim2.new(0, 160, 0.5, -16), Color3.fromRGB(80, 20, 20), C.Red)
local botStatus = Label(BBar, "Configure items, then press START", 11, C.Sub, Enum.Font.Gotham)
botStatus.Size = UDim2.new(1, -310, 1, 0)
botStatus.Position = UDim2.new(0, 295, 0, 0)
-- ══════════════════════════════════════════
--  SELLER RUNTIME
-- ══════════════════════════════════════════
local SellerRunning=false
local SellerThread

local function RunSeller()
    SellerRunning=true
    -- Claim booth
    local function IsBoothAvailable(id)
        for _,t in pairs(ClaimedBooths) do if t.BoothID==id then return false end end; return true
    end
    local function ClaimBooth()
        local cands={}
        local minX,maxX=math.huge,-math.huge
        for _,m in pairs(BoothsInteractive) do local x=m.Pets.Position.X; if x<minX then minX=x end; if x>maxX then maxX=x end end
        local cx=(minX+maxX)/2
        for id,m in next, BoothsInteractive do
            if ClaimedBooths[LocalPlayer] then return end
            if IsBoothAvailable(id) then table.insert(cands,{id=id,m=m,y=m.Pets.Position.Y,xd=math.abs(m.Pets.Position.X-cx)}) end
        end
        table.sort(cands,function(a,b) return a.y==b.y and a.xd<b.xd or a.y<b.y end)
        for _,b in next, cands do
            local ok=Library.Network.Invoke("Booths_ClaimBooth",b.id)
            if ok then
                local Interact=b.m:WaitForChild("Interact",7)
                if Interact then Library.Network.Fire("Hoverboard_RequestUnequip"); task.wait(1); HumanoidRootPart.CFrame=Interact.CFrame*CFrame.new(0,-2,-6)*CFrame.Angles(0,math.rad(180),0) end
                return true
            end
        end
    end
    ClaimBooth()
    local timeout=os.time()
    repeat task.wait() until ClaimedBooths[LocalPlayer] or (os.time()-timeout)>20
    if not ClaimedBooths[LocalPlayer] then
        -- Try once more
        warn("[Plaza Plus]: First booth claim failed, retrying...")
        ClaimBooth()
        local timeout2=os.time()
        repeat task.wait() until ClaimedBooths[LocalPlayer] or (os.time()-timeout2)>15
    end
    if not ClaimedBooths[LocalPlayer] then
        warn("[Plaza Plus]: Could not claim booth — all booths may be taken. Waiting 10s...")
        botStatus.TextColor3=C.Red; botStatus.Text="⚠ Could not claim booth — retrying in 10s"
        task.wait(10)
        ClaimBooth()
        repeat task.wait() until ClaimedBooths[LocalPlayer] or (os.time()-timeout)>30
    end
    if not ClaimedBooths[LocalPlayer] then
        warn("[Plaza Plus]: Booth claim failed completely.")
        botStatus.TextColor3=C.Red; botStatus.Text="⚠ Booth claim failed! Try a different server."
        SellerRunning=false; IsRunning=false
        Tw(launchBtn,{BackgroundColor3=C.Green})
        return
    end
    warn("[Plaza Plus]: Booth claimed, listing items...")
    botStatus.Text="🏪 Seller running..."; botStatus.TextColor3=C.Green

    -- Sold notification
    Library.Network.Fired("Booths: Add History"):Connect(function(Info)
        local cost=0
        for _,CT in next, Info["Received"] do for _,it in CT do if (it._am or 1)>cost then cost=it._am or 1 end end end
        for Class,CT in next, Info["Given"] do
            for UID,it in CT do
                warn("[Plaza Plus]: Sold: "..it.id.." x"..(it._am or 1))
                local id=ItemList[Class]
                local ItemData=id and id[it.id]
                if not ItemData and id then for _,v in next,id do if v.ID==it.id then ItemData=v; break end end end
                if ItemData then task.wait(0.5); SellerWebhook({ID=it.id,Name=ItemData.Display,Amount=it._am or 1,Spent=cost,Class=Class,Icon=ItemData.Icon}) end
            end
        end
    end)

    -- Single flat listing function — lists ONE slot for ONE item then returns
    -- so the outer loop can immediately check for newly added items
    local function TryListItem(name, data)
        local maxSlots = PlayerSave.Get().BoothSlots or 8
        local usedSlots = FindItemsInBooth() or 0
        if usedSlots >= maxSlots then return end

        -- Build the lookup name including type prefix and tier
        local lookupName = name
        if not data.AllTypes then
            if data.Shiny   then lookupName = "Shiny "..lookupName end
            if data.Rainbow then lookupName = "Rainbow "..lookupName end
            if data.Golden  then lookupName = "Golden "..lookupName end
        end
        -- Append tier as Roman numeral if specified (e.g. "Treasure Hunter II")
        if data.Tier then
            lookupName = lookupName .. " " .. ToRoman(data.Tier)
        end
        local FindInfo = GenerateFindInfo(lookupName, data)
        local UID, ItemData = FindItem(FindInfo)
        if not UID then return end

        local Amount = ItemData.Amount or 1
        local PD = {
            IsPercentage = type(data.Price)=="string" and data.Price:find("%%"),
            AboveRAP     = type(data.Price)=="string" and data.Price:find("+"),
            NegativePrice= (type(data.Price)=="number" and data.Price<0) or (type(data.Price)=="string" and data.Price:find("^%-")),
        }
        PD.RealPrice = tonumber(type(data.Price)=="string" and (not PD.IsPercentage and RemoveSuffix(data.Price) or data.Price:gsub("%D","")) or data.Price)

        if PD.IsPercentage or PD.AboveRAP or PD.NegativePrice then
            local NI = Library.Items.Types[ItemData.Class](ItemData.ID)
            if ItemData.Golden  then NI:SetGolden() end
            if ItemData.Rainbow then NI:SetRainbow() end
            if ItemData.Shiny   then NI:SetShiny(true) end
            if ItemData.Tier    then NI:SetTier(ItemData.Tier) end
            local RAP = (table.find({PS99.Normal,PS99.Pro},game.PlaceId) and NI.GetDevRAP and NI:GetDevRAP()) or NI.GetRAP and NI:GetRAP()
            if not RAP then BlacklistedUIDs[UID]=true; return end
            if PD.NegativePrice then PD.RealPrice = RAP + PD.RealPrice end
            if PD.IsPercentage or PD.AboveRAP then
                PD.RealPrice = PD.AboveRAP and RAP+(RAP*(PD.RealPrice/100)) or RAP-(RAP*(PD.RealPrice/100))
            end
        end

        if not PD.RealPrice or PD.RealPrice <= 0 then
            warn("[Plaza Plus]: Invalid price for "..name); return
        end

        if data.Amount then Amount = math.min(Amount, data.Amount) end
        local MaxAmount = 50000
        if PD.RealPrice * Amount >= RemoveSuffix("100b") then
            Amount = math.floor(RemoveSuffix("100b") / PD.RealPrice)
        end

        local _, itemSlots = FindItemsInBooth(FindInfo.ID, FindInfo.Class)
        if data.Amount and itemSlots and itemSlots >= data.Amount then return end
        if Amount <= 0 then return end

        print("[Plaza Plus]: Listing "..name.." × "..Amount.." for "..tostring(PD.RealPrice))
        task.wait(math.random(2, 5))

        local fails = 0
        while Amount > 0 and (FindItemsInBooth() or 0) < maxSlots do
            if not SellerRunning then break end
            local t2 = os.time()
            local ok = Library.Network.Invoke("Booths_CreateListing", UID, math.floor(PD.RealPrice), math.min(Amount, MaxAmount))
            repeat task.wait() until ok or (os.time()-t2) >= 10
            if ok then
                warn("[Plaza Plus]: Listed "..name.." × "..math.min(Amount,MaxAmount))
                Amount = Amount - MaxAmount
            else
                fails = fails + 1
                table.remove(LastUIDs, table.find(LastUIDs, UID))
                warn("[Plaza Plus]: FAILED listing "..name)
            end
            if fails >= 3 then break end
        end
    end

    SellerThread = task.spawn(function()
        while SellerRunning do
            local maxSlots = PlayerSave.Get().BoothSlots or 8
            local usedSlots = FindItemsInBooth() or 0

            if usedSlots < maxSlots then
                -- Rebuild list fresh every tick — new items added via GUI are picked up instantly
                local priority, normal = {}, {}
                for _, item in pairs(Cfg.SellerItems or {}) do
                    if item.Priority then table.insert(priority, item)
                    else table.insert(normal, item) end
                end

                -- Process priority items first, then normal
                for _, item in ipairs(priority) do
                    if not SellerRunning then break end
                    TryListItem(item.Name, item)
                end
                for _, item in ipairs(normal) do
                    if not SellerRunning then break end
                    TryListItem(item.Name, item)
                end
            else
                -- Booth full — just wait and recheck
                task.wait(5)
            end

            if Cfg.SwitchServers and Cfg.Delay and (os.time()-StartingTime) >= (Cfg.Delay*60) then
                warn("[Plaza Plus]: Switch servers triggered")
                GrabIDs(); Serverhop()
            end

            task.wait(1)
        end
    end)
end

-- ══════════════════════════════════════════
--  SNIPER RUNTIME
-- ══════════════════════════════════════════
local SniperRunning=false

local function RunSniper()
    SniperRunning=true
    botStatus.Text="🎯 Sniper running..."; botStatus.TextColor3=C.Yellow

    -- Print what we're sniping
    warn("[Plaza Plus]: Sniper started. Watching for:")
    for _,item in pairs(Cfg.SniperItems or {}) do
        warn("  [Booth] "..tostring(item.Name).." at price: "..tostring(item.Price))
    end
    for _,item in pairs(Cfg.TerminalItems or {}) do
        warn("  [Terminal] "..tostring(item.Name).." at price: "..tostring(item.Price))
    end
    if #(Cfg.TerminalItems or {})==0 and #(Cfg.SniperItems or {})==0 then
        warn("  (no items configured — add items in the Sniper tab)")
    end

    -- FindInfo cache — rebuilt each cycle so newly added snipe targets work live
    local FindInfoCache={}

    local function GetFindInfo(item)
        if not FindInfoCache[item.Name] then
            FindInfoCache[item.Name]=GenerateFindInfo(item.Name,item)
        end
        return FindInfoCache[item.Name]
    end

    local function ProcessBooth(BoothID, Booth)
        for BI,IV in next, Booth do
            if BI~="Listings" then continue end
            for ItemUID,ItemInfo in next, IV do
                local ID=ItemInfo.Item._data
                local CI={
                    UID=ItemUID, ID=ID.id, Display=ID.id,
                    Class=ItemInfo.Item.Class.Name,
                    Rainbow=ItemInfo.Item.IsRainbow and ItemInfo.Item:IsRainbow(),
                    Golden=ItemInfo.Item.IsGolden and ItemInfo.Item:IsGolden(),
                    Shiny=ItemInfo.Item.IsShiny and ItemInfo.Item:IsShiny(),
                    Amount=ID["_am"] or 1, Tier=ID["tn"], Cost=ItemInfo.DiamondCost,
                    RAP=(table.find({PS99.Normal,PS99.Pro},game.PlaceId) and ItemInfo.Item.GetDevRAP and ItemInfo.Item:GetDevRAP()) or ItemInfo.Item.GetRAP and ItemInfo.Item:GetRAP(),
                    IsHuge=ItemInfo.Item.IsHuge and ItemInfo.Item:IsHuge() or false,
                    IsTitanic=ItemInfo.Item.IsTitanic and ItemInfo.Item:IsTitanic() or false,
                    IsExclusive=ItemInfo.Item.GetRarity and ItemInfo.Item:GetRarity()._id=="Exclusive",
                    Icon=ItemInfo.Item.GetIcon and ItemInfo.Item:GetIcon(),
                    Rarity=ItemInfo.Item.GetRarity and ItemInfo.Item:GetRarity()._id,
                }
                if CI.Rainbow then CI.Display="Rainbow "..CI.Display elseif CI.Golden then CI.Display="Golden "..CI.Display end
                if CI.Shiny then CI.Display="Shiny "..CI.Display end
                if CI.Tier then CI.Display=CI.Display.." "..CI.Tier end

                for _,item in pairs(Cfg.SniperItems or {}) do
                    local FI=GetFindInfo(item)
                    if not FI then continue end
                    if not ValidateItem(CI,FI) then continue end

                    -- Price check
                    local PD={IsPercentage=type(item.Price)=="string" and item.Price:find("%%"),AboveRAP=type(item.Price)=="string" and item.Price:find("+")}
                    PD.RealPrice=tonumber(type(item.Price)=="string" and (not PD.IsPercentage and RemoveSuffix(item.Price) or item.Price:gsub("%D","")) or item.Price)
                    local Percent=CI.RAP and CalcPercent(CI.RAP,CI.Cost) or nil
                    local valid=false
                    if PD.IsPercentage and type(Percent)=="number" then
                        valid=PD.AboveRAP and Percent>=tonumber("-"..PD.RealPrice) or Percent>=PD.RealPrice
                    else
                        valid=PD.RealPrice and PD.RealPrice-CI.Cost>=0
                    end
                    if not valid then continue end
                    if GetDiamonds()<CI.Cost then continue end

                    local canBuy=math.floor(GetDiamonds()/CI.Cost)
                    local buyAmt=math.min(CI.Amount,canBuy)
                    if item.InventoryLimit then buyAmt=math.min(buyAmt,item.InventoryLimit-(FindItem(FI,true) or 0)) end
                    if buyAmt<=0 then continue end

                    warn("[Plaza Plus]: Sniping ×"..buyAmt.." "..CI.Display)

                    -- Move to booth interact point
                    local BoothModel=BoothsInteractive[BoothID]
                    if BoothModel then
                        local Interact=BoothModel:FindFirstChild("Interact") or BoothModel:WaitForChild("Interact",5)
                        if Interact then
                            HumanoidRootPart.CFrame=Interact.CFrame*CFrame.new(0,-2,-6)
                            task.wait(0.5)
                        end
                    end

                    -- Get PlayerID from booth data
                    local PlayerID=Booth.PlayerID or Booth.Player and Booth.Player.UserId
                    if not PlayerID then
                        warn("[Plaza Plus]: Could not get PlayerID for booth "..tostring(BoothID))
                        continue
                    end

                    local Thing={Caller={LineNumber=532,ParameterCount=2,Variadic=false,Traceback="ReplicatedStorage.Library.Client.BoothCmds:532",ScriptPath="ReplicatedStorage.Library.Client.BoothCmds",ScriptClass="ModuleScript",FunctionName="PromptPurchase2",ScriptType="Instance",SourceIdentifier="ReplicatedStorage.Library.Client.BoothCmds"}}
                    local ok=Library.Network.Invoke("Booths_RequestPurchase",PlayerID,{[CI.UID]=buyAmt},Thing)
                    if ok then
                        CI.Bought=buyAmt
                        if Percent then SniperWebhook(CI,Percent) end
                    else
                        warn("[Plaza Plus]: Purchase failed for "..CI.Display)
                    end
                end
            end
        end
    end

    -- ── Terminal Search runtime ──────────────
    local TerminalServers={}
    local Values={}

    local function ReturnCosmicValue(Pet)
        if Values[Pet] then return Values[Pet] end
        local ok,Search=pcall(function()
            return game:HttpGet("https://petsimulatorvalues.com/details.php?Name="..Pet:gsub(" ","+"))
        end)
        if not ok then return nil end
        local Val=Search:split('value</Span><Span class="float-right">')[2]
        if Val then
            Val=Val:split("</Span>")[1]
            if Val:find("%d") then
                local v=RemoveSuffix(Val); Values[Pet]=v; return v
            end
        end
        return nil
    end

    local function OrderedTable(tbl,order)
        local parts={}
        for _,key in ipairs(order) do
            local val=tbl[key]; local fv
            if type(val)=="string" then fv='"'..val..'"'
            elseif type(val)=="boolean" or type(val)=="number" then fv=tostring(val) end
            if fv~=nil then table.insert(parts,'"'..key..'":' ..fv) end
        end
        return "{"..table.concat(parts,",").."}"
    end

    -- Maps internal ItemList class names to Terminal InvokeServer class names
    local TerminalClassMap = {
        ["Pet"]       = "Pets",
        ["Card"]      = "Cards",
        ["Misc"]      = "Items",
        ["Potion"]    = "Potions",
        ["Enchant"]   = "Enchants",
        ["Ultimate"]  = "Ultimates",
        ["Hoverboard"]= "Boards",
        ["Egg"]       = "Eggs",
        ["Charm"]     = "Charms",
        ["Box"]       = "Items",
        ["Lootbox"]   = "Items",
        ["Fruit"]     = "Items",
        -- If user typed the terminal name directly, pass through
        ["Pets"]      = "Pets",
        ["Cards"]     = "Cards",
        ["Items"]     = "Items",
        ["Potions"]   = "Potions",
        ["Enchants"]  = "Enchants",
        ["Ultimates"] = "Ultimates",
        ["Boards"]    = "Boards",
        ["Eggs"]      = "Eggs",
        ["Charms"]    = "Charms",
    }

    local function SearchTerminal(itemID, itemClass, item, tier)
        -- Exact format confirmed by spy:
        -- InvokeServer: TradingTerminal_Search | [1] Misc | [2] {"id":"Mini Chest"}
        -- With tier: {"id":"Treasure Hunter","tn":2}
        local Encoded
        if tier then
            Encoded = '{"id":"'..itemID..'","tn":'..tostring(tier)..'}'
        else
            Encoded = '{"id":"'..itemID..'"}'
        end
        warn("[Plaza Plus Terminal]: Searching "..itemClass.." for: "..itemID..(tier and " tier "..tier or ""))

        local FoundServer
        pcall(function()
            FoundServer = game.ReplicatedStorage.Network.TradingTerminal_Search:InvokeServer(itemClass, Encoded, nil, false)
        end)

        if type(FoundServer) == "table" and FoundServer["place_id"] and FoundServer["job_id"] then
            local placeOk = table.find({PS99.Normal, PS99.Pro}, FoundServer["place_id"])
            if placeOk then
                if not Cfg.OnlyPro or FoundServer["place_id"] == PS99.Pro then
                    warn("[Plaza Plus Terminal]: ✓ Found server for "..itemID.." — teleporting...")
                    table.insert(TerminalServers, {PlaceID=FoundServer["place_id"], JobID=FoundServer["job_id"], Item=item})
                end
            end
            return
        elseif FoundServer == false then
            warn("[Plaza Plus Terminal]: No listings found for "..itemID.." anywhere")
            return
        elseif FoundServer == nil then
            -- InvokeServer returned nil — likely means popup was shown instead
            -- Watch for Yes button
        else
            warn("[Plaza Plus Terminal]: Unexpected response for "..itemID..": "..tostring(FoundServer))
        end

        -- Watch for the Yes popup and auto-click it
        task.spawn(function()
            local t = tick()
            while tick()-t < 5 do
                task.wait(0.05)
                for _, obj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if obj:IsA("TextButton") and obj.Visible then
                        local ok, txt = pcall(function() return obj.Text:lower() end)
                        if ok and (txt == "yes" or txt == "yes!") then
                            warn("[Plaza Plus Terminal]: Auto-clicking Yes for "..itemID)
                            pcall(function() firebutton(obj) end)
                            return
                        end
                    end
                end
            end
        end)
    end

    -- Terminal search loop
    local warnedItems = {}
    task.spawn(function()
        while SniperRunning do
            for _,item in pairs(Cfg.TerminalItems or {}) do
                if not SniperRunning then break end
                local FI = GetFindInfo(item)

                if not FI or not FI.Class then
                    if not warnedItems[item.Name] then
                        warn("[Plaza Plus Terminal]: Could not resolve: '"..tostring(item.Name).."'")
                        for Class, List in next, ItemList do
                            for DisplayName, Data in next, List do
                                if DisplayName:lower():find(item.Name:lower()) or (Data.ID and tostring(Data.ID):lower():find(item.Name:lower())) then
                                    warn("[Plaza Plus Terminal]: Try → Class: "..Class.." | Display: "..DisplayName.." | ID: "..tostring(Data.ID))
                                end
                            end
                        end
                        warnedItems[item.Name] = true
                    end
                    continue
                end
                warnedItems[item.Name] = nil

                if item.InventoryLimit then
                    local have = FindItem(FI, true) or 0
                    if have >= item.InventoryLimit then continue end
                end

                -- Remap class names to what TradingTerminal_Search actually expects
                -- Confirmed by spy: game sends "Misc" not "Items"
                local terminalClass = ({
                    ["Misc"]     = "Misc",
                    ["Items"]    = "Misc",
                    ["Pet"]      = "Pet",
                    ["Pets"]     = "Pet",
                    ["Card"]     = "Card",
                    ["Cards"]    = "Card",
                    ["Potion"]   = "Potion",
                    ["Potions"]  = "Potion",
                    ["Enchant"]  = "Enchant",
                    ["Enchants"] = "Enchant",
                    ["Ultimate"] = "Ultimate",
                    ["Egg"]      = "Egg",
                    ["Eggs"]     = "Egg",
                    ["Hoverboard"] = "Hoverboard",
                    ["Charm"]    = "Charm",
                    ["Box"]      = "Misc",
                    ["Lootbox"]  = "Misc",
                    ["Fruit"]    = "Misc",
                })[FI.Class] or FI.Class

                SearchTerminal(FI.ID or item.Name, terminalClass, item, FI.Tier)
                task.wait(2)
            end

            if #TerminalServers > 0 then
                local target = table.remove(TerminalServers, 1)
                if target and target.JobID ~= game.JobId then
                    -- Save the pending buy to file so we auto-buy when we arrive
                    if target.Item then
                        Cfg.PendingTerminalBuy = {
                            Name  = target.Item.Name,
                            Price = target.Item.Price,
                            InventoryLimit = target.Item.InventoryLimit,
                            JobID = target.JobID,
                        }
                        SaveCfg()
                        warn("[Plaza Plus Terminal]: Saved pending buy for "..target.Item.Name.." — teleporting...")
                    end
                    DisableAntiScam()
                    local tok, terr = pcall(function()
                        TeleportService:TeleportToPlaceInstance(target.PlaceID, target.JobID, LocalPlayer)
                    end)
                    if not tok then
                        warn("[Plaza Plus Terminal]: Teleport failed: "..tostring(terr))
                        Cfg.PendingTerminalBuy = nil
                        SaveCfg()
                    end
                    task.wait(2)
                end
            end

            task.wait(1)
        end
    end)

    -- ── Booth scanner loop ───────────────────
    task.spawn(function()
        while SniperRunning do
            for _,Users in next, Booths do
                for Username,Booth in next, Users do
                    if not SniperRunning then break end
                    local skip=false
                    pcall(function() if Booth.Player and Booth.Player:IsInGroup(5060810) then skip=true end end)
                    if not skip then
                        local BoothID = Booth.BoothID
                        if not BoothID then
                            for bid, bdata in pairs(ClaimedBooths or {}) do
                                if bdata and bdata.Player and tostring(bdata.Player)==tostring(Username) then
                                    BoothID = bdata.BoothID; break
                                end
                            end
                        end
                        pcall(ProcessBooth, BoothID or Username, Booth)
                    end
                end
            end
            if Cfg.SwitchServers and Cfg.Delay and (os.time()-StartingTime)>=(Cfg.Delay*60) then
                GrabIDs(); Serverhop()
            end
            task.wait(0.3)
        end
    end)
end

-- ══════════════════════════════════════════
--  AUTO-BUY ON ARRIVAL (Terminal teleport)
-- ══════════════════════════════════════════
task.spawn(function()
    local pending = Cfg.PendingTerminalBuy
    if not pending then return end
    if pending.JobID and pending.JobID ~= game.JobId then
        -- Wrong server, clear it
        Cfg.PendingTerminalBuy = nil; SaveCfg(); return
    end

    warn("[Plaza Plus Terminal]: Arrived! Auto-buying "..tostring(pending.Name).."...")
    botStatus.Text="🛒 Buying "..pending.Name.."..."; botStatus.TextColor3=C.Yellow

    -- Wait for booths to load
    task.wait(4)

    local FindInfo = GenerateFindInfo(pending.Name, pending)
    if not FindInfo or not FindInfo.ID then
        warn("[Plaza Plus Terminal]: Could not resolve item on arrival: "..pending.Name)
        Cfg.PendingTerminalBuy = nil; SaveCfg(); return
    end

    local priceVal = type(pending.Price)=="string" and RemoveSuffix(pending.Price) or pending.Price
    local bought = false

    -- Scan all booths for the item at the right price
    for _, Users in next, Booths do
        if bought then break end
        for Username, Booth in next, Users do
            if bought then break end
            for BI, IV in next, Booth do
                if BI ~= "Listings" then continue end
                for ItemUID, ItemInfo in next, IV do
                    local ID = ItemInfo.Item._data
                    local cost = ItemInfo.DiamondCost
                    if not cost then continue end

                    local CI = {
                        UID = ItemUID, ID = ID.id,
                        Class = ItemInfo.Item.Class.Name,
                        Rainbow = ItemInfo.Item.IsRainbow and ItemInfo.Item:IsRainbow(),
                        Golden  = ItemInfo.Item.IsGolden  and ItemInfo.Item:IsGolden(),
                        Shiny   = ItemInfo.Item.IsShiny   and ItemInfo.Item:IsShiny(),
                        Amount  = ID["_am"] or 1,
                        Tier    = ID["tn"],
                        Cost    = cost,
                        RAP     = (ItemInfo.Item.GetDevRAP and ItemInfo.Item:GetDevRAP()) or (ItemInfo.Item.GetRAP and ItemInfo.Item:GetRAP()),
                    }

                    if not ValidateItem(CI, FindInfo) then continue end
                    if cost > priceVal then
                        warn("[Plaza Plus Terminal]: Found "..CI.ID.." but price "..AddSuffix(cost).." > max "..AddSuffix(priceVal).." — skipping")
                        continue
                    end
                    if GetDiamonds() < cost then
                        warn("[Plaza Plus Terminal]: Not enough diamonds to buy "..CI.ID)
                        continue
                    end

                    -- Check inventory limit
                    if pending.InventoryLimit then
                        local have = FindItem(FindInfo, true) or 0
                        if have >= pending.InventoryLimit then
                            warn("[Plaza Plus Terminal]: Inventory limit reached for "..CI.ID)
                            continue
                        end
                    end

                    local canBuy = math.floor(GetDiamonds() / cost)
                    local buyAmt = math.min(CI.Amount, canBuy)
                    if buyAmt <= 0 then continue end

                    warn("[Plaza Plus Terminal]: Buying ×"..buyAmt.." "..CI.ID.." for "..AddSuffix(cost).." each")

                    -- Move to booth
                    local BoothModel = BoothsInteractive and BoothsInteractive[Booth.BoothID]
                    if BoothModel then
                        local Interact = BoothModel:FindFirstChild("Interact")
                        if Interact then
                            HumanoidRootPart.CFrame = Interact.CFrame * CFrame.new(0,-2,-6)
                            task.wait(0.5)
                        end
                    end

                    local PlayerID = Booth.PlayerID or (Booth.Player and Booth.Player.UserId)
                    if not PlayerID then continue end

                    local Thing = {Caller={LineNumber=532,ParameterCount=2,Variadic=false,Traceback="ReplicatedStorage.Library.Client.BoothCmds:532",ScriptPath="ReplicatedStorage.Library.Client.BoothCmds",ScriptClass="ModuleScript",FunctionName="PromptPurchase2",ScriptType="Instance",SourceIdentifier="ReplicatedStorage.Library.Client.BoothCmds"}}
                    local ok = Library.Network.Invoke("Booths_RequestPurchase", PlayerID, {[CI.UID]=buyAmt}, Thing)
                    if ok then
                        warn("[Plaza Plus Terminal]: ✓ Bought ×"..buyAmt.." "..CI.ID.."!")
                        botStatus.Text="✓ Bought "..CI.ID.." ×"..buyAmt; botStatus.TextColor3=C.Green
                        -- Send webhook
                        if CI.RAP then
                            CI.Bought = buyAmt
                            CI.Display = CI.ID
                            CI.Rarity = ItemInfo.Item.GetRarity and ItemInfo.Item:GetRarity()._id
                            CI.Icon = ItemInfo.Item.GetIcon and ItemInfo.Item:GetIcon()
                            local pct = CalcPercent(CI.RAP, cost)
                            SniperWebhook(CI, pct)
                        end
                        bought = true
                        break
                    else
                        warn("[Plaza Plus Terminal]: Purchase failed for "..CI.ID)
                    end
                end
            end
        end
    end

    if not bought then
        warn("[Plaza Plus Terminal]: Item not found at right price — re-searching terminal...")
        botStatus.Text="🔍 Re-searching for "..pending.Name.."..."; botStatus.TextColor3=C.Yellow
        -- Re-trigger terminal search for this item
        task.wait(2)
        local FI2 = GenerateFindInfo(pending.Name, pending)
        if FI2 and FI2.Class then
            local terminalClass = ({
                ["Misc"]="Misc",["Items"]="Misc",["Pet"]="Pet",["Pets"]="Pet",
                ["Card"]="Card",["Potion"]="Potion",["Enchant"]="Enchant",
                ["Ultimate"]="Ultimate",["Egg"]="Egg",["Hoverboard"]="Hoverboard",
                ["Charm"]="Charm",["Box"]="Misc",["Lootbox"]="Misc",["Fruit"]="Misc",
            })[FI2.Class] or FI2.Class
            local Encoded = FI2.Tier and '{"id":"'..FI2.ID..'","tn":'..FI2.Tier..'}' or '{"id":"'..FI2.ID..'"}'
            local FoundServer
            pcall(function()
                FoundServer = game.ReplicatedStorage.Network.TradingTerminal_Search:InvokeServer(terminalClass, Encoded, nil, false)
            end)
            if type(FoundServer)=="table" and FoundServer["place_id"] and FoundServer["job_id"] then
                if FoundServer["job_id"] ~= game.JobId then
                    Cfg.PendingTerminalBuy = {
                        Name=pending.Name, Price=pending.Price,
                        InventoryLimit=pending.InventoryLimit,
                        JobID=FoundServer["job_id"],
                    }
                    SaveCfg()
                    warn("[Plaza Plus Terminal]: Found cheaper server — teleporting again...")
                    DisableAntiScam()
                    local tOk, tErr = pcall(function()
                        TeleportService:TeleportToPlaceInstance(FoundServer["place_id"], FoundServer["job_id"], LocalPlayer)
                    end)
                    if not tOk then
                        warn("[Plaza Plus Terminal]: Teleport failed ("..tostring(tErr)..") — searching for another server...")
                        Cfg.PendingTerminalBuy = nil; SaveCfg()
                        -- Re-search immediately for a different server
                        task.wait(2)
                        pcall(function()
                            game.ReplicatedStorage.Network.TradingTerminal_Search:InvokeServer(terminalClass, Encoded, nil, false)
                        end)
                        task.spawn(function()
                            local t2=tick()
                            while tick()-t2<5 do
                                task.wait(0.05)
                                for _,obj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                                    if obj:IsA("TextButton") and obj.Visible then
                                        local ok2,txt=pcall(function() return obj.Text:lower() end)
                                        if ok2 and (txt=="yes" or txt=="yes!") then
                                            pcall(function() firebutton(obj) end); return
                                        end
                                    end
                                end
                            end
                        end)
                    end
                else
                    warn("[Plaza Plus Terminal]: Same server returned — item may be sold out")
                    botStatus.Text="⚠ No cheaper listing found"; botStatus.TextColor3=C.Red
                    Cfg.PendingTerminalBuy = nil; SaveCfg()
                end
            else
                -- Try yes popup
                task.spawn(function()
                    local t=tick()
                    while tick()-t<5 do
                        task.wait(0.05)
                        for _,obj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                            if obj:IsA("TextButton") and obj.Visible then
                                local ok,txt=pcall(function() return obj.Text:lower() end)
                                if ok and (txt=="yes" or txt=="yes!") then
                                    pcall(function() firebutton(obj) end); return
                                end
                            end
                        end
                    end
                    warn("[Plaza Plus Terminal]: No server found on re-search")
                    botStatus.Text="⚠ No listing found anywhere"; botStatus.TextColor3=C.Red
                    Cfg.PendingTerminalBuy = nil; SaveCfg()
                end)
                return -- don't clear pending yet, popup watcher handles it
            end
        else
            Cfg.PendingTerminalBuy = nil; SaveCfg()
        end
    else
        Cfg.PendingTerminalBuy = nil; SaveCfg()
    end
end)
launchBtn.MouseButton1Click:Connect(function()
    if IsRunning then return end
    local mode = Cfg.Mode or "Seller"
    local sellerItems = Cfg.SellerItems or {}
    local sniperItems = Cfg.SniperItems or {}

    if (mode=="Seller" or mode=="Both") and #sellerItems==0 then
        botStatus.TextColor3=C.Red
        botStatus.Text="⚠ Add items to the Seller tab first!"
        task.delay(3,function() botStatus.TextColor3=C.Sub; botStatus.Text="Configure items, then press START" end)
        return
    end
    if (mode=="Sniper" or mode=="Both") and #sniperItems==0 then
        botStatus.TextColor3=C.Red
        botStatus.Text="⚠ Add targets to the Sniper tab first!"
        task.delay(3,function() botStatus.TextColor3=C.Sub; botStatus.Text="Configure items, then press START" end)
        return
    end

    IsRunning=true
    Tw(launchBtn,{BackgroundColor3=C.GreenDim})
    botStatus.TextColor3=C.Green
    botStatus.Text="⏳ Starting "..mode.." mode..."

    if mode=="Seller" or mode=="Both" then
        task.spawn(RunSeller)
    end
    if mode=="Sniper" or mode=="Both" then
        task.spawn(RunSniper)
    end
    if Cfg.SwitchServers then
        task.spawn(function() GrabIDs() end)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    IsRunning=false; SellerRunning=false; SniperRunning=false
    if SellerThread then task.cancel(SellerThread) end
    Tw(launchBtn,{BackgroundColor3=C.Green})
    botStatus.TextColor3=C.Sub; botStatus.Text="Stopped. Reconfigure and press START again."
    warn("[Plaza Plus]: Stopped by user.")
end)

-- ══════════════════════════════════════════
--  DRAG + TOGGLE
-- ══════════════════════════════════════════
do
    local drag,ds,sp=false,nil,nil
    TBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp=Win.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds; Win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end
UserInputService.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.RightShift then Win.Visible=not Win.Visible end end)

if not table.find({PS99.Normal,PS99.Pro,PETSGO.Normal,PETSGO.Pro},game.PlaceId) then
    botStatus.TextColor3=C.Red
    botStatus.Text="⚠ Wrong game! Go to PS99 or PETS GO Trading Plaza."
end

print("[Plaza Plus GUI]: Ready! Press RightShift to toggle.")
