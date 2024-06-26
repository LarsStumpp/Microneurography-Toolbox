function auto_bp(app) 
%auto_Bb checks if bb is already detected and runs  if
%not 
%   Detailed explanation goes here
if isempty(app.bp_res)

    [data,ts,~, ~] = current_signal(app, app.settings.channel_idx.bldp);
    data = lowpass(data,3,1/ts(1));
    [ footIndex, systolicIndex, notchIndex, dicroticIndex ] = ...
    bp_dect( data, 200, 1, 'mmHg', 1);
    results.foot_idx = footIndex;
    results.systolic_idx = systolicIndex;
    results.notch_idx = notchIndex;
    results.dicrotic_idx = dicroticIndex;
    results.ts = ts(1);
    app.bp_res = results;
    derived_bp_signals(app)
end
end