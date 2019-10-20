jesus = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj; end)
Citizen.CreateThread(function() while not ESX do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj; end); Wait(0); end; end)

jesus.controls = {
  ["Enable"] = 47,
  ["Select+"] = 174,
  ["Select-"] = 175,
  ["Gather"] = 246,
  ["Reject"] = 305,
  ["Kill"] = 252,
}

jesus.rejectTimer = 1 -- seconds for sinner rejection to be available again after use.
jesus.gatherTimer = 2 -- seconds for esx.getplayers() to trigger... more timer = less lag?

jesus.rejectCount = 10 -- max sinners to reject at a time
jesus.rejectionPower = 100.0 -- more power = more certain death for rejected sinners
jesus.convictionRate = 100 -- all peds are sinners.