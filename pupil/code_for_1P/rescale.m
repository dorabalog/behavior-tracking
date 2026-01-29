function [rescaled_signal] = rescale(signal)

rescaled_signal = (signal - min(signal))./(max(signal) - min(signal));
