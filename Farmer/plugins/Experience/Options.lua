local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Experience'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Experience = {
      displayExperience = false,
      experienceThreshold = 1,
    },
  },
}).vars.farmerOptions.Experience;

panel:mapOptions(options, {
  displayExperience = panel:addCheckBox(L['show experience']),
  experienceThreshold = panel:addSlider(0, 100, L['minimum %'], '0', '100', 0),
});
