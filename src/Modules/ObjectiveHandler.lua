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
                Name = Parent.Name
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

repeat task.wait() until Signals.StageUpdated

Signals.StageUpdated:Connect(function(StageData)
    if StageData['Stage'] == 'End' then
       Signals.CarryingChanged:Fire(nil)
       for _, Objective in pairs(SR.Objectives) do Signals.ObjectiveRemoving:Fire(Objective.Name) end
    end
end)