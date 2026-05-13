-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
-- â•‘        PLAZA PLUS â€” GUI EDITION          â•‘
-- â•‘   Full seller + sniper with in-game UI   â•‘
-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  KEY AUTHENTICATION (KeyAuth)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
    -- No key set â€” show key input GUI then halt
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
                statusL.TextColor3=Color3.fromRGB(52,211,153); statusL.Text="OK: "..msg
                authBtn.Text="Authenticated!"
                authBtn.BackgroundColor3=Color3.fromRGB(30,140,90)
                getgenv().script_key = key
                task.wait(1)
                KeyGui:Destroy()
                -- Continue loading the main script
                loadstring(game:HttpGet(getgenv()._PlazaPlusURL or ""))()
            else
                statusL.TextColor3=Color3.fromRGB(239,68,68); statusL.Text="Error: "..msg
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
        local el=Instance.new("TextLabel"); el.Text="PLAZA PLUS - AUTH FAILED\n\n"..msg; el.TextSize=13; el.Font=Enum.Font.GothamBold; el.TextColor3=Color3.fromRGB(239,68,68); el.BackgroundTransparency=1; el.Size=UDim2.new(1,-20,1,0); el.Position=UDim2.new(0,10,0,0); el.TextXAlignment=Enum.TextXAlignment.Center; el.TextWrapped=true; el.Parent=eb
        task.delay(5, function() eg:Destroy() end)
        warn("[Plaza Plus]: Auth failed - "..msg)
        return
    end
    warn("[Plaza Plus]: Authenticated successfully")
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
        statusL.TextColor3 = C.Green; statusL.Text = "Added: " .. displayKey
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
local PlayerScripts = LocalPlayer.PlayerScripts.Scripts

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  GAME LIBRARIES
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  FILE PERSISTENCE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  HELPERS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  ITEM LIST BUILD
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  CORE LOGIC FUNCTIONS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  SERVER HOP
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  WEBHOOK
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
            footer = {text = "@"..LocalPlayer.Name.." Â· Plaza Plus", icon_url = "https://i.gyazo.com/784ff41bd2b15e0046c8b621fab31990.png"},
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
            footer = {text = "@"..LocalPlayer.Name.." Â· Plaza Plus", icon_url = "https://i.gyazo.com/784ff41bd2b15e0046c8b621fab31990.png"},
            timestamp = DateTime.now():ToIsoDate(),
        }}
    })
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  MAILBOX LOOP
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
task.spawn(function()
    while task.wait(30) do
        pcall(function() Library.Network.Invoke("Mailbox: Claim All") end)
    end
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  GUI SYSTEM (Redesigned from preview.webp)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
if CoreGui:FindFirstChild("PlazaPlusGUI") then CoreGui:FindFirstChild("PlazaPlusGUI"):Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlazaPlusGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local C = {
    BG       = Color3.fromRGB(7, 8, 12),
    Panel    = Color3.fromRGB(15, 16, 23),
    Sidebar  = Color3.fromRGB(10, 11, 16),
    Header   = Color3.fromRGB(9, 10, 15),
    Accent   = Color3.fromRGB(99, 102, 241),
    Accent2  = Color3.fromRGB(34, 197, 184),
    Border   = Color3.fromRGB(34, 36, 48),
    Text     = Color3.fromRGB(238, 241, 248),
    Sub      = Color3.fromRGB(135, 143, 162),
    Card     = Color3.fromRGB(19, 21, 30),
    InputBG  = Color3.fromRGB(20, 22, 31),
    Green    = Color3.fromRGB(52, 211, 153),
    Red      = Color3.fromRGB(248, 113, 113),
    Yellow   = Color3.fromRGB(251, 191, 36),
}

local function Corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function Stroke(p, col, t) local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = t or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function Tw(obj, props, t) TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad), props):Play() end

local function Frame(p, size, pos, col, r)
    local f = Instance.new("Frame"); f.Size = size; f.Position = pos; f.BackgroundColor3 = col; f.BorderSizePixel = 0; f.Parent = p
    if r then Corner(f, r) end; return f
end

local function Label(p, txt, size, col, font, align)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = txt; l.TextSize = size; l.TextColor3 = col; l.Font = font or Enum.Font.Gotham; l.TextXAlignment = align or Enum.TextXAlignment.Left; l.Parent = p; return l
end

local function Btn(p, txt, size, pos, col, textCol)
    local b = Instance.new("TextButton"); b.Size = size; b.Position = pos; b.BackgroundColor3 = col; b.Text = txt; b.TextSize = 12; b.TextColor3 = textCol or C.Text; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Parent = p
    Corner(b, 7); b.MouseEnter:Connect(function() Tw(b, { BackgroundTransparency = 0.08 }) end); b.MouseLeave:Connect(function() Tw(b, { BackgroundTransparency = 0 }) end)
    return b
end

local function Input(p, placeholder, size, pos)
    local i = Instance.new("TextBox"); i.Size = size; i.Position = pos; i.BackgroundColor3 = C.InputBG; i.PlaceholderText = placeholder; i.Text = ""; i.TextSize = 12; i.TextColor3 = C.Text; i.PlaceholderColor3 = C.Sub; i.Font = Enum.Font.Gotham; i.BorderSizePixel = 0; i.ClearTextOnFocus = false; i.Parent = p
    Corner(i, 6)
    local s = Stroke(i, C.Border, 1)
    i.Focused:Connect(function() Tw(s, { Color = C.Accent }) end)
    i.FocusLost:Connect(function() Tw(s, { Color = C.Border }) end)
    return i
end

local function Toggle(p, pos, default)
    local tBase = Frame(p, UDim2.new(0, 38, 0, 20), pos, Color3.fromRGB(30, 30, 44), 10)
    local tDot  = Frame(tBase, UDim2.new(0, 14, 0, 14), UDim2.new(0, 3, 0.5, -7), C.Sub, 7)
    local active = default or false
    local function Update()
        Tw(tBase, { BackgroundColor3 = active and C.Accent or Color3.fromRGB(30, 30, 44) })
        Tw(tDot,  { Position = active and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = active and C.Text or C.Sub })
    end
    Update()
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = tBase
    local callbacks = {}
    btn.MouseButton1Click:Connect(function() active = not active; Update(); for _, cb in pairs(callbacks) do cb(active) end end)
    return tBase, function() return active end, function(cb) table.insert(callbacks, cb) end, function(v) active = v; Update() end
end

local function ItemCard(p, name, price, extra, onDel)
    local card = Frame(p, UDim2.new(1, -10, 0, 44), UDim2.new(0, 5, 0, 0), C.Card, 8)
    Stroke(card, C.Border, 1)
    local nL = Label(card, name, 12, C.Text, Enum.Font.GothamBold); nL.Position = UDim2.new(0, 12, 0, -8)
    local priceText = type(price) == "number" and AddSuffix(price) or tostring(price)
    local pL = Label(card, priceText, 11, C.Accent, Enum.Font.Gotham); pL.Position = UDim2.new(0, 12, 0, 10)
    if extra then local eL = Label(card, extra, 10, C.Sub); eL.Position = UDim2.new(0, 80, 0, 10) end
    local del = Btn(card, "X", UDim2.new(0, 24, 0, 24), UDim2.new(1, -32, 0.5, -12), Color3.fromRGB(40, 20, 20), C.Red)
    del.MouseButton1Click:Connect(function() card:Destroy(); onDel() end)
    return card
end

-- â”€â”€ MAIN WINDOW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Win = Frame(ScreenGui, UDim2.new(0, 720, 0, 480), UDim2.new(0.5, -360, 0.5, -240), C.BG, 14)
Stroke(Win, C.Border, 2)
Win.ClipsDescendants = true
local winGrad = Instance.new("UIGradient")
winGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 13, 19)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(7, 8, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 4, 7)),
})
winGrad.Rotation = 135
winGrad.Parent = Win

-- â”€â”€ SIDEBAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Side = Frame(Win, UDim2.new(0, 180, 1, 0), UDim2.new(0, 0, 0, 0), C.Sidebar, 0)
Corner(Side, 14); Frame(Side, UDim2.new(0, 20, 1, 0), UDim2.new(1, -20, 0, 0), C.Sidebar, 0) -- fix corners
local Logo = Frame(Side, UDim2.new(1, 0, 0, 38), UDim2.new(0, 0, 0, 0), C.Sidebar, 0)
Label(Logo, "PLAZA PLUS", 15, C.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)

local Profile = Frame(Side, UDim2.new(1, -24, 0, 94), UDim2.new(0, 12, 0, 46), C.Sidebar, 8)
Profile.BackgroundTransparency = 0.35
Stroke(Profile, C.Border, 1)
local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 48, 0, 48)
Avatar.Position = UDim2.new(0, 10, 0, 10)
Avatar.BackgroundColor3 = C.Card
Avatar.BorderSizePixel = 0
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Avatar.Parent = Profile
Corner(Avatar, 24)
Stroke(Avatar, C.Accent2, 1)
local ProfileName = Label(Profile, LocalPlayer.DisplayName, 13, C.Text, Enum.Font.GothamBold)
ProfileName.Position = UDim2.new(0, 68, 0, 14); ProfileName.Size = UDim2.new(1, -76, 0, 18); ProfileName.TextTruncate = Enum.TextTruncate.AtEnd
local ProfileRole = Label(Profile, "Guest", 10, C.Sub, Enum.Font.Gotham)
ProfileRole.Position = UDim2.new(0, 68, 0, 33); ProfileRole.Size = UDim2.new(1, -76, 0, 14)
local ProfileId = Label(Profile, tostring(LocalPlayer.UserId), 10, C.Sub, Enum.Font.Gotham)
ProfileId.Position = UDim2.new(0, 68, 0, 49); ProfileId.Size = UDim2.new(1, -76, 0, 14)

local Nav = Frame(Side, UDim2.new(1, 0, 1, -152), UDim2.new(0, 0, 0, 150), C.Sidebar, 0)
local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 4); navLayout.Parent = Nav
local navPad = Instance.new("UIPadding")
navPad.PaddingLeft = UDim.new(0, 12)
navPad.PaddingRight = UDim.new(0, 12)
navPad.Parent = Nav

local Tabs = {}
local function NavBtn(txt, icon, panel)
    local b = Btn(Nav, "  " .. icon .. "   " .. txt, UDim2.new(1, 0, 0, 38), UDim2.new(0, 0, 0, 0), Color3.fromRGB(0,0,0), C.Sub)
    b.BackgroundTransparency = 1; b.TextXAlignment = Enum.TextXAlignment.Left
    Tabs[txt] = { Btn = b, Panel = panel }
    return b
end

-- â”€â”€ PANELS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Content = Frame(Win, UDim2.new(1, -195, 1, -75), UDim2.new(0, 188, 0, 65), C.BG, 0)
local DashPanel = Frame(Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.BG, 0)
local SellPanel = Frame(Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.BG, 0); SellPanel.Visible = false
local SniPanel  = Frame(Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.BG, 0); SniPanel.Visible = false
local CfgPanel  = Frame(Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.BG, 0); CfgPanel.Visible = false
local LogPanel  = Frame(Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.BG, 0); LogPanel.Visible = false

local function SwitchTab(name)
    for k, v in pairs(Tabs) do
        local active = (k == name)
        Tw(v.Btn, { BackgroundColor3 = active and C.Accent or Color3.fromRGB(0,0,0), BackgroundTransparency = active and 0 or 1, TextColor3 = active and C.Text or C.Sub })
        v.Panel.Visible = active
    end
end

NavBtn("Dashboard", "*", DashPanel).MouseButton1Click:Connect(function() SwitchTab("Dashboard") end)
NavBtn("Seller",    "$", SellPanel).MouseButton1Click:Connect(function() SwitchTab("Seller") end)
NavBtn("Sniper",    "#", SniPanel).MouseButton1Click:Connect(function() SwitchTab("Sniper") end)
NavBtn("Settings",  "@", CfgPanel).MouseButton1Click:Connect(function() SwitchTab("Settings") end)
NavBtn("Logs",      ">", LogPanel).MouseButton1Click:Connect(function() SwitchTab("Logs") end)
SwitchTab("Dashboard")

-- â”€â”€ HEADER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Header = Frame(Win, UDim2.new(1, -195, 0, 60), UDim2.new(0, 188, 0, 0), C.BG, 0)
Header.BackgroundTransparency = 0.18
local menuGlyph = Label(Header, "=", 20, C.Sub, Enum.Font.GothamBold)
menuGlyph.Position = UDim2.new(0, 2, 0, 0); menuGlyph.Size = UDim2.new(0, 28, 1, 0)
local hTitle = Label(Header, "Dashboard", 18, C.Text, Enum.Font.GothamBold)
hTitle.Position = UDim2.new(0, 34, 0, 0); hTitle.Size = UDim2.new(0, 230, 1, 0)
local function UpdateHeader(t) hTitle.Text = t end
for k, v in pairs(Tabs) do v.Btn.MouseButton1Click:Connect(function() UpdateHeader(k) end) end

local SearchBtn = Btn(Header, "?", UDim2.new(0, 30, 0, 30), UDim2.new(1, -110, 0, 15), C.Panel, C.Sub)
local CloseBtn = Btn(Header, "X", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 15), Color3.fromRGB(40, 20, 20), C.Red)
local MinBtn   = Btn(Header, "-", UDim2.new(0, 30, 0, 30), UDim2.new(1, -75, 0, 15), C.Panel, C.Sub)

-- â”€â”€ DASHBOARD PANEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
do
    local statGrid = Frame(DashPanel, UDim2.new(1, 0, 0, 100), UDim2.new(0, 0, 0, 0), C.BG, 0)
    local function Stat(txt, val, pos, col)
        local f = Frame(statGrid, UDim2.new(0.32, -5, 1, 0), pos, C.Panel, 12); Stroke(f, C.Border, 1)
        Label(f, txt, 11, C.Sub).Position = UDim2.new(0, 15, 0, -25)
        local vL = Label(f, val, 20, col or C.Text, Enum.Font.GothamBold); vL.Position = UDim2.new(0, 15, 0, 5)
        return vL
    end
    local sDiamonds = Stat("Total Gained", "0", UDim2.new(0, 0, 0, 0), C.Green)
    local sSnipes   = Stat("Items Sniped", "0", UDim2.new(0.34, 0, 0, 0), C.Yellow)
    local sSales    = Stat("Items Sold",   "0", UDim2.new(0.68, 0, 0, 0), C.Accent)

    local feedFrame = Frame(DashPanel, UDim2.new(1, 0, 1, -115), UDim2.new(0, 0, 0, 115), C.Panel, 12); Stroke(feedFrame, C.Border, 1)
    Label(feedFrame, "ACTIVITY FEED", 11, C.Sub, Enum.Font.GothamBold).Position = UDim2.new(0, 15, 0, 12)
    local feedScroll = Instance.new("ScrollingFrame"); feedScroll.Size = UDim2.new(1, -20, 1, -45); feedScroll.Position = UDim2.new(0, 10, 0, 35); feedScroll.BackgroundTransparency = 1; feedScroll.BorderSizePixel = 0; feedScroll.ScrollBarThickness = 2; feedScroll.ScrollBarImageColor3 = C.Accent; feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0); feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; feedScroll.Parent = feedFrame
    local feedLayout = Instance.new("UIListLayout"); feedLayout.Padding = UDim.new(0, 6); feedLayout.Parent = feedScroll

    function AddLog(txt, col)
        local l = Frame(feedScroll, UDim2.new(1, -5, 0, 22), UDim2.new(0, 0, 0, 0), Color3.fromRGB(0,0,0), 0); l.BackgroundTransparency = 1
        local tL = Label(l, "[" .. os.date("%X") .. "] " .. txt, 11, col or C.Sub); tL.Parent = l
        if #feedScroll:GetChildren() > 50 then feedScroll:GetChildren()[2]:Destroy() end
        -- Sync to logs tab too
    end
    AddLog("Plaza Plus interface loaded.", C.Green)
end

-- â”€â”€ SELLER PANEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
do
    local SLeft = Frame(SellPanel, UDim2.new(0.55, -10, 1, 0), UDim2.new(0, 0, 0, 0), C.Panel, 12)
    local SRight = Frame(SellPanel, UDim2.new(0.45, -10, 1, 0), UDim2.new(0.55, 10, 0, 0), C.Panel, 12)
    Stroke(SLeft, C.Border, 1); Stroke(SRight, C.Border, 1)

    local bh = Frame(SLeft, UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 8), C.Panel, 0); bh.BackgroundTransparency = 1
    Label(bh, "Current Seller Items", 11, C.Sub, Enum.Font.GothamBold)
    local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -20, 1, -45); scroll.Position = UDim2.new(0, 10, 0, 35); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = C.Accent; scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = SLeft
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 4); layout.Parent = scroll

    local SellerItemData = {}
    for _, item in pairs(Cfg.SellerItems or {}) do
        SellerItemData[item._displayKey or item.Name] = item
        ItemCard(scroll, item._displayKey or item.Name, item.Price, (item.Amount and "x"..item.Amount or "xmax"), function()
            SellerItemData[item._displayKey or item.Name] = nil
            local t = {}; for _, v in pairs(SellerItemData) do table.insert(t, v) end; Cfg.SellerItems = t; SaveCfg()
        end)
    end

    local function FLabel(p, txt, y) local f = Frame(p, UDim2.new(1, -20, 0, 14), UDim2.new(0, 10, 0, y), C.Panel, 0); f.BackgroundTransparency = 1; Label(f, txt, 10, C.Sub, Enum.Font.Gotham); return f end
    FLabel(SRight, "Item Name (e.g. Gem)", 5)
    local nameIn = Input(SRight, "e.g. Gem", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 22))
    FLabel(SRight, "Price (e.g. 500 or 1.5m)", 60)
    local priceIn = Input(SRight, "e.g. 1.5m", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 77))
    FLabel(SRight, "Amount (leave blank for all)", 115)
    local amtIn = Input(SRight, "e.g. 50", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 132))
    FLabel(SRight, "Class (optional)", 170)
    local clsIn = Input(SRight, "e.g. Misc", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 187))

    local toggles = Frame(SRight, UDim2.new(1, -20, 0, 150), UDim2.new(0, 10, 0, 225), C.Panel, 0); toggles.BackgroundTransparency = 1
    local function TRow(p, txt, y, def)
        local r = Frame(p, UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, y), C.Panel, 0); r.BackgroundTransparency = 1
        Label(r, txt, 11, C.Text)
        return Toggle(r, UDim2.new(1, -42, 0.5, -10), def)
    end
    local _, getShiny,   _, setShiny   = TRow(toggles, "Shiny",   0,  false)
    local _, getRainbow, _, setRainbow = TRow(toggles, "Rainbow", 28, false)
    local _, getGolden,  _, setGolden  = TRow(toggles, "Golden",  56, false)
    local _, getAll,     _, setAll     = TRow(toggles, "All Types", 84, false)

    local addBtn = Btn(SRight, "+ Add Item", UDim2.new(1, -20, 0, 34), UDim2.new(0, 10, 0, 380), C.Accent)
    local statusL = Label(SRight, "", 11, C.Green, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    statusL.Size = UDim2.new(1, -20, 0, 18); statusL.Position = UDim2.new(0, 10, 0, 420)

    local function DoAddItem(name, price, amt, cls, tier, rainbow, golden, shiny, allTypes)
        if name == "" or price == "" then statusL.TextColor3 = C.Red; statusL.Text = "Name and price required"; task.delay(2, function() statusL.Text = "" end); return end
        local typePrefix = (shiny and "Shiny " or "") .. (rainbow and "Rainbow " or "") .. (golden and "Golden " or "")
        local displayKey = typePrefix .. name .. (tier and " T" .. tier or "")
        if SellerItemData[displayKey] then statusL.TextColor3 = C.Red; statusL.Text = "Already in list"; task.delay(2, function() statusL.Text = "" end); return end
        local priceVal = tonumber(price) or price
        local item = { Name = name, Price = priceVal, Amount = amt, Class = cls, Tier = tier, Rainbow = rainbow, Golden = golden, Shiny = shiny, AllTypes = allTypes, _displayKey = displayKey }
        SellerItemData[displayKey] = item
        local ext = (amt and "x" .. amt or "xmax") .. (cls and " - " .. cls or "") .. (tier and " T" .. tier or "")
        ItemCard(scroll, displayKey, priceVal, ext, function()
            SellerItemData[displayKey] = nil
            local t = {}; for _, v in pairs(SellerItemData) do table.insert(t, v) end; Cfg.SellerItems = t; SaveCfg()
        end)
        statusL.TextColor3 = C.Green; statusL.Text = "Added: " .. displayKey
        task.delay(2, function() statusL.Text = "" end)
        local t = {}; for _, v in pairs(SellerItemData) do table.insert(t, v) end; Cfg.SellerItems = t; SaveCfg()
        AddLog("Added " .. displayKey .. " to seller list.", C.Green)
    end

    addBtn.MouseButton1Click:Connect(function()
        DoAddItem(nameIn.Text, priceIn.Text, tonumber(amtIn.Text), clsIn.Text ~= "" and clsIn.Text or nil, nil, getRainbow(), getGolden(), getShiny(), getAll())
        nameIn.Text = ""; priceIn.Text = ""; amtIn.Text = ""; clsIn.Text = ""; setShiny(false); setRainbow(false); setGolden(false); setAll(false)
    end)
end

-- â”€â”€ SNIPER PANEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
do
    local SNLeft = Frame(SniPanel, UDim2.new(0.55, -10, 1, 0), UDim2.new(0, 0, 0, 0), C.Panel, 12)
    local SNRight = Frame(SniPanel, UDim2.new(0.45, -10, 1, 0), UDim2.new(0.55, 10, 0, 0), C.Panel, 12)
    Stroke(SNLeft, C.Border, 1); Stroke(SNRight, C.Border, 1)

    local subTabBar = Frame(SNRight, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 8), Color3.fromRGB(20, 20, 32), 8)
    local function SubTab(txt, xOff, active)
        local t = Instance.new("TextButton"); t.Size = UDim2.new(0.5, -3, 1, -6); t.Position = UDim2.new(xOff, 2, 0, 3)
        t.BackgroundColor3 = active and C.Accent or Color3.fromRGB(28, 28, 44); t.TextColor3 = active and C.Text or C.Sub
        t.Text = txt; t.TextSize = 11; t.Font = Enum.Font.GothamBold; t.BorderSizePixel = 0; t.AutoButtonColor = false; t.Parent = subTabBar
        Corner(t, 6); return t
    end
    local boothSubTab = SubTab("Booth", 0, true)
    local termSubTab  = SubTab("Terminal", 0.5, false)

    local boothForm = Frame(SNRight, UDim2.new(1, 0, 1, -45), UDim2.new(0, 0, 0, 45), C.Panel, 0); boothForm.BackgroundTransparency = 1
    local termForm  = Frame(SNRight, UDim2.new(1, 0, 1, -45), UDim2.new(0, 0, 0, 45), C.Panel, 0); termForm.BackgroundTransparency = 1; termForm.Visible = false

    boothSubTab.MouseButton1Click:Connect(function()
        boothForm.Visible = true; termForm.Visible = false
        Tw(boothSubTab, { BackgroundColor3 = C.Accent, TextColor3 = C.Text })
        Tw(termSubTab,  { BackgroundColor3 = Color3.fromRGB(28, 28, 44), TextColor3 = C.Sub })
    end)
    termSubTab.MouseButton1Click:Connect(function()
        boothForm.Visible = false; termForm.Visible = true
        Tw(termSubTab,  { BackgroundColor3 = C.Accent, TextColor3 = C.Text })
        Tw(boothSubTab, { BackgroundColor3 = Color3.fromRGB(28, 28, 44), TextColor3 = C.Sub })
    end)

    local bh = Frame(SNLeft, UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 8), C.Panel, 0); bh.BackgroundTransparency = 1
    Label(bh, "Booth Targets", 11, C.Sub, Enum.Font.GothamBold)
    local bScroll = Instance.new("ScrollingFrame"); bScroll.Size = UDim2.new(1, -20, 0.48, -25); bScroll.Position = UDim2.new(0, 10, 0, 30); bScroll.BackgroundTransparency = 1; bScroll.BorderSizePixel = 0; bScroll.ScrollBarThickness = 3; bScroll.ScrollBarImageColor3 = C.Accent; bScroll.CanvasSize = UDim2.new(0, 0, 0, 0); bScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; bScroll.Parent = SNLeft
    local bLayout = Instance.new("UIListLayout"); bLayout.Padding = UDim.new(0, 4); bLayout.Parent = bScroll

    local th = Frame(SNLeft, UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0.5, 6), C.Panel, 0); th.BackgroundTransparency = 1
    Label(th, "Terminal Targets", 11, C.Sub, Enum.Font.GothamBold)
    local tScroll = Instance.new("ScrollingFrame"); tScroll.Size = UDim2.new(1, -20, 0.48, -25); tScroll.Position = UDim2.new(0, 10, 0.5, 26); tScroll.BackgroundTransparency = 1; tScroll.BorderSizePixel = 0; tScroll.ScrollBarThickness = 3; tScroll.ScrollBarImageColor3 = C.Yellow; tScroll.CanvasSize = UDim2.new(0, 0, 0, 0); tScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; tScroll.Parent = SNLeft
    local tLayout = Instance.new("UIListLayout"); tLayout.Padding = UDim.new(0, 4); tLayout.Parent = tScroll

    Frame(SNLeft, UDim2.new(1, -20, 0, 1), UDim2.new(0, 10, 0.5, 2), C.Border, 0)

    local SniperItemData = {}
    local TerminalItemData = {}
    for _, item in pairs(Cfg.SniperItems or {}) do
        SniperItemData[item.Name] = item
        ItemCard(bScroll, item.Name, item.Price, (item.InventoryLimit and "limit:"..item.InventoryLimit or ""), function()
            SniperItemData[item.Name] = nil
            local t = {}; for _, v in pairs(SniperItemData) do table.insert(t, v) end; Cfg.SniperItems = t; SaveCfg()
        end)
    end
    for _, item in pairs(Cfg.TerminalItems or {}) do
        TerminalItemData[item.Name] = item
        ItemCard(tScroll, item.Name, item.Price, (item.Class or ""), function()
            TerminalItemData[item.Name] = nil
            local t = {}; for _, v in pairs(TerminalItemData) do table.insert(t, v) end; Cfg.TerminalItems = t; SaveCfg()
        end)
    end

    local function FLabel(p, txt, y) local f = Frame(p, UDim2.new(1, -20, 0, 14), UDim2.new(0, 10, 0, y), C.Panel, 0); f.BackgroundTransparency = 1; Label(f, txt, 10, C.Sub, Enum.Font.Gotham); return f end
    FLabel(boothForm, "Item Name (e.g. All Huges)", 5)
    local sNameIn = Input(boothForm, "e.g. All Huges", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 22))
    FLabel(boothForm, "Max Price (flat or %)", 60)
    local sPriceIn = Input(boothForm, "e.g. 15m or 50%", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 77))
    FLabel(boothForm, "Inventory Limit", 115)
    local sLimitIn = Input(boothForm, "e.g. 100", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 132))
    local _, getAllTypes, _, setAllTypes = Toggle(boothForm, UDim2.new(1, -42, 0, 172), false)
    Label(boothForm, "All Types", 11, C.Text).Position = UDim2.new(0, 10, 0, 172)
    local sAddBtn = Btn(boothForm, "+ Add Booth Target", UDim2.new(1, -20, 0, 34), UDim2.new(0, 10, 0, 210), C.Accent)

    sAddBtn.MouseButton1Click:Connect(function()
        local name, price = sNameIn.Text:match("^%s*(.-)%s*$"), sPriceIn.Text:match("^%s*(.-)%s*$")
        if name == "" or price == "" then return end
        local priceVal = tonumber(price) or price
        local limit = tonumber(sLimitIn.Text)
        local item = { Name = name, Price = priceVal, InventoryLimit = limit, AllTypes = getAllTypes() }
        SniperItemData[name] = item
        ItemCard(bScroll, name, priceVal, (limit and "limit:"..limit or ""), function()
            SniperItemData[name] = nil
            local t = {}; for _, v in pairs(SniperItemData) do table.insert(t, v) end; Cfg.SniperItems = t; SaveCfg()
        end)
        sNameIn.Text = ""; sPriceIn.Text = ""; sLimitIn.Text = ""; setAllTypes(false); SaveCfg(); AddLog("Added sniper target: "..name, C.Yellow)
    end)

    FLabel(termForm, "Item Name", 5)
    local tNameIn = Input(termForm, "e.g. Huge Night Terror Cat", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 22))
    FLabel(termForm, "Max Price", 60)
    local tPriceIn = Input(termForm, "e.g. 15m or 50%", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 77))
    FLabel(termForm, "Class (Pet, Misc...)", 115)
    local tClassIn = Input(termForm, "e.g. Pet", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 132))
    local _, getCosmicVal, _, setCosmicVal = Toggle(termForm, UDim2.new(1, -42, 0, 172), false)
    Label(termForm, "Use Cosmic Values", 11, C.Text).Position = UDim2.new(0, 10, 0, 172)
    local tAddBtn = Btn(termForm, "+ Add Terminal Target", UDim2.new(1, -20, 0, 34), UDim2.new(0, 10, 0, 210), C.Yellow, Color3.fromRGB(40, 30, 10))

    tAddBtn.MouseButton1Click:Connect(function()
        local name, price = tNameIn.Text:match("^%s*(.-)%s*$"), tPriceIn.Text:match("^%s*(.-)%s*$")
        if name == "" or price == "" then return end
        local item = { Name = name, Price = tonumber(price) or price, Class = tClassIn.Text ~= "" and tClassIn.Text or nil, UseCosmicValues = getCosmicVal() }
        TerminalItemData[name] = item
        ItemCard(tScroll, name, item.Price, item.Class or "", function()
            TerminalItemData[name] = nil
            local t = {}; for _, v in pairs(TerminalItemData) do table.insert(t, v) end; Cfg.TerminalItems = t; SaveCfg()
        end)
        tNameIn.Text = ""; tPriceIn.Text = ""; tClassIn.Text = ""; setCosmicVal(false); SaveCfg(); AddLog("Added terminal target: "..name, C.Yellow)
    end)
end

-- â”€â”€ SETTINGS PANEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
do
    local sf = Frame(CfgPanel, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), C.Panel, 12); Stroke(sf, C.Border, 1)
    local function Row(label, y)
        local r = Frame(sf, UDim2.new(1, -24, 0, 42), UDim2.new(0, 12, 0, y), C.Card, 10); Stroke(r, C.Border, 1)
        Label(r, label, 13, C.Text, Enum.Font.GothamBold).Position = UDim2.new(0, 15, 0, 0)
        return r
    end
    Label(sf, "GENERAL SETTINGS", 11, C.Sub, Enum.Font.GothamBold).Position = UDim2.new(0, 12, 0, 12)
    
    local modeRow = Row("Bot Mode", 35)
    local modeOpt = {"Seller", "Sniper", "Both"}
    local modeIdx = table.find(modeOpt, Cfg.Mode) or 1
    local modeBtn = Btn(modeRow, modeOpt[modeIdx], UDim2.new(0, 100, 0, 30), UDim2.new(1, -110, 0.5, -15), C.Accent)
    modeBtn.MouseButton1Click:Connect(function()
        modeIdx = modeIdx % #modeOpt + 1; modeBtn.Text = modeOpt[modeIdx]; Cfg.Mode = modeOpt[modeIdx]; SaveCfg()
    end)

    local ssRow = Row("Server Hop", 85)
    local _, getSS, onSS, setSS = Toggle(ssRow, UDim2.new(1, -55, 0.5, -11), Cfg.SwitchServers)
    onSS(function(v) Cfg.SwitchServers = v; SaveCfg() end)

    local whRow = Row("Discord Webhook", 135)
    local whIn = Input(whRow, "Webhook URL", UDim2.new(1, -140, 0, 28), UDim2.new(0, 130, 0.5, -14))
    whIn.Text = Cfg.WebhookURL or ""; whIn.FocusLost:Connect(function() Cfg.WebhookURL = whIn.Text; SaveCfg() end)

    local launchBtn = Btn(sf, "> START SCRIPT", UDim2.new(1, -24, 0, 45), UDim2.new(0, 12, 1, -110), C.Green, Color3.fromRGB(10, 40, 20))
    local stopBtn   = Btn(sf, "[] STOP SCRIPT",  UDim2.new(1, -24, 0, 45), UDim2.new(0, 12, 1, -55),  Color3.fromRGB(60, 20, 20), C.Red)
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
