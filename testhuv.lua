-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
-- â•‘        PLAZA PLUS â€” GUI EDITION          â•‘
-- â•‘   Full seller + sniper with in-game UI   â•‘
-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

print("[Plaza Plus]: Script executed.")
local timer = tick()
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
end)

local PS99  = {Pro = 15588442388,    Normal = 15502339080}
local PETSGO = {Pro = 133783083257328, Normal = 19006211286}

local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService     = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)
if not CoreGui then CoreGui = Players.LocalPlayer:WaitForChild("PlayerGui") end

print("[Plaza Plus]: Initializing...")
local get_genv = getgenv or function() return _G end
local LocalPlayer = Players.LocalPlayer
local loadTimeout = os.time() + 15
repeat task.wait()
    LocalPlayer = Players.LocalPlayer
until (LocalPlayer and LocalPlayer.GetAttribute and LocalPlayer:GetAttribute("__LOADED")) or os.time() > loadTimeout

if not LocalPlayer.Character then 
    local ct = os.time()
    repeat task.wait() until LocalPlayer.Character or os.time() > ct + 5
end
local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("HumanoidRootPart", 5)

local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
if PlayerScripts then
    PlayerScripts = PlayerScripts:WaitForChild("Scripts", 5) or PlayerScripts
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  GAME LIBRARIES
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local NLibrary      = ReplicatedStorage:WaitForChild("Library", 5)
local PlayerSave, TradingPlazaCmds, Mailbox, Rarities
local Constants, UpgradeCmds, Variables
local CanUsePro = false

if NLibrary then
    local client = NLibrary:FindFirstChild("Client")
    local types = NLibrary:FindFirstChild("Types")
    local dir = NLibrary:FindFirstChild("Directory")
    local bal = NLibrary:FindFirstChild("Balancing")
    local shared = NLibrary:FindFirstChild("Shared")

    PlayerSave    = client and client:FindFirstChild("Save") and require(client.Save) or nil
    TradingPlazaCmds = client and client:FindFirstChild("TradingPlazaCmds") and require(client.TradingPlazaCmds) or nil
    Mailbox       = types and types:FindFirstChild("Mailbox") and require(types.Mailbox) or nil
    Rarities      = dir and dir:FindFirstChild("Rarity") and table.clone(require(dir.Rarity)) or {}

    if table.find({PS99.Normal, PS99.Pro}, game.PlaceId) then
        if TradingPlazaCmds and TradingPlazaCmds.GetAvailable and #TradingPlazaCmds.GetAvailable() > 1 then CanUsePro = true end
        Constants = bal and bal:FindFirstChild("Constants") and require(bal.Constants) or nil
    end
    if table.find({PETSGO.Normal, PETSGO.Pro}, game.PlaceId) then
        UpgradeCmds = client and client:FindFirstChild("UpgradeCmds") and require(client.UpgradeCmds) or nil
        Variables   = shared and shared:FindFirstChild("Variables") and require(shared.Variables) or nil
    end

    if not get_genv().Library then
        get_genv().Library = {}
        local function LoadModules(Path, T)
            if not Path then return end
            for _,v in next, Path:GetChildren() do
                if v:IsA("ModuleScript") and not v:GetAttribute("NOLOAD") then
                    task.spawn(function()
                        local ok, m = pcall(require, v)
                        if ok then T[v.Name] = m end
                    end)
                end
            end
        end
        LoadModules(client, get_genv().Library)
        LoadModules(NLibrary, get_genv().Library)
    end
else
    Rarities = {}
    if not get_genv().Library then get_genv().Library = {} end
end
local Library = get_genv().Library

local Booths, ClaimedBooths, BoothsInteractive
if NLibrary and table.find({PS99.Pro, PS99.Normal, PETSGO.Normal, PETSGO.Pro}, game.PlaceId) then
    local Interacts
    local attempts = 0
    repeat task.wait(0.5)
        attempts = attempts + 1
        pcall(function()
            local targetScript = NLibrary.Client:FindFirstChild("BoothCmds")
            if targetScript and targetScript:IsA("ModuleScript") then
                local mod = require(targetScript)
                Booths = mod.getState or mod.GetState
                Interacts = mod.updateAllInteracts or mod.UpdateAllInteracts
            elseif targetScript and targetScript:IsA("LocalScript") then
                local env = getsenv(targetScript)
                Booths = env.getState or env.GetState
                Interacts = env.updateAllInteracts or env.UpdateAllInteracts
            elseif PlayerScripts then
                local gameFol = PlayerScripts:FindFirstChild("Game")
                if gameFol then
                    local tpFol = gameFol:FindFirstChild("Trading Plaza")
                    if tpFol then
                        local frontend = tpFol:FindFirstChild("Booths Frontend")
                        if frontend then
                            local env = getsenv(frontend)
                            Booths = env.getState
                            Interacts = env.updateAllInteracts
                        end
                    end
                end
            end
        end)
    until (Booths and Interacts) or attempts > 10
    
    if Booths then
        pcall(function() Booths = getupvalues(Booths) end)
    end
    if Interacts then
        pcall(function()
            ClaimedBooths    = getupvalues(Interacts)[1]
            BoothsInteractive = getupvalues(Interacts)[3]
        end)
    end
end

-- Disable idle / server-closing scripts
if PlayerScripts then
    pcall(function() PlayerScripts.Core["Server Closing"].Enabled = false end)
    pcall(function() PlayerScripts.Core["Idle Tracking"].Enabled  = false end)
end
pcall(function() Library.Network.Fire("Idle Tracking: Stop Timer") end)
LocalPlayer.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),   workspace.CurrentCamera.CFrame)
    end)
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
pcall(function()
    if not NLibrary then return end
    local items = NLibrary:FindFirstChild("Items")
    if not items then return end
    local typesMod = items:FindFirstChild("Types")
    if not typesMod then return end
    
    local TempClasses = require(typesMod).Types
    if type(TempClasses) ~= "table" then return end
    local Classes, DirClasses = {}, {}
    for Name in next, TempClasses do Classes[Name] = {} end
    Classes.Currency, Classes.Page = nil, nil
    for Name in next, Classes do
        ItemList[Name] = {}
        local found = false
        local dir = NLibrary:FindFirstChild("Directory")
        if dir then
            for _,C in next, dir:GetChildren() do
                if tostring(C):find(Name) then found=true end
            end
        end
        if not found then Classes[Name]=nil; --continue end
        if Name=="Misc" or Name=="Card" then DirClasses[Name]=Name.."Items"
        elseif Name=="Lootbox" or Name=="Box" then DirClasses[Name]=Name.."es"
        else DirClasses[Name]=Name.."s" end
    end
    for Class in next, Classes do
        pcall(function()
            local dir = NLibrary:FindFirstChild("Directory")
            if not dir then return end
            local mod = dir:FindFirstChild(DirClasses[Class])
            if not mod then return end
            for Item, Info in next, require(mod) do
                if type(Info) ~= "table" then --continue end
                if Info.DisplayName and type(Info.DisplayName)=="function" then
                    for i=(Info.BaseTier or 1),(Info.MaxTier or 1) do
                        ItemList[Class][Info.DisplayName(i)] = {ID=Item,Display=Info.DisplayName(i),Power=Info.Power and Info.Power(i),Rarity=Info.Rarity and Info.Rarity(i),Tier=i,Icon=type(Info.Icon)=="function" and Info.Icon(i) or Info.Icon}
                    end
                elseif Info.Tiers and type(Info.Tiers) == "table" then
                    for i=1,#Info.Tiers do
                        if type(Info.Tiers[i]) ~= "table" then --continue end
                        local Disp,Icon,Rar,Pow
                        if Info.Tiers[i].Effect and Info.Tiers[i].Effect.Type and Info.Tiers[i].Effect.Type.Tiers and Info.Tiers[i].Effect.Type.Tiers[i] then
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
                    if type(DN)=="function" then pcall(function() DN=DN(1) end) end
                    if type(DN)=="string" then ItemList[Class][DN]={ID=Item,Display=DN,Tier=Info.Tier,Icon=Info.Icon or Info.thumbnail,Power=Info.Power,Rarity=Info.Rarity} end
                end
            end
        end)
    end
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  CORE LOGIC FUNCTIONS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function CalcPercent(rap,cost)
    local w=((cost-rap)/rap)*100
    w=math.floor(w*2+0.5)/2
    return w<0 and math.abs(w) or w*-1
end
local function GetDiamonds(retUID)
    if not PlayerSave then return 0 end
    local save = PlayerSave.Get()
    if not save or not save["Inventory"] or not save["Inventory"].Currency then return 0 end
    for i,v in next, save["Inventory"].Currency do
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
    local Main,Tier=Name:match("(.+)%s+(%d+)%s*$")
    if Tier then F.Tier=tonumber(Tier); Name=Main.." "..ToRoman(F.Tier)
    elseif Name:find("(%u+)%s*$") then F.Tier=tonumber(FromRoman(Name:match("(%u+)%s*$"))) end
    F.Display=Name
    -- Also check if Data provides explicit Class
    if Data and Data.Class then F.Class=Data.Class end
    for Class,List in next, ItemList do
        if ItemList[Class][Name] then
            local D=ItemList[Class][Name]
            F.Class=F.Class or Class; F.ID=D.ID; F.Icon=D.Icon
            if Class~="Pet" and Class~="Hoverboard" and Class~="Card" and Class~="Fruit" then
                F.Rainbow,F.Golden,F.Shiny=nil,nil,nil
                if D.Tier and not F.Tier then F.Tier=D.Tier end
            end
            break
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
    if not Booths then return nil end
    for _,Users in next, Booths do
        if type(Users) == "table" then
            for Username,Booth in next, Users do
                if type(Booth) ~= "table" then --continue end
                for BI,IV in next, Booth do
                    if BI=="Listings" and tostring(Username):find(LocalPlayer.Name) then
                        if type(IV) == "table" then
                            for _ in next, IV do bc=bc+1 end
                            if Name and Class then
                                for _,PI in next, IV do
                                    if type(PI)=="table" and PI.Item and PI.Item._data then
                                        local PD=PI.Item._data
                                        if PD["id"]==Name and PI.Item.Class and PI.Item.Class.Name==Class then
                                            ic=ic+(PD["_am"] or 1)
                                        end
                                    end
                                end
                            end
                        end
                        return bc,ic
                    end
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
        if not Inv or not Inv._byUID then --continue end
        for UID,IT in pairs(Inv._byUID) do
            if not ReturnAmount then
                if table.find(LastUIDs,UID) then
                    local _,ic=FindItemsInBooth(IT.GetId and IT:GetId(), IT.GetClass and IT:GetClass() or (IT.Class and IT.Class.Name) or Data.Class or "Pet")
                    if ic and ic>=1 then --continue else table.remove(LastUIDs,table.find(LastUIDs,UID)) end
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
            if II.IsLocked or II.NotTradeable or BlacklistedUIDs[UID] or not UID then --continue end
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
        if table.find(Cfg.LastServers,S.JobID) then --continue end
        if #Cfg.LastServers>=7 then table.remove(Cfg.LastServers,1) end
        table.insert(Cfg.LastServers,S.JobID)
        SaveCfg()
        DisableAntiScam()
        local opts=Instance.new("TeleportOptions")
        opts.ServerJobId=S.JobID
        local ok,err=pcall(function() TeleportService:TeleportAsync(S.PlaceID,{LocalPlayer},opts) end)
        if not ok then warn("[Plaza Plus]: Teleport failed: "..tostring(err)); task.wait(3); --continue end
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
--  GUI SYSTEM
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
print("[Plaza Plus]: Starting GUI rendering...")
if CoreGui:FindFirstChild("PlazaPlusGUI") then CoreGui:FindFirstChild("PlazaPlusGUI"):Destroy() end

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="PlazaPlusGUI"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=CoreGui

-- Runtime state
local IsRunning=false
local RunMode="Seller" -- "Seller","Sniper","Both"

-- Color palette - dark admin panel style
local C={
    BG=Color3.fromRGB(7,8,12),
    Panel=Color3.fromRGB(15,16,23),
    Sidebar=Color3.fromRGB(10,11,17),
    Header=Color3.fromRGB(9,10,15),
    Card=Color3.fromRGB(21,22,32),
    CardHover=Color3.fromRGB(28,30,42),
    Border=Color3.fromRGB(35,37,50),
    Accent=Color3.fromRGB(99,102,241),
    Accent2=Color3.fromRGB(34,197,184),
    AccentDim=Color3.fromRGB(60,63,160),
    Green=Color3.fromRGB(52,211,153),
    GreenDim=Color3.fromRGB(20,90,65),
    Red=Color3.fromRGB(239,68,68),
    Yellow=Color3.fromRGB(251,191,36),
    Text=Color3.fromRGB(238,241,248),
    Sub=Color3.fromRGB(135,143,162),
    InputBG=Color3.fromRGB(20,22,31),
}

local function Tw(obj,props,t,s)
    TweenService:Create(obj,TweenInfo.new(t or 0.15,s or Enum.EasingStyle.Quad),props):Play()
end
local function Corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function Stroke(p,col,th) local s=Instance.new("UIStroke"); s.Color=col or C.Border; s.Thickness=th or 1; s.Parent=p; return s end
local function Padding(p,a,b,l,r) local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,a or 0); pad.PaddingBottom=UDim.new(0,b or 0); pad.PaddingLeft=UDim.new(0,l or 0); pad.PaddingRight=UDim.new(0,r or 0); pad.Parent=p; return pad end

local function Frame(parent,size,pos,color,radius)
    local f=Instance.new("Frame")
    f.Size=size; f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=color or C.Panel; f.BorderSizePixel=0; f.Parent=parent
    if radius then Corner(f,radius) end
    return f
end
local function Label(parent,text,size,color,font,xalign)
    local l=Instance.new("TextLabel")
    l.Text=text; l.TextSize=size or 13; l.TextColor3=color or C.Text
    l.Font=font or Enum.Font.GothamBold; l.BackgroundTransparency=1
    l.Size=UDim2.new(1,0,1,0); l.TextXAlignment=xalign or Enum.TextXAlignment.Left
    l.Parent=parent; return l
end
local function Btn(parent,text,size,pos,bg,tc)
    local b=Instance.new("TextButton")
    b.Size=size; b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=bg or C.Accent; b.TextColor3=tc or C.Text
    b.Text=text; b.TextSize=13; b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=parent
    Corner(b,8)
    b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=Color3.new(b.BackgroundColor3.R+0.06,b.BackgroundColor3.G+0.06,b.BackgroundColor3.B+0.08)}) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=bg or C.Accent}) end)
    return b
end
local function Input(parent,placeholder,size,pos)
    local box=Instance.new("TextBox")
    box.Size=size; box.Position=pos or UDim2.new(0,0,0,0)
    box.BackgroundColor3=C.InputBG; box.TextColor3=C.Text
    box.PlaceholderColor3=C.Sub; box.PlaceholderText=placeholder or ""
    box.Text=""; box.TextSize=12; box.Font=Enum.Font.Gotham
    box.BorderSizePixel=0; box.ClearTextOnFocus=false; box.Parent=parent
    Corner(box,7); Padding(box,0,0,8,8)
    local sk=Stroke(box,C.Border,1)
    box.Focused:Connect(function() Tw(sk,{Color=C.Accent}) end)
    box.FocusLost:Connect(function() Tw(sk,{Color=C.Border}) end)
    return box
end
local function Toggle(parent,pos,default)
    local h=Frame(parent,UDim2.new(0,42,0,22),pos,Color3.fromRGB(35,35,55),11)
    local k=Frame(h,UDim2.new(0,16,0,16),UDim2.new(0,3,0.5,-8),default and C.Accent or C.Border,8)
    local state=default or false
    local callbacks={}
    local function Upd()
        Tw(h,{BackgroundColor3=state and C.AccentDim or Color3.fromRGB(35,35,55)})
        Tw(k,{Position=state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),BackgroundColor3=state and C.Accent or C.Sub})
    end
    Upd()
    local tb=Instance.new("TextButton"); tb.Size=UDim2.new(1,0,1,0); tb.BackgroundTransparency=1; tb.Text=""; tb.Parent=h
    tb.MouseButton1Click:Connect(function() state=not state; Upd(); for _,cb in pairs(callbacks) do cb(state) end end)
    return h,
        function() return state end,
        function(cb) table.insert(callbacks,cb) end,
        function(v) state=v; Upd() end
end

-- â”€â”€ Main Window â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Win=Frame(ScreenGui,UDim2.new(0,760,0,520),UDim2.new(0.5,-380,0.5,-260),C.BG,14)
Win.ClipsDescendants=true
do
    local g=Instance.new("UIGradient"); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(14,15,22)),ColorSequenceKeypoint.new(0.55,Color3.fromRGB(7,8,12)),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,4,7))}); g.Rotation=135; g.Parent=Win
    Stroke(Win,C.Border,1)
end

-- Admin sidebar inspired by the reference image
local Sidebar=Frame(Win,UDim2.new(0,190,1,0),UDim2.new(0,0,0,0),C.Sidebar,0)
Frame(Sidebar,UDim2.new(0,18,1,0),UDim2.new(1,-18,0,0),C.Sidebar,0)
local Brand=Frame(Sidebar,UDim2.new(1,0,0,42),UDim2.new(0,0,0,0),C.Sidebar,0)
Label(Brand,"PLAZA PLUS",15,C.Text,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
local Profile=Frame(Sidebar,UDim2.new(1,-24,0,94),UDim2.new(0,12,0,48),Color3.fromRGB(13,14,21),8)
Stroke(Profile,C.Border,1)
local Avatar=Instance.new("ImageLabel")
Avatar.Size=UDim2.new(0,48,0,48); Avatar.Position=UDim2.new(0,10,0,10)
Avatar.BackgroundColor3=C.Card; Avatar.BorderSizePixel=0
Avatar.Image="rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
Avatar.Parent=Profile; Corner(Avatar,24); Stroke(Avatar,C.Accent2,1)
local pn=Label(Profile,LocalPlayer.DisplayName,13,C.Text,Enum.Font.GothamBold)
pn.Position=UDim2.new(0,68,0,13); pn.Size=UDim2.new(1,-76,0,18); pn.TextTruncate=Enum.TextTruncate.AtEnd
local pr=Label(Profile,"Guest",10,C.Sub,Enum.Font.Gotham)
pr.Position=UDim2.new(0,68,0,32); pr.Size=UDim2.new(1,-76,0,14)
local pid=Label(Profile,tostring(LocalPlayer.UserId),10,C.Sub,Enum.Font.Gotham)
pid.Position=UDim2.new(0,68,0,48); pid.Size=UDim2.new(1,-76,0,14)

-- Title bar
local TBar=Frame(Win,UDim2.new(1,-190,0,50),UDim2.new(0,190,0,0),C.Header,0)
do
    local menu=Instance.new("TextLabel"); menu.Text="="; menu.TextSize=20; menu.Font=Enum.Font.GothamBold; menu.TextColor3=C.Sub; menu.BackgroundTransparency=1; menu.Position=UDim2.new(0,18,0,0); menu.Size=UDim2.new(0,24,1,0); menu.TextXAlignment=Enum.TextXAlignment.Left; menu.Parent=TBar
    local tl=Instance.new("TextLabel"); tl.Text="Admin Panel"; tl.TextSize=15; tl.Font=Enum.Font.GothamBold; tl.TextColor3=C.Text; tl.BackgroundTransparency=1; tl.Position=UDim2.new(0,48,0,8); tl.Size=UDim2.new(0,160,0,20); tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=TBar
    local sl=Instance.new("TextLabel"); sl.Text="Auto Seller & Sniper"; sl.TextSize=10; sl.Font=Enum.Font.Gotham; sl.TextColor3=C.Sub; sl.BackgroundTransparency=1; sl.Position=UDim2.new(0,48,0,28); sl.Size=UDim2.new(0,200,0,14); sl.TextXAlignment=Enum.TextXAlignment.Left; sl.Parent=TBar
    -- status dot
    local dot=Frame(TBar,UDim2.new(0,8,0,8),UDim2.new(0,220,0,21),C.Sub,4)
    -- close/min
    local searchBtn=Btn(TBar,"?",UDim2.new(0,30,0,30),UDim2.new(1,-112,0.5,-15),C.Panel,C.Sub)
    local cBtn=Btn(TBar,"X",UDim2.new(0,30,0,30),UDim2.new(1,-40,0.5,-15),Color3.fromRGB(60,18,18),C.Red)
    cBtn.MouseButton1Click:Connect(function() Win.Visible=false end)
    local mBtn=Btn(TBar,"-",UDim2.new(0,30,0,30),UDim2.new(1,-76,0.5,-15),C.Panel,C.Sub)
    local minimized=false
    mBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        Tw(Win,{Size=minimized and UDim2.new(0,760,0,50) or UDim2.new(0,760,0,520)},0.2)
    end)
    -- Running indicator
    task.spawn(function()
        while task.wait(1) do
            if IsRunning then Tw(dot,{BackgroundColor3=C.Green}) else Tw(dot,{BackgroundColor3=C.Sub}) end
        end
    end)
end

-- Tab row
local TabRow=Frame(Sidebar,UDim2.new(1,-24,1,-158),UDim2.new(0,12,0,152),C.Sidebar,0)
TabRow.BackgroundTransparency=1

local function MakeTabBtn(text,xOff,active)
    local t=Instance.new("TextButton"); t.Size=UDim2.new(1,0,0,38); t.Position=UDim2.new(0,0,0,xOff)
    t.BackgroundColor3=active and C.Accent or Color3.fromRGB(0,0,0); t.BackgroundTransparency=active and 0 or 1; t.TextColor3=active and C.Text or C.Sub
    t.Text=text; t.TextSize=12; t.Font=Enum.Font.GothamBold; t.BorderSizePixel=0; t.AutoButtonColor=false; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=TabRow
    Corner(t,7); return t
end

local SelTab=MakeTabBtn("  $   Seller",0,true)
local SniTab=MakeTabBtn("  #   Sniper",44,false)
local CfgTab=MakeTabBtn("  @   Settings",88,false)

-- Content host
local ContentArea=Frame(Win,UDim2.new(1,-210,1,-118),UDim2.new(0,200,0,62),C.BG,0)
ContentArea.BackgroundTransparency=1

-- â”€â”€ Panels â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function Panel()
    local p=Frame(ContentArea,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.BG,0)
    p.BackgroundTransparency=1; return p
end

local SelPanel=Panel()
local SniPanel=Panel(); SniPanel.Visible=false
local CfgPanel=Panel(); CfgPanel.Visible=false

local function SwitchTab(panel,activeTab)
    SelPanel.Visible=panel==SelPanel; SniPanel.Visible=panel==SniPanel; CfgPanel.Visible=panel==CfgPanel
    for _,t in pairs({SelTab,SniTab,CfgTab}) do Tw(t,{BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,TextColor3=C.Sub}) end
    Tw(activeTab,{BackgroundColor3=C.Accent,BackgroundTransparency=0,TextColor3=C.Text})
end
SelTab.MouseButton1Click:Connect(function() SwitchTab(SelPanel,SelTab) end)
SniTab.MouseButton1Click:Connect(function() SwitchTab(SniPanel,SniTab) end)
CfgTab.MouseButton1Click:Connect(function() SwitchTab(CfgPanel,CfgTab) end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  SHARED: Item card builder
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function ItemCard(parent,name,price,extra,onRemove)
    local card=Frame(parent,UDim2.new(1,0,0,46),UDim2.new(0,0,0,0),C.Card,8)
    Stroke(card,C.Border,1)
    local nl=Instance.new("TextLabel"); nl.Text=name; nl.TextSize=12; nl.Font=Enum.Font.GothamBold; nl.TextColor3=C.Text; nl.BackgroundTransparency=1; nl.Position=UDim2.new(0,10,0,6); nl.Size=UDim2.new(1,-50,0,18); nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=card; nl.TextTruncate=Enum.TextTruncate.AtEnd
    local dl=Instance.new("TextLabel"); dl.Text="$ "..tostring(price)..(extra~="" and "  -  "..extra or ""); dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextColor3=C.Sub; dl.BackgroundTransparency=1; dl.Position=UDim2.new(0,10,0,26); dl.Size=UDim2.new(1,-50,0,14); dl.TextXAlignment=Enum.TextXAlignment.Left; dl.Parent=card
    -- Live badge shown when script is running
    local liveBadge=Instance.new("TextLabel"); liveBadge.Text="LIVE"; liveBadge.TextSize=9; liveBadge.Font=Enum.Font.GothamBold; liveBadge.TextColor3=C.Green; liveBadge.BackgroundTransparency=1; liveBadge.Position=UDim2.new(1,-70,0,6); liveBadge.Size=UDim2.new(0,36,0,12); liveBadge.TextXAlignment=Enum.TextXAlignment.Right; liveBadge.Parent=card; liveBadge.Visible=false
    task.spawn(function()
        while card.Parent do
            liveBadge.Visible=IsRunning
            task.wait(1)
        end
    end)
    local rb=Instance.new("TextButton"); rb.Size=UDim2.new(0,26,0,26); rb.Position=UDim2.new(1,-34,0.5,-13); rb.BackgroundColor3=Color3.fromRGB(50,15,15); rb.TextColor3=C.Red; rb.Text="X"; rb.TextSize=12; rb.Font=Enum.Font.GothamBold; rb.BorderSizePixel=0; rb.AutoButtonColor=false; rb.Parent=card; Corner(rb,6)
    rb.MouseButton1Click:Connect(function()
        card:Destroy()
        -- Also wipe from blacklist so re-adding works cleanly
        for uid,_ in pairs(BlacklistedUIDs) do BlacklistedUIDs[uid]=nil end
        onRemove()
    end)
    return card
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  SELLER PANEL
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local SLeft=Frame(SelPanel,UDim2.new(0.52,-5,1,0),UDim2.new(0,0,0,0),C.Panel,10)
local SRight=Frame(SelPanel,UDim2.new(0.48,-5,1,0),UDim2.new(0.52,5,0,0),C.Panel,10)

-- Item list (left)
do
    local h=Frame(SLeft,UDim2.new(1,-16,0,28),UDim2.new(0,8,0,8),C.Panel,0); h.BackgroundTransparency=1
    Label(h,"Items to Sell",12,C.Sub,Enum.Font.GothamBold)
    local scroll=Instance.new("ScrollingFrame"); scroll.Size=UDim2.new(1,-16,1,-46); scroll.Position=UDim2.new(0,8,0,40); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=C.Accent; scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=SLeft
    local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,4); layout.Parent=scroll

    local SellerItemData={}
    -- Restore saved
    for _,item in pairs(Cfg.SellerItems or {}) do
        SellerItemData[item.Name]=item
        local ext=(item.Amount and "Ã—"..item.Amount or "Ã—max")..(item.Class and " Â· "..item.Class or "")..(item.Priority and " âš¡" or "")
        ItemCard(scroll,item.Name,item.Price,ext,function()
            SellerItemData[item.Name]=nil
            local t={}; for _,v in pairs(SellerItemData) do table.insert(t,v) end; Cfg.SellerItems=t; SaveCfg()
        end)
    end

    -- Add form (right)
    local function FLabel(p,txt,y) local f=Frame(p,UDim2.new(1,-16,0,14),UDim2.new(0,8,0,y),C.Panel,0); f.BackgroundTransparency=1; Label(f,txt,10,C.Sub,Enum.Font.Gotham); return f end
    FLabel(SRight,"Item Name",8)
    local nameIn=Input(SRight,"e.g. Spring Bluebell Token",UDim2.new(1,-16,0,28),UDim2.new(0,8,0,24))
    FLabel(SRight,"Price  (2 Â· 1m Â· +20% Â· -5%)",58)
    local priceIn=Input(SRight,"e.g. 2  or  1m  or  +20%",UDim2.new(1,-16,0,28),UDim2.new(0,8,0,74))
    FLabel(SRight,"Amount  (blank = sell all)",108)
    local amtIn=Input(SRight,"blank = max available",UDim2.new(1,-16,0,28),UDim2.new(0,8,0,124))
    FLabel(SRight,"Class  (Misc, Pet â€¦ blank=auto)",158)
    local classIn=Input(SRight,"e.g. Misc",UDim2.new(1,-16,0,28),UDim2.new(0,8,0,174))

    -- Type row: Rainbow / Golden / Shiny toggles
    FLabel(SRight,"Pet Type",208)
    local typeRow=Frame(SRight,UDim2.new(1,-16,0,28),UDim2.new(0,8,0,224),C.Panel,0); typeRow.BackgroundTransparency=1
    -- Rainbow
    local rainbowDot=Frame(typeRow,UDim2.new(0,10,0,10),UDim2.new(0,0,0.5,-5),Color3.fromRGB(99,200,255),5)
    local rainbowLbl=Instance.new("TextLabel"); rainbowLbl.Text="Rainbow"; rainbowLbl.TextSize=11; rainbowLbl.Font=Enum.Font.Gotham; rainbowLbl.TextColor3=C.Sub; rainbowLbl.BackgroundTransparency=1; rainbowLbl.Position=UDim2.new(0,14,0,0); rainbowLbl.Size=UDim2.new(0,60,1,0); rainbowLbl.TextXAlignment=Enum.TextXAlignment.Left; rainbowLbl.Parent=typeRow
    local _,getRainbow,_,setRainbow=Toggle(typeRow,UDim2.new(0,74,0.5,-11),false)
    -- Golden
    local goldenDot=Frame(typeRow,UDim2.new(0,10,0,10),UDim2.new(0.48,0,0.5,-5),Color3.fromRGB(255,200,50),5)
    local goldenLbl=Instance.new("TextLabel"); goldenLbl.Text="Golden"; goldenLbl.TextSize=11; goldenLbl.Font=Enum.Font.Gotham; goldenLbl.TextColor3=C.Sub; goldenLbl.BackgroundTransparency=1; goldenLbl.Position=UDim2.new(0.48,14,0,0); goldenLbl.Size=UDim2.new(0,55,1,0); goldenLbl.TextXAlignment=Enum.TextXAlignment.Left; goldenLbl.Parent=typeRow
    local _,getGolden,_,setGolden=Toggle(typeRow,UDim2.new(0.48,68,0.5,-11),false)

    -- Shiny row
    local shinyRow=Frame(SRight,UDim2.new(1,-16,0,26),UDim2.new(0,8,0,258),C.Panel,0); shinyRow.BackgroundTransparency=1
    local shinyDot=Frame(shinyRow,UDim2.new(0,10,0,10),UDim2.new(0,0,0.5,-5),Color3.fromRGB(255,130,230),5)
    local shinyLbl=Instance.new("TextLabel"); shinyLbl.Text="Shiny"; shinyLbl.TextSize=11; shinyLbl.Font=Enum.Font.Gotham; shinyLbl.TextColor3=C.Sub; shinyLbl.BackgroundTransparency=1; shinyLbl.Position=UDim2.new(0,14,0,0); shinyLbl.Size=UDim2.new(0,45,1,0); shinyLbl.TextXAlignment=Enum.TextXAlignment.Left; shinyLbl.Parent=shinyRow
    local _,getShiny,_,setShiny=Toggle(shinyRow,UDim2.new(0,58,0.5,-11),false)
    -- AllTypes toggle beside shiny
    local allTypesLbl=Instance.new("TextLabel"); allTypesLbl.Text="All Types"; allTypesLbl.TextSize=11; allTypesLbl.Font=Enum.Font.Gotham; allTypesLbl.TextColor3=C.Sub; allTypesLbl.BackgroundTransparency=1; allTypesLbl.Position=UDim2.new(0.48,0,0,0); allTypesLbl.Size=UDim2.new(0,60,1,0); allTypesLbl.TextXAlignment=Enum.TextXAlignment.Left; allTypesLbl.Parent=shinyRow
    local _,getAllTypes,_,setAllTypes=Toggle(shinyRow,UDim2.new(0.48,64,0.5,-11),false)

    -- Priority toggle
    local prioRow=Frame(SRight,UDim2.new(1,-16,0,26),UDim2.new(0,8,0,290),C.Panel,0); prioRow.BackgroundTransparency=1
    Label(prioRow,"Priority (list first)",12,C.Text,Enum.Font.Gotham)
    local _,getPrio,_,setPrio=Toggle(prioRow,UDim2.new(1,-46,0.5,-11),false)

    -- Quick-add: All Huges button
    local quickBtn=Btn(SRight,"âš¡ Quick: All Huges +20%",UDim2.new(1,-16,0,26),UDim2.new(0,8,0,322),Color3.fromRGB(40,30,10),C.Yellow)
    quickBtn.TextSize=11

    local addBtn=Btn(SRight,"ï¼‹ Add Item",UDim2.new(1,-16,0,32),UDim2.new(0,8,0,354),C.Accent)
    local statusL=Instance.new("TextLabel"); statusL.Size=UDim2.new(1,-16,0,18); statusL.Position=UDim2.new(0,8,0,392); statusL.BackgroundTransparency=1; statusL.TextColor3=C.Green; statusL.Font=Enum.Font.Gotham; statusL.TextSize=11; statusL.Text=""; statusL.TextXAlignment=Enum.TextXAlignment.Center; statusL.Parent=SRight

    local function DoAddItem(name, price, amt, cls, prio, rainbow, golden, shiny, allTypes)
        if name=="" or price=="" then statusL.TextColor3=C.Red; statusL.Text="âš  Name and price required"; task.delay(2,function() statusL.Text="" end); return end
        -- Build unique key including type so e.g. "Rainbow Huge Cat" and "Huge Cat" can both exist
        local typePrefix = (shiny and "Shiny " or "")..(rainbow and "Rainbow " or "")..(golden and "Golden " or "")
        local displayKey = typePrefix..name
        if SellerItemData[displayKey] then statusL.TextColor3=C.Red; statusL.Text="âš  Already in list"; task.delay(2,function() statusL.Text="" end); return end
        local priceVal=tonumber(price) or price
        local item={Name=name, Price=priceVal, Amount=amt, Class=cls, Priority=prio,
                    Rainbow=rainbow, Golden=golden, Shiny=shiny, AllTypes=allTypes,
                    _displayKey=displayKey}
        SellerItemData[displayKey]=item
        local typeStr=(allTypes and "all-types" or typePrefix~="" and typePrefix:gsub(" $","") or "normal")
        local ext=(amt and "Ã—"..amt or "Ã—max")..(cls and " Â· "..cls or "").." Â· "..typeStr..(prio and " âš¡" or "")
        ItemCard(scroll,displayKey,priceVal,ext,function()
            SellerItemData[displayKey]=nil
            local t={}; for _,v in pairs(SellerItemData) do table.insert(t,v) end; Cfg.SellerItems=t; SaveCfg()
        end)
        if IsRunning then
            statusL.TextColor3=C.Yellow; statusL.Text="âš¡ Added live â€” listing next cycle"
        else
            statusL.TextColor3=C.Green; statusL.Text="âœ“ Added: "..displayKey
        end
        task.delay(2,function() statusL.Text="" end)
        local t={}; for _,v in pairs(SellerItemData) do table.insert(t,v) end; Cfg.SellerItems=t; SaveCfg()
    end

    addBtn.MouseButton1Click:Connect(function()
        local name=nameIn.Text:match("^%s*(.-)%s*$")
        local price=priceIn.Text:match("^%s*(.-)%s*$")
        local amt=amtIn.Text~="" and tonumber(amtIn.Text) or nil
        local cls=classIn.Text~="" and classIn.Text or nil
        DoAddItem(name,price,amt,cls,getPrio(),getRainbow(),getGolden(),getShiny(),getAllTypes())
        nameIn.Text=""; priceIn.Text=""; amtIn.Text=""; classIn.Text=""
        setRainbow(false); setGolden(false); setShiny(false); setAllTypes(false); setPrio(false)
    end)

    -- Quick-add All Huges
    quickBtn.MouseButton1Click:Connect(function()
        DoAddItem("All Huges","+20%",nil,nil,false,false,false,false,true)
        statusL.TextColor3=C.Yellow; statusL.Text="âš¡ All Huges added at +20% RAP"
        task.delay(2,function() statusL.Text="" end)
    end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  SNIPER PANEL  (two sub-tabs)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local SNLeft=Frame(SniPanel,UDim2.new(0.52,-5,1,0),UDim2.new(0,0,0,0),C.Panel,10)
local SNRight=Frame(SniPanel,UDim2.new(0.48,-5,1,0),UDim2.new(0.52,5,0,0),C.Panel,10)

-- Sub-tab bar inside SNRight
local subTabBar=Frame(SNRight,UDim2.new(1,-16,0,28),UDim2.new(0,8,0,6),Color3.fromRGB(20,20,32),6)
local function SubTab(txt,xOff,active)
    local t=Instance.new("TextButton"); t.Size=UDim2.new(0.5,-2,1,-4); t.Position=UDim2.new(xOff,2,0,2)
    t.BackgroundColor3=active and C.Accent or Color3.fromRGB(0,0,0); t.BackgroundTransparency=active and 0 or 1; t.TextColor3=active and C.Text or C.Sub
    t.Text=txt; t.TextSize=11; t.Font=Enum.Font.GothamBold; t.BorderSizePixel=0; t.AutoButtonColor=false; t.Parent=subTabBar
    Corner(t,5); return t
end
local boothSubTab=SubTab("ðŸ” Booth",0,true)
local termSubTab=SubTab("ðŸ“¡ Terminal",0.5,false)

-- Booth sniper form
local boothForm=Frame(SNRight,UDim2.new(1,0,1,-40),UDim2.new(0,0,0,40),C.Panel,0); boothForm.BackgroundTransparency=1

-- Terminal form
local termForm=Frame(SNRight,UDim2.new(1,0,1,-40),UDim2.new(0,0,0,40),C.Panel,0); termForm.BackgroundTransparency=1; termForm.Visible=false

boothSubTab.MouseButton1Click:Connect(function()
    boothForm.Visible=true; termForm.Visible=false
    Tw(boothSubTab,{BackgroundColor3=C.Accent,TextColor3=C.Text})
    Tw(termSubTab,{BackgroundColor3=Color3.fromRGB(28,28,44),TextColor3=C.Sub})
end)
termSubTab.MouseButton1Click:Connect(function()
    boothForm.Visible=false; termForm.Visible=true
    Tw(termSubTab,{BackgroundColor3=C.Accent,TextColor3=C.Text})
    Tw(boothSubTab,{BackgroundColor3=Color3.fromRGB(28,28,44),TextColor3=C.Sub})
end)

-- Left: shared item list with two sections
do
    -- Booth items header
    local bh=Frame(SNLeft,UDim2.new(1,-16,0,16),UDim2.new(0,8,0,6),C.Panel,0); bh.BackgroundTransparency=1
    Label(bh,"ðŸ” Booth Targets",11,C.Sub,Enum.Font.GothamBold)
    local bScroll=Instance.new("ScrollingFrame"); bScroll.Size=UDim2.new(1,-16,0.48,-28); bScroll.Position=UDim2.new(0,8,0,24); bScroll.BackgroundTransparency=1; bScroll.BorderSizePixel=0; bScroll.ScrollBarThickness=3; bScroll.ScrollBarImageColor3=C.Accent; bScroll.CanvasSize=UDim2.new(0,0,0,0); bScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; bScroll.Parent=SNLeft
    local bLayout=Instance.new("UIListLayout"); bLayout.Padding=UDim.new(0,3); bLayout.Parent=bScroll

    -- Terminal items header
    local th=Frame(SNLeft,UDim2.new(1,-16,0,16),UDim2.new(0,8,0.5,4),C.Panel,0); th.BackgroundTransparency=1
    Label(th,"ðŸ“¡ Terminal Targets",11,C.Sub,Enum.Font.GothamBold)
    local tScroll=Instance.new("ScrollingFrame"); tScroll.Size=UDim2.new(1,-16,0.48,-28); tScroll.Position=UDim2.new(0,8,0.5,22); tScroll.BackgroundTransparency=1; tScroll.BorderSizePixel=0; tScroll.ScrollBarThickness=3; tScroll.ScrollBarImageColor3=C.Yellow; tScroll.CanvasSize=UDim2.new(0,0,0,0); tScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; tScroll.Parent=SNLeft
    local tLayout=Instance.new("UIListLayout"); tLayout.Padding=UDim.new(0,3); tLayout.Parent=tScroll

    -- Divider
    local div=Frame(SNLeft,UDim2.new(1,-16,0,1),UDim2.new(0,8,0.5,1),C.Border,0)

    local SniperItemData={}
    local TerminalItemData={}

    -- Restore saved booth items
    for _,item in pairs(Cfg.SniperItems or {}) do
        SniperItemData[item.Name]=item
        local ext=(item.InventoryLimit and "limit:"..item.InventoryLimit or "")..(item.AllTypes and " all-types" or "")..(item.DetectManipulation and " anti-manip" or "")
        ItemCard(bScroll,item.Name,item.Price,ext,function()
            SniperItemData[item.Name]=nil
            local t={}; for _,v in pairs(SniperItemData) do table.insert(t,v) end; Cfg.SniperItems=t; SaveCfg()
        end)
    end

    -- Restore saved terminal items
    for _,item in pairs(Cfg.TerminalItems or {}) do
        TerminalItemData[item.Name]=item
        local ext=(item.InventoryLimit and "limit:"..item.InventoryLimit or "")..(item.UseCosmicValues and " cosmic" or "")
        ItemCard(tScroll,item.Name,item.Price,ext,function()
            TerminalItemData[item.Name]=nil
            local t={}; for _,v in pairs(TerminalItemData) do table.insert(t,v) end; Cfg.TerminalItems=t; SaveCfg()
        end)
    end

    -- â”€â”€ BOOTH FORM â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    local function FLabel(p,txt,y) local f=Frame(p,UDim2.new(1,-16,0,13),UDim2.new(0,8,0,y),C.Panel,0); f.BackgroundTransparency=1; Label(f,txt,10,C.Sub,Enum.Font.Gotham); return f end

    FLabel(boothForm,"Item Name  (All Huges, Huge Catâ€¦)",4)
    local sNameIn=Input(boothForm,"e.g. All Huges",UDim2.new(1,-16,0,26),UDim2.new(0,8,0,19))
    FLabel(boothForm,"Max Price  (flat or %)",51)
    local sPriceIn=Input(boothForm,"e.g. 15m  or  50%  or  +2%",UDim2.new(1,-16,0,26),UDim2.new(0,8,0,66))
    FLabel(boothForm,"Inventory Limit  (blank = none)",98)
    local sLimitIn=Input(boothForm,"e.g. 100",UDim2.new(1,-16,0,26),UDim2.new(0,8,0,113))

    local atRow=Frame(boothForm,UDim2.new(1,-16,0,24),UDim2.new(0,8,0,145),C.Panel,0); atRow.BackgroundTransparency=1
    Label(atRow,"All Types",11,C.Text,Enum.Font.Gotham)
    local _,getAllTypes,_,setAllTypes=Toggle(atRow,UDim2.new(0.5,0,0.5,-11),false)
    local dmLabel=Instance.new("TextLabel"); dmLabel.Text="Anti-Manip"; dmLabel.TextSize=11; dmLabel.Font=Enum.Font.Gotham; dmLabel.TextColor3=C.Text; dmLabel.BackgroundTransparency=1; dmLabel.Position=UDim2.new(0.5,50,0,0); dmLabel.Size=UDim2.new(0.4,0,1,0); dmLabel.TextXAlignment=Enum.TextXAlignment.Left; dmLabel.Parent=atRow
    local _,getDetect,_,setDetect=Toggle(atRow,UDim2.new(1,-46,0.5,-11),false)

    local sAddBtn=Btn(boothForm,"ï¼‹ Add Booth Target",UDim2.new(1,-16,0,28),UDim2.new(0,8,0,175),C.Accent)
    sAddBtn.TextSize=11
    local sStatusL=Instance.new("TextLabel"); sStatusL.Size=UDim2.new(1,-16,0,16); sStatusL.Position=UDim2.new(0,8,0,209); sStatusL.BackgroundTransparency=1; sStatusL.TextColor3=C.Green; sStatusL.Font=Enum.Font.Gotham; sStatusL.TextSize=10; sStatusL.Text=""; sStatusL.TextXAlignment=Enum.TextXAlignment.Center; sStatusL.Parent=boothForm

    sAddBtn.MouseButton1Click:Connect(function()
        local name=sNameIn.Text:match("^%s*(.-)%s*$")
        local price=sPriceIn.Text:match("^%s*(.-)%s*$")
        if name=="" or price=="" then sStatusL.TextColor3=C.Red; sStatusL.Text="âš  Name and price required"; task.delay(2,function() sStatusL.Text="" end); return end
        if SniperItemData[name] then sStatusL.TextColor3=C.Red; sStatusL.Text="âš  Already in list"; task.delay(2,function() sStatusL.Text="" end); return end
        local priceVal=tonumber(price) or price
        local limit=sLimitIn.Text~="" and tonumber(sLimitIn.Text) or nil
        local allTypes=getAllTypes(); local detect=getDetect()
        local item={Name=name,Price=priceVal,InventoryLimit=limit,AllTypes=allTypes,DetectManipulation=detect}
        SniperItemData[name]=item
        local ext=(limit and "limit:"..limit or "")..(allTypes and " all-types" or "")..(detect and " anti-manip" or "")
        ItemCard(bScroll,name,priceVal,ext,function()
            SniperItemData[name]=nil
            local t={}; for _,v in pairs(SniperItemData) do table.insert(t,v) end; Cfg.SniperItems=t; SaveCfg()
        end)
        sNameIn.Text=""; sPriceIn.Text=""; sLimitIn.Text=""; setAllTypes(false); setDetect(false)
        sStatusL.TextColor3=IsRunning and C.Yellow or C.Green
        sStatusL.Text=IsRunning and "âš¡ Added live" or "âœ“ Added"
        task.delay(2,function() sStatusL.Text="" end)
        local t={}; for _,v in pairs(SniperItemData) do table.insert(t,v) end; Cfg.SniperItems=t; SaveCfg()
    end)

    -- â”€â”€ TERMINAL FORM â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    local function TLabel(p,txt,y) local f=Frame(p,UDim2.new(1,-16,0,13),UDim2.new(0,8,0,y),C.Panel,0); f.BackgroundTransparency=1; Label(f,txt,10,C.Sub,Enum.Font.Gotham); return f end

    -- Info box
    local infoBox=Frame(termForm,UDim2.new(1,-16,0,36),UDim2.new(0,8,0,4),Color3.fromRGB(20,30,20),8)
    Stroke(infoBox,C.Green,1)
    local infoL=Instance.new("TextLabel"); infoL.Text="ðŸ“¡ Terminal searches ALL servers\nfor the cheapest listings globally"; infoL.TextSize=10; infoL.Font=Enum.Font.Gotham; infoL.TextColor3=C.Green; infoL.BackgroundTransparency=1; infoL.Position=UDim2.new(0,8,0,0); infoL.Size=UDim2.new(1,-16,1,0); infoL.TextXAlignment=Enum.TextXAlignment.Left; infoL.TextWrapped=true; infoL.Parent=infoBox

    TLabel(termForm,"Item Name  (exact name required)",46)
    local tNameIn=Input(termForm,"e.g. Huge Night Terror Cat",UDim2.new(1,-16,0,26),UDim2.new(0,8,0,61))
    TLabel(termForm,"Max Price  (flat or %)",93)
    local tPriceIn=Input(termForm,"e.g. 15m  or  50%",UDim2.new(1,-16,0,26),UDim2.new(0,8,0,108))
    TLabel(termForm,"Inventory Limit  (blank = none)",140)
    local tLimitIn=Input(termForm,"e.g. 50",UDim2.new(1,-16,0,26),UDim2.new(0,8,0,155))

    local cvRow=Frame(termForm,UDim2.new(1,-16,0,24),UDim2.new(0,8,0,187),C.Panel,0); cvRow.BackgroundTransparency=1
    Label(cvRow,"Use Cosmic Values",11,C.Text,Enum.Font.Gotham)
    local _,getCosmicVal,_,setCosmicVal=Toggle(cvRow,UDim2.new(1,-46,0.5,-11),false)

    local tAddBtn=Btn(termForm,"ï¼‹ Add Terminal Target",UDim2.new(1,-16,0,28),UDim2.new(0,8,0,218),C.Yellow,Color3.fromRGB(30,20,5))
    tAddBtn.TextSize=11; tAddBtn.TextColor3=Color3.fromRGB(40,28,5)
    local tStatusL=Instance.new("TextLabel"); tStatusL.Size=UDim2.new(1,-16,0,16); tStatusL.Position=UDim2.new(0,8,0,252); tStatusL.BackgroundTransparency=1; tStatusL.TextColor3=C.Green; tStatusL.Font=Enum.Font.Gotham; tStatusL.TextSize=10; tStatusL.Text=""; tStatusL.TextXAlignment=Enum.TextXAlignment.Center; tStatusL.Parent=termForm

    tAddBtn.MouseButton1Click:Connect(function()
        local name=tNameIn.Text:match("^%s*(.-)%s*$")
        local price=tPriceIn.Text:match("^%s*(.-)%s*$")
        if name=="" or price=="" then tStatusL.TextColor3=C.Red; tStatusL.Text="âš  Name and price required"; task.delay(2,function() tStatusL.Text="" end); return end
        if TerminalItemData[name] then tStatusL.TextColor3=C.Red; tStatusL.Text="âš  Already in list"; task.delay(2,function() tStatusL.Text="" end); return end
        local priceVal=tonumber(price) or price
        local limit=tLimitIn.Text~="" and tonumber(tLimitIn.Text) or nil
        local cosmic=getCosmicVal()
        local item={Name=name,Price=priceVal,InventoryLimit=limit,UseCosmicValues=cosmic}
        TerminalItemData[name]=item
        local ext=(limit and "limit:"..limit or "")..(cosmic and " cosmic" or "")
        ItemCard(tScroll,name,priceVal,ext,function()
            TerminalItemData[name]=nil
            local t={}; for _,v in pairs(TerminalItemData) do table.insert(t,v) end; Cfg.TerminalItems=t; SaveCfg()
        end)
        tNameIn.Text=""; tPriceIn.Text=""; tLimitIn.Text=""; setCosmicVal(false)
        tStatusL.TextColor3=IsRunning and C.Yellow or C.Green
        tStatusL.Text=IsRunning and "âš¡ Added live â€” searching now" or "âœ“ Added"
        task.delay(2,function() tStatusL.Text="" end)
        local t={}; for _,v in pairs(TerminalItemData) do table.insert(t,v) end; Cfg.TerminalItems=t; SaveCfg()
    end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  SETTINGS PANEL
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
do
    local sf=Frame(CfgPanel,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.Panel,10)
    local function Row(label,y)
        local r=Frame(sf,UDim2.new(1,-16,0,38),UDim2.new(0,8,0,y),C.Card,8); Stroke(r,C.Border,1)
        local l=Instance.new("TextLabel"); l.Text=label; l.TextSize=12; l.Font=Enum.Font.GothamBold; l.TextColor3=C.Text; l.BackgroundTransparency=1; l.Position=UDim2.new(0,12,0,0); l.Size=UDim2.new(0.55,0,1,0); l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        return r
    end

    -- Section label
    local sl=Instance.new("TextLabel"); sl.Text="GENERAL"; sl.TextSize=10; sl.Font=Enum.Font.GothamBold; sl.TextColor3=C.Sub; sl.BackgroundTransparency=1; sl.Position=UDim2.new(0,8,0,8); sl.Size=UDim2.new(1,0,0,16); sl.TextXAlignment=Enum.TextXAlignment.Left; sl.Parent=sf

    -- Mode
    local modeRow=Row("Mode  (what to run)",28)
    local modeOptions={"Seller","Sniper","Both"}
    local modeIdx=1
    for i,v in ipairs(modeOptions) do if v==Cfg.Mode then modeIdx=i end end
    local modeLabel=Instance.new("TextLabel"); modeLabel.Size=UDim2.new(0,90,0,26); modeLabel.Position=UDim2.new(1,-100,0.5,-13); modeLabel.BackgroundColor3=C.Accent; modeLabel.TextColor3=C.Text; modeLabel.Text=modeOptions[modeIdx]; modeLabel.TextSize=12; modeLabel.Font=Enum.Font.GothamBold; modeLabel.BorderSizePixel=0; modeLabel.Parent=modeRow; Corner(modeLabel,6)
    local mBtn2=Instance.new("TextButton"); mBtn2.Size=UDim2.new(1,0,1,0); mBtn2.BackgroundTransparency=1; mBtn2.Text=""; mBtn2.Parent=modeLabel
    mBtn2.MouseButton1Click:Connect(function()
        modeIdx=modeIdx%#modeOptions+1; modeLabel.Text=modeOptions[modeIdx]; Cfg.Mode=modeOptions[modeIdx]; SaveCfg()
    end)

    -- Switch servers
    local ssRow=Row("Switch Servers",74)
    local _,getSS,onSS,setSS=Toggle(ssRow,UDim2.new(1,-56,0.5,-11),Cfg.SwitchServers or false)
    setSS(Cfg.SwitchServers or false)
    onSS(function(v) Cfg.SwitchServers=v; SaveCfg() end)

    -- Delay
    local delRow=Row("Switch Delay  (minutes)",118)
    local delIn=Input(delRow,"20",UDim2.new(0,80,0,24),UDim2.new(1,-90,0.5,-12))
    delIn.Text=tostring(Cfg.Delay or 20)
    delIn.FocusLost:Connect(function() Cfg.Delay=tonumber(delIn.Text) or 20; SaveCfg() end)

    -- Only Pro
    local proRow=Row("Only Pro Servers",162)
    local _,getPro,onPro,setPro=Toggle(proRow,UDim2.new(1,-56,0.5,-11),Cfg.OnlyPro or false)
    setPro(Cfg.OnlyPro or false)
    onPro(function(v) Cfg.OnlyPro=v; SaveCfg() end)

    -- Webhook section
    local wl=Instance.new("TextLabel"); wl.Text="WEBHOOK"; wl.TextSize=10; wl.Font=Enum.Font.GothamBold; wl.TextColor3=C.Sub; wl.BackgroundTransparency=1; wl.Position=UDim2.new(0,8,0,210); wl.Size=UDim2.new(1,0,0,16); wl.TextXAlignment=Enum.TextXAlignment.Left; wl.Parent=sf

    local whRow=Frame(sf,UDim2.new(1,-16,0,38),UDim2.new(0,8,0,230),C.Card,8); Stroke(whRow,C.Border,1)
    local whLabel=Instance.new("TextLabel"); whLabel.Text="Discord URL"; whLabel.TextSize=12; whLabel.Font=Enum.Font.GothamBold; whLabel.TextColor3=C.Text; whLabel.BackgroundTransparency=1; whLabel.Position=UDim2.new(0,12,0,0); whLabel.Size=UDim2.new(0,80,1,0); whLabel.TextXAlignment=Enum.TextXAlignment.Left; whLabel.Parent=whRow
    local whIn=Input(whRow,"https://discord.com/api/webhooks/...",UDim2.new(1,-105,0,7),UDim2.new(0,95,0,7))
    whIn.Text=Cfg.WebhookURL or ""
    whIn.FocusLost:Connect(function() Cfg.WebhookURL=whIn.Text; SaveCfg() end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  BOTTOM BAR â€” Launch / Stop
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local BBar=Frame(Win,UDim2.new(1,-190,0,48),UDim2.new(0,190,1,-48),C.Header,0)
local launchBtn=Btn(BBar,">  START",UDim2.new(0,140,0,32),UDim2.new(0,12,0.5,-16),C.Green,Color3.fromRGB(5,30,18))
launchBtn.TextColor3=Color3.fromRGB(5,40,22)
local stopBtn=Btn(BBar,"[] STOP",UDim2.new(0,120,0,32),UDim2.new(0,160,0.5,-16),Color3.fromRGB(80,20,20),C.Red)
local botStatus=Instance.new("TextLabel"); botStatus.Size=UDim2.new(1,-310,1,0); botStatus.Position=UDim2.new(0,295,0,0); botStatus.BackgroundTransparency=1; botStatus.TextColor3=C.Sub; botStatus.Font=Enum.Font.Gotham; botStatus.TextSize=11; botStatus.Text="Configure items, then press START"; botStatus.TextXAlignment=Enum.TextXAlignment.Left; botStatus.Parent=BBar

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  SELLER RUNTIME
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
        warn("[Plaza Plus]: Could not claim booth â€” all booths may be taken. Waiting 10s...")
        botStatus.TextColor3=C.Red; botStatus.Text="âš  Could not claim booth â€” retrying in 10s"
        task.wait(10)
        ClaimBooth()
        repeat task.wait() until ClaimedBooths[LocalPlayer] or (os.time()-timeout)>30
    end
    if not ClaimedBooths[LocalPlayer] then
        warn("[Plaza Plus]: Booth claim failed completely.")
        botStatus.TextColor3=C.Red; botStatus.Text="âš  Booth claim failed! Try a different server."
        SellerRunning=false; IsRunning=false
        Tw(launchBtn,{BackgroundColor3=C.Green})
        return
    end
    warn("[Plaza Plus]: Booth claimed, listing items...")
    botStatus.Text="ðŸª Seller running..."; botStatus.TextColor3=C.Green

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

    -- Single flat listing function â€” lists ONE slot for ONE item then returns
    -- so the outer loop can immediately check for newly added items
    local function TryListItem(name, data)
        local maxSlots = (PlayerSave and PlayerSave.Get() and PlayerSave.Get().BoothSlots) or 8
        local usedSlots = FindItemsInBooth() or 0
        if usedSlots >= maxSlots then return end

        -- Build the lookup name including type prefix (Rainbow/Golden/Shiny)
        local lookupName = name
        if not data.AllTypes then
            if data.Shiny   then lookupName = "Shiny "..lookupName end
            if data.Rainbow then lookupName = "Rainbow "..lookupName end
            if data.Golden  then lookupName = "Golden "..lookupName end
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

        print("[Plaza Plus]: Listing "..name.." Ã— "..Amount.." for "..tostring(PD.RealPrice))
        task.wait(math.random(2, 5))

        local fails = 0
        while Amount > 0 and (FindItemsInBooth() or 0) < maxSlots do
            if not SellerRunning then break end
            local t2 = os.time()
            local ok = Library.Network.Invoke("Booths_CreateListing", UID, math.floor(PD.RealPrice), math.min(Amount, MaxAmount))
            repeat task.wait() until ok or (os.time()-t2) >= 10
            if ok then
                warn("[Plaza Plus]: Listed "..name.." Ã— "..math.min(Amount,MaxAmount))
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
            local maxSlots = (PlayerSave and PlayerSave.Get() and PlayerSave.Get().BoothSlots) or 8
            local usedSlots = FindItemsInBooth() or 0

            if usedSlots < maxSlots then
                -- Rebuild list fresh every tick â€” new items added via GUI are picked up instantly
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
                -- Booth full â€” just wait and recheck
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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  SNIPER RUNTIME
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local SniperRunning=false

local function RunSniper()
    SniperRunning=true
    botStatus.Text="ðŸŽ¯ Sniper running..."; botStatus.TextColor3=C.Yellow

    -- Print what we're sniping
    warn("[Plaza Plus]: Sniper started. Watching for:")
    for _,item in pairs(Cfg.SniperItems or {}) do
        warn("  â†’ "..tostring(item.Name).." at price: "..tostring(item.Price))
    end

    -- FindInfo cache â€” rebuilt each cycle so newly added snipe targets work live
    local FindInfoCache={}

    local function GetFindInfo(item)
        if not FindInfoCache[item.Name] then
            FindInfoCache[item.Name]=GenerateFindInfo(item.Name,item)
        end
        return FindInfoCache[item.Name]
    end

    local function ProcessBooth(BoothID, Booth)
        for BI,IV in next, Booth do
            if BI~="Listings" then --continue end
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
                    if not FI then --continue end
                    if not ValidateItem(CI,FI) then --continue end

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
                    if not valid then --continue end
                    if GetDiamonds()<CI.Cost then --continue end

                    local canBuy=math.floor(GetDiamonds()/CI.Cost)
                    local buyAmt=math.min(CI.Amount,canBuy)
                    if item.InventoryLimit then buyAmt=math.min(buyAmt,item.InventoryLimit-(FindItem(FI,true) or 0)) end
                    if buyAmt<=0 then --continue end

                    warn("[Plaza Plus]: Sniping Ã—"..buyAmt.." "..CI.Display)

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
                        --continue
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

    -- â”€â”€ Terminal Search runtime â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

    local function SearchTerminal(Class, Encoded, SearchQuery, item)
        local FoundServer
        pcall(function()
            FoundServer=game.ReplicatedStorage.Network.TradingTerminal_Search:InvokeServer(Class,Encoded,nil,false)
        end)
        if not FoundServer then
            warn("[Plaza Plus Terminal]: No server found for "..tostring(SearchQuery.id))
            return
        end
        if type(FoundServer)~="table" or not FoundServer["place_id"] or not FoundServer["job_id"] then return end

        -- Check if it's a valid PS99 server
        local placeOk = table.find({PS99.Normal,PS99.Pro},FoundServer["place_id"])
        if not placeOk then return end
        if Cfg.OnlyPro and FoundServer["place_id"]~=PS99.Pro then return end

        warn("[Plaza Plus Terminal]: Found "..tostring(SearchQuery.id).." â€” teleporting to buy...")
        table.insert(TerminalServers,{PlaceID=FoundServer["place_id"],JobID=FoundServer["job_id"],Item=item})
    end

    -- Terminal search loop
    task.spawn(function()
        while SniperRunning do
            for _,item in pairs(Cfg.TerminalItems or {}) do
                if not SniperRunning then break end
                local FI=GetFindInfo(item)
                if not FI or not FI.Class then
                    warn("[Plaza Plus Terminal]: Could not resolve class for: "..tostring(item.Name))
                    --continue
                end

                -- Check inventory limit
                if item.InventoryLimit then
                    local have=FindItem(FI,true) or 0
                    if have>=item.InventoryLimit then --continue end
                end

                local searchTable={
                    id=FI.ID,
                    pt=FI.Golden and 1 or FI.Rainbow and 2 or nil,
                    sh=FI.Shiny or nil,
                    tn=FI.Tier or nil
                }
                local keyOrder={"id","pt","sh","tn"}
                local Encoded=OrderedTable(searchTable,keyOrder)
                local Decoded=HttpService:JSONDecode(Encoded)

                SearchTerminal(FI.Class,Encoded,Decoded,item)
                task.wait(0.5)
            end

            -- Process any found servers
            if #TerminalServers>0 then
                local target=table.remove(TerminalServers,1)
                if target and target.JobID~=game.JobId then
                    -- Teleport to buy
                    DisableAntiScam()
                    local opts=Instance.new("TeleportOptions")
                    opts.ServerJobId=target.JobID
                    local ok,err=pcall(function()
                        TeleportService:TeleportAsync(target.PlaceID,{LocalPlayer},opts)
                    end)
                    if not ok then
                        warn("[Plaza Plus Terminal]: Teleport failed: "..tostring(err))
                    end
                    task.wait(2)
                end
            end

            task.wait(1)
        end
    end)

    -- â”€â”€ Booth scanner loop â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    task.spawn(function()
        while SniperRunning do
            if Booths then
                for _,Users in next, Booths do
                    if type(Users) == "table" then
                        for Username,Booth in next, Users do
                            if type(Booth) ~= "table" then --continue end
                            if not SniperRunning then break end
                            local skip=false
                            pcall(function() if Booth.Player and Booth.Player:IsInGroup(5060810) then skip=true end end)
                            if not skip then
                                local BoothID = Booth.BoothID
                                if not BoothID then
                                    for bid, bdata in pairs(ClaimedBooths or {}) do
                                        if bdata and type(bdata)=="table" and bdata.Player and tostring(bdata.Player)==tostring(Username) then
                                            BoothID = bdata.BoothID; break
                                        end
                                    end
                                end
                                pcall(ProcessBooth, BoothID or Username, Booth)
                            end
                        end
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
            task.wait(0.3)
        end
    end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  LAUNCH / STOP BUTTONS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
launchBtn.MouseButton1Click:Connect(function()
    if IsRunning then return end
    local mode = Cfg.Mode or "Seller"
    local sellerItems = Cfg.SellerItems or {}
    local sniperItems = Cfg.SniperItems or {}

    if (mode=="Seller" or mode=="Both") and #sellerItems==0 then
        botStatus.TextColor3=C.Red
        botStatus.Text="âš  Add items to the Seller tab first!"
        task.delay(3,function() botStatus.TextColor3=C.Sub; botStatus.Text="Configure items, then press START" end)
        return
    end
    if (mode=="Sniper" or mode=="Both") and #sniperItems==0 then
        botStatus.TextColor3=C.Red
        botStatus.Text="âš  Add targets to the Sniper tab first!"
        task.delay(3,function() botStatus.TextColor3=C.Sub; botStatus.Text="Configure items, then press START" end)
        return
    end

    IsRunning=true
    Tw(launchBtn,{BackgroundColor3=C.GreenDim})
    botStatus.TextColor3=C.Green
    botStatus.Text="â³ Starting "..mode.." mode..."

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

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  DRAG + TOGGLE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
do
    local drag,ds,sp=false,nil,nil
    TBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp=Win.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds; Win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end
UserInputService.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.RightShift then Win.Visible=not Win.Visible end end)

if not table.find({PS99.Normal,PS99.Pro,PETSGO.Normal,PETSGO.Pro},game.PlaceId) then
    botStatus.TextColor3=C.Red
    botStatus.Text="âš  Wrong game! Go to PS99 or PETS GO Trading Plaza."
end

print("[Plaza Plus GUI]: Ready! Press RightShift to toggle.")
