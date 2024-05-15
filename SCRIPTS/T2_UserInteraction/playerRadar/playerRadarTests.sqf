// [] spawn NWG_RADAR_CountFps
NWG_RADAR_CountFps = {
    private _endTime = time + 10;
    private _polls = 0;
    private _fps = 0;
    waitUntil {
        sleep 0.1;
        _polls = _polls + 1;
        _fps = _fps + diag_fps;
        time > _endTime
    };
    systemChat format ["[%1]: Average FPS: %2",time,(_fps/_polls)];
};

// call NWG_RADAR_Disable
NWG_RADAR_Disable = {
    NWG_RADAR_OnEachFrame = {};
};