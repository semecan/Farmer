local addonName, addon = ...;

local unpack = _G.unpack;
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena;

local DEFAULT_COLOR = {1, 1, 1};

local farmerFrame = addon.frame;
local getIcon = addon.getIcon;
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {},
}).vars.farmerOptions.Core;

local mailIsOpen = false;
addon.on('MAIL_SHOW', function ()
  mailIsOpen = true;
end);

--[[ when having the mail open and accepting a queue, the MAIL_CLOSED event does
not fire, so we clear the flag after entering the world --]]
addon.on({'MAIL_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
  mailIsOpen = false;
end);

local function checkHideOptions ()
  if (options.hideAtMailbox == true and
      mailIsOpen) then
    return false;
  end

  if (options.hideOnExpeditions == true and
      -- cannot be deferred earlier, as this frame gets initialized dynamically
      _G.IslandsPartyPoseFrame and
      _G.IslandsPartyPoseFrame:IsShown()) then
    return false;
  end

  if (options.hideInArena == true and
      IsActiveBattlefieldArena and
      IsActiveBattlefieldArena()) then
    return false;
  end

  return true;
end

local function printMessage (message, colors)
  colors = colors or DEFAULT_COLOR;

  farmerFrame:AddMessage(message, unpack(colors, 1, 3));
end

local function printMessageWithData (subspace, identifier, data, message, colors)
  colors = colors or DEFAULT_COLOR;

  farmerFrame:AddMessageWithData(subspace, identifier, data, message, unpack(colors));
end

local function printIconMessage (texture, message, colors)
  printMessage(getIcon(texture) .. ' ' .. message, colors);
end

local function printIconMessageWithData (subspace, identifier, data, texture, message, colors)
  printMessageWithData(subspace, identifier, data, getIcon(texture) .. ' ' .. message, colors);
end

addon.Print = {
  checkHideOptions = checkHideOptions,
  printMessage = printMessage;
  printMessageWithData = printMessageWithData;
  printIconMessage = printIconMessage;
  printIconMessageWithData = printIconMessageWithData;
};
