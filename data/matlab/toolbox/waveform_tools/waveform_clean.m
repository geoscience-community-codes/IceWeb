function [w,filtered]=waveform_clean(w, varargin)
% [w,filtered] = waveform_clean(w)
print_debug(sprintf('> %s',mfilename),2);
warning on;

[remove_calibs, remove_spikes, remove_trend, remove_response, interactive_mode, filterObj] = ...
    process_options(varargin, 'remove_calibs', true, 'remove_spikes', true, 'remove_trend', true, 'remove_response', false, ...
    'interactive_mode', false, 'filterObj', filterobject('b',[0.5 15],2) );

if remove_calibs
    try
        w=waveform_removeCalibrationPulses(w);
    catch
        disp('waveform_removeCalibrationPulses failed');
    end
end

for c = 1: length(w)
    if remove_spikes
        if interactive_mode
            figure;
            plot(w(c));
            title('raw');
            anykey();
        
            %w(c)=waveform_spike(w(c));
            figure;
            plot(w(c));
            title('spiked');
            anykey();        
        end
    
        % despike & declip
        m = median(abs(w(c)));
        while std(w(c)) > 100*m
            w(c) = clip(w(c),100*m);
            w(c) = waveform_despike(w(c));
            m = median(abs(w(c)));
        end
        if interactive_mode
            figure;
            plot(w(c));
            title('despiked');
            anykey();
        end  
    end
    
    if remove_trend
        w(c) = detrend(fillgaps(w(c),mean(w(c))));
        if interactive_mode
            figure;
            plot(w(c));
            title('detrended');
            anykey();
        end   
    end

    % high pass filter (and remove response if requested)
    filtered = false;
    if remove_response
            try
                resp = get(w, 'response');
                if ~isempty(resp)
                    w(c) = response_apply(w(c), filterObj, 'structure', resp);
                else
                    w(c) = response_apply(w(c),filterObj,'antelope','dbmaster/master_stations');
                end
                filtered = true;
            catch
                warning(sprintf('response_apply failed .\nTrying to bandpass instead.'));
            end
    end

    if ~filtered
            try
                w(c) = waveform_bandpass(w(c),filterObj); 
                filtered = true; 
            end
    end       
    if ~filtered
        warning('Cannot filter waveform');
    end
    
end

print_debug(sprintf('< %s',mfilename),2);
