// Functions
export function FormatMoney(s) {
    s = parseInt(s);
    return s.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
}

export function CalculateVehicleStatistic(type, SelectedVehicleTable, VehicleStatisticMaxValues) {
    let value;
    if (type == 'speed') {
        value = Math.round((SelectedVehicleTable.VehicleTopSpeed / VehicleStatisticMaxValues.MaxSpeed) * 100);
        return value < 60 ? 67 : value;
    } else if (type == 'brake') {
        value = (SelectedVehicleTable.VehicleBraking / VehicleStatisticMaxValues.MaxBrake) * 100;
        return value < 50 ? 58 : value;
    } else if (type == 'acceleration') {
        value = Math.round((SelectedVehicleTable.VehicleAcceleration / VehicleStatisticMaxValues.MaxAcceleration) * 100);
        return value < 50 ? 62 : value;
    } else if (type == 'suspension') {
        value = Math.round((SelectedVehicleTable.VehicleSuspension / VehicleStatisticMaxValues.MaxSuspension) * 100);
        return value < 50 ? 62 : value;
    } else if (type == 'handling') {
        value = Math.round((SelectedVehicleTable.VehicleHandling / VehicleStatisticMaxValues.MaxHandling) * 100);
        return value < 50 ? 55 : value;
    }
}

export function ShowNotify(type, text, ms, NotifySettings, SoundPlayer) {
    if (NotifySettings.Show) return;

    if (type && text && ms) {
        let seconds = ms / 1000;
        NotifySettings.Show = true;
        NotifySettings.Type = type;
        NotifySettings.Message = text;
        NotifySettings.Time = seconds;
        SoundPlayer('notification.wav');
        setTimeout(() => {
            NotifySettings.Show = false;
            NotifySettings.Type = '';
            NotifySettings.Message = '';
            NotifySettings.Time = 0;
        }, ms);
    }
}