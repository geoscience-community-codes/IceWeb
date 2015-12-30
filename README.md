# IceWeb
**A web-based seismic monitoring system for volcanoes, including a rapid spectrogram browser**

IceWeb is a near-real-time monitoring tool used at the Alaska Volcano Observatory (AVO) since 1998. Its main product are Spectrograms and Reduced Displacement plots, which are linked to the AVO Internal Page. Digital helicorder plots were also part of the IceWeb system, though this feature has not been utilised since 1999 when an Earthworm helicorder module became available.

IceWeb was designed primarily as a tool for the AVO Duty Seismologist, to allow facilitate alarm response. Given the bandwidth limitations of dial-up modems that were commonplace at that time, static web content was the only way to go. Yet the data needed to be near-real-time, i.e. a delay of no more than 10 minutes. This would mean that by the time the Duty Seismologist received an alarm and fired up his home computer, the spectrograms and reduced displacement plots related to that alarm would be available. So there needed to be a software system at AVO that regenerated this web content every 10 minutes.

IceWeb also includes an Alarm System, based on reduced displacement levels defined for each station. This sends email and pager alerts to the AVO Duty Seismologist. All IceWeb parameters, including the alarm settings for individual stations, can be configured over the web suing the IceWeb Setup Utility. This makes IceWeb a truly web-based system. The design decision behind this was to enable the Duty Seismologist to modify alarm settings over the web in case:

* seismicity was escalating at a particular volcano, and the Duty Seismologist only wanted to know when a new level had been reached
* a particular station became noisy (e.g. due to telemetry problems) and was causing false alarms to be sent

While designed primarily as an alarm response system, IceWeb is also a useful laboratory tool, with many AVO staff favouring the spectrograms over traditional helicorder-style displays. A number of Interactive IceWeb Tools were developed to enable AVO staff to generate spectrograms and reduced displacements plots for any volcano for any time period at will. An archive of daily spectrograms was also made accessible. Web-based graphical user interfaces were added as front-ends to all these tools, to allow AVO staff to run these tools remotely.

# History

IceWeb was written by Glenn Thompson at the Alaska Volcano Observatory beginning in March 1998, motivated by some John Benoit and Kent Lindquist for some concept code which they wrote during the Pavlof eruption in 1996. IceWeb was forked to other observatories, including Montserrat where Glenn moved to in January 2000.

The IceWeb helicorders were made redundant by Earthworm helicorders in 1999 and then SWARM in 2005. But the spectrogram browser continued to be a core monitoring tool at AVO and other observatories.

Upon rejoining AVO in November 2008, Glenn wrote IceWeb version 2. This was a complete rewrite, replacing the Perl-CGI web interface with PhP, and refactoring the MATLAB code based on GISMO. 

**As of December 2015, IceWeb spectrograms have also become redundant thanks to Tom Parker's <a href="http://volcanoes.usgs.gov/software/pensive/download.php">"Pensive"</a> application, essentially a Java rewrite of the IceWeb spectrograms...Glenn thinks you should use that instead!**


