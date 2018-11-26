{

# Julian Calendar function
:global functionJulianDate do={

:local months [:toarray "jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec"];
:local jd
:local M [:pick $1 0 3];
:local D [:pick $1 4 6];
:local Y [:pick $1 7 11];

:for x from=0 to=([:len $months] - 1) do={
:if ([:tostr [:pick $months $x]] = $M) do={
:set M ($x + 1); } 
}
:if ( $M = 1 || $M = 2) do={
:set Y ($Y-1);
:set M ($M+12);
}

:local A ($Y/100);
:local B ($A/4);
:local C (2-$A+$B);
:local E ((($Y+4716) * 36525)/100);
:local F ((306001*($M+1))/10000);
return ($C+$D+$E+$F-1525);
};

# Timestamp function to get UNIX POSIX timestamp in UTC timezone
:global timestamp do={

:local functionJulianDate $functionJulianDate
:local currenttime [/system clock get time];
:local gmtoffset [/system clock get gmt-offset];
:local jdnow [$functionJulianDate [/system clock get date]];
:local days ($jdnow - 2440587);
:local hours [:pick $currenttime 0 2];
:local minutes [:pick $currenttime 3 5];
:local seconds [:pick $currenttime 6 8];

return (($days * 86400) + ($hours * 3600) + ($minutes * 60) + $seconds - $gmtoffset);
}

# Get uptime in seconds
:global uptimeseconds do={

:local UptimeSeconds 0;
:local uptime [/system resource get uptime];
:local weekend 0;
:local dayend 0;
:local weeks 0;
:local days 0;

:if ([:find $uptime "w" -1] > 0) do={
:set weekend [:find $uptime "w" -1];
:set weeks [:pick $uptime 0 $weekend];
:set weekend ($weekend+1);
};

:if ([:find $uptime "d" -1] > 0) do={
:set dayend [:find $uptime "d" -1];
:set days [:pick $uptime $weekend $dayend];
};

:local time [:pick $uptime ([:len $uptime]-8) [:len $uptime]]; 

:local hours [:pick $time 0 2];
:local minutes [:pick $time 3 5];
:local seconds [:pick $time 6 8]; 

return ($weeks*86400*7+$days*86400+$hours*3600+$minutes*60+$seconds);
}

}
