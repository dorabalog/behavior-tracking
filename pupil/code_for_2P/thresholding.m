function [binned_signal] = thresholding(signal, threshold)

binned_signal = signal;
binned_signal(signal<threshold) = 0;
binned_signal(signal>=threshold) = 1;


