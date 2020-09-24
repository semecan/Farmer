local addonName, addon = ...;

local unpack = _G.unpack;
local max = _G.max;
local min = _G.min;
local strupper = _G.strupper;
local GetItemIcon = _G.GetItemIcon;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

local L = addon.L;
local addonVars = addon.share('vars');

local ADDON_ICON_ID = 3334;
local ANCHOR_DEFAULT = {'BOTTOM', nil, 'CENTER', 0, 50};

local Panel = addon.OptionClass.Panel;
local mainPanel = Panel:new(addonName);
local farmerFrame = addon.frame;

addon.mainPanel = mainPanel.panel;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Core = {
      anchor = ANCHOR_DEFAULT,
      displayTime = 4,
      fontSize = 18,
      iconScale = 0.8,
      outline = 'OUTLINE',
      hideAtMailbox = true,
      hideInArena = true,
      hideOnExpeditions = true,
      itemNames = true,
    },
  },
});

local options = saved.vars.farmerOptions.Core;

local function storePosition ()
  options.anchor = {farmerFrame:GetPoint()};
end

local function stopMovingFrame ()
  local icon = addon.getIcon(GetItemIcon(ADDON_ICON_ID));

  farmerFrame:EnableMouse(false);
  farmerFrame:SetMovable(false);
  farmerFrame:SetFading(true);
  farmerFrame:Clear();
  farmerFrame:AddMessage(icon);
  farmerFrame:StopMovingOrSizing();
  farmerFrame:SetScript('OnDragStart', nil);
  farmerFrame:SetScript('OnReceiveDrag', nil);
  storePosition();
end

local function moveFrame ()
  local icon = addon.getIcon(GetItemIcon(ADDON_ICON_ID));

  farmerFrame:RegisterForDrag('LeftButton');
  farmerFrame:SetFading(false);
  farmerFrame:Clear();
  farmerFrame:AddMessage(icon);
  farmerFrame:EnableMouse(true);
  farmerFrame:SetMovable(true);
  farmerFrame:SetScript('OnDragStart', function (self)
    if (self:IsMovable() == true) then
      self:StartMoving();
    end
  end);

  farmerFrame:SetScript('OnReceiveDrag', stopMovingFrame);
end

local function setFramePosition (position)
  farmerFrame:ClearAllPoints();
  farmerFrame:SetPoint(unpack(position));
end

local function setDefaultPosition ()
  setFramePosition(ANCHOR_DEFAULT);
  stopMovingFrame();
end

local function setFontSize (size, scale, outline)
  -- adding line spacing makes textures completely off so they need y-offset
  -- for some reason that offset has to be 1.5 times the spacing
  -- i have no idea why, i just figured it out by testing
  local maximumIconSize = 128;
  local minimumIconSize = 8;
  local iconSize = max(min(size * scale, maximumIconSize), minimumIconSize);
  local spacing = 0;
  local iconOffset = -spacing * 1.5;
  local shadowOffset = size / 10;
  local font = addon.font;

  --[[ we have to use the standard font because on screen messages are always
       localized --]]
  font:SetFont(STANDARD_TEXT_FONT, size, outline);
  font:SetSpacing(spacing);
  font:SetShadowColor(0, 0, 0);
  font:SetShadowOffset(shadowOffset, -shadowOffset);

  addonVars.iconOffset = addon.stringJoin({'', iconSize, iconSize, '0', iconOffset}, ':');
end

local function applyOptions ()
  setFontSize(options.fontSize, options.iconScale, options.outline);
  farmerFrame:SetTimeVisible(options.displayTime -
      farmerFrame:GetFadeDuration());
end

do
  local optionMap = {};

  optionMap.itemNames = mainPanel:addCheckBox(L['show names of all items']);
  optionMap.hideAtMailbox = mainPanel:addCheckBox(L['don\'t display at mailboxes']);

  if (not addon.isClassic()) then
    optionMap.hideInArena = mainPanel:addCheckBox(L['don\'t display in arena']);
    optionMap.hideOnExpeditions = mainPanel:addCheckBox(L['don\'t display on island expeditions']);
  end

  optionMap.iconScale = mainPanel:addSlider(0.1, 3, L['icon scale'], '0.1', '3', 1);
  optionMap.fontSize = mainPanel:addSlider(8, 64, L['font size'], '8', '64', 0, function (_, value)
    setFontSize(value, options.iconScale, options.outline);
  end);
  optionMap.displayTime = mainPanel:addSlider(1, 10, L['display time'], '1', '10', 0, function (_, value)
    farmerFrame:SetTimeVisible(value - farmerFrame:GetFadeDuration());
  end);
  optionMap.outline = mainPanel:addDropdown(L['outline mode'], {
    {
      text = L['None'],
      value = '',
    }, {
      text = L['Thin'],
      value = 'OUTLINE',
    }, {
      text = L['Thick'],
      value = 'THICKOUTLINE',
    }, {
      text = L['Monochrome'],
      value = 'MONOCHROME, OUTLINE',
    }, {
      text = L['Thick Monochrome'],
      value = 'MONOCHROME, THICKOUTLINE',
    }
  });

  mainPanel:addButton(L['reset position'], setDefaultPosition);
  mainPanel:addButton(L['move display'], moveFrame);

  mainPanel:mapOptions(options, optionMap);
  mainPanel:OnSave(applyOptions);
  mainPanel:OnCancel(applyOptions);
end

local function setGrowDirection (direction)
  local currentDirection = strupper(farmerFrame:GetInsertMode());

  direction = strupper(direction);

  if (direction ~= currentDirection) then
    local anchor = {farmerFrame:GetPoint()};

    if (direction == 'TOP') then
      anchor[5] = anchor[5] - farmerFrame:GetHeight();
    else
      anchor[5] = anchor[5] + farmerFrame:GetHeight();
    end

    farmerFrame:SetPoint(unpack(anchor));
  end

  farmerFrame:SetInsertMode(direction);
end


saved:OnLoad(function ()
  setFramePosition(options.anchor);
  applyOptions();
end);

--[[
///#############################################################################
/// slash commands
///#############################################################################
--]]

addon.slash('move', moveFrame);
addon.slash('reset', setDefaultPosition);

addon.slash('default', function ()
  return (Panel.openLastPanel() or mainPanel:open());
end);

addon.slash('grow', setGrowDirection);
