Config = {}

Config.Locale = 'en'

Config.Delays = {
	ProcessPernik = 1000 * 1
}

Config.Pricesell = 700

Config.MinPiecesWed = 1



Config.DrugDealerItems = {
	plastic_baggie = 91
}

Config.LicenseEnable = false -- enable processing licenses? The player will be required to buy a license in order to process drugs. 



Config.GiveBlack = false -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
	PickupPernik = {coords = vector3(3728.7, 3805.07, 5.57), name = 'blip_PickupPernik', color = 25, sprite = 496, radius = 30.0},
	ProcessPernik = {coords = vector3(2433.94, 4968.69, 42.35), name = 'blip_ProcessPernik', color = 25, sprite = 496, radius = 100.0},
	DrugDealer = {coords = vector3(2407.75, 3031.64, 48.15), name = 'blip_DrugDealer', color = 6, sprite = 378, radius = 25.0},
}