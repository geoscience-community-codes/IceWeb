function [spectrogram_position,trace_position]=calculate_frame_positions(numstations,frame_num,spectrogram_fraction);

global parameterspf;
panel_width=pfget_num(parameterspf,'panel_width');
panel_height=pfget_num(parameterspf,'panel_height');

frame_height = panel_height/numstations;
spectrogram_height = spectrogram_fraction * frame_height;
trace_height = (1-spectrogram_fraction) * frame_height; 
panel_left=(1-panel_width)/2;
panel_base=0.03+(1-panel_height)/2;
spectrogram_position=[panel_left, panel_base+(frame_height*(frame_num-1)), panel_width, spectrogram_height];
trace_position=[panel_left, panel_base+(frame_height*(frame_num-1))+spectrogram_height, panel_width, trace_height];
