%METRICDIST Compute distances between sets of spike train pairs.
%   D = METRICDIST(N,TIMES,LABELS,OPTS) uses the metric
%   space method to compute the distances between all possible spike
%   train pairs in the data set. D is a 3-D matrix where the third dimension
%   corresponds to the elements of OPTS.shift_cost.
%
%   N is the number of neurons recorded simultaneously.
%
%   TIMES is an Px1 cell array of spike times where P is the number of
%   trials in the data set. Each member of the cell array consists of
%   spike times interleaved from simultaneous trials.
%
%   LABELS is a Px1 cell array with labels of the spikes in TIMES.
%
%   The options and parameters for this function are:
%      OPTS.shift_cost: The cost of shifting a spike per unit time
%         relative to inserting or deleting a spike. This option may
%         be a vector of such values. The default is
%         1/(end_time-start_time).
%      OPTS.label_cost: This applies only to data sets with
%         simultaneously recorded spike trains. It is the cost of
%         altering a spike's label, and may range from 0 to 2. This
%         option may be a vector of such values whose length is equal
%         to OPTS.shift_cost. The default is 0.
%      OPTS.metric_family: Selects the metric to be used.
%         OPTS.metric_family=0: Uses D^spike metric.
%         OPTS.metric_family=1: Uses D^interval metric. This is
%            only applicable to single-site data.
%         The default value is 0.
%      OPTS.parallel: Selects which algorithm version to
%         use.
%         OPTS.parallel=0: Computes distances for a single shift_cost,
%             label_cost pairs at a time.
%         OPTS.parallel=1: Uses an algorithm that computes the
%             distances for all shift_cost,label_cost pairs
%             concurrently. When many parameters sets are being
%             analyzed, this method can provide considerable
%             computational savings. 
%         The default value is 0 if OPTS.shift_cost has one element
%             and 1 if OPTS.shift_cost has multiple elements.
%
%   D = METRICDIST(N,TIMES,LABELS) uses the default options and
%   parameters.
%
%   [D,OPTS_USED] = METRICDIST(N,TIMES,LABELS) or [D,OPTS_USED] =
%   METRICDIST(N,TIMES,LABELS,OPTS) additionally return the
%   options used.
% 
%   See also METRICOPEN, METRICCLUST.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
