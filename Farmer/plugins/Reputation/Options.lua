local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Reputation'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    reputation = true,
    reputationThreshold = 15,
  },
}).vars.farmerOptions;

panel:mapOptions(options, {
  reputation = panel:addCheckBox(L['show reputation']),
  reputationThreshold = panel:addSlider(1, 100, L['minimum'], '1', '100', 1),
});
