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

First of all we need to generate an `API Key` and a new `Application Key`. We can do it [here](https://app.datadoghq.com/account/settings#api).

Once created both keys, as already done before, we have to add a new Schedule. This one generate the JSON data and push it to Datadog API using `fetch` command. We need to adapt vars on the script because when we call Datadog API we need to identify ourself with the generated `API key` and `Application key`.

When you copy [DatadogMonitoring.rsc](https://github.com/mtrimarchi/MikrotikJSON4DatadogAPI/raw/master/DatadogMonitoring.rsc) pay attention to the first part of the script identified as "Datadog API Settings".

Adapt all the values:
- **apikey** → _Your API keys are unique to your organization. An API key is required by the Datadog Agent to submit metrics and events to Datadog._
- **applicationkey** → _Application keys, in conjunction with your org's API key, give you full access to Datadog's programmatic API. Application keys are associated with the user account that created them and can be named. The application key is used to log all requests made to the API._
- **ddendpoint** → `"https://app.datadoghq.com/api/v1"` _URL Datadog API endpoint._
- **type** → `"gauge"` _[optional, default=gauge]: Type of your metric either: gauge, rate, or count._
- **tags** → `"source:mikrotik"` _[optional, default=None]: A list of tags associated with the metric._

Now you have to go once again on `System \ Scheduler` and add a new Schedule.

Configure the schedule this way:
- **Schedule name** → `DatadogMonitoring`
- **Start Date** → `Nov/27/2018`
- **Start Time** → `00:00:00`
- **Interval** → `00:00:05`
- **On Event** → _copy/paste the modified content of DatadogMonitoring.rsc_

You can adjust `Interval` seconds value in order to change the frequency timeframe for generation and push of the JSON to Datadog.

# Let's test!

You can see `system.cpu.load` metric using `Metrics Explorer` on Datadog website.

Click here for an example: [https://app.datadoghq.com/metric/explorer?live=true&exp_metric=system.cpu.load](https://app.datadoghq.com/metric/explorer?live=true&exp_metric=system.cpu.load)
