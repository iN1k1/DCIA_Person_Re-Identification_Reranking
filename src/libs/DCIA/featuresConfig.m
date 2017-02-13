function [config] = featuresConfig(featuresPars)

% Available Features:'RGB','HSV','Lab','PHOG','LBP'
features = featuresPars.enumeration;
channels = featuresPars.usedChannels;

% Color Spaces Histogram parameters
config.RGB.enabled = false;
config.RGB.channels = '111';
config.RGB.colorSpace = 'RGB';
config.RGB.histOp = 'none';
config.RGB.bins = featuresPars.RGB;
config.RGB.excludeRange = [-inf -1];
config.RGB.normalize = true;
config.RGB.distance = 'chisq';

config.HSV.enabled = false;
config.HSV.channels = '111';
config.HSV.colorSpace = 'HSV';
config.HSV.histOp = 'none';
config.HSV.bins = featuresPars.HSV;
config.HSV.excludeRange = [-inf -1];
config.HSV.normalize = true;
config.HSV.distance = 'chisq';

config.Lab.enabled = false;
config.Lab.channels = '111';
config.Lab.colorSpace = 'Lab';
config.Lab.histOp = 'none';
config.Lab.bins = featuresPars.Lab;
config.Lab.excludeRange = [-inf -1000];
config.Lab.normalize = true;
config.Lab.distance = 'chisq';

% PHOG paramters
config.phog.enabled = false;
config.phog.histOp = 'eq';
config.phog.bin = featuresPars.phog;
config.phog.angle = 180;
config.phog.levels = 1;
config.phog.evaluateDifferentChannels = true;
config.phog.distance = 'chisq';

% LBP parameters (Local Binary Patterns)
config.lbp.enabled = false;
config.lbp.histOp = 'eq';
config.lbp.patchSize = [];
config.lbp.step = [];
config.lbp.points = featuresPars.lbp;
config.lbp.radius = 4;%1
config.lbp.mapping = 'riu2';
config.lbp.distance = 'chisq';

for i = 1:length(features)
    switch(features{i})
        % Color Spaces Histogram parameters
        case 'RGB'
            config.RGB.enabled = true;
            config.RGB.channels = channels{i};
        case 'HSV'
            config.HSV.enabled = true;
            config.HSV.channels = channels{i};

        case 'Lab'
            config.Lab.enabled = true;
            config.Lab.channels = channels{i};
        % PHOG paramters
        case 'phog'
            config.phog.enabled = true;
        % LBP parameters (Local Binary Patterns)
        case 'LBP'
            config.lbp.enabled = true;
    end
end


