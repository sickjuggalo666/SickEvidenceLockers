Config = {}

Config.Target = 'ox_target'

Config.location = {
    {
        UsePed = true, -- Do you want to use a ped?
        coords = vector3(473.6921, -1005.8665, 25.2734), 
        h = 162.1413, 
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
        coords = vector3(300.2429, -580.0558, 42.2609), 
        h = 72.4052, 
        job = 'ambulance',
        AllowedRank = 3, 
        cop = false,
        TargetLabel = 'Open Ambulance Lockers',
        ped = 'S_M_M_Doctor_01'
    }
}

Config.NotificationType = { -- i forgot this on initial drop!SS
    client = 'okokNotify',
    server = 'okokNotify'
}