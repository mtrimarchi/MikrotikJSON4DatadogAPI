{

# Datadog API Settings
:local apikey "a1b2c3...DATADOG APIKEY";
:local applicationkey "a1b2c3...DATADOG APPLICATION KEY";
:local ddendpoint "https://app.datadoghq.com/api/v1";
:local type "gauge";
:local tags "source:mikrotik";

# Misc variables for stuff and things.
:local metrics;
:local metric "";
:local value "";
:local httpdata "";
:local datetime [$timestamp];
:local identity [/system identity get name];

# Exceptional metrics pre-declared due to some additional checks

# system resource bad-blocks
:local badblocks [/system resource get bad-blocks];
:if ([:len $badblocks] = 0) do={
    :set badblocks 0;
}

# system resource write-sect-total
:local writesecttotal [/system resource get write-sect-total];
:if ([:len $writesecttotal] = 0) do={
    :set writesecttotal 0;
}

# system resource write-sect-since-reboot
:local writesectsincereboot [/system resource get write-sect-since-reboot];
:if ([:len $writesectsincereboot] = 0) do={
    :set writesectsincereboot 0;
}

# system health voltage
:local healthvoltage [/system health get voltage];
:if ([:len $healthvoltage] = 0) do={
    :set healthvoltage 0;
}

# system health current
:local healthcurrent [/system health get current];
:if ([:len $healthcurrent] = 0) do={
    :set healthcurrent 0;
}

# system health temperature
:local healthtemperature [/system health get temperature];
:if ([:len $healthtemperature] = 0) do={
    :set healthtemperature 0;
}

# system health cpu-temperature
:local healthcputemperature [/system health get cpu-temperature];
:if ([:len $healthcputemperature] = 0) do={
    :set healthcputemperature 0;
}

# system health power-consumption
:local healthpowerconsumption [/system health get power-consumption];
:if ([:len $healthpowerconsumption] = 0) do={
    :set healthpowerconsumption 0;
}

# system health fan1-speed
:local healthfan1speed [/system health get fan1-speed];
:if ([:len $healthfan1speed] = 0) do={
    :set healthfan1speed 0;
}

# system health fan2-speed
:local healthfan2speed [/system health get fan2-speed];
:if ([:len $healthfan2speed] = 0) do={
    :set healthfan2speed 0;
}

# Create metrics array
:set metrics {
    "system.cpu.load"=[/system resource get cpu-load];
    "system.memory.total"=[/system resource get total-memory];
    "system.memory.free"=[/system resource get free-memory];
    "system.disk.hddspace.total"=[/system resource get total-hdd-space];
    "system.disk.hddspace.free"=[/system resource get free-hdd-space];
    "system.disk.writesect.total"=$writesecttotal;
    "system.disk.writesect.sincereboot"=$writesectsincereboot;
    "system.disk.badblocks"=$badblocks;
    "system.firewall.connections"=[/ip firewall connection print count-only];
    "system.ppp.all"=[/ppp active print count-only];
    "system.ppp.sstp"=[/ppp active print count-only where service=sstp];
    "system.ppp.pptp"=[/ppp active print count-only where service=pptp];
    "system.ppp.ovpn"=[/ppp active print count-only where service=ovpn];
    "system.ppp.pppoe"=[/ppp active print count-only where service=pppoe];
    "system.ppp.l2tp"=[/ppp active print count-only where service=l2tp];
    "system.health.voltage"=$healthvoltage;
    "system.health.current"=$healthcurrent;
    "system.health.temperature"=$healthtemperature;
    "system.health.temperature.cpu"=$healthcputemperature;
    "system.health.consumption"=$healthpowerconsumption;
    "system.health.fanspeed.1"=$healthfan1speed;
    "system.health.fanspeed.2"=$healthfan2speed;
}

# Additional values that we can add to main metrics array

# monitor-traffic tx/rx bps on all ethernet interfaces
:foreach interface in=[/interface ethernet find] do={
    :local intfName [/interface get $interface name];
    /interface monitor-traffic $intfName once do={
        :set ($metrics->("system.interfaces.".$intfName.".tx-bits-per-second")) (tx-bits-per-second / 1024);
        :set ($metrics->("system.interfaces.".$intfName.".rx-bits-per-second")) (rx-bits-per-second / 1024);
    }
}

# monitor-traffic tx/rx bps on all vlan interfaces
:foreach interface in=[/interface vlan find] do={
    :local intfName [/interface get $interface name];
    /interface monitor-traffic $intfName once do={
        :set ($metrics->("system.interfaces.".$intfName.".tx-bits-per-second")) (tx-bits-per-second / 1024);
        :set ($metrics->("system.interfaces.".$intfName.".rx-bits-per-second")) (rx-bits-per-second / 1024);
    }
}

# monitor-traffic tx/rx bps on all bridge interfaces
:foreach interface in=[/interface bridge find] do={
    :local intfName [/interface get $interface name];
    /interface monitor-traffic $intfName once do={
        :set ($metrics->("system.interfaces.".$intfName.".tx-bits-per-second")) (tx-bits-per-second / 1024);
        :set ($metrics->("system.interfaces.".$intfName.".rx-bits-per-second")) (rx-bits-per-second / 1024);
    }
}

# monitor-traffic tx/rx bps on all bonding interfaces
:foreach interface in=[/interface bonding find] do={
    :local intfName [/interface get $interface name];
    /interface monitor-traffic $intfName once do={
        :set ($metrics->("system.interfaces.".$intfName.".tx-bits-per-second")) (tx-bits-per-second / 1024);
        :set ($metrics->("system.interfaces.".$intfName.".rx-bits-per-second")) (rx-bits-per-second / 1024);
    }
}

# Datadog JSON data to parse with Datadog API post-timeseries-points

# Open Series
:set httpdata ($httpdata."{\"series\":[");

:foreach metric,value in=($metrics) do={
    :set httpdata ($httpdata."{\"metric\":\"".$metric."\",\"points\":[[".$datetime.",".$value."]],\"type\":\"".$type."\",\"tags\":\"".$tags."\",\"host\":\"".$identity."\"},");
}

# Remove "," on latest "}" when append last info or you will get a 400 Bad Request
# Payload is not in the expected format: invalid character ']' looking for beginning of value

# set system.uptime metric as closing series
:set $metric "system.uptime";
:set $value [$uptimeseconds];
:set httpdata ($httpdata."{\"metric\":\"".$metric."\",\"points\":[[".$datetime.",".$value."]],\"type\":\"".$type."\",\"tags\":\"".$tags."\",\"host\":\"".$identity."\"}");

# Close Series
:set httpdata ($httpdata."]}");

# Call API via POST
:set ddendpoint ($ddendpoint."/series\?api_key=".$apikey."&application_key=".$applicationkey);
/tool fetch keep-result=no mode=https http-method=post http-header-field="Content-Type:application/json" http-data=$httpdata url=$ddendpoint;

}
