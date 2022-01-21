script.Name = 'ObjectiveHandler'

--[[

       _____ __              ____                       _       _
      / ___// /_____  ____  / __ \___  ____ ___  ____ _(_)___  (_)___  ____ _
      \__ \/ __/ __ \/ __ \/ /_/ / _ \/ __ `__ \/ __ `/ / __ \/ / __ \/ __ `/
     ___/ / /_/ /_/ / /_/ / _, _/  __/ / / / / / /_/ / / / / / / / / / /_/ /
    /____/\__/\____/ .___/_/ |_|\___/_/ /_/ /_/\__,_/_/_/ /_/_/_/ /_/\__, /
                  /_/                                               /____/

    -- Stop Remaining
    -- By: RainyLofi

    ObjectiveHandler
]]--
--------------------------------------------------------------------------------------------

local Workspace = game:GetService('Workspace')

local SR = _G.SR

local Modules = SR.Modules
local Signal, Signals = Modules.Signal, SR.Signals
local Shared = Modules.Shared

local OS = SR.ObjectiveService

--------------------------------------------------------------------------------------------

Signals.CarryingChanged = Signal.new()
Signals.CarryingChanged:Connect(function(Carrying) SR.CarryingItem = Carrying print('Carrying', tostring(Carrying)) end)

Signals.ObjectiveAdded = Signal.new()
Signals.ObjectiveAdded:Connect(function(Objective) table.insert(SR.Objectives, Objective) print('New Objective', Objective.Name) end)

Signals.ObjectiveRemoving = Signal.new()
Signals.ObjectiveRemoving:Connect(function(ObjectiveName)
    for _, Objective in pairs(SR.Objectives) do
        if Objective.Name == ObjectiveName then
            print('Removed Objective', Objective.Name)
            table.remove(SR.Objectives, table.find(SR.Objectives, Objective))
        end
    end
end)

--------------------------------------------------------------------------------------------

OS.UpdateCarryingItem.OnClientEvent:Connect(function(Name, _) Signals.CarryingChanged:Fire(Name) end)
OS.RemoveCarryingItem.OnClientEvent:Connect(function() Signals.CarryingChanged:Fire(nil) end)

OS.RegisterObjectiveMarkers.OnClientEvent:Connect(function(Markers, Parent)
    for Purpose, Data in pairs(Markers) do
        if Data.point and Purpose == 'Main Marker' then

            Signals.ObjectiveAdded:Fire({
                Object = Parent,
                Name = Parent.Name,
                Point = Data.point
            })

            local Connection = nil
            Connection = Data.point.AncestryChanged:connect(function()
                if not Data.point:IsDescendantOf(Workspace) then
                    Signals.ObjectiveRemoving:Fire(Parent.Name)
                    Connection:Disconnect()
                end
            end)

        end
    end
end)

task.spawn(function()
    repeat task.wait() until Signals.StageUpdated
    Signals.StageUpdated:Connect(function(StageData)
        if StageData['Stage'] == 'End' then
            Signals.CarryingChanged:Fire(nil)
            for _, Objective in pairs(SR.Objectives) do Signals.ObjectiveRemoving:Fire(Objective.Name) end
            Shared.Functions.NoClip(false)
        end
    end)
end)

--------------------------------------------------------------------------------------------

local Objectives, ObjectiveModules = {
    'EscortChar', 'Car', 'Fuel Truck'
}, {}
for _, Objective in pairs(Objectives) do
    ObjectiveModules[Objective] = _G.Import('Modules/Objectives/' .. Objective)
end

ObjectiveModules['Silverado'] = ObjectiveModules['Car']
ObjectiveModules['Tundra'] = ObjectiveModules['Tundra']

local DoObjective = function() -- should be called each frame
    if #SR.Objectives == 0 then return false end

    local Objective = SR.Objectives[1] -- the first objective
    local ObjectiveModule = ObjectiveModules[Objective.Name]
    if ObjectiveModule then
        return ObjectiveModule.Run(Objective)
    end
end

return DoObjective

--[[ 
    Game:GetService("ReplicatedStorage").ServiceRemotes.ObjectiveService.RegisterObjectiveMarkers:OnClientEvent(
    {
        ["Tire1"] = {
            ["offset"] = Vector3.new(0, 1.5, 0),
            ["point"] = Game:GetService("Workspace").World.Objectives.Part,
            ["display"] = Game:GetService("Workspace").World.Objectives.Part.DisplayText,
            ["size"] = 18,
            ["ended"] = false
        },
        ["Tire2"] = {
            ["offset"] = Vector3.new(0, 1.5, 0),
            ["point"] = Game:GetService("Workspace").World.Objectives.Part,
            ["display"] = Game:GetService("Workspace").World.Objectives.Part.DisplayText,
            ["size"] = 18,
            ["ended"] = false
        },
        ["Fuel Tank"] = {
            ["offset"] = Vector3.new(0, 1.5, 0),
            ["point"] = Game:GetService("Workspace").World.Objectives.Part,
            ["display"] = Game:GetService("Workspace").World.Objectives.Part.DisplayText,
            ["size"] = 18,
            ["ended"] = false
        },
        ["Main Marker"] = {
            ["offset"] = Vector3.new(0, 1.5, 0),
            ["point"] = Game:GetService("Workspace").World.Objectives.Silverado.Part,
            ["display"] = Game:GetService("Workspace").World.Objectives.Silverado.Part.Icon,
            ["size"] = 18,
            ["ended"] = false
        },
        ["Engine"] = {
            ["offset"] = Vector3.new(0, 1.5, 0),
            ["point"] = Game:GetService("Workspace").World.Objectives.Part,
            ["display"] = Game:GetService("Workspace").World.Objectives.Part.DisplayText,
            ["size"] = 18,
            ["ended"] = false
        }
    },
    Game:GetService("Workspace").World.Objectives.Silverado
)
Script: Game:GetService("Players").RhythmeticShots.PlayerScripts.FrameworkClient-- CLIENT EVENT CALLED! --
]]

--[[Game:GetService("ReplicatedStorage").ServiceRemotes.ObjectiveService.RegisterObjectiveMarkers:OnClientEvent(
    {
        ["Main Marker"] = {
            ["offset"] = Vector3.new(0, 1.5, 0),
            ["point"] = Game:GetService("Workspace").Entities.Objectives.EscortChar.Part,
            ["display"] = Game:GetService("Workspace").Entities.Objectives.EscortChar.Part.Icon,
            ["size"] = 18,
            ["ended"] = false
        },
        ["Description Marker"] = {
            ["offset"] = Vector3.new(0, 1.5, 0),
            ["point"] = Game:GetService("Workspace").Entities.Objectives.EscortChar.Part,
            ["display"] = Game:GetService("Workspace").Entities.Objectives.EscortChar.Part.DisplayText,
            ["size"] = 18,
            ["ended"] = false
        }
    },
    Game:GetService("Workspace").Entities.Objectives.EscortChar
)]]--