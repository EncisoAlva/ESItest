dir = strcat(getenv('USERPROFILE'),'\Desktop\NicoletFile\NicoletFile\');
cd(dir);
filename= strcat(dir, 'pruned.e');
OBJ = NicoletFile(filename);
%OUT = getdata( OBJ, 1, [1 137472], 1:11);
OUT = getdata( OBJ, 1, [1 258565], 1:128);
%OUT = getdata( OBJ, 1, [1 8192], 1:11);
save('OUT.mat', 'OUT');
plot(OUT(:,1));