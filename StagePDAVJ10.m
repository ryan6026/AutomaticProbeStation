% device=SR830Ctrl()
% s = serialport("COM4", 9600)
% read(s, s.NumBytesAvailable,"char")
distance=6e4; %must be even integer
% 1e5 is equal to 1cm
N=40; intensity=zeros([N,N]); phase=zeros([N,N]);
j=0;k=0;
write(s, "M X="+int2str(-distance/2)+"Y="+int2str(-distance/2)+char(0x0d), "char")
pause(4)
for x=linspace(-distance/2,distance/2, N)
    j=j+1;
    for y=linspace(-distance/2, distance/2, N)
        k=k+1;
        write(s, "M X="+int2str(x)+"Y="+int2str(y)+char(0x0d), "char")
        if(k==0)
            pause(2)
        else
            pause(1)
        end
        tmp=device.getDisp(0.1, 10);
        intensity(j,k)=tmp(1);
        phase(j,k)=tmp(2);
    end
    pause(1)
    k=0;
%     distance=-distance;
end
% intensity(find(1-mod(1:N,2)),:) = fliplr(intensity(find(1-mod(1:N,2)),:));
intensity = intensity./0.065./120;
figure()
imagesc(linspace(0, distance/1e5, N), linspace(0, distance/1e5, N), intensity)
title("Beam Profile, 4um filter, focused", 'FontSize', 24)
xlabel("Distance (cm)", 'FontSize', 18)
ylabel("Distance (cm)", 'FontSize', 18)
a=colorbar()
ylabel(a, "Power in W/mm^2", "FontSize", 18)

figure()
imagesc(linspace(0, distance/1e5, N), linspace(0, distance/1e5, N), phase)
title("Phase Lock")
xlabel("Distance (cm)")
ylabel("Distance (cm)")