<?php
$_ENV{'ANTELOPE'} = "/opt/antelope/4.11";
#
if( !extension_loaded( "Datascope" ) ) { 
        dl( "Datascope.so" ) or die( "Failed to dynamically load Datascope.so" ) ; 
}
$cwd = getcwd();

clearstatcache();
?>
