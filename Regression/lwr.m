load('q2x.dat');
load('q2y.dat');

x = [ones(size(q2x,1),1) q2x];
y = q2y;

% solve for parameter theta directly (linear regression)

theta = pinv(x'*x)*x'*y;

% plot result

figure;
hold on;
plot(x(:,2),y,'.b');
regr_line_x = min(x(:,2)):.1:max(x(:,2));
regr_line_y = theta(2)*regr_line_x + theta(1);
plot(regr_line_x,regr_line_y,'b');


% now do locally weighted regression

sigmas = [.1 .3 .8 2 10];
colors = ['r' 'g' 'm' 'y' 'k'];

n = size(q2x,1);

for i = 1:size(sigmas,2)
   sigma = sigmas(i);
   
   for k = 1:size(regr_line_x,2)
     
     W = zeros(n,n);
     for l = 1:n
      W(l,l) = exp(-(regr_line_x(k)-x(l,2))^2/(2 * sigma^2));
     end
     
     theta          = pinv(x'*W*x)*x'*W*y;
     regr_line_y(k) = theta(2) * regr_line_x(k) + theta(1);
   
   end
   
   plot(regr_line_x,regr_line_y,colors(i));
end
legend('trainingdata','linear','sigma=0.1','sigma=0.3','sigma=0.8','sigma=2','sigma=10')
