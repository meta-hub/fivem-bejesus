utils = {}

-- Credits : Illidan54
-- https://gist.github.com/IllidanS4/9865ed17f60576425369fc1da70259b2

local entityEnumerator = {
  __gc = function(enum)
    if enum.destructor and enum.handle then
      enum.destructor(enum.handle)
    end

    enum.destructor = nil
    enum.handle = nil
  end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end

    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)

    local next = true
    repeat
    coroutine.yield(id)
    next, id = moveFunc(iter)
    until not next

    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

--

utils.getPeds = function(exclusions)
  local peds  = {}
  for ped in EnumeratePeds() do
    local doAdd = true
    if exclusions then
      if type(exclusions) == "table" then
        for key,val in pairs(exclusions) do
          if val == ped then
            doAdd = false
          end
        end
      else
        if exclusions == ped then
          doAdd = false
        end
      end
    end
    if doAdd then
      table.insert(peds,ped)
    end
  end
  return peds
end