# MikrotikJSON4DatadogAPI

This is a simple example to generate and push metrics in JSON format to Datadog API using RouterOS scripting language.

I'm using [Timeseries Points](https://docs.datadoghq.com/api/?lang=bash#post-timeseries-points) `POST` Datadog API call.


With this example you can generate a dashboard like that:

![datadog-public-dashboard-example](https://github.com/mtrimarchi/MikrotikJSON4DatadogAPI/raw/master/datadog-public-dashboard-example.png "Datadog public dashboard example")

So, let's go!

# First step, LoadGlobalFunctions.rsc

At first, we need to add some basic global functions and load them on startup.

You have to go on `System \ Scheduler` and add a new Schedule.

Configure the schedule this way:
- **Schedule name** → `LoadAllFunctions`
- **Start Date** → `Nov/27/2018`
- **Start Time** → `startup`
- **Interval** → `00:00:00`
- **On Event** → _just copy/paste [LoadGlobalFunctions.rsc](https://github.com/mtrimarchi/MikrotikJSON4DatadogAPI/raw/master/LoadGlobalFunctions.rsc) content_

Ok, now if we reboot our router we will get loaded three functions. We can find them on `System \ Scripts \ Environment`.
These loaded scripts are named:
- **functionJulianDate** _Julian Calendar function wich convert RouterOS date call in JD format seconds_
- **timestamp** _Timestamp function to get UNIX POSIX timestamp in UTC timezone_
- **uptimeseconds** _Get uptime in seconds_

# Second step, DatadogMonitoring.rsc

... todo ...
