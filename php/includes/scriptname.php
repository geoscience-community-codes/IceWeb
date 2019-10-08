<?php
function scriptname()
{
$file = $_SERVER["SCRIPT_NAME"];
$break = Explode('/', $file);
$pfile = $break[count($break) - 1]; 
return $pfile;
}
?>
