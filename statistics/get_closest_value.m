function [idx,closest_value] = get_closest_value(x,val)
% Finds the closest value in vector x to the number specified in val.
% Outputs:
% - idx = index in x where the closest value occurs
% - closest_value = closest value in x to val
% Nate Zuk (2020)

diffx = abs(x-val);
idx = find(diffx==min(diffx));
closest_value = x(idx);