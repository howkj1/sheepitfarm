# sheepfarm.sh ui map

cli : sheepfarm.sh

___
## Overview

### main menu
1. run latest sheepit
2. configure client
3. download latest sheepit
4. build rendering machine
5. exit / quit

### 1. run latest sheepit
[farm_sheep]
* downloads latest sheepit client
* creates or updates ./sheepfarm.conf
* runs sheepit client with sheepfarm.conf args

### 2. configure client
[updaatesheepitconf]
* overwrites sheepfarm.conf
* takes args for sheepfarm.conf

### 3. download latest sheepit
* downloads official sheepit-latest.jar from https://sheepit-renderfarm.com

### 4. build render machine
* sheep_prep

---

## Configure Client : Args

```
## official sheepit client help ##
 Usage:
  --no-gpu                               : Don't detect GPUs
  --no-systray                           : Don't use systray
  --show-gpu                             : Print available CUDA devices and exit
  --verbose                              : Display log
  --version                              : Display application version
  -cache-dir /tmp/cache                  : Cache/Working directory. Caution,
                                           everything in it not related to the
                                           render-farm will be removed
  -compute-method CPU                    : CPU: only use cpu, GPU: only use gpu,
                                           CPU_GPU: can use cpu and gpu (not at
                                           the same time) if -gpu is not use it
                                           will not use the gpu
  -config VAL                            : Specify the configuration file
  -cores 3                               : Number of cores/threads to use for
                                           the render
  -extras VAL                            : Extras data push on the authentication
                                           request
  -gpu CUDA_0                            : Name of the GPU used for the render,
                                           for example CUDA_0 for Nvidia or
                                           OPENCL_0 for AMD/Intel card
  -login LOGIN                           : User's login
  -memory VAL                            : Maximum memory allow to be used by
                                           renderer, number with unit (800M, 2G,
                                           ...)
  -password PASSWORD                     : User's password
  -priority N                            : Set render process priority (19
                                           lowest to -19 highest)
  -proxy http://login:password@host:port : URL of the proxy
  -rendertime N                          : Maximum time allow for each frame (in
                                           minute)
  -request-time 2:00-8:30,17:00-23:00    : H1:M1-H2:M2,H3:M3-H4:M4 Use the 24h
                                           format. For example to request job
                                           between 2am-8.30am and 5pm-11pm you
                                           should do --request-time 2:00-8:30,17:
                                           00-23:00 Caution, it's the requesting
                                           job time to get a project not the
                                           working time
  -server URL                            : Render-farm server, default https://cl
                                           ient.sheepit-renderfarm.com
  -title VAL                             : Custom title for the GUI Client
  -ui VAL                                : Specify the user interface to use,
                                           default 'swing', available 'oneLine',
                                           'text', 'swing' (graphical)
```
