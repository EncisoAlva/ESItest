% Read a text file that contains the sphere coordinate of electrodes
% Copyright (C) 2013 Yueming Liu, University of Texas at Arlington
%
function elec = read_elecrodes_position( filename )
    fid = fopen(filename, 'rt');
    line = fgetl(fid);
    [N, R] = strtok(line,'=');
    [N, R] = strtok(R,'=');
    Nchan = str2double(N);
    %adults
    r=100; %Default radius, unit: mm
    %children
    %r=85; %Default radius, unit: mm
    for i=1:Nchan
      line = fgetl(fid);
      [idx, R] = strtok(line);
      [label, R] = strtok(R);
      %[idx, label, theta, phi] = sscanf(line,'%d %*s %d %d');
      A = sscanf(R,'%i %i');
      theta = pi*A(1)/180;
      phi = pi*A(2)/180;
      elec.label{i} = label;
      %easycap formula
%       elec.pnt(i,1) = r*sin(theta)*cos(phi);
%       elec.pnt(i,2) = r*sin(theta)*sin(phi);
      %biosemi formula
      elec.pnt(i,1) = -r*sin(theta)*sin(phi);
      elec.pnt(i,2) = r*sin(theta)*cos(phi);
      
      elec.pnt(i,3) = r*cos(theta);
    end
    elec.label = elec.label(:); % as_vector()

    elec.chanpos = elec.pnt;
    elec.elecpos = elec.pnt;
    elec.type = 'easycap-M1';
    elec.unit='mm';
    elec.dhk = [];
end