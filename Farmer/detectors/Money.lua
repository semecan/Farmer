local _, addon = ...;

local GetMoney = _G.GetMoney;

local moneyStamp;

addon:on('PLAYER_LOGIN', function ()
  moneyStamp = GetMoney();
end);

addon:on('PLAYER_MONEY', function ()
  if (not moneyStamp) then return end

  local money = GetMoney();
  local difference = money - moneyStamp;

  moneyStamp = money;

  addon:yell('MONEY_CHANGED', difference);
end);
