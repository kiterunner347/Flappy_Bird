clear;clc;
addpath(genpath('src'));

width = [64,32,32,32,32,32,32,256];
height = [128,32,128,16,32,32,32,64];
src = {'back.png','bird.png','down.png','head.png','tail.png','bird_up.png','bird_down.png','over.png'};
targ = {'back.coe','bird.coe','down.coe','head.coe','tail.coe','bird_up.coe','bird_down.coe','over.coe'};
for i =1:length(src)
    pic_gen(width(i),height(i),src{i},targ{i});
end