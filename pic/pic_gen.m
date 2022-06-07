function pic_gen(width,height,src,targ)

pixel = width*height;
src = imread(src);
tg = imresize(src,[height width]);

r = tg(:,:,1);
g = tg(:,:,2);
b = tg(:,:,3);

R2 = uint16(r);
G2 = uint16(g);
B2 = uint16(b);
b = uint16(zeros(height,width));
b = bitor(bitand(bitshift(R2,8),63488),b); %十进制 63488 为二进制 11111000 00000000
b = bitor(bitand(bitshift(G2,3),2016),b); %十进制 2016 为二进制 00000111 11100000
b = bitor(bitand(bitshift(B2,-3),31),b); %十进制 31 为二进制 00000000 00011111
b = reshape(b',1,[]);
b = dec2hex(b,4);

fid=fopen(targ, 'wt');%打开文件
fprintf(fid, 'MEMORY_INITIALIZATION_RADIX=16;\n');
fprintf(fid, 'MEMORY_INITIALIZATION_VECTOR=\n');
for i = 1 : pixel-1
    fprintf(fid,'%s,\n', b(i,:));%使用%x表示十六进制数
end
fprintf(fid, '%s;\n',b(pixel,:));%%输出结尾,每个数据后面用逗号或者空格或者换行符隔开，最后一个数据后面加分号
fclose(fid);%%关闭文件

end