# sheepfarm.sh ui map

cli : sheepfarm.sh

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
