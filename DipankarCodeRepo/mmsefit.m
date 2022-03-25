function p=mmsefit(x_values,y_values)
p=zeros(2,1);
x_bar = mean(x_values);
y_bar = mean(y_values);
xy_bar = mean(x_values.*y_values);
x2_bar = mean(x_values.^2);
sxx = x2_bar-x_bar^2;
sxy = xy_bar-x_bar*y_bar;
p(1)= sxy/sxx;
p(2)= y_bar - p(1)*x_bar;
end