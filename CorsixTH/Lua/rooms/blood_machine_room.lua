--[[ Copyright (c) 2009 Manuel König

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

local room = {}
room.id = "blood_machine"
room.vip_must_visit = false
room.level_config_id = 15
room.class = "BloodMachineRoom"
room.name = _S.rooms_short.blood_machine
room.long_name = _S.rooms_long.blood_machine
room.tooltip = _S.tooltip.rooms.blood_machine
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { blood_machine = 1 }
room.build_preview_animation = 5094
room.categories = {
  diagnosis = 6,
}
room.minimum_size = 4
room.wall_type = "yellow"
room.floor_tile = 19
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd006.wav"
room.handyman_call_sound = "maint015.wav"

class "BloodMachineRoom" (Room)

---@type BloodMachineRoom
local BloodMachineRoom = _G["BloodMachineRoom"]

function BloodMachineRoom:BloodMachineRoom(...)
  self:Room(...)
end

function BloodMachineRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local machine, stf_x, stf_y = self.world:findObjectNear(patient, "blood_machine")
  local pat_x, pat_y = machine:getSecondaryUsageTile()

  staff:setNextAction(WalkAction(stf_x, stf_y))
  patient:setNextAction(WalkAction(pat_x, pat_y))
  patient:queueAction(IdleAction():setDirection(machine.direction == "north" and "west" or "north"))

  local length = math.random(2, 4)
  local loop_callback = --[[persistable:blood_machine_loop_callback]] function(action)
    if length <= 0 then
      action.prolonged_usage = false
    end
    length = length - 1
  end

  local after_use = --[[persistable:blood_machine_after_use]] function()
    staff:setNextAction(MeanderAction())
    self:dealtWithPatient(patient)
  end

  staff:queueAction(MultiUseObjectAction(machine, patient):setProlongedUsage(true)
      :setInvisiblePhaseSpan({-3, 3}):setLoopCallback(loop_callback):setAfterUse(after_use))

  return Room.commandEnteringPatient(self, patient)
end

return room
