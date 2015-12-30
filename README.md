# IceWeb
**A web-based seismic monitoring system for volcanoes, including a rapid spectrogram browser**

IceWeb is a near-real-time monitoring tool used at the Alaska Volcano Observatory (AVO) since 1998. Its main product are:

* mosaics of 10-minute and daily spectrograms, each image file containing spectrograms for multiple stations
* reduced displacement plots (think of them as calibrated RSAM plots) with a sampling rate of 1 sample per minute
* hourly and daily pseudo-helicorder plots

All these plots are updated every 10 minutes and linked to the AVO Internal Page. 

IceWeb was designed primarily as a tool for the AVO Duty Seismologist, to facilitate alarm response. Given the bandwidth limitations of dial-up modems that were commonplace in 1998 in Fairbanks, static web content was the only way to go. Yet the data needed to be near-real-time, i.e. a delay of no more than 10 minutes. This would mean that by the time the Duty Seismologist received an alarm and fired up his home computer, the spectrograms and reduced displacement plots related to that alarm would be available. 

IceWeb also includes a tremor alarm system, based on reduced displacement thresholds manually set for each station/channel. This sends email and pager alerts to the AVO Duty Seismologist when a manually set number of station/channels trigger simultaneously. A web-based GUI allows the Duty Seismologist to alter which volcanoes and which station/channels for each volcano are being monitored, and to adjust the thresholds for each station/channel. In the middle of the night in case, for example:

* As seismicity continues to escalate at a particular volcano, it is sometimes desirable to raise the threshold from (say) 5cm^2 to (say) 10cm^2, rather than have alarms repeat at the same level.
* If a particular station became noisy (e.g. due to telemetry problems) and is causing false alarms to be sent, it can be turned off, allowing the Duty Seismologist to sleep.

IceWeb GUIs were developed to enable AVO staff to generate spectrograms and reduced displacements plots for any volcano for any time period at will.

While designed primarily as an alarm response system, IceWeb is also an exceptionally useful laboratory tool, with many AVO staff favouring the spectrograms over traditional helicorder-style displays. Indeed, IceWeb spectrograms quickly became established as the most efficient way to analyze 24-hours of seismicity at up to 30 volcanoes, each with up to 8 displayed stations. 

# Development History

I wrote IceWeb while a postdoc at the Alaska Volcano Observatory beginning in March 1998, motivated by work John Benoit and Kent Lindquist did during the Pavlof eruption in 1996. IceWeb was forked to other observatories, including Montserrat where I moved to in January 2000.

The IceWeb helicorders were made redundant by Earthworm helicorders in 1999 and then SWARM in 2005. But the spectrogram browser continued to be a core monitoring tool at AVO and other observatories.

Upon rejoining AVO in November 2008, I wrote IceWeb version 2. This was a complete rewrite, replacing the Perl-CGI web interface with PhP, and refactoring the MATLAB code based on <a href="https://geoscience-community-codes.github.io/GISMO">GISMO</a>. This enables IceWeb to read waveform data from IRIS/FDSN web services, EW/WinstonWS, Antelope databases, Miniseed/SAC/Seisan files etc. 

I saw Tom's earliest work at a modern reimplementation in 2006 and I've always been very encouraging of this because that MATLAB part needed to go. 

- Glenn

* In 2008 I rebuilt IceWeb on GISMO - a seismic data analysis toolbox/framework for MATLAB. It is GISMO that provides these data reading capabilities, IceWeb just has access to them via GISMO. GISMO also reads a wide variety of catalog data formats/sources, and reads RSAM binary files and creates RSAM data too. I've also ported some of that functionality to Python to enhance ObsPy for volcano-seismic data analysis/research.
 
IceWeb's weakest link is it uses MATLAB to generate the image files. While MATLAB is great for rapid prototyping, the license requirement limited IceWeb's wider adoption for the USGS Volcano Disaster Assistance Program. So back as far as 1999 I planned to rewrite it in C (hence my interest in the Earthworm sgram module), but that project never rose to the top of my to-do list. However, **as of December 2015, IceWeb spectrograms have also become redundant thanks to Tom Parker's <a href="http://volcanoes.usgs.gov/software/pensive/index.php">"Pensive"</a> application, essentially a Java rewrite of the IceWeb spectrograms...I encourage you to use that instead for real-time operations!**

-- Glenn Thompson


