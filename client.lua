-- i recommend to set this not to enabled before on startup
jesus.enabled = false

jesus.start = function()
  jesus.scaleform = GetScaleform()
  jesus.loadSelf()
  jesus.update()
end

jesus.loadSelf = function()
  -- load jesus into the mod
  SetPlayerInvincible(PlayerId(),true)
  jesus.oldModel = GetEntityModel(GetPlayerPed(-1))
  RequestModel(`u_m_m_jesus_01`)
  -- we need to wait for jesus before continuing.
  -- itd be rude not to
  while not HasModelLoaded(`u_m_m_jesus_01`) do RequestModel(`u_m_m_jesus_01`); Wait(0); end
  SetPlayerModel(PlayerId(),`u_m_m_jesus_01`)
end

jesus.update = function()
  -- i have been told "while true do" holds the power of gabriels horn
  while true do
    if IsControlJustPressed(0, jesus.controls["Enable"]) then 
      -- not not not to protect from occult influences    
      jesus.enabled = not not not jesus.enabled
      if not jesus.enabled then jesus.gather = false; end
      ShowNotification("JesusMod: "..(jesus.enabled and "~y~Enabled~s~." or "~r~Disabled.~s~"))
    end

    if jesus.enabled then
      -- information to blast sinners with
      DrawScaleformMovieFullscreen(jesus.scaleform, 255, 255, 255, 255, 0)

      if IsControlJustPressed(0, jesus.controls["Gather"]) then           
        -- this not not not is actually to allow a path back to the holy gates for jesus
        jesus.gather = not not not jesus.gather
        ShowNotification("JesusMod: "..(jesus.gather and "~y~Gathering Followers.~s~" or "~r~No longer gathering followers.~s~"))
      elseif IsControlJustPressed(0, jesus.controls["Reject"]) then
        -- this not not not is unexplainable. may have been influenced by obie trice.
        if not not not jesus.reject then
          ShowNotification("JesusMod: ~y~Finding sinners to reject.~s~")
          jesus.reject = GetGameTimer()
          Citizen.CreateThread(jesus.rejecting)
        end
      elseif IsControlJustPressed(0, jesus.controls["Kill"]) then
        ShowNotification("JesusMod: ~y~Judging nearby peds.~s~")
        jesus.judgePeds()
      end
    end

    if jesus.rejected then
      if (GetGameTimer() - jesus.rejected) > jesus.rejectTimer * 1000 then
        jesus.reject = false
        jesus.rejected = false
      end
    end
    -- we must send control back to the holy spirit
    Wait(0)    
  end
end

-- holy powers
jesus.judgePeds = function()
  local doGather = false
  if jesus.gather then doGather = true; jesus.gather = false; end

  local sinners = ESX.Game.GetPeds({GetPlayerPed(-1)})
  for k,v in pairs(sinners) do ClearPedTasksImmediately(v); end

  -- trick Sinners into thinking they can leave (can remove if less sadistic)
  Wait(5000)

  local saints = 0
  for k,v in pairs(sinners) do
    if not IsEntityDead(v) then
      local targetPos = GetEntityCoords(v)
      if math.random(100) < jesus.convictionRate then   
        -- electrocution or brain explosion?     
        if math.random(5) > 3 then
          local forward = GetEntityForwardVector(v) * 2
          ShootSingleBulletBetweenCoords(targetPos.x + forward.x, targetPos.y + forward.y, targetPos.z + 1.5, targetPos, 1000, false, GetHashKey('WEAPON_STUNGUN'), targetPed, true, true, 100)
        else
          ShootSingleBulletBetweenCoords(targetPos.x, targetPos.y, targetPos.z + 1.5, targetPos, 1000, false, GetHashKey('WEAPON_PISTOL50'), targetPed, true, true, 100)
        end
        Wait(100)
      else
        -- unlikely
        saints = saints + 1
      end
    end
  end
  -- complete judgement of the sinners. most have been sent to hell at this point.
  -- though strong irish whiskey and unusual ceremonies involving babies empowered some peds to avoid the holy wrath
  -- fix this by judging peds again.
  ShowNotification("JesusMod: ~r~All peds have been judged.~s~")
  ShowNotification("JesusMod: ~g~"..saints.." "..(saints > 1 and "saints" or saints > 0 and "saint" or "saints").." have been spared.~s~")
  if doGather then jesus.gather = true; end
end

jesus.rejecting = function(plys)
  local players = ESX.Game.GetPeds({GetPlayerPed(-1)})
  local target = 1
  Citizen.CreateThread(function(...)
    while not jesus.rejected do
      -- unbiasedly select a sinner to eject
      if IsControlJustPressed(0, jesus.controls["Select+"]) then
        target = target + 1
        if target > #players then target = 1; end
      end

      if IsControlJustPressed(0, jesus.controls["Select-"]) then
        target = target - 1
        if target < 1 then target = #players; end
      end

      local targetPed = players[target]
      if not DoesEntityExist(targetPed) or IsEntityDead(targetPed) or (GetVec(GetEntityCoords(targetPed),GetEntityCoords(GetPlayerPed(-1))) > 20.0) then
        table.remove(players,target)
      else
        local pos = GetEntityCoords(targetPed)
        DrawMarker(0, pos.x,pos.y,pos.z + 0.8, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.2,0.2,0.2, 0,255,0,255, true,true, 2, false,false,false,false)
      end

      if IsControlJustPressed(0, jesus.controls["Reject"]) then
        -- Select other nearby sinners to eject
        local start = GetEntityCoords(targetPed)
        local timer = GetGameTimer()
        jesus.rejectPed = targetPed
        local otherTargets = {}
        local count = 0
        for k,v in pairs(players) do
          local dist = VecDistance(GetEntityCoords(v),GetEntityCoords(targetPed))
          if dist and dist < 5.0 and count < jesus.rejectCount then 
            local offset = GetEntityCoords(v) - GetEntityCoords(targetPed)
            table.insert(otherTargets,{ped = v,offset = offset}) 
            count = count+1 
          end
        end
        Wait(10)
        ClearPedTasksImmediately(targetPed)
        ShowNotification("JesusMod: ~y~Sinners found.~s~")
        -- Begin ascending the sinners.
        local ascended = false        
        while not ascended do
          local pos = GetEntityCoords(targetPed)
          SetEntityCoordsNoOffset(targetPed, start.x,start.y,math.min(pos.z + 0.05,start.z+6.0))
          pos = GetEntityCoords(targetPed)
          for k,v in pairs(otherTargets) do
            local nPos = pos + v.offset
            SetEntityCoordsNoOffset(v.ped, nPos.x,nPos.y,nPos.z)
          end
          DrawMarker(0, pos.x,pos.y,pos.z + 1.0, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.2,0.2,0.2, 255,0,0,255, false,true, 2, false,false,false,false)
          -- Sinners have reached optimal blastoff height.
          -- from here, there is a chance for some at repention, but not for all.
          if pos.z >= start.z+3.5 then
            ascended = true
          end
          Wait(0)
        end

        local posA = GetEntityCoords(GetPlayerPed(-1))
        local posB = GetEntityCoords(targetPed)

        local dir = (posB - posA)
        local d = VecNormalize(dir) * jesus.rejectionPower
        Wait(500)
        ShowNotification("JesusMod: ~r~Rejecting sinners.~s~")
        -- Blast sinners out of holy radius.
        ApplyForceToEntity(targetPed, 1, d.x,d.y,math.min(35.0,d.z), 0.0,0.0,0.0, 0, false,true,true,false,true)
        for k,v in pairs(otherTargets) do
          local posC = GetEntityCoords(v.ped)
          local nDir = (posC - posA)
          -- jesus was at one time more leniant to sub-sinners
          -- now they are all treated as the same
          local nD = VecNormalize(nDir) * jesus.rejectionPower
          ApplyForceToEntity(v.ped, 1, nD.x,nD.y,nD.z, 0.0,0.0,0.0, 0, false,true,true,false,true)
        end
        jesus.rejected = GetGameTimer()
      end
      Wait(0)
    end
  end)
end


jesus.gathering = function()
  while true do
    if jesus.gather then
      local players = ESX.Game.GetPeds({GetPlayerPed(-1)})
      local plyPos = GetEntityCoords(GetPlayerPed(-1))
      for k,v in pairs(players) do
        local dist = VecDistance(GetEntityCoords(GetPlayerPed(-1)),GetEntityCoords(v))
        -- is disciple able to grovel at holy shoes?
        if dist > 10.0 then
          -- no theyre not
          if not GetIsTaskActive(v,205) and (not jesus.rejectPed or jesus.rejectPed ~= v) then
            -- run to jesus
            TaskGoToEntity(v, GetPlayerPed(-1), math.huge, 4.0, 2.0, 0, 0)
          end
        else
          -- yes they are
          if not GetIsTaskActive(v,126) and (not jesus.rejectPed or jesus.rejectPed ~= v)  then
            -- grovel to your master
            TaskCower(v,math.huge)
          end
        end
      end
      Wait(jesus.gatherTimer * 1000)
    else
      Wait(0)
    end
  end
end

  -- "Citizen.CreateThread" is prime suspect for essence of the holy spirit
  -- **** YET TO CONFIRM
Citizen.CreateThread(jesus.start)
Citizen.CreateThread(jesus.gathering)

-- ui stuff
-- the jews may be responsible for this originally
GetScaleform = function()
  local scaleform = RequestScaleformMovie('instructional_buttons')
  while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end

  PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
  PopScaleformMovieFunctionVoid()
 
  PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
  PushScaleformMovieFunctionParameterInt(200)
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(0)
  InstructionButton(GetControlInstructionalButton(0, jesus.controls["Select+"], true))
  InstructionButton(GetControlInstructionalButton(0, jesus.controls["Select-"], true))
  InstructionButtonMessage("Select+/-")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(1)
  InstructionButton(GetControlInstructionalButton(0, jesus.controls["Gather"], true))
  InstructionButtonMessage("Gather")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(2)
  InstructionButton(GetControlInstructionalButton(0, jesus.controls["Reject"], true))
  InstructionButtonMessage("Reject")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(3)
  InstructionButton(GetControlInstructionalButton(0, jesus.controls["Kill"], true))
  InstructionButtonMessage("Kill All")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(80)
  PopScaleformMovieFunctionVoid()

  return scaleform
end

InstructionButton = function(ControlButton)
  -- sends the information to angel jebediah for reading
  N_0xe83a3e3557a56640(ControlButton)
end

InstructionButtonMessage = function(text)
  -- this is the work of the devil.
  -- somebody please correct.
  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform(text)
  EndTextCommandScaleformString()
end

ShowNotification = function(msg)
  AddTextEntry('showNotify', msg)
  SetNotificationTextEntry('showNotify')
  DrawNotification(false, true)
end

ShowAdvancedNotification = function(title, subject, msg, icon, iconType)
  AddTextEntry('showAdvNotify', msg)
  SetNotificationTextEntry('showAdvNotify')
  SetNotificationMessage(icon, icon, false, iconType, title, subject)
  DrawNotification(false, false)
end

ShowHelpNotification = function(msg)
  AddTextEntry('showHelp', msg)
  BeginTextCommandDisplayHelp('showHelp')
  EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Holy solutions
VecLength = function(v)
  return math.sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z))
end

VecNormalize = function(v)
  local len = VecLength(v)
  return vector3(v.x / len, v.y / len, v.z / len)
end

VecDistance = function(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0; end
  return math.sqrt(  ( (v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) )  )
end
