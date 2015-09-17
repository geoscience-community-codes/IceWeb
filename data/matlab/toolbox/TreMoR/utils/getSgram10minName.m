function tenminspfile = getSgram10minName(paths, subnet, enum)
debug.printfunctionstack('>');
timestamp = datestr(enum, 30);
spdir = fullfile(paths.spectrogram_plots, subnet, timestamp(1:4), timestamp(5:6), timestamp(7:8));
tenminspfile = fullfile(spdir, [timestamp, '.png']);
debug.printfunctionstack('<');
