# DCIA
Discriminant Context Information Analysis for Post-Ranking Person Re-Identification - IEEE Transcations on Image Processing 2017

This package provides you an updated version of the MATLAB code for following paper: 
Garcia J., Martinel N., Gardel A., Bravo I., Foresti G.L., Micheloni C., "Discriminant Context Information Analysis for Post-Ranking Person Re-Identification"
Published in IEEE Transcations on Image Processing 2017

## USAGE:

### Simple Demo
```MATLAB
 startup;
```
Initialize all the directiories which are needed to run the main algorithm

```MATLAB
DCIA_test_viper_baseline
```
Evaluates the DCIA improvement over the four selected baseline methods (i.e., KCCA/KISSME/LADF/Euclidean) using the VIPeR dataset. Results, like the CMC and the normalized Area Under Curve are stored in the "results" folder.
Result structures are stored as "results/DATASET NAME/EXPERIMENT ID/results.mat" where DATASET NAME and EXPERIMENT ID are user defined.

### Algorithm Settings
If you want to play with the approach parameters, please refer to the ``run_experiment.m`` and ``DCIA_InitParameter.m`` files.

### Different Dataset/Features
To evaluate the proposed approach with a different dataset you should generate a data structure named ``dataset`` that has the following fields:
+ ``name``: name of the dataset;
+ ``count``: scalar value indicating the total number of images in the dataset;
+ ``index``: row vector 1:total number of images in the dataset;
+ ``imageNames``: cell array containing the image paths;
+ ``personID``: row vector contatining the person IDs;
+ ``cam``: row vector containing the camera IDs;
+ ``images``: 4D matrix of the form H x W x 3 x total number of images in the dataset. This containsmatrix contains all the images;
+ ``peopleCount``: scalar indicating the total number of images in the dataset;

To represent all the images as visual features, please extract them for each image, then generate a single ``data`` matrix such that ``data = N x D`` where ``N`` is the number of images and ``D`` is the feature dimension.

To ease the evaluation process by using the ``run_experiment.m`` script on the new data, it is convenient to place the ``dataset`` structure in the ``data/dataset`` folder and name the file as ``data_name-of-the-dataset.mat``.
Similarly, the visual feature matrix ``data`` should be placed in ``data/features`` and the file named as ``data_name-of-the-dataset.mat`` where ``name-of-the-dataset`` can be any string.

## ADDITIONAL TOOLBOX:
With this package some additional libraries used in the method are also provided. Note that the algorithm works with the given libraries versions and it's not guaranteed to work with newer or older ones.
However, when using one of the methods below, please kindly refer/cite the original paper properly.

+ Implementation of ensembles of multiple output regression trees (c) 2002-2010 Pierre Geurts (http://www.montefiore.ulg.ac.be/~geurts/Software.html)
+ KISSME: M. Köstinger, M. Hirzer, P. Wohlhart, P. M. Roth, H. Bischof - Large Scale Metric Learning from Equivalence Constraints (https://lrs.icg.tugraz.at/research/kissme/)
+ KCCA: Hardoon D.R., Szedmak S., Shawe-Taylor J. -  Canonical correlation analysis: an overview with application to learning methods (http://www.davidroihardoon.com/code.html)
+ LADF/SVMML:  Li, Z., Chang, S., Liang, F., Huang, T.S., Cao, L., Smith, J.R. - Learning locally-adaptive decision functions for person verification

## COMPILE:
Please note that some libraries contain mex-files that needs to be compiled for your machine. We provide a limited set of binary within the package. We have not yet provided a script to compile all the dependences.

## CITATION:
If you use the code contained in this package we appreciate if you'll cite our work. 
BIBTEX:
@article{Garcia2017,
author = {Garcia, Jorge and Martinel, Niki and Gardel, Alfredo and Bravo, Ignacio and Foresti, Gian Luca and Micheloni, Christian},
doi = {10.1109/TIP.2017.2652725},
journal = {IEEE Transactions on Image Processing},
title = {{Discriminant Context Information Analysis for Post-Ranking Person Re-Identification}},
year = {2017}
}


