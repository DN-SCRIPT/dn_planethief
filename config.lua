Config              = {}
Config.DrawDistance = 100
Config.CopsRequired = 1
Config.BlipUpdateTime = 3000 --In milliseconds. I used it on 3000. If you want instant update, 50 is more than enough. Even 100 is good. I hope it doesn't kill FPS and the server.
Config.CooldownMinutes = 10
Config.Locale = 'en'


Config.Zones = {
	VehicleSpawner = {
		Pos   = {x = -941.6364, y = -2955.0425, z = 13.9451},
		Size  = {x = 1.0, y = 1.0, z = 1.0},
		Color = {r = 255, g = 0, b = 0},
		Type  = 33,
		Colour = 1, --BLIP
		Id = 423, --BLIP
	},
}

Config.VehicleSpawnPoint = {
      Pos   = {x = -898.3793, y = -3197.8198, z = 13.9447}, 
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Type  = -1,
}

Config.Delivery = {

	Delivery1 = {
		Pos   = {x = 2139.4851, y = 4806.1733, z = 40.4881},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 255, g = 0, b = 0},-- rgb
		Type  = 1,
		Payment  = 20000, -- payment
		plain = {'frogger','plaingobob4','cuban800','frogger2','maverick'}, -- plain
	},
    	Delivery4 = {
		Pos   = {x = 1721.7561, y = 3256.2839, z = 40.1938},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 255, g = 0, b = 0},
		Type  = 1,
		Payment  = 20000, -- payment
		plain = {'shamal','luxor','cuban800','titan','turismor'}, -- plain
	},
    	Delivery7 = {
		Pos   = {x = -2116.0471, y = 2867.0911, z = 31.9829},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 255, g = 0, b = 0}, -- rgb
		Type  = 1,
		Payment  = 20000, -- payment
		plain = {'vestra','Besra','valkyrie','duster','microlight'}, -- plain
	},

}
