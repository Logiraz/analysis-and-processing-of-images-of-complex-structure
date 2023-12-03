function condition = checkLimits(endPoint, limits)
condition = true;
condition = condition & (endPoint.xx > limits(1, 1));
condition = condition & (endPoint.yy > limits(1, 2));
condition = condition & (endPoint.xx < limits(2, 1));
condition = condition & (endPoint.yy < limits(2, 2));
end