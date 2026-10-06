-- Client Job Module

Bridge = Bridge or {}
Bridge.Job = Bridge.Job or {}

-- Helper: Ensure framework is ready
local function EnsureFrameworkReady()
    if Bridge.EnsureReady then
        Bridge.EnsureReady()
    elseif not Bridge.Ready then
        while not Bridge.Framework do
            Wait(100)
        end
    end
end

-- Get current job of local player
function Bridge.Job.GetJob()
    EnsureFrameworkReady()
    local playerData = Bridge.GetPlayerData()

    if Bridge.Framework == 'esx' then
        return playerData.job or {}
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return playerData.job or {}
    elseif Bridge.Framework == 'standalone' then
        return {
            name = 'unemployed',
            label = 'Unemployed',
            grade = 0
        }
    end
    return {}
end

-- Get job name
function Bridge.Job.GetJobName()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()
    return job.name or 'unemployed'
end

-- Get job label
function Bridge.Job.GetJobLabel()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()
    return job.label or 'Unknown'
end

-- Get job grade
function Bridge.Job.GetGrade()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()

    if Bridge.Framework == 'esx' then
        return job.grade or 0
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return job.grade and job.grade.level or 0
    end

    return 0
end

-- Get job grade name
function Bridge.Job.GetGradeName()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()

    if Bridge.Framework == 'esx' then
        return job.grade_name or 'Unknown'
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return job.grade and job.grade.name or 'Unknown'
    end

    return 'Unknown'
end

-- Check if player has specific job
function Bridge.Job.HasJob(jobName, minGrade)
    EnsureFrameworkReady()
    minGrade = minGrade or 0
    local job = Bridge.Job.GetJob()

    if not job or not job.name then return false end

    local grade = Bridge.Job.GetGrade()
    return job.name == jobName and grade >= minGrade
end

-- Check if player has any of the jobs
function Bridge.Job.HasAnyJob(jobList, minGrade)
    EnsureFrameworkReady()
    minGrade = minGrade or 0

    for _, jobName in ipairs(jobList) do
        if Bridge.Job.HasJob(jobName, minGrade) then
            return true
        end
    end

    return false
end

-- Get job duty status
function Bridge.Job.IsOnDuty()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()

    if Bridge.Framework == 'esx' then
        -- ESX has no duty system by default, always on duty
        return true
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return job.onduty or false
    end

    return true
end

-- Toggle duty status (client-side)
function Bridge.Job.ToggleDuty()
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        -- ESX has no duty system by default
        return false
    elseif Bridge.Framework == 'qbcore' then
        TriggerServerEvent('QBCore:ToggleDuty')
        return true
    elseif Bridge.Framework == 'qbox' then
        TriggerServerEvent('QBCore:ToggleDuty')
        return true
    elseif Bridge.Framework == 'standalone' then
        return false
    end
    return false
end

-- Set duty status (client-side)
function Bridge.Job.SetDuty(onDuty)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        -- ESX has no duty system by default
        return false
    elseif Bridge.Framework == 'qbcore' then
        TriggerServerEvent('QBCore:Server:SetDuty', onDuty)
        return true
    elseif Bridge.Framework == 'qbox' then
        TriggerServerEvent('QBCore:Server:SetDuty', onDuty)
        return true
    elseif Bridge.Framework == 'standalone' then
        return false
    end
    return false
end

-- Get job type
function Bridge.Job.GetJobType()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()

    if Bridge.Framework == 'esx' then
        -- ESX has no job type field by default
        return 'none'
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return job.type or 'none'
    end

    return 'none'
end

-- Check if job is specific type
function Bridge.Job.IsJobType(jobType)
    EnsureFrameworkReady()
    return Bridge.Job.GetJobType() == jobType
end

-- Check if player is boss/management
function Bridge.Job.IsBoss()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()

    if Bridge.Framework == 'esx' then
        -- ESX checks for grade_name 'boss'
        return job.grade_name == 'boss'
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        -- QBCore/QBX has isboss field
        return job.isboss or false
    end

    return false
end

-- Get job payment (salary)
function Bridge.Job.GetPayment()
    EnsureFrameworkReady()
    local job = Bridge.Job.GetJob()

    if Bridge.Framework == 'esx' then
        return job.grade_salary or 0
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return job.payment or 0
    end

    return 0
end

-- Check if job is a whitelist job (LEO, EMS, etc.)
function Bridge.Job.IsWhitelistJob()
    EnsureFrameworkReady()
    local whitelistJobs = {
        'police', 'sheriff', 'ambulance', 'doctor', 'mechanic', 'judge', 'lawyer'
    }

    local jobName = Bridge.Job.GetJobName()
    for _, job in ipairs(whitelistJobs) do
        if jobName == job then
            return true
        end
    end

    return false
end

-- Check if job is a LEO (Law Enforcement) job
function Bridge.Job.IsLeo()
    EnsureFrameworkReady()
    local leoJobs = {
        'police', 'sheriff', 'statepolice', 'ranger', 'corrections'
    }

    local jobName = Bridge.Job.GetJobName()
    for _, job in ipairs(leoJobs) do
        if jobName == job then
            return true
        end
    end

    return false
end

-- Check if job is an EMS/Medical job
function Bridge.Job.IsEMS()
    EnsureFrameworkReady()
    local emsJobs = {
        'ambulance', 'doctor', 'ems', 'medic'
    }

    local jobName = Bridge.Job.GetJobName()
    for _, job in ipairs(emsJobs) do
        if jobName == job then
            return true
        end
    end

    return false
end

-- Get gang (QBCore/QBX only)
function Bridge.Job.GetGang()
    EnsureFrameworkReady()

    if Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        local playerData = Bridge.GetPlayerData()
        return playerData.gang or {}
    end

    return {}
end

-- Get gang name
function Bridge.Job.GetGangName()
    EnsureFrameworkReady()
    local gang = Bridge.Job.GetGang()
    return gang.name or 'none'
end

-- Check if in gang
function Bridge.Job.IsInGang(gangName)
    EnsureFrameworkReady()
    local gang = Bridge.Job.GetGang()
    if gangName then
        return gang.name == gangName
    end
    return gang.name ~= 'none' and gang.name ~= nil
end
