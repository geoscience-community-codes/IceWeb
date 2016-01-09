<?php

function allFactors($n) {
 $factors_array = array();
 for ($x = 1; $x <= sqrt(abs($n)); $x++)
 {
    if ($n % $x == 0)
    {
        $z = $n/$x; 
        array_push($factors_array, $x, $z);
       }
   }
   return $factors_array;
 }

?>
