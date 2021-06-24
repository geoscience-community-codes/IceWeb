# iceweb_uafgi
Volcanic tremor monitoring system, forked from giseislab

IceWeb has been running at UAFGI since May 1998. The version here is a copy of what I was running at UAFGI in early 2013. 
This used the Antelope rtexec framework to run, monitor and autorestart various modules and thereby improve overall robustness.
A pipeline approach was taken where one program created 10-minute waveform files, another processed those waveform files into spectrogram plots, etc.
Multiple copies of each job could be fired up to parallelize the work, with lockfiles used to prevent any collisions.
This is quite different to the simpler but less robust way spectrograms are implemented in GISMO, or in Pensive.

Codes exist to periodically query waveform data servers for existing operational seismic stations, and update the IceWeb configuration files accordingly. 
If run, these prevent blank data channels appearing on spectrograms. 

Various data quality checks are also done to eliminate poor waveform data.

The PhP interface was implemented because back in the late-1990s, AVO had relatively powerful Sun workstation servers but the Duty Seismologist at home
would have only a low power desktop computer, so it was important to keep as much processing as possible on the server-side. 
Today, the Javascript approach employed in Pensive is better.

Pensive is essentially a clone of IceWeb from MATLAB/PhP to Java.
