Config = {}
Config.Framework = 'QBCore'
Config.Target = 'ox_target'

Config.location = {
    {
        UsePed = true, -- Do you want to use a ped?
        coords = vector3(98.7446, -961.8238, 28.4538), 
        h = 246.6253, 
        size = vec3(3, 2, 3), -- size of the box zone
        rotation = 90, -- Rotation of box zone
        AllowedRank = 3, -- allowed ranks for Chief Options
        cop = true,  -- is this a police job? allows evidence lockers
        job = 'police', -- what job do you want here?
        TargetLabel = 'Open Evidence', -- easier to label for each job
        ped = 's_m_m_armoured_01' -- ped is now location/job based
    },
    {
        UsePed = true,
        coords = vector3(96.9536, -968.1559, 28.4064), 
        h = 239.6446, 
        job = 'ambulance',
        AllowedRank = 3, 
        cop = false,
        TargetLabel = 'Open Ambulance Lockers',
        ped = 'S_M_M_Doctor_01'
    }
}

Config.NotificationType = {
    client = 'ox_libs'
}