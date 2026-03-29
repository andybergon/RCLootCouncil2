require "busted.runner" ()
local addon = loadfile(".specs/AddonLoader.lua")().LoadToc("RCLootCouncil.toc")
dofile ".specs/EmulatePlayerLogin.lua"

describe("#Export #History #JSON", function()
	local History = addon:GetModule("RCLootHistory")
	History:Enable()

	it("should export json", function()
		addon.lootDB.factionrealm = {
			["Player1-Realm1"] = {
				{
					["mapID"] = 2552,
					["date"] = "2025/03/05",

					["class"] = "WARRIOR",
					["iSubClass"] = 4,
					["groupSize"] = 0,
					["boss"] = "Mug'Zee, Heads of Security",
					["time"] = "22:27:00",
					["iClass"] = 2,
					["itemReplaced1"] =
					"|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r",
					["typeCode"] = "default",
					["owner"] = "Potdisc-Ravencrest",
					["instance"] = "Khaz Algar (Surface)-",
					["response"] = "Stat upgrade",
					["id"] = "1741210091-32",
					["difficultyID"] = 0,
					["lootWon"] =
					"|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r",
					["isAwardReason"] = false,
					["color"] = {
						0.99,
						0.9,
						0.27,
						1,
					},
					["responseID"] = 3,
					["votes"] = 0,
				},
			},
		}
		local json = History:ExportJSON()
		assert.equals("Potdisc-Ravencrest", json:match('"owner":"([%w-]+)"'))
		assert.equals("2025/03/05", json:match('"date":"([%d/]+)"'))
		assert.equals("1741210091-32", json:match('"id":"([%d-]+)"'))
		assert.equals("item:163265:::::::::::28:3:5125:1537:4783", json:match('"itemString":"(item:[%d:-]+)"'))
	end)

	it("should export items with \"'s in their name correctly", function()
		addon.lootDB.factionrealm = {
			["Player1-Realm1"] = {
				{
					["mapID"] = 2552,
					["date"] = "2025/03/05",

					["class"] = "WARRIOR",
					["iSubClass"] = 4,
					["groupSize"] = 0,
					["boss"] = "Mug'Zee, Heads of Security",
					["time"] = "22:27:00",
					["iClass"] = 2,
					["itemReplaced1"] =
					"|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r",
					["typeCode"] = "default",
					["owner"] = "Potdisc-Ravencrest",
					["instance"] = "Khaz Algar (Surface)-",
					["response"] = "Stat upgrade",
					["id"] = "1741210091-32",
					["difficultyID"] = 0,
					["lootWon"] =
					"|cffa335ee|Hitem:228864::::::::80:262::3:6:6652:11966:10354:11980:1494:10255:1:28:2462|h[\"Streamlined\" Cartel Uniform]|h|r",
					["isAwardReason"] = false,
					["color"] = {
						0.99,
						0.9,
						0.27,
						1,
					},
					["responseID"] = 3,
					["votes"] = 0,
				},
			},
		}
		local json = History:ExportJSON()
		assert.equals("Potdisc-Ravencrest", json:match('"owner":"([%w-]+)"'))
		assert.equals("2025/03/05", json:match('"date":"([%d/]+)"'))
		assert.equals("1741210091-32", json:match('"id":"([%d-]+)"'))
		assert.equals("item:228864::::::::80:262::3:6:6652:11966:10354:11980:1494:10255:1:28:2462",
			json:match('"itemString":"(item:[%d:-]+)"'))
		assert.equals("\\\"Streamlined\\\" Cartel Uniform", json:match('"itemName":"([%w%s\\"]+)"'))
	end)

	it("should export candidates when present", function()
		addon.lootDB.factionrealm = {
			["Player1-Realm1"] = {
				{
					["mapID"] = 2552,
					["date"] = "2025/03/05",
					["class"] = "WARRIOR",
					["iSubClass"] = 4,
					["groupSize"] = 20,
					["boss"] = "Mug'Zee, Heads of Security",
					["time"] = "22:27:00",
					["iClass"] = 2,
					["itemReplaced1"] =
					"|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r",
					["typeCode"] = "default",
					["owner"] = "Potdisc-Ravencrest",
					["instance"] = "Liberation of Undermine-Mythic",
					["response"] = "Mainspec/Need",
					["id"] = "1741210091-32",
					["difficultyID"] = 16,
					["lootWon"] =
					"|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r",
					["isAwardReason"] = false,
					["color"] = { 0, 1, 0, 1 },
					["responseID"] = 1,
					["votes"] = 3,
					["candidates"] = {
						["Player1-Realm1"] = {
							response = 1,
							class = "WARRIOR",
							votes = 3,
						},
						["Player2-Realm1"] = {
							response = 2,
							class = "PALADIN",
							votes = 1,
							note = "offspec",
						},
						["Player3-Realm1"] = {
							response = "PASS",
							class = "MAGE",
						},
					},
				},
			},
		}
		local json = History:ExportJSON()
		-- Should contain candidates object
		assert.is_not.Nil(json:find('"candidates":{'))
		-- Should contain each candidate
		assert.is_not.Nil(json:find('"Player1%-Realm1"'))
		assert.is_not.Nil(json:find('"Player2%-Realm1"'))
		assert.is_not.Nil(json:find('"Player3%-Realm1"'))
		-- Should contain candidate data
		assert.is_not.Nil(json:find('"class":"PALADIN"'))
		assert.is_not.Nil(json:find('"note":"offspec"'))
	end)

	it("should not include candidates key when not present", function()
		addon.lootDB.factionrealm = {
			["Player1-Realm1"] = {
				{
					["mapID"] = 2552,
					["date"] = "2025/03/05",
					["class"] = "WARRIOR",
					["iSubClass"] = 4,
					["groupSize"] = 0,
					["boss"] = "Mug'Zee, Heads of Security",
					["time"] = "22:27:00",
					["iClass"] = 2,
					["typeCode"] = "default",
					["owner"] = "Potdisc-Ravencrest",
					["instance"] = "Khaz Algar (Surface)-",
					["response"] = "Stat upgrade",
					["id"] = "1741210091-32",
					["difficultyID"] = 0,
					["lootWon"] =
					"|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r",
					["isAwardReason"] = false,
					["color"] = { 0.99, 0.9, 0.27, 1 },
					["responseID"] = 3,
					["votes"] = 0,
				},
			},
		}
		local json = History:ExportJSON()
		assert.is.Nil(json:find('"candidates"'))
	end)

	it("should export candidates with voters when present", function()
		addon.lootDB.factionrealm = {
			["Player1-Realm1"] = {
				{
					["mapID"] = 2552,
					["date"] = "2025/03/05",
					["class"] = "WARRIOR",
					["iSubClass"] = 4,
					["groupSize"] = 20,
					["boss"] = "Mug'Zee, Heads of Security",
					["time"] = "22:27:00",
					["iClass"] = 2,
					["typeCode"] = "default",
					["owner"] = "Potdisc-Ravencrest",
					["instance"] = "Liberation of Undermine-Mythic",
					["response"] = "Mainspec/Need",
					["id"] = "1741210091-32",
					["difficultyID"] = 16,
					["lootWon"] =
					"|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r",
					["isAwardReason"] = false,
					["color"] = { 0, 1, 0, 1 },
					["responseID"] = 1,
					["votes"] = 3,
					["candidates"] = {
						["Player1-Realm1"] = {
							response = 1,
							class = "WARRIOR",
							votes = 3,
							voters = {"CouncilA-Realm1", "CouncilB-Realm1", "CouncilC-Realm1"},
						},
					},
				},
			},
		}
		local json = History:ExportJSON()
		assert.is_not.Nil(json:find('"voters"'))
		assert.is_not.Nil(json:find('"CouncilA%-Realm1"'))
		assert.is_not.Nil(json:find('"CouncilB%-Realm1"'))
	end)
end)
