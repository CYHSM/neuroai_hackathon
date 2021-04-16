# Description of the dataset Stensola2012 v1.2.1

This file contains description of data in the dataset. The dataset consists of recordings found in folder `recordings` and files `readNwb.m`, `cell_list.csv`:
* `readNwb.m`. Shows an example of how to read information from a data file.
* `cell_lists.csv`. Contains the overview of single units included in the dataset.

The file name of data files consist of animal number part and session ID part, i.e. `animalName_sessionID.h5`. Session ID consists mostly of a recording date. An example of a session ID is `2011-02-16_18-07-33`.

Each data file contains:
* Animal tracked coordinates and corresponding timestamps.
* Spike timestamps from single units.
* EEG signals.

Files inside the `recordings` folder are in [NWB format](http://www.nwb.org/). It is possible to quickly inspect the content of files by using [HDFView app](https://www.hdfgroup.org/products/java/hdfview/). You can also use the Matlab script `readNwb.m` to get an idea of how to read files in this format. You will need the Statistics and Machine Learning Matlab Toolbox in order to run the provided scripts.

Refer to the NWB format for description of fields inside .h5 files. Here is the list of most important fields:
* `/acquisition/timeseries/<sessionName>-LED1` Raw position data as output by tracking software.
* `/acquisition/timeseries/<sessionName>-LED2` Raw position data as output by tracking software.
* `/epochs`. Contains information about individual recording sessions. Most of the recordings consist only from a single epoch (whole recording).
* `/processing/matlab_scripts/Position/body` Contains processed position data. Position samples here have been smoothed, interpolated, and converted to meters.
* `/processing/matlab_scripts/UnitTimes/`. Contains spike timestamps from single units.

## Deformation experiment

Data that correspond to experiment of functional independence of grid modules are found inside folder `recordings/deformation`. The format of data inside `h5` files is the same as for other recording files except that these files contain no EEG signal. The folder contains also file `Cells_overview.xlsx`, which describes cell correspondence between different recordings. Some cells were not stable enough to be recorded through multiple recording sessions and thus information about them is missing from the file.

## How to cite the data

A publication based on the data is:
* [Stensola, H., 2012, "The entorhinal grid map is discretized", Nature, 492, 72-78](http://dx.doi.org/10.1038/nature11649)

You can use the data for whatever you want. All we ask is that you refer to the above publication in your Methods section when you write up the results (at the same time we take no responsibility for what is published!).

Please do not hesitate to contact us for updates and information at [edvard.moser@ntnu.no](mailto:edvard.moser@ntnu.no).

## Change log

### [1.2.1] - 2017-04-18
 - Rebuilt with up-to-date code.

### [1.2.0] - 2017-02-27
 - Fixed a bug in Axona data loading which resulted in lost correspondence between tracking data and spikes.
 - Put all kinds of data in the dataset: NeuraLynx recordings, Axona, deformation experiment.

### [1.1.0] - 2017-01-05
 - Added data that correspond to deformation experiment.

### [1.0.0] - 2016-09-30
 - Initial release.

*Last updated on 2017-04-18.*