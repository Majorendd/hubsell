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

-- ══════════════════════════════════════════
--  GUI SYSTEM — Modern Dark Panel
-- ══════════════════════════════════════════
if CoreGui:FindFirstChild("PlazaPlusGUI") then CoreGui:FindFirstChild("PlazaPlusGUI"):Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlazaPlusGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local IsRunning = false
local SellerRunning = false
local SniperRunning = false
local SellerThread = nil

-- ── Palette ──────────────────────────────
local C = {
    BG      = Color3.fromRGB(13, 13, 17),
    Sidebar = Color3.fromRGB(17, 17, 23),
    Panel   = Color3.fromRGB(20, 20, 28),
    Card    = Color3.fromRGB(26, 26, 36),
    CardHov = Color3.fromRGB(30, 30, 42),
    Border  = Color3.fromRGB(38, 38, 55),
    Accent  = Color3.fromRGB(108, 99, 255),
    AccentD = Color3.fromRGB(70, 64, 180),
    AccentS = Color3.fromRGB(130, 122, 255),
    Green   = Color3.fromRGB(52, 211, 153),
    GreenD  = Color3.fromRGB(22, 100, 70),
    Red     = Color3.fromRGB(239, 68, 68),
    RedD    = Color3.fromRGB(100, 28, 28),
    Yellow  = Color3.fromRGB(251, 191, 36),
    Text    = Color3.fromRGB(240, 240, 250),
    TextD   = Color3.fromRGB(160, 160, 185),
    Sub     = Color3.fromRGB(100, 100, 130),
    Input   = Color3.fromRGB(15, 15, 22),
    White   = Color3.fromRGB(255, 255, 255),
}

local function Tw(o, p, t, s)
    TweenService:Create(o, TweenInfo.new(t or 0.18, s or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end
local function Cor(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p return c end
local function Str(p, col, th) local s = Instance.new("UIStroke"); s.Color = col or C.Border; s.Thickness = th or 1; s.Parent = p return s end
local function Pad(p, t, b, l, r) local u = Instance.new("UIPadding"); u.PaddingTop = UDim.new(0,t or 0); u.PaddingBottom = UDim.new(0,b or 0); u.PaddingLeft = UDim.new(0,l or 0); u.PaddingRight = UDim.new(0,r or 0); u.Parent = p end

local function MkFrame(par, sz, pos, col, rad)
    local f = Instance.new("Frame")
    f.Size = sz; f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = col or C.Panel; f.BorderSizePixel = 0; f.Parent = par
    if rad then Cor(f, rad) end
    return f
end
local function MkLabel(par, txt, tsz, col, font, xa)
    local l = Instance.new("TextLabel")
    l.Text = txt; l.TextSize = tsz or 13; l.TextColor3 = col or C.Text
    l.Font = font or Enum.Font.GothamBold; l.BackgroundTransparency = 1
    l.Size = UDim2.new(1,0,1,0); l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.Parent = par; return l
end
local function MkBtn(par, txt, sz, pos, bg, tc, rad)
    local b = Instance.new("TextButton")
    b.Size = sz; b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bg or C.Accent; b.TextColor3 = tc or C.White
    b.Text = txt; b.TextSize = 12; b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Parent = par
    Cor(b, rad or 8)
    local origBg = bg or C.Accent
    b.MouseEnter:Connect(function() Tw(b, {BackgroundColor3 = Color3.new(origBg.R+0.05, origBg.G+0.05, origBg.B+0.07)}) end)
    b.MouseLeave:Connect(function() Tw(b, {BackgroundColor3 = origBg}) end)
    return b
end
local function MkInput(par, ph, sz, pos)
    local b = Instance.new("TextBox")
    b.Size = sz; b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = C.Input; b.TextColor3 = C.Text
    b.PlaceholderColor3 = C.Sub; b.PlaceholderText = ph or ""
    b.Text = ""; b.TextSize = 12; b.Font = Enum.Font.Gotham
    b.BorderSizePixel = 0; b.ClearTextOnFocus = false; b.Parent = par
    Cor(b, 7); Pad(b, 0, 0, 10, 10)
    local sk = Str(b, C.Border, 1)
    b.Focused:Connect(function() Tw(sk, {Color=C.Accent}) end)
    b.FocusLost:Connect(function() Tw(sk, {Color=C.Border}) end)
    return b
end
local function MkToggle(par, pos, default)
    local track = MkFrame(par, UDim2.new(0,40,0,20), pos, C.Border, 10)
    local knob  = MkFrame(track, UDim2.new(0,14,0,14), UDim2.new(0,3,0.5,-7), C.Sub, 7)
    local state = default or false
    local cbs = {}
    local function Upd()
        Tw(track, {BackgroundColor3 = state and C.AccentD or C.Border})
        Tw(knob,  {Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
                   BackgroundColor3 = state and C.Accent or C.Sub})
    end
    Upd()
    local tb = Instance.new("TextButton"); tb.Size=UDim2.new(1,0,1,0); tb.BackgroundTransparency=1; tb.Text=""; tb.Parent=track
    tb.MouseButton1Click:Connect(function() state=not state; Upd(); for _,cb in pairs(cbs) do cb(state) end end)
    return track,
        function() return state end,
        function(cb) table.insert(cbs,cb) end,
        function(v) state=v; Upd() end
end

-- ── Main Window ──────────────────────────
local Win = MkFrame(ScreenGui, UDim2.new(0,680,0,500), UDim2.new(0.5,-340,0.5,-250), C.BG, 14)
Win.ClipsDescendants = true
Str(Win, C.Border, 1)

-- Subtle gradient
local Grad = Instance.new("UIGradient")
Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14,14,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12,10,18)),
})
Grad.Rotation = 120; Grad.Parent = Win

-- ── Sidebar ──────────────────────────────
local Sidebar = MkFrame(Win, UDim2.new(0,200,1,0), UDim2.new(0,0,0,0), C.Sidebar, 0)
-- Right border on sidebar
local SBDiv = MkFrame(Sidebar, UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), C.Border, 0)

-- Logo area
local LogoArea = MkFrame(Sidebar, UDim2.new(1,0,0,70), UDim2.new(0,0,0,0), C.Sidebar, 0)
local LogoIcon = MkFrame(LogoArea, UDim2.new(0,32,0,32), UDim2.new(0,18,0.5,-20), C.Accent, 8)
local LogoIconL = Instance.new("TextLabel"); LogoIconL.Text="P+"; LogoIconL.TextSize=13; LogoIconL.Font=Enum.Font.GothamBold; LogoIconL.TextColor3=C.White; LogoIconL.BackgroundTransparency=1; LogoIconL.Size=UDim2.new(1,0,1,0); LogoIconL.TextXAlignment=Enum.TextXAlignment.Center; LogoIconL.Parent=LogoIcon
local LogoTitleF = MkFrame(LogoArea, UDim2.new(1,-62,0,32), UDim2.new(0,58,0.5,-20), C.Sidebar, 0)
LogoTitleF.BackgroundTransparency=1
local LogoTitle = MkLabel(LogoTitleF, "Plaza Plus", 14, C.Text, Enum.Font.GothamBold)
local LogoSubF = MkFrame(LogoArea, UDim2.new(1,-62,0,16), UDim2.new(0,58,0.5,14), C.Sidebar, 0)
LogoSubF.BackgroundTransparency=1
local LogoSub = MkLabel(LogoSubF, "v1.0  ·  Auto Seller", 10, C.Sub, Enum.Font.Gotham)

-- Divider
local LogoDiv = MkFrame(Sidebar, UDim2.new(1,-32,0,1), UDim2.new(0,16,0,68), C.Border, 0)

-- Nav items
local NavItems = {}
local NavPages = {}
local ActiveNav = nil

local function MkNav(icon, label, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-16,0,40); btn.Position = UDim2.new(0,8,0,yPos)
    btn.BackgroundColor3 = C.Sidebar; btn.TextColor3 = C.Sub
    btn.Text = ""; btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Parent = Sidebar
    Cor(btn, 8)

    -- Active indicator bar
    local bar = MkFrame(btn, UDim2.new(0,3,0.5,-10), UDim2.new(0,0,0,5), C.Accent, 2)
    bar.Visible = false

    local iconL = Instance.new("TextLabel"); iconL.Text=icon; iconL.TextSize=16; iconL.Font=Enum.Font.GothamBold; iconL.TextColor3=C.Sub; iconL.BackgroundTransparency=1; iconL.Position=UDim2.new(0,14,0,0); iconL.Size=UDim2.new(0,24,1,0); iconL.TextXAlignment=Enum.TextXAlignment.Center; iconL.Parent=btn
    local labelL = Instance.new("TextLabel"); labelL.Text=label; labelL.TextSize=12; labelL.Font=Enum.Font.GothamBold; labelL.TextColor3=C.Sub; labelL.BackgroundTransparency=1; labelL.Position=UDim2.new(0,44,0,0); labelL.Size=UDim2.new(1,-52,1,0); labelL.TextXAlignment=Enum.TextXAlignment.Left; labelL.Parent=btn

    local entry = {btn=btn, bar=bar, iconL=iconL, labelL=labelL, label=label}
    table.insert(NavItems, entry)
    return entry
end

local navSeller  = MkNav("🏪", "Seller",   82)
local navSniper  = MkNav("🔒", "Sniper",  130)
local navSettings= MkNav("⚙", "Settings",178)

-- Status badge at bottom of sidebar
local StatusBadge = MkFrame(Sidebar, UDim2.new(1,-16,0,54), UDim2.new(0,8,1,-70), C.Card, 10)
Str(StatusBadge, C.Border, 1)
local StatusDot = MkFrame(StatusBadge, UDim2.new(0,8,0,8), UDim2.new(0,12,0,10), C.Sub, 4)
local StatusTitleF = MkFrame(StatusBadge, UDim2.new(1,-36,0,16), UDim2.new(0,28,0,8), C.Card, 0)
StatusTitleF.BackgroundTransparency=1
local StatusTitle = MkLabel(StatusTitleF, "Idle", 11, C.Sub, Enum.Font.GothamBold)
local StatusSubF = MkFrame(StatusBadge, UDim2.new(1,-36,0,14), UDim2.new(0,28,0,26), C.Card, 0)
StatusSubF.BackgroundTransparency=1
local StatusSub = MkLabel(StatusSubF, "Press Start to begin", 10, C.Sub, Enum.Font.Gotham)

local function SetStatus(title, sub, color)
    StatusTitle.Text = title
    StatusSub.Text = sub or ""
    local col = color or C.Sub
    Tw(StatusDot, {BackgroundColor3 = col})
    Tw(StatusTitle, {TextColor3 = col})
end

-- ── Content area ─────────────────────────
local Content = MkFrame(Win, UDim2.new(1,-200,1,-56), UDim2.new(0,200,0,0), C.BG, 0)
Content.BackgroundTransparency = 1

-- Page header
local PageHeader = MkFrame(Win, UDim2.new(1,-200,0,56), UDim2.new(0,200,0,0), C.BG, 0)
local PageTitleF = MkFrame(PageHeader, UDim2.new(1,-16,1,0), UDim2.new(0,16,0,0), C.BG, 0)
PageTitleF.BackgroundTransparency=1
local PageTitle = MkLabel(PageTitleF, "Seller", 16, C.Text, Enum.Font.GothamBold)
local PageSub   = Instance.new("TextLabel"); PageSub.Text="Manage items to sell in your booth"; PageSub.TextSize=11; PageSub.Font=Enum.Font.Gotham; PageSub.TextColor3=C.Sub; PageSub.BackgroundTransparency=1; PageSub.Position=UDim2.new(0,0,0.55,0); PageSub.Size=UDim2.new(1,0,0.4,0); PageSub.TextXAlignment=Enum.TextXAlignment.Left; PageSub.Parent=PageTitleF
local PageDiv = MkFrame(Win, UDim2.new(1,-200,0,1), UDim2.new(0,200,0,55), C.Border, 0)

-- ── Pages ────────────────────────────────
local function MkPage()
    local p = MkFrame(Content, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.BG, 0)
    p.BackgroundTransparency = 1; p.Visible = false; return p
end

local SellerPage  = MkPage()
local SniperPage  = MkPage()
local SettingsPage= MkPage()

local function SetPage(page, nav)
    for _, n in ipairs(NavItems) do
        Tw(n.btn, {BackgroundColor3 = C.Sidebar})
        Tw(n.iconL, {TextColor3 = C.Sub})
        Tw(n.labelL, {TextColor3 = C.Sub})
        n.bar.Visible = false
    end
    SellerPage.Visible   = false
    SniperPage.Visible   = false
    SettingsPage.Visible = false
    page.Visible = true
    Tw(nav.btn, {BackgroundColor3 = C.Card})
    Tw(nav.iconL, {TextColor3 = C.Accent})
    Tw(nav.labelL, {TextColor3 = C.Text})
    nav.bar.Visible = true
    ActiveNav = nav
    -- Update page title
    local titles = {
        [navSeller]  = {"Seller",   "Manage items to sell in your booth"},
        [navSniper]  = {"Sniper",   "Coming soon in a future update"},
        [navSettings]= {"Settings", "Configure automation options"},
    }
    local t = titles[nav]
    if t then PageTitle.Text = t[1]; PageSub.Text = t[2] end
end

navSeller.btn.MouseButton1Click:Connect(function()   SetPage(SellerPage,   navSeller)   end)
navSniper.btn.MouseButton1Click:Connect(function()   SetPage(SniperPage,   navSniper)   end)
navSettings.btn.MouseButton1Click:Connect(function() SetPage(SettingsPage, navSettings) end)

-- ── Bottom bar ───────────────────────────
local BottomBar = MkFrame(Win, UDim2.new(1,-200,0,56), UDim2.new(0,200,1,-56), C.Sidebar, 0)
local BBDiv = MkFrame(BottomBar, UDim2.new(1,0,0,1), UDim2.new(0,0,0,0), C.Border, 0)

local StartBtn = MkBtn(BottomBar, "▶  Start", UDim2.new(0,120,0,34), UDim2.new(0,12,0.5,-17), C.Green, Color3.fromRGB(8,30,20), 8)
StartBtn.TextColor3 = Color3.fromRGB(10,42,28)
local StopBtn  = MkBtn(BottomBar, "■  Stop",  UDim2.new(0,100,0,34), UDim2.new(0,140,0.5,-17), C.RedD, C.Red, 8)

local BotStatusF = MkFrame(BottomBar, UDim2.new(1,-272,1,0), UDim2.new(0,256,0,0), C.Sidebar, 0)
BotStatusF.BackgroundTransparency=1
local botStatus = MkLabel(BotStatusF, "Configure items then press Start", 11, C.Sub, Enum.Font.Gotham)

-- Close / minimise
local CloseBtn = MkBtn(BottomBar, "✕", UDim2.new(0,28,0,28), UDim2.new(1,-42,0.5,-14), C.RedD, C.Red, 6)
CloseBtn.MouseButton1Click:Connect(function() Win.Visible = false end)
local MinBtn = MkBtn(BottomBar, "─", UDim2.new(0,28,0,28), UDim2.new(1,-76,0.5,-14), C.Card, C.Sub, 6)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Tw(Win, {Size = minimized and UDim2.new(0,680,0,56) or UDim2.new(0,680,0,500)}, 0.22)
end)

-- ════════════════════════════════════════
--  SHARED HELPERS
-- ════════════════════════════════════════
local function SectionLabel(par, txt, yPos)
    local f = MkFrame(par, UDim2.new(1,-24,0,14), UDim2.new(0,12,0,yPos), C.BG, 0)
    f.BackgroundTransparency = 1
    local l = MkLabel(f, txt:upper(), 9, C.Sub, Enum.Font.GothamBold)
    l.LetterSpacing = 2
    return f
end

local function FieldLabel(par, txt, yPos)
    local f = MkFrame(par, UDim2.new(1,-24,0,14), UDim2.new(0,12,0,yPos), C.BG, 0)
    f.BackgroundTransparency = 1
    MkLabel(f, txt, 10, C.Sub, Enum.Font.Gotham)
    return f
end

-- Item card builder
local function ItemCard(scroll, name, price, detail, onRemove)
    local card = MkFrame(scroll, UDim2.new(1,0,0,48), UDim2.new(0,0,0,0), C.Card, 8)
    Str(card, C.Border, 1)

    -- Left accent bar
    local accentBar = MkFrame(card, UDim2.new(0,3,0.6,0), UDim2.new(0,0,0.2,0), C.Accent, 2)

    local nameL = Instance.new("TextLabel"); nameL.Text=name; nameL.TextSize=12; nameL.Font=Enum.Font.GothamBold; nameL.TextColor3=C.Text; nameL.BackgroundTransparency=1; nameL.Position=UDim2.new(0,14,0,7); nameL.Size=UDim2.new(1,-60,0,18); nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.TextTruncate=Enum.TextTruncate.AtEnd; nameL.Parent=card

    local priceL = Instance.new("TextLabel"); priceL.Text="💎 "..tostring(price); priceL.TextSize=10; priceL.Font=Enum.Font.Gotham; priceL.TextColor3=C.Accent; priceL.BackgroundTransparency=1; priceL.Position=UDim2.new(0,14,0,27); priceL.Size=UDim2.new(0,90,0,14); priceL.TextXAlignment=Enum.TextXAlignment.Left; priceL.Parent=card

    if detail and detail ~= "" then
        local detL = Instance.new("TextLabel"); detL.Text=detail; detL.TextSize=10; detL.Font=Enum.Font.Gotham; detL.TextColor3=C.Sub; detL.BackgroundTransparency=1; detL.Position=UDim2.new(0,108,0,27); detL.Size=UDim2.new(1,-150,0,14); detL.TextXAlignment=Enum.TextXAlignment.Left; detL.TextTruncate=Enum.TextTruncate.AtEnd; detL.Parent=card
    end

    -- Live dot
    local liveDot = MkFrame(card, UDim2.new(0,6,0,6), UDim2.new(1,-36,0,8), C.Sub, 3)
    task.spawn(function() while card.Parent do liveDot.BackgroundColor3 = IsRunning and C.Green or C.Sub; task.wait(1) end end)

    -- Remove
    local rb = MkBtn(card, "✕", UDim2.new(0,24,0,24), UDim2.new(1,-30,0.5,-12), C.RedD, C.Red, 6)
    rb.TextSize = 11
    rb.MouseButton1Click:Connect(function()
        Tw(card, {BackgroundTransparency=1, Size=UDim2.new(1,0,0,0)}, 0.15)
        task.delay(0.15, function() card:Destroy(); onRemove() end)
    end)
    return card
end

-- ════════════════════════════════════════
--  SELLER PAGE
-- ════════════════════════════════════════
local SellerItemData = {}

-- Two column layout
local SelLeft  = MkFrame(SellerPage, UDim2.new(0.5,-6,1,-12), UDim2.new(0,6,0,6),  C.Panel, 10)
local SelRight = MkFrame(SellerPage, UDim2.new(0.5,-6,1,-12), UDim2.new(0.5,3,0,6), C.Panel, 10)

-- Left: item list
SectionLabel(SelLeft, "Active Items", 10)
local SelScroll = Instance.new("ScrollingFrame")
SelScroll.Size = UDim2.new(1,-12,1,-32); SelScroll.Position = UDim2.new(0,6,0,26)
SelScroll.BackgroundTransparency=1; SelScroll.BorderSizePixel=0
SelScroll.ScrollBarThickness=3; SelScroll.ScrollBarImageColor3=C.Accent
SelScroll.CanvasSize=UDim2.new(0,0,0,0); SelScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
SelScroll.Parent=SelLeft
local SelLayout = Instance.new("UIListLayout"); SelLayout.Padding=UDim.new(0,4); SelLayout.Parent=SelScroll
local SelScrollPad = Instance.new("UIPadding"); SelScrollPad.PaddingTop=UDim.new(0,2); SelScrollPad.Parent=SelScroll

-- Right: add form
SectionLabel(SelRight, "Add Item", 10)
Pad(SelRight, 30, 8, 12, 12)

local function MkField(yOff, lbl, ph)
    local lf = Instance.new("TextLabel"); lf.Text=lbl; lf.TextSize=10; lf.Font=Enum.Font.Gotham; lf.TextColor3=C.Sub; lf.BackgroundTransparency=1; lf.Position=UDim2.new(0,0,0,yOff); lf.Size=UDim2.new(1,0,0,14); lf.TextXAlignment=Enum.TextXAlignment.Left; lf.Parent=SelRight
    local inp = MkInput(SelRight, ph, UDim2.new(1,0,0,28), UDim2.new(0,0,0,yOff+15))
    return inp
end

local nameIn  = MkField(4,  "Item Name",  "e.g. Spring Bluebell Token")
local priceIn = MkField(50, "Price",      "e.g. 2  ·  1m  ·  +20%  ·  -5%")
local amtIn   = MkField(96, "Amount",     "blank = sell all")
local classIn = MkField(142,"Class",      "e.g. Misc  (blank = auto)")
local tierIn  = MkField(188,"Tier",       "e.g. 2  (for potions, blank = any)")

-- Type toggles row
local typeRowY = 240
local typeRowF = MkFrame(SelRight, UDim2.new(1,0,0,52), UDim2.new(0,0,0,typeRowY), C.Card, 8)
Str(typeRowF, C.Border, 1)
-- Rainbow
local rbF = MkFrame(typeRowF, UDim2.new(0.33,0,1,0), UDim2.new(0,0,0,0), C.Card, 0); rbF.BackgroundTransparency=1
local rbDot = MkFrame(rbF, UDim2.new(0,8,0,8), UDim2.new(0,8,0.5,-4), Color3.fromRGB(80,180,255), 4)
local rbL = Instance.new("TextLabel"); rbL.Text="Rainbow"; rbL.TextSize=10; rbL.Font=Enum.Font.Gotham; rbL.TextColor3=C.Sub; rbL.BackgroundTransparency=1; rbL.Position=UDim2.new(0,20,0,0); rbL.Size=UDim2.new(1,-52,1,0); rbL.TextXAlignment=Enum.TextXAlignment.Left; rbL.Parent=rbF
local _,getRB,_,setRB = MkToggle(rbF, UDim2.new(1,-44,0.5,-10), false)
-- Golden
local gdF = MkFrame(typeRowF, UDim2.new(0.33,0,1,0), UDim2.new(0.33,0,0,0), C.Card, 0); gdF.BackgroundTransparency=1
local gdDot = MkFrame(gdF, UDim2.new(0,8,0,8), UDim2.new(0,8,0.5,-4), Color3.fromRGB(255,200,50), 4)
local gdL = Instance.new("TextLabel"); gdL.Text="Golden"; gdL.TextSize=10; gdL.Font=Enum.Font.Gotham; gdL.TextColor3=C.Sub; gdL.BackgroundTransparency=1; gdL.Position=UDim2.new(0,20,0,0); gdL.Size=UDim2.new(1,-52,1,0); gdL.TextXAlignment=Enum.TextXAlignment.Left; gdL.Parent=gdF
local _,getGD,_,setGD = MkToggle(gdF, UDim2.new(1,-44,0.5,-10), false)
-- Shiny
local shF = MkFrame(typeRowF, UDim2.new(0.34,0,1,0), UDim2.new(0.66,0,0,0), C.Card, 0); shF.BackgroundTransparency=1
local shDot = MkFrame(shF, UDim2.new(0,8,0,8), UDim2.new(0,8,0.5,-4), Color3.fromRGB(255,130,230), 4)
local shL = Instance.new("TextLabel"); shL.Text="Shiny"; shL.TextSize=10; shL.Font=Enum.Font.Gotham; shL.TextColor3=C.Sub; shL.BackgroundTransparency=1; shL.Position=UDim2.new(0,20,0,0); shL.Size=UDim2.new(1,-52,1,0); shL.TextXAlignment=Enum.TextXAlignment.Left; shL.Parent=shF
local _,getSH,_,setSH = MkToggle(shF, UDim2.new(1,-44,0.5,-10), false)

-- Options row
local optRowF = MkFrame(SelRight, UDim2.new(1,0,0,34), UDim2.new(0,0,0,typeRowY+58), C.Card, 8)
Str(optRowF, C.Border, 1)
local prioF = MkFrame(optRowF, UDim2.new(0.5,0,1,0), UDim2.new(0,0,0,0), C.Card, 0); prioF.BackgroundTransparency=1
local prioL = Instance.new("TextLabel"); prioL.Text="Priority"; prioL.TextSize=10; prioL.Font=Enum.Font.Gotham; prioL.TextColor3=C.Sub; prioL.BackgroundTransparency=1; prioL.Position=UDim2.new(0,10,0,0); prioL.Size=UDim2.new(1,-52,1,0); prioL.TextXAlignment=Enum.TextXAlignment.Left; prioL.Parent=prioF
local _,getPrio,_,setPrio = MkToggle(prioF, UDim2.new(1,-44,0.5,-10), false)
local allTypesF = MkFrame(optRowF, UDim2.new(0.5,0,1,0), UDim2.new(0.5,0,0,0), C.Card, 0); allTypesF.BackgroundTransparency=1
local atL = Instance.new("TextLabel"); atL.Text="All Types"; atL.TextSize=10; atL.Font=Enum.Font.Gotham; atL.TextColor3=C.Sub; atL.BackgroundTransparency=1; atL.Position=UDim2.new(0,10,0,0); atL.Size=UDim2.new(1,-52,1,0); atL.TextXAlignment=Enum.TextXAlignment.Left; atL.Parent=allTypesF
local _,getAT,_,setAT = MkToggle(allTypesF, UDim2.new(1,-44,0.5,-10), false)

-- Quick add button
local quickBtn = MkBtn(SelRight, "⚡  Quick Add: All Huges +20%", UDim2.new(1,0,0,28), UDim2.new(0,0,0,typeRowY+98), Color3.fromRGB(35,25,5), C.Yellow, 8)
quickBtn.TextSize=11

-- Add button
local addBtn = MkBtn(SelRight, "+ Add Item", UDim2.new(1,0,0,34), UDim2.new(0,0,0,typeRowY+132), C.Accent, C.White, 8)

-- Status
local selStatus = Instance.new("TextLabel"); selStatus.Text=""; selStatus.TextSize=11; selStatus.Font=Enum.Font.Gotham; selStatus.TextColor3=C.Green; selStatus.BackgroundTransparency=1; selStatus.Position=UDim2.new(0,0,0,typeRowY+172); selStatus.Size=UDim2.new(1,0,0,16); selStatus.TextXAlignment=Enum.TextXAlignment.Center; selStatus.Parent=SelRight

-- Restore saved seller items
for _, item in pairs(Cfg.SellerItems or {}) do
    SellerItemData[item._displayKey or item.Name] = item
    local typeStr = (item.AllTypes and "all-types") or (item.Shiny and "shiny " or "")..(item.Rainbow and "rainbow " or "")..(item.Golden and "golden " or "") or "normal"
    local ext = (item.Amount and "×"..item.Amount or "×max")..(item.Class and " · "..item.Class or "")..(item.Tier and " T"..item.Tier or "")
    local key = item._displayKey or item.Name
    ItemCard(SelScroll, key, item.Price, ext, function()
        SellerItemData[key] = nil
        local t={}; for _,v in pairs(SellerItemData) do table.insert(t,v) end; Cfg.SellerItems=t; SaveCfg()
    end)
end

local function DoAddSellerItem(name, price, amt, cls, tier, prio, rb, gd, sh, at)
    if name=="" or price=="" then
        selStatus.TextColor3=C.Red; selStatus.Text="⚠ Name and price are required"
        task.delay(2, function() selStatus.Text="" end); return
    end
    local typePrefix = (sh and "Shiny " or "")..(rb and "Rainbow " or "")..(gd and "Golden " or "")
    local displayKey = typePrefix..name..(tier and " T"..tier or "")
    if SellerItemData[displayKey] then
        selStatus.TextColor3=C.Red; selStatus.Text="⚠ Already in list"
        task.delay(2, function() selStatus.Text="" end); return
    end
    local priceVal = tonumber(price) or price
    local item = {Name=name, Price=priceVal, Amount=amt, Class=cls, Tier=tier,
                  Priority=prio, Rainbow=rb, Golden=gd, Shiny=sh, AllTypes=at, _displayKey=displayKey}
    SellerItemData[displayKey] = item
    local ext = (amt and "×"..amt or "×max")..(cls and " · "..cls or "")..(tier and " T"..tier or "")
    ItemCard(SelScroll, displayKey, priceVal, ext, function()
        SellerItemData[displayKey]=nil
        local t={}; for _,v in pairs(SellerItemData) do table.insert(t,v) end; Cfg.SellerItems=t; SaveCfg()
    end)
    nameIn.Text=""; priceIn.Text=""; amtIn.Text=""; classIn.Text=""; tierIn.Text=""
    setRB(false); setGD(false); setSH(false); setAT(false); setPrio(false)
    selStatus.TextColor3 = IsRunning and C.Yellow or C.Green
    selStatus.Text = IsRunning and "⚡ Added — listing next cycle" or "✓ Added successfully"
    task.delay(2, function() selStatus.Text="" end)
    local t={}; for _,v in pairs(SellerItemData) do table.insert(t,v) end; Cfg.SellerItems=t; SaveCfg()
end

addBtn.MouseButton1Click:Connect(function()
    DoAddSellerItem(
        nameIn.Text:match("^%s*(.-)%s*$"),
        priceIn.Text:match("^%s*(.-)%s*$"),
        amtIn.Text~="" and tonumber(amtIn.Text) or nil,
        classIn.Text~="" and classIn.Text or nil,
        tierIn.Text~="" and tonumber(tierIn.Text) or nil,
        getPrio(), getRB(), getGD(), getSH(), getAT()
    )
end)
quickBtn.MouseButton1Click:Connect(function()
    DoAddSellerItem("All Huges","+20%",nil,nil,nil,false,false,false,false,true)
end)

-- ════════════════════════════════════════
--  SNIPER PAGE — COMING SOON
-- ════════════════════════════════════════
do
    local cs = MkFrame(SniperPage, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.Panel, 10)
    local iconL = Instance.new("TextLabel"); iconL.Text="🔒"; iconL.TextSize=42; iconL.Font=Enum.Font.GothamBold; iconL.TextColor3=C.Sub; iconL.BackgroundTransparency=1; iconL.Position=UDim2.new(0,0,0.28,0); iconL.Size=UDim2.new(1,0,0,56); iconL.TextXAlignment=Enum.TextXAlignment.Center; iconL.Parent=cs
    local titleL = Instance.new("TextLabel"); titleL.Text="Coming Soon"; titleL.TextSize=20; titleL.Font=Enum.Font.GothamBold; titleL.TextColor3=C.Text; titleL.BackgroundTransparency=1; titleL.Position=UDim2.new(0,0,0.52,0); titleL.Size=UDim2.new(1,0,0,28); titleL.TextXAlignment=Enum.TextXAlignment.Center; titleL.Parent=cs
    local subL = Instance.new("TextLabel"); subL.Text="The Sniper feature is under development\nand will be available in a future update."; subL.TextSize=12; subL.Font=Enum.Font.Gotham; subL.TextColor3=C.Sub; subL.BackgroundTransparency=1; subL.Position=UDim2.new(0,40,0.65,0); subL.Size=UDim2.new(1,-80,0,44); subL.TextXAlignment=Enum.TextXAlignment.Center; subL.TextWrapped=true; subL.Parent=cs
    -- Badge
    local badge = MkFrame(cs, UDim2.new(0,100,0,26), UDim2.new(0.5,-50,0.84,0), Color3.fromRGB(30,25,5), 13)
    Str(badge, C.Yellow, 1)
    local badgeL = Instance.new("TextLabel"); badgeL.Text="In Development"; badgeL.TextSize=10; badgeL.Font=Enum.Font.GothamBold; badgeL.TextColor3=C.Yellow; badgeL.BackgroundTransparency=1; badgeL.Size=UDim2.new(1,0,1,0); badgeL.TextXAlignment=Enum.TextXAlignment.Center; badgeL.Parent=badge
end

-- ════════════════════════════════════════
--  SETTINGS PAGE
-- ════════════════════════════════════════
do
    local sf = MkFrame(SettingsPage, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.BG, 0)
    sf.BackgroundTransparency=1
    Pad(sf, 8, 8, 8, 8)

    local function SettingCard(label, sub, yPos, height)
        local card = MkFrame(sf, UDim2.new(1,0,0,height or 48), UDim2.new(0,0,0,yPos), C.Panel, 10)
        Str(card, C.Border, 1)
        local lbl = Instance.new("TextLabel"); lbl.Text=label; lbl.TextSize=12; lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=C.Text; lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,14,0,7); lbl.Size=UDim2.new(0.6,0,0,18); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=card
        if sub then
            local sl = Instance.new("TextLabel"); sl.Text=sub; sl.TextSize=10; sl.Font=Enum.Font.Gotham; sl.TextColor3=C.Sub; sl.BackgroundTransparency=1; sl.Position=UDim2.new(0,14,0,26); sl.Size=UDim2.new(0.7,0,0,14); sl.TextXAlignment=Enum.TextXAlignment.Left; sl.Parent=card
        end
        return card
    end

    -- Mode selector
    SectionLabel(sf, "General", 0)
    local modeCard = SettingCard("Mode", "What to run when Start is pressed", 18)
    local modeOptions = {"Seller","Sniper","Both"}
    local modeIdx = 1
    for i,v in ipairs(modeOptions) do if v==(Cfg.Mode or "Seller") then modeIdx=i end end
    local modeBadge = MkFrame(modeCard, UDim2.new(0,72,0,26), UDim2.new(1,-84,0.5,-13), C.AccentD, 6)
    local modeLbl = Instance.new("TextLabel"); modeLbl.Text=modeOptions[modeIdx]; modeLbl.TextSize=11; modeLbl.Font=Enum.Font.GothamBold; modeLbl.TextColor3=C.White; modeLbl.BackgroundTransparency=1; modeLbl.Size=UDim2.new(1,0,1,0); modeLbl.TextXAlignment=Enum.TextXAlignment.Center; modeLbl.Parent=modeBadge
    local modeBtnClick = Instance.new("TextButton"); modeBtnClick.Size=UDim2.new(1,0,1,0); modeBtnClick.BackgroundTransparency=1; modeBtnClick.Text=""; modeBtnClick.Parent=modeBadge
    modeBtnClick.MouseButton1Click:Connect(function()
        modeIdx=modeIdx%#modeOptions+1; modeLbl.Text=modeOptions[modeIdx]; Cfg.Mode=modeOptions[modeIdx]; SaveCfg()
    end)

    -- Switch Servers
    local ssCard = SettingCard("Switch Servers", "Auto hop servers on a timer", 74)
    local _,getSS,onSS,setSS = MkToggle(ssCard, UDim2.new(1,-54,0.5,-10), Cfg.SwitchServers or false)
    setSS(Cfg.SwitchServers or false)
    onSS(function(v) Cfg.SwitchServers=v; SaveCfg() end)

    -- Delay
    local delCard = SettingCard("Switch Delay", "Minutes between server hops", 130)
    local delIn = MkInput(delCard, "20", UDim2.new(0,70,0,24), UDim2.new(1,-84,0.5,-12))
    delIn.Text = tostring(Cfg.Delay or 20)
    delIn.FocusLost:Connect(function() Cfg.Delay=tonumber(delIn.Text) or 20; SaveCfg() end)

    -- Only Pro
    local proCard = SettingCard("Pro Servers Only", "Only teleport to Pro servers", 186)
    local _,getPro,onPro,setPro = MkToggle(proCard, UDim2.new(1,-54,0.5,-10), Cfg.OnlyPro or false)
    setPro(Cfg.OnlyPro or false)
    onPro(function(v) Cfg.OnlyPro=v; SaveCfg() end)

    -- Webhook
    SectionLabel(sf, "Notifications", 240)
    local whCard = SettingCard("Discord Webhook", nil, 258, 56)
    local whIn = MkInput(whCard, "https://discord.com/api/webhooks/...", UDim2.new(1,-24,0,28), UDim2.new(0,12,0,20))
    whIn.Text = Cfg.WebhookURL or ""
    whIn.FocusLost:Connect(function() Cfg.WebhookURL=whIn.Text; SaveCfg() end)

    -- Account info
    SectionLabel(sf, "Account", 324)
    local accCard = SettingCard("Logged In", LocalPlayer.Name, 342)
    local accBadge = MkFrame(accCard, UDim2.new(0,70,0,22), UDim2.new(1,-82,0.5,-11), C.GreenD, 6)
    Str(accBadge, C.Green, 1)
    local accBadgeL = Instance.new("TextLabel"); accBadgeL.Text="✓ Verified"; accBadgeL.TextSize=10; accBadgeL.Font=Enum.Font.GothamBold; accBadgeL.TextColor3=C.Green; accBadgeL.BackgroundTransparency=1; accBadgeL.Size=UDim2.new(1,0,1,0); accBadgeL.TextXAlignment=Enum.TextXAlignment.Center; accBadgeL.Parent=accBadge
end

-- ════════════════════════════════════════
--  SELLER RUNTIME
-- ════════════════════════════════════════
local function RunSeller()
    SellerRunning = true

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
        ClaimBooth()
        local t2=os.time()
        repeat task.wait() until ClaimedBooths[LocalPlayer] or (os.time()-t2)>15
    end
    if not ClaimedBooths[LocalPlayer] then
        warn("[Plaza Plus]: Booth claim failed")
        SetStatus("Error", "Could not claim booth", C.Red)
        botStatus.Text="⚠ Booth claim failed — try another server"; botStatus.TextColor3=C.Red
        SellerRunning=false; IsRunning=false; Tw(StartBtn,{BackgroundColor3=C.Green}); return
    end
    warn("[Plaza Plus]: Booth claimed — listing items...")
    SetStatus("Selling", "Booth claimed", C.Green)
    botStatus.Text="🏪 Seller running..."; botStatus.TextColor3=C.Green

    Library.Network.Fired("Booths: Add History"):Connect(function(Info)
        local cost=0
        for _,CT in next, Info["Received"] do for _,it in CT do if (it._am or 1)>cost then cost=it._am or 1 end end end
        for Class,CT in next, Info["Given"] do
            for UID,it in CT do
                warn("[Plaza Plus]: Sold: "..it.id.." x"..(it._am or 1))
                local id=ItemList[Class]; local ItemData=id and id[it.id]
                if not ItemData and id then for _,v in next,id do if v.ID==it.id then ItemData=v; break end end end
                if ItemData then task.wait(0.5); SellerWebhook({ID=it.id,Name=ItemData.Display,Amount=it._am or 1,Spent=cost,Class=Class,Icon=ItemData.Icon}) end
            end
        end
    end)

    local function TryListItem(name, data)
        local maxSlots = PlayerSave.Get().BoothSlots or 8
        local usedSlots = FindItemsInBooth() or 0
        if usedSlots >= maxSlots then return end
        local lookupName = name
        if not data.AllTypes then
            if data.Shiny   then lookupName="Shiny "..lookupName end
            if data.Rainbow then lookupName="Rainbow "..lookupName end
            if data.Golden  then lookupName="Golden "..lookupName end
        end
        if data.Tier then lookupName=lookupName.." "..ToRoman(data.Tier) end
        local FindInfo=GenerateFindInfo(lookupName, data)
        local UID,ItemData=FindItem(FindInfo)
        if not UID then return end
        local Amount=ItemData.Amount or 1
        local PD={
            IsPercentage=type(data.Price)=="string" and data.Price:find("%%"),
            AboveRAP=type(data.Price)=="string" and data.Price:find("+"),
            NegativePrice=(type(data.Price)=="number" and data.Price<0) or (type(data.Price)=="string" and data.Price:find("^%-")),
        }
        PD.RealPrice=tonumber(type(data.Price)=="string" and (not PD.IsPercentage and RemoveSuffix(data.Price) or data.Price:gsub("%D","")) or data.Price)
        if PD.IsPercentage or PD.AboveRAP or PD.NegativePrice then
            local NI=Library.Items.Types[ItemData.Class](ItemData.ID)
            if ItemData.Golden then NI:SetGolden() end
            if ItemData.Rainbow then NI:SetRainbow() end
            if ItemData.Shiny then NI:SetShiny(true) end
            if ItemData.Tier then NI:SetTier(ItemData.Tier) end
            local RAP=(table.find({PS99.Normal,PS99.Pro},game.PlaceId) and NI.GetDevRAP and NI:GetDevRAP()) or NI.GetRAP and NI:GetRAP()
            if not RAP then BlacklistedUIDs[UID]=true; return end
            if PD.NegativePrice then PD.RealPrice=RAP+PD.RealPrice end
            if PD.IsPercentage or PD.AboveRAP then PD.RealPrice=PD.AboveRAP and RAP+(RAP*(PD.RealPrice/100)) or RAP-(RAP*(PD.RealPrice/100)) end
        end
        if not PD.RealPrice or PD.RealPrice<=0 then return end
        if data.Amount then Amount=math.min(Amount,data.Amount) end
        local MaxAmount=50000
        if PD.RealPrice*Amount>=RemoveSuffix("100b") then Amount=math.floor(RemoveSuffix("100b")/PD.RealPrice) end
        local _,itemSlots=FindItemsInBooth(FindInfo.ID,FindInfo.Class)
        if data.Amount and itemSlots and itemSlots>=data.Amount then return end
        if Amount<=0 then return end
        print("[Plaza Plus]: Listing "..name.." × "..Amount.." @ "..tostring(PD.RealPrice))
        task.wait(math.random(2,5))
        local fails=0
        while Amount>0 and (FindItemsInBooth() or 0)<maxSlots do
            if not SellerRunning then break end
            local t2=os.time()
            local ok=Library.Network.Invoke("Booths_CreateListing",UID,math.floor(PD.RealPrice),math.min(Amount,MaxAmount))
            repeat task.wait() until ok or (os.time()-t2)>=10
            if ok then warn("[Plaza Plus]: Listed "..name.." × "..math.min(Amount,MaxAmount)); Amount=Amount-MaxAmount
            else fails=fails+1; table.remove(LastUIDs,table.find(LastUIDs,UID)); warn("[Plaza Plus]: FAILED listing "..name) end
            if fails>=3 then break end
        end
    end

    SellerThread=task.spawn(function()
        while SellerRunning do
            local maxSlots=PlayerSave.Get().BoothSlots or 8
            local usedSlots=FindItemsInBooth() or 0
            if usedSlots<maxSlots then
                local priority,normal={},{}
                for _,item in pairs(Cfg.SellerItems or {}) do
                    if item.Priority then table.insert(priority,item) else table.insert(normal,item) end
                end
                for _,item in ipairs(priority) do if not SellerRunning then break end; TryListItem(item.Name,item) end
                for _,item in ipairs(normal)   do if not SellerRunning then break end; TryListItem(item.Name,item) end
            else
                task.wait(5)
            end
            if Cfg.SwitchServers and Cfg.Delay and (os.time()-StartingTime)>=(Cfg.Delay*60) then
                GrabIDs(); Serverhop()
            end
            task.wait(1)
        end
    end)
end

-- ════════════════════════════════════════
--  AUTO-BUY ON ARRIVAL (Terminal teleport)
-- ════════════════════════════════════════
task.spawn(function()
    local pending = Cfg.PendingTerminalBuy
    if not pending then return end
    if pending.JobID and pending.JobID ~= game.JobId then
        Cfg.PendingTerminalBuy=nil; SaveCfg(); return
    end
    warn("[Plaza Plus Terminal]: Arrived! Auto-buying "..tostring(pending.Name).."...")
    SetStatus("Buying", pending.Name, C.Yellow)
    botStatus.Text="🛒 Buying "..pending.Name.."..."; botStatus.TextColor3=C.Yellow
    task.wait(4)
    local FindInfo=GenerateFindInfo(pending.Name,pending)
    if not FindInfo or not FindInfo.ID then Cfg.PendingTerminalBuy=nil; SaveCfg(); return end
    local priceVal=type(pending.Price)=="string" and RemoveSuffix(pending.Price) or pending.Price
    local bought=false
    for _,Users in next, Booths do
        if bought then break end
        for Username,Booth in next, Users do
            if bought then break end
            for BI,IV in next, Booth do
                if BI~="Listings" then continue end
                for ItemUID,ItemInfo in next, IV do
                    local ID=ItemInfo.Item._data; local cost=ItemInfo.DiamondCost
                    if not cost then continue end
                    local CI={UID=ItemUID,ID=ID.id,Class=ItemInfo.Item.Class.Name,
                        Rainbow=ItemInfo.Item.IsRainbow and ItemInfo.Item:IsRainbow(),
                        Golden=ItemInfo.Item.IsGolden and ItemInfo.Item:IsGolden(),
                        Shiny=ItemInfo.Item.IsShiny and ItemInfo.Item:IsShiny(),
                        Amount=ID["_am"] or 1,Tier=ID["tn"],Cost=cost,
                        RAP=(ItemInfo.Item.GetDevRAP and ItemInfo.Item:GetDevRAP()) or (ItemInfo.Item.GetRAP and ItemInfo.Item:GetRAP())}
                    if not ValidateItem(CI,FindInfo) then continue end
                    if cost>priceVal then warn("[Plaza Plus Terminal]: "..CI.ID.." too expensive ("..AddSuffix(cost).." > "..AddSuffix(priceVal)..")"); continue end
                    if GetDiamonds()<cost then continue end
                    if pending.InventoryLimit and (FindItem(FindInfo,true) or 0)>=pending.InventoryLimit then continue end
                    local canBuy=math.floor(GetDiamonds()/cost)
                    local buyAmt=math.min(CI.Amount,canBuy)
                    if buyAmt<=0 then continue end
                    warn("[Plaza Plus Terminal]: Buying ×"..buyAmt.." "..CI.ID.." for "..AddSuffix(cost).." each")
                    local BoothModel=BoothsInteractive and BoothsInteractive[Booth.BoothID]
                    if BoothModel then local Int=BoothModel:FindFirstChild("Interact"); if Int then HumanoidRootPart.CFrame=Int.CFrame*CFrame.new(0,-2,-6); task.wait(0.5) end end
                    local PlayerID=Booth.PlayerID or (Booth.Player and Booth.Player.UserId)
                    if not PlayerID then continue end
                    local Thing={Caller={LineNumber=532,ParameterCount=2,Variadic=false,Traceback="ReplicatedStorage.Library.Client.BoothCmds:532",ScriptPath="ReplicatedStorage.Library.Client.BoothCmds",ScriptClass="ModuleScript",FunctionName="PromptPurchase2",ScriptType="Instance",SourceIdentifier="ReplicatedStorage.Library.Client.BoothCmds"}}
                    local ok=Library.Network.Invoke("Booths_RequestPurchase",PlayerID,{[CI.UID]=buyAmt},Thing)
                    if ok then
                        warn("[Plaza Plus Terminal]: ✓ Bought ×"..buyAmt.." "..CI.ID)
                        SetStatus("Bought!", CI.ID.." ×"..buyAmt, C.Green)
                        botStatus.Text="✓ Bought "..CI.ID.." ×"..buyAmt; botStatus.TextColor3=C.Green
                        if CI.RAP then CI.Bought=buyAmt; CI.Display=CI.ID; CI.Rarity=ItemInfo.Item.GetRarity and ItemInfo.Item:GetRarity()._id; CI.Icon=ItemInfo.Item.GetIcon and ItemInfo.Item:GetIcon(); SniperWebhook(CI,CalcPercent(CI.RAP,cost)) end
                        bought=true; break
                    end
                end
            end
        end
    end
    if not bought then
        warn("[Plaza Plus Terminal]: Not found at right price — re-searching...")
        botStatus.Text="🔍 Re-searching..."; botStatus.TextColor3=C.Yellow
        task.wait(2)
        local FI2=GenerateFindInfo(pending.Name,pending)
        if FI2 and FI2.Class then
            local tc=({["Misc"]="Misc",["Items"]="Misc",["Pet"]="Pet",["Card"]="Card",["Potion"]="Potion",["Enchant"]="Enchant",["Ultimate"]="Ultimate",["Egg"]="Egg",["Hoverboard"]="Hoverboard",["Charm"]="Charm",["Box"]="Misc",["Lootbox"]="Misc",["Fruit"]="Misc"})[FI2.Class] or FI2.Class
            local Enc=FI2.Tier and '{"id":"'..FI2.ID..'","tn":'..FI2.Tier..'}' or '{"id":"'..FI2.ID..'"}'
            local FS; pcall(function() FS=game.ReplicatedStorage.Network.TradingTerminal_Search:InvokeServer(tc,Enc,nil,false) end)
            if type(FS)=="table" and FS["place_id"] and FS["job_id"] and FS["job_id"]~=game.JobId then
                Cfg.PendingTerminalBuy={Name=pending.Name,Price=pending.Price,InventoryLimit=pending.InventoryLimit,JobID=FS["job_id"]}
                SaveCfg(); DisableAntiScam()
                pcall(function() TeleportService:TeleportToPlaceInstance(FS["place_id"],FS["job_id"],LocalPlayer) end)
                return
            end
        end
        botStatus.Text="⚠ No cheaper listing found"; botStatus.TextColor3=C.Red
    end
    Cfg.PendingTerminalBuy=nil; SaveCfg()
end)

-- ════════════════════════════════════════
--  LAUNCH / STOP
-- ════════════════════════════════════════
StartBtn.MouseButton1Click:Connect(function()
    if IsRunning then return end
    local mode=Cfg.Mode or "Seller"
    local sellerItems=Cfg.SellerItems or {}
    if (mode=="Seller" or mode=="Both") and #sellerItems==0 then
        botStatus.TextColor3=C.Red; botStatus.Text="⚠ Add items to sell first!"
        task.delay(3,function() botStatus.TextColor3=C.Sub; botStatus.Text="Configure items then press Start" end); return
    end
    IsRunning=true
    Tw(StartBtn,{BackgroundColor3=C.GreenD})
    SetStatus("Starting...", mode.." mode", C.Yellow)
    botStatus.TextColor3=C.Green; botStatus.Text="⏳ Starting "..mode.."..."
    if mode=="Seller" or mode=="Both" then task.spawn(RunSeller) end
    if Cfg.SwitchServers then task.spawn(function() GrabIDs() end) end
end)

StopBtn.MouseButton1Click:Connect(function()
    IsRunning=false; SellerRunning=false; SniperRunning=false
    if SellerThread then pcall(function() task.cancel(SellerThread) end) end
    Tw(StartBtn,{BackgroundColor3=C.Green})
    SetStatus("Idle","Press Start to begin",C.Sub)
    botStatus.TextColor3=C.Sub; botStatus.Text="Stopped."
    warn("[Plaza Plus]: Stopped by user.")
end)

-- ════════════════════════════════════════
--  DRAG + HOTKEY
-- ════════════════════════════════════════
do
    local drag,ds,sp=false,nil,nil
    local DragZone=MkFrame(Win,UDim2.new(1,-200,0,56),UDim2.new(0,200,0,0),C.BG,0)
    DragZone.BackgroundTransparency=1
    DragZone.ZIndex=10
    local db=Instance.new("TextButton");db.Size=UDim2.new(1,0,1,0);db.BackgroundTransparency=1;db.Text="";db.ZIndex=10;db.Parent=DragZone
    db.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=Win.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds; Win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end
UserInputService.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.RightShift then Win.Visible=not Win.Visible end end)

-- Set default page
SetPage(SellerPage, navSeller)

if not table.find({PS99.Normal,PS99.Pro,PETSGO.Normal,PETSGO.Pro},game.PlaceId) then
    SetStatus("Wrong Game","Go to PS99 Trading Plaza",C.Red)
    botStatus.TextColor3=C.Red; botStatus.Text="⚠ Wrong game — join PS99 Trading Plaza"
end

print("[Plaza Plus]: Ready! Press RightShift to toggle.")
