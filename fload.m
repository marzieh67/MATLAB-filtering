clear
clc
%Grid points
Zindex=[0 1000 1400 1600 1700 1800 1890 1980 2070 2160 2260 2460 2860 3260 3660 4060 4560 5060 6060 7060];

Xindex=[0 150 300 450 550 600 650 700 735 765 800 830 860 885 915];

Yindex=[129 144 159 171 181 191 201 206];
%----------------
%Grid points

dir(pwd);
count=0;
for i = 1:size(Zindex,2)
for j=7:size(Xindex,2)
    for k=1:size(Yindex,2)

        l=Zindex(i)
        m=Xindex(j)
        n=Yindex(k)
        if exist(sprintf('Z-%d,X-%d,Y-%d', l,m,n))>0 
%load files for time series
     [header,data]=hdrload(sprintf('Z-%d,X-%d,Y-%d', l,m,n));
%read time series and convert the units to m/s
     u(:,1)=0.01*data(:,2);
     v(:,1)=0.01*data(:,3);
     w(:,1)=0.01*data(:,4);
     %----------------
%Despiking of time series
     % uds is the despiked time serie of the u,v and w 
     [uds,ipu]=func_despike_phasespace3d(u,9,2);
     [vds,ipv]=func_despike_phasespace3d(v,9,2);
     [wds,ipw]=func_despike_phasespace3d(w,9,2);
     %----------------
     %Correct the last spike using Min/Max threshold filter
%      udsmin=mean(uds)-sqrt(2*log(size(uds,1)))*std(uds);
%      udsmax=mean(uds)+sqrt(2*log(size(uds,1)))*std(uds);
%      
%      if (uds(size(uds,1)-1))>udsmax or(uds(size(uds,1)))<udsmin
%          uds(size(uds,1))=uds(size(uds,1)-1);
%      end
%      
%      vdsmin=mean(vds)-sqrt(2*log(size(vds,1)))*std(vds);
%      vdsmax=mean(vds)+sqrt(2*log(size(vds,1)))*std(vds);
%      
%      if (vds(size(uds,1)))>udsmax or(vds(size(vds,1)))<vdsmin
%          vds(size(vds,1))=vds(size(vds,1)-1);
%      end
%      
%      wdsmin=mean(wds)-sqrt(2*log(size(wds,1)))*std(wds);
%      wdsmax=mean(wds)+sqrt(2*log(size(wds,1)))*std(wds);
%      
%      if (wds(size(wds,1)))>wdsmax or(wds(size(wds,1)))<wdsmin
%          wds(size(wds,1))=wds(size(wds,1)-1);
%      end
     
     %----------------
     uds(size(uds,1))=uds(size(uds,1)-1);
     vds(size(vds,1))=vds(size(vds,1)-1);
     wds(size(wds,1))=wds(size(wds,1)-1);
     fid2=fopen(sprintf('Z-%d,X-%d,Y-%d-ds', l,m,n),'w');
     for o=1:size(u,1)
     fprintf(fid2,'%6.4f   %6.4f   %6.4f\n',uds(o),vds(o),wds(o));
     end
     fclose(fid2);
%Mean values
     % uavg is the average of the uds time series (m/s)
     % vmag is the velocity magnitute(m/s)
     % ke is the mean kinetic energy m^2/s^2 
     uavg=mean(uds);
     vavg=mean(vds);
     wavg=mean(wds);
     vmag=sqrt(uavg^2+vavg^2+wavg^2);
     ke=0.5*(uavg^2+vavg^2+wavg^2);
     
     %----------------
     
%Instantaneus values
     % up is the instantaneus time series (m/s)
     up=uds-uavg;                  
     vp=vds-vavg;
     wp=wds-wavg;
     %----------------
     
%Turbulence statistics
    % uv is Reynolds stress or -r (u'u')bar
    % ui is turbulence intencity for u component
    % ti is total turbulence intensity
    % tke is turbulent kinetic energy
ro=1000; %(kg/m^3)
ustar=0.0195; %(m/s)
uu=-ro*mean(up.*up);
vv=-ro*mean(vp.*vp);
ww=-ro*mean(wp.*wp);

uv=-ro*mean(up.*vp);
uw=-ro*mean(up.*wp);
vw=-ro*mean(vp.*wp);

urms=sqrt(mean(up.*up));
vrms=sqrt(mean(vp.*vp));
wrms=sqrt(mean(wp.*wp));

tiu=sqrt(mean(up.*up))/uavg;
tiv=sqrt(mean(vp.*vp))/vavg;
tiw=sqrt(mean(wp.*wp))/wavg;
ti=(sqrt(0.3333*(mean(up.*up)+mean(vp.*vp)+mean(wp.*wp))))/vmag;
tke=0.5*(uu+vv+ww)/-ro;
count=count+1;
ff(count,1:22)=[Zindex(i)/2 (1000-Xindex(j)-50) (260-Yindex(k)-50) uavg vavg wavg vmag ke uu vv ww uv uw vw urms vrms wrms tiu tiv tiw ti tke];
fclose('all');
        end
                end
        
        clc
end
end
fid1=fopen('final result-str-150-143.xls','w');
fprintf(fid1,'%-6.1s   %-6.1s   %-6.1s   %-7.4s   %-7.4s   %-7.4s   %-7.7s   %-7.6s   %-7.6s   %-7.6s   %-7.6s   %-7.6s   %-7.6s   %-7.6s   %-7.6s   %-7.6s   %-8.6s   %-8.6s   %-7.6s   %-7.6s   %-7.6s   %-7.6s   %-7.6s\n','X','Y','Z','U','V','W','Vel_mag','MKE','ruu','rvv','rww','ruv','ruw','rvw','u_RMS','v_RMS','w_RMS','uInt.','vInt.','wInt.','T.I','TKE');      
fprintf(fid1,'                               \n');
%fprintf(fid1,'%6.1f   %6.1f   %6.1f   %5.4f   %5.4f   %6.4f   %7.4g   %6.4g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g   %6.3g\n',X   Y   Z   U   V   W   Vel_mag   MKE   ruu   rvv   rww   ruv   ruw   rvw   u_RMS   v_RMS   w_RMS   uInt.   vInt.   wInt.   TKE\n');      
 for i=1:size(ff,1)
     fprintf(fid1,'%-6.1f   %-6.1f   %-7.1f   %-7.4f   %-7.4f   %-7.4f   %-7.4g   %-7.4g   %-7.3g   %-7.3g   %-7.3g   %-7.3g   %-7.3g   %-7.3g   %-7.3g   %-8.3g   %-8.3g   %-7.3g   %-7.3g   %-7.3g   %-7.3g   %-7.3g\n',ff(i,1),ff(i,2),ff(i,3),ff(i,4),ff(i,5),ff(i,6),ff(i,7),ff(i,8),ff(i,9),ff(i,10),ff(i,11),ff(i,12),ff(i,13),ff(i,14),ff(i,15),ff(i,16),ff(i,17),ff(i,18),ff(i,19),ff(i,20),ff(i,21),ff(i,22));
 end
fclose(fid1);
% plot3(up,vp,wp,'o')
