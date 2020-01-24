function [] = MC()
clear
clc
close all

%Simulation options
sim.steps = 1000;
sim.delay = 0.01;
sim.percent = 0.05;
sim.dist = 0.1; %m
sim.V = 10; %V
sim.F = 1.60217662e-19 * sim.V/sim.dist; %N

%particle options
part.N = 10000;

%particle declarations
part.x = zeros(1,part.N);
part.v = zeros(1,part.N);
part.m = 9.10938356e-31; %kg
part.a = sim.F/part.m; %m/s;

%simulation declarations
sim.vd = zeros(1,sim.steps);
sim.vExamine = zeros(1,sim.steps);
sim.xExamine = zeros(1,sim.steps);
sim.vdSum = 0;
sim.dt = sqrt(2*sim.dist/part.a)/sim.steps;
sim.axis = [0,0.1,-0.05,0.05];

%draw electron figure
sim.fig = figure('units','normalized','outerposition',[0 0 1 1]);
sim.ax = subplot(4, 1, 1, 'Parent', sim.fig);
hold(sim.ax, 'on');
sim.plotPos = plot(sim.ax,part.x,zeros(1,part.N),'.b');
sim.plotVel = quiver(sim.ax,part.x,zeros(1,part.N),part.v,zeros(1,part.N),1.5,'b');
axis(sim.ax,sim.axis);
xlabel(sim.ax,'x');
ylabel(sim.ax,'y');
title(sim.ax,'Position of Particles (Drift Velocity = 0)');
grid(sim.ax,'on');

%draw drift velocity figure
sim.ax2 = subplot(4, 1, 2, 'Parent', sim.fig);
sim.plotVd = plot(sim.ax2,0,0,'-');
hold(sim.ax2, 'on');
sim.plotVdAv = plot(sim.ax2,0,0,'-');
xlabel(sim.ax2,'time (s)');
ylabel(sim.ax2,'drift velocity (m/s)');
title(sim.ax2,'Drift Velocity vs Time');
grid(sim.ax2,'on');

sim.ax3 = subplot(4, 1, 3, 'Parent', sim.fig);
sim.plotVx = plot(sim.ax3,0,0,'-');
xlabel(sim.ax3,'x (m)');
ylabel(sim.ax3,'v (m/s)');
title(sim.ax3,'Velocity of Particles vs Time');
grid(sim.ax3,'on');

sim.ax4 = subplot(4, 1, 4, 'Parent', sim.fig);
sim.plotHist = histogram(sim.ax4,part.v);
xlabel(sim.ax4,'v (m/s)');
ylabel(sim.ax4,'count');
title(sim.ax4,'Velocity of Particles Histogram');
grid(sim.ax4,'on');


%loop through all steps
for n = 1:sim.steps 
    %determine new positions
    dv = part.a * sim.dt;
    part.v = part.v + dv;
    dx = part.v * sim.dt + part.a * sim.dt^2 / 2;
    part.x = part.x + dx;
    
    %scatter a percentage of particles
    I = rand(1,part.N) < sim.percent;
    part.v(I) = -part.v(I);
    
    %calculate drift velocity
    sim.vd(n) = mean(part.v);
    sim.vdSum = sim.vdSum + sim.vd(n);
    
    %update velocity examination
    sim.vExamine(n) = part.v(1);
    sim.xExamine(n) = part.x(1);
    
    %update plots
    title(sim.ax,['Position of Particles (Instantaneous Drift Velocity = ',num2str(sim.vd(n)),' m/s, Average Drift Velocity = ',num2str(sim.vdSum/n),' m/s)']);
    sim.axis(2) = max(part.x)*1.1;
    axis(sim.ax,sim.axis);
    set(sim.plotPos, 'XData', part.x);
    set(sim.plotVel,'XData',part.x,'UData',part.v);
    set(sim.plotVd,'XData',(0:(n-1))*sim.dt,'YData',sim.vd(1:n));
    set(sim.plotVdAv,'XData',[0, n*sim.dt],'YData',[sim.vdSum/n,sim.vdSum/n]);
    set(sim.plotVx,'XData',sim.xExamine(1:n),'YData',sim.vExamine(1:n));
    sim.plotHist = histogram(sim.ax4,part.v);
    
    %delay between iterations
    pause(sim.delay)
end
end
