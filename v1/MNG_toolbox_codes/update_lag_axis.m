function update_lag_axis(app, action,varargin)

load = false;
plt = false;
update_sig = false; 
update_sldr = false;
update_ov = false;
calc_corr = false;
switch action
    case 'init'

        load = true;
        plt = true;
    case 'sig'
        
        load = true;
        update_sig = true;
        update_sldr = true;

    case 'slider'
        update_sldr = true;
        cla(app.ax_lag_xcorr)
        cla(app.ax_lag_overlay)
    case 'calc'
        tmp = [app.sldr_lag_start.Value,app.sldr_lag_end.Value];
        sig1 = app.settings.lagsig1(tmp(1):tmp(2))-mean(app.settings.lagsig1(tmp(1):tmp(2)));
        sig1 = sig1/max(abs(sig1));
        
        sig2 = app.settings.lagsig2(tmp(1):tmp(2))-mean(app.settings.lagsig2(tmp(1):tmp(2)));
        sig2 = sig2/max(abs(sig2));

        app.settings.lagxc = xcorr(sig1, sig2);%abs(xcorr(sig1, sig2));%app.settings.lagxc = abs(xcorr(app.settings.lagsig1(tmp(1):tmp(2)), app.settings.lagsig2(tmp(1):tmp(2))));
        app.settings.lagxcts = ((-1)*(length(app.settings.lagts)-1):(length(app.settings.lagts)-1))*(mean (diff(app.settings.lagts)));
        plot(app.ax_lag_xcorr,app.settings.lagxcts, app.settings.lagxc,'HitTest','off')
        [~,idx] = max(abs(app.settings.lagxc));
        if app.settings.lagxc(idx) < 0
            app.settings.inverse_lagsig = true;
        else
            app.settings.inverse_lagsig = false;
        end
        line(app.ax_lag_xcorr,[app.settings.lagxcts(1) app.settings.lagxcts(end)], [0,0], 'Color', 'k','LineStyle',':','HitTest','off')
        line(app.ax_lag_xcorr,[app.settings.lagxcts(idx) app.settings.lagxcts(idx)], ylim(app.ax_lag_xcorr), 'Color', 'r','HitTest','off')
        lag = (idx-length(app.settings.lagsig1(tmp(1):tmp(2))))*mean(diff(app.settings.lagts));
        app.lbl_lag_lag.Text = ['Lag: ' num2str(lag) ' s'];
        idx = idx-length(app.settings.lagsig1(tmp(1):tmp(2)));
        xlim (app.ax_lag_xcorr, [app.settings.lagxcts(1), app.settings.lagxcts(end)])
        update_ov = true;
        calc_corr = true;

    case 'select'
%         loc = round(varargin{1,1});
        loc = find (app.settings.lagxcts >= varargin{1,1},1);
        tmp = [app.sldr_lag_start.Value,app.sldr_lag_end.Value];
        if app.chkbx_lock.Value
            idx= [];
            while isempty(idx)

                rng = round(2.5/mean(diff(app.settings.lagts)));
                tmp_int = abs(app.settings.lagxc(loc-rng: loc+rng));
                [~,idx] = findpeaks(tmp_int, 'NPeaks',1);
    
                idx = idx-1-rng+loc;
                if isempty(idx)
                    if tmp_int(1) <tmp_int(end)
                        step = round(5/mean(diff(app.settings.lagts)));
                    else
                        step = round(5/mean(diff(app.settings.lagts)))*(-1);
                    end
                    loc = loc+step;
                end
            end

        else
            rng = round(0.5/mean(diff(app.settings.lagts)));
            [~,idx] = max(abs(app.settings.lagxc(loc-rng: loc+rng)));
            
            idx = idx-1-rng+loc;
        end
%         rng = round(0.5/mean(diff(app.settings.lagts)));
%         
%         [~,idx] = max(abs(app.settings.lagxc(loc-rng: loc+rng)));
%         tmp = [app.sldr_lag_start.Value,app.sldr_lag_end.Value];
%         idx = idx-1-rng+loc;
%         if app.settings.lagxc(idx)< 0
%             app.settings.inverse_lagsig = true;
%         else
%             app.settings.inverse_lagsig = false;
%         end
        plot(app.ax_lag_xcorr, app.settings.lagxcts, app.settings.lagxc,'HitTest','off')
        line(app.ax_lag_xcorr,[app.settings.lagxcts(idx), app.settings.lagxcts(idx)], ylim(app.ax_lag_xcorr), 'Color', 'r','HitTest','off')
        line(app.ax_lag_xcorr,[app.settings.lagxcts(1) app.settings.lagxcts(end)], [0,0], 'Color', 'k','LineStyle',':','HitTest','off')
        lag = (idx-length(app.settings.lagsig1(tmp(1):tmp(2))))*mean(diff(app.settings.lagts));
        app.lbl_lag_lag.Text = ['Lag: ' num2str(lag) ' s'];
        idx = idx-length(app.settings.lagsig1(tmp(1):tmp(2)));
        xlim (app.ax_lag_xcorr, [app.settings.lagxcts(1),app.settings.lagxcts(end)])
        update_ov = true;

end

if load 
        tmp = find(strcmp(app.popup_lag_sig1.Value, app.popup_lag_sig1.Items));
        [tmp_data1,tmp_ts1,tmp_name1, tmp_unit1] = current_signal(app, tmp);
%         if app.chkbx_invert_sig1.Value
%             tmp_data1 = tmp_data1.*(-1);
%         end

        tmp_data1(:,2)= tmp_ts1(1):tmp_ts1(1):tmp_ts1(2);
        tmp = find(strcmp(app.popup_lag_sig2.Value, app.popup_lag_sig2.Items));
        [tmp_data2,tmp_ts2,tmp_name2, tmp_unit2] = current_signal(app, tmp);
%         if app.chkbx_invert_sig2.Value
%             tmp_data2 = tmp_data2.*(-1);
%         end
        tmp_data2(:,2)= tmp_ts2(1):tmp_ts2(1):tmp_ts2(2);

        if tmp_ts1(1) < tmp_ts2(1)
            app.settings.lagsig1 = tmp_data1(:,1);
            app.settings.lagts = tmp_data1(:,2);
            app.settings.lagsig2 = interp1(tmp_data2(:,2),tmp_data2(:,1),tmp_data1(:,2));
        else
            app.settings.lagsig2 = tmp_data2(:,1);
            app.settings.lagts = tmp_data2(:,2);
            app.settings.lagsig1 = interp1(tmp_data1(:,2),tmp_data1(:,1),tmp_data2(:,2));
        end        
        
        if ~strcmp(app.popup_lag_int.Value, 'full')       
            tmp = find(vertcat(app.burst_ints.type) ==1);
            brdrs = [];
            for i= 1:length(tmp)
                if strcmp(app.burst_ints(tmp(i)).name, app.popup_lag_int.Value)
                    brdrs = app.burst_ints(tmp(i)).borders;
                end
            end
    
            tmp = find (app.settings.lagts<brdrs(1),1,'last');
            app.settings.lagsig1(1:tmp) = [];
            app.settings.lagsig2(1:tmp) = [];
            app.settings.lagts(1:tmp) = [];
    
            tmp = find (app.settings.lagts>brdrs(2),1,'first');
            app.settings.lagsig1(tmp:end) = [];
            app.settings.lagsig2(tmp:end) = [];
            app.settings.lagts(tmp:end) = [];
        end
        
        if app.chkbx_lag_ma_sig1.Value
            tmp = round(app.edt_lag_ma_sig1.Value / mean(diff(app.settings.lagts))); %% change window centered on curren idx
            app.settings.lagsig1 = movmean(app.settings.lagsig1 ,tmp);
        end

        if app.chkbx_lag_ma_sig2.Value
            tmp = round(app.edt_lag_ma_sig2.Value / mean(diff(app.settings.lagts))); %% change window centered on curren idx
            app.settings.lagsig2 = movmean(app.settings.lagsig2 ,tmp);
        end
        
        app.sldr_lag_start.Limits = [1,length(app.settings.lagts)];
        app.sldr_lag_start.Value = app.sldr_lag_start.Limits(1);
        app.sldr_lag_end.Limits = [1,length(app.settings.lagts)];
        app.sldr_lag_end.Value = app.sldr_lag_end.Limits(2);
end

if plt 
    
    cla(app.ax_lag_sig1)
    cla(app.ax_lag_sig2)
    cla(app.ax_lag_xcorr)
    cla(app.ax_lag_overlay)
    plot (app.ax_lag_sig1,app.settings.lagts,app.settings.lagsig1, Color=[0 0.4470 0.7410])
    hold (app.ax_lag_sig1,'on')
    plot (app.ax_lag_sig1,app.settings.lagts(1:app.sldr_lag_start.Value),app.settings.lagsig1(1:app.sldr_lag_start.Value), Color=[0.8,0.8,0.8]);
    plot (app.ax_lag_sig1,app.settings.lagts(app.sldr_lag_end.Value:length(app.settings.lagts)),app.settings.lagsig1(app.sldr_lag_end.Value:length(app.settings.lagts)), Color=[0.8,0.8,0.8]);
    hold (app.ax_lag_sig1,'off')
    xlim (app.ax_lag_sig1,[app.settings.lagts(1),app.settings.lagts(end)])

    plot (app.ax_lag_sig2,app.settings.lagts,app.settings.lagsig2, Color=[0.8500 0.3250 0.0980])
    hold (app.ax_lag_sig2,'on')
    plot (app.ax_lag_sig2,app.settings.lagts(1:app.sldr_lag_start.Value),app.settings.lagsig2(1:app.sldr_lag_start.Value), Color=[0.8,0.8,0.8]);
    plot (app.ax_lag_sig2,app.settings.lagts(app.sldr_lag_end.Value:length(app.settings.lagts)),app.settings.lagsig2(app.sldr_lag_end.Value:length(app.settings.lagts)), Color=[0.8,0.8,0.8]);
    hold (app.ax_lag_sig2,'off')
    xlim (app.ax_lag_sig2,[app.settings.lagts(1),app.settings.lagts(end)])

end

if update_sig
    app.ax_lag_sig1.Children(3).XData =app.settings.lagts;
    app.ax_lag_sig1.Children(3).YData =app.settings.lagsig1;
    xlim (app.ax_lag_sig1, [app.settings.lagts(1), app.settings.lagts(end)])
     
    app.ax_lag_sig2.Children(3).XData =app.settings.lagts;
    app.ax_lag_sig2.Children(3).YData =app.settings.lagsig2;
    xlim (app.ax_lag_sig2, [app.settings.lagts(1), app.settings.lagts(end)])
    drawnow
end

if update_sldr
    tmp = app.sldr_lag_start.Value;
    app.ax_lag_sig1.Children(2).XData =app.settings.lagts(1:tmp);
    app.ax_lag_sig1.Children(2).YData =app.settings.lagsig1(1:tmp);
    app.ax_lag_sig2.Children(2).XData =app.settings.lagts(1:tmp);
    app.ax_lag_sig2.Children(2).YData =app.settings.lagsig2(1:tmp);

    tmp = app.sldr_lag_end.Value;
    app.ax_lag_sig1.Children(1).XData =app.settings.lagts(tmp:end);
    app.ax_lag_sig1.Children(1).YData =app.settings.lagsig1(tmp:end);
    app.ax_lag_sig2.Children(1).XData =app.settings.lagts(tmp:end);
    app.ax_lag_sig2.Children(1).YData =app.settings.lagsig2(tmp:end);
    drawnow
end

if update_ov
    tmp = [app.sldr_lag_start.Value,app.sldr_lag_end.Value];
    
    sig1 = app.settings.lagsig1(tmp(1):tmp(2))-mean(app.settings.lagsig1(tmp(1):tmp(2)));
    sig1 = sig1/max(abs(sig1));

    sig2 = app.settings.lagsig2(tmp(1):tmp(2))-mean(app.settings.lagsig2(tmp(1):tmp(2)));
    sig2 = sig2/max(abs(sig2));
    if idx>=0
        sig2 = [nan(idx,1);sig2];
    else
        sig1 = [nan(abs(idx),1);sig1];
    end
    
    if app.settings.inverse_lagsig
        sig2 = sig2*(-1);
    end

    plot(app.ax_lag_overlay, sig1, LineWidth=1.5)
    hold (app.ax_lag_overlay, 'on') 
    plot(app.ax_lag_overlay, sig2, LineWidth=1.5)
    hold (app.ax_lag_overlay, 'off')
    xlim (app.ax_lag_overlay, [1,max(length(sig1),length(sig2))])
end
if calc_corr
    tmp = [app.sldr_lag_start.Value,app.sldr_lag_end.Value];
    
    sig1 = app.settings.lagsig1(tmp(1):tmp(2))-mean(app.settings.lagsig1(tmp(1):tmp(2)));
    sig1 = sig1/max(abs(sig1));

    sig2 = app.settings.lagsig2(tmp(1):tmp(2))-mean(app.settings.lagsig2(tmp(1):tmp(2)));
    sig2 = sig2/max(abs(sig2)); 
    if idx>=0
        sig1(1:idx) = [];
        sig2(end-idx+1:end) = [];
    else
        sig2(1:idx) = [];
        sig1(end-idx+1:end) = [];
    end
    rk=999;pk =999;
%     [rk,pk ]  = corr(sig1,sig2,'Type','Kendall');
    [rs,ps ]  = corr(sig1,sig2,'Type','Spearman');
    app.lbl_lag_xcorr.Text = {['Kendalls tau: ' num2str(rk,3) ', p: ' num2str(pk,5)],['Spearmans rho: ' num2str(rs,3) ', p: ' num2str(ps,5)]};

end