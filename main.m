%array yang menampung fitur-fitur yang diekstrak
%dari kiri ke kanan :
%1.slimness, 2.narrow factor, 3.rectangularity, 4.roundness, 5.rpd, 6.prp, 7.mean
%red, 8.mean green, 9.mean blue, 10.skewness red, 11.skewness green, 12.skewness
%blue, 13.kurtosis red, 14.kurtosis green, 15.kurtosis blue, 16. GLB
arr(300,17) = 0;

iter = 1;
listing = dir('Leaves');

for k = 1001:1300
    %membaca training sample
    source = strcat('.\Leaves\', num2str(k), '.jpg' );
    img = imread(source);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    %PREPROCESSING
    
    %ekstraksi RGB dari training sample
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    
    %inisialisasi array untuk menampung background pixel
    v=zeros(1200,1600);
    
    %thresholding untuk mengambil background pixel
    for i=1:1200
        for j=1:1600
            if B(i,j) > 60
                v(i,j)=1;
            end
        end
    end
    
    %membuat Binary Image
    b = logical(not(v));
    %mengisi lubang (holes) pada Binary Image dengan nilai dari foreground
    %pixel
    b = imfill(b, 'holes');
        
    name=strcat(num2str(k),'.jpg');
    %figure('name',name,'NumberTitle','off'); imshow(b);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    %EKSTRAKSI FITUR BENTUK
    
    %menghitung parameter seperti Area, Perimeter dari Objek pada Binary
    %Image
    results=regionprops(b,'Area','Perimeter','EquivDiameter','MajorAxisLength','MinorAxisLength');
    
    arrPanjang = arrayfun(@(struct)max(struct.MajorAxisLength(:)),results);
    panjang = max(arrPanjang(:));
    arrLebar = arrayfun(@(struct)max(struct.MinorAxisLength(:)),results);
    lebar = max(arrLebar(:));
    arrDiameter = arrayfun(@(struct)max(struct.EquivDiameter(:)),results);
    diameter = max(arrDiameter(:));
    arrArea = arrayfun(@(struct)max(struct.Area(:)),results);
    area = max(arrArea(:));
    arrPerimeter = arrayfun(@(struct)max(struct.Perimeter(:)),results);
    perimeter = max(arrPerimeter(:));
    
    slimness = panjang/lebar;
    arr(iter,1)=slimness;
    
    narrow_factor=diameter/panjang;
    arr(iter,2)=narrow_factor;
    
    rectangularity=(panjang*lebar)/area;
    arr(iter,3)=rectangularity;
    
    roundness=(4*pi*area)/perimeter^2;
    arr(iter,4)=roundness;
    
    %rasio keliling dan diameter
    rpd=perimeter/diameter;
    arr(iter,5)=rpd;
    
    %rasio perimeter dengan panjang dan lebar
    prp=perimeter/(panjang+lebar);
    arr(iter,6)=prp;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    %EKSTRAKSI FITUR WARNA
    
    %merubah nilai background image menjadi black (0) menggunakan filter
    %mask
    mask = uint8(not(v));
    im_new = img .* repmat(mask, [1,1,3]);
    
    %mengambil nilai masing masing chanel red green dan blue dari citra
    red=im_new(:,:,1);      %red
    green=im_new(:,:,2);    %green
    blue=im_new(:,:,3);     %blue
    
    %menentukan mean dari channel red, green dan blue citra input
    iter_red = 0;
    sum_red = 0.0;
    
    iter_green = 0;
    sum_green = 0.0;
    
    iter_blue = 0;
    sum_blue = 0.0;
    
    for i=1:1200
        for j=1:1600
            if red(i,j) > 0
                sum_red = sum_red + double(red(i,j));
                iter_red = iter_red + 1;
            end
            if green(i,j) > 0
                sum_green = sum_green + double(green(i,j));
                iter_green = iter_green + 1;
            end
            if blue(i,j) > 0
                sum_blue = sum_blue + double(blue(i,j));
                iter_blue = iter_blue + 1;
            end
        end
    end
    
    %mean dari channel red, green dan blue
    mean_red = sum_red/iter_red;
    arr(iter,7)=mean_red;
    mean_green = sum_green/iter_green;
    arr(iter,8)=mean_green;
    mean_blue = sum_blue/iter_blue;
    arr(iter,9)=mean_blue;
    
    %menentukan skewness dan kurtosis dari channel red, green dan blue citra input
    pangkat2_red = 0;
    pangkat3_red = 0;
    pangkat4_red = 0;
    
    pangkat2_green = 0;
    pangkat3_green = 0;
    pangkat4_green = 0;
    
    pangkat2_blue = 0;
    pangkat3_blue = 0;
    pangkat4_blue = 0;
    
    for i=1:1200
        for j=1:1600
            if red(i,j) > 0
                temp_red = double(red(i,j)) - mean_red;
                pangkat2_red = pangkat2_red + (temp_red^2);
                pangkat3_red = pangkat3_red + (temp_red^3);
                pangkat4_red = pangkat4_red + (temp_red^4);
            end
            if green(i,j) > 0
                temp_green = double(green(i,j)) - mean_green;
                pangkat2_green = pangkat2_green + (temp_green^2);
                pangkat3_green = pangkat3_green + (temp_green^3);
                pangkat4_green = pangkat4_green + (temp_green^4);
            end
            if blue(i,j) > 0
                temp_blue = double(blue(i,j)) - mean_blue;
                pangkat2_blue = pangkat2_blue + (temp_blue^2);
                pangkat3_blue = pangkat3_blue + (temp_blue^3);
                pangkat4_blue = pangkat4_blue + (temp_blue^4);
            end
        end
    end
        
    %standar deviasi dari channel red, green dan blue
    S_red = sqrt(double(pangkat2_red / iter_red));
    S_green = sqrt(double(pangkat2_green / iter_green));
    S_blue = sqrt(double(pangkat2_blue / iter_blue));
    
    %skewness dan kurtosis dari channel red, green dan blue
    skewness_red = (pangkat3_red / iter_red) / (S_red^3);
    kurtosis_red = (pangkat4_red / iter_red) / (S_red^4);
    arr(iter,10)=skewness_red;
    arr(iter,13)=kurtosis_red;
    
    skewness_green = (pangkat3_green / iter_green) / (S_green^3);
    kurtosis_green = (pangkat4_green / iter_green) / (S_green^4);
    arr(iter,11)=skewness_green;
    arr(iter,14)=kurtosis_green;
    
    skewness_blue = (pangkat3_blue / iter_blue) / (S_blue^3);
    kurtosis_blue = (pangkat4_blue / iter_blue) / (S_blue^4);
    arr(iter,12)=skewness_blue;
    arr(iter,15)=kurtosis_blue;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    %EKSTRAKSI FITUR TEKSTUR
    
    %Gliding Box Lacunarity
    [rows, cols] = size(b);
    r = 2;
    edge = 1;
    finish = rows - edge;
    
    jumlah_kotak = power(finish,2);
    sigma_fraktal = 0.0;
    sigma2_fraktal = 0.0;
    
    for i=1:finish
        for j=1:finish
            sums = sum(sum(b(i:i+edge,j:j+edge)));
            sigma_fraktal = sigma_fraktal + sums;
            sigma2_fraktal = sigma2_fraktal + power(sums,2);
        end
    end
    
    GBL = (jumlah_kotak*sigma2_fraktal)/(power(sigma_fraktal,2));
    arr(iter,16)=GBL;
    
    %nilai = 0;
    if (1001<=k) && (1030>=k)
        nilai=1;
    elseif (1031<=k) && (1060>=k)
        nilai=2;
    elseif (1061<=k) && (1090>=k)
        nilai=3;
    elseif (1091<=k) && (1120>=k)
        nilai=4;
    elseif (1121<=k) && (1150>=k)
        nilai=5;
    elseif (1151<=k) && (1180>=k)
        nilai=10;
    elseif (1181<=k) && (1210>=k)
        nilai=6;
    elseif (1211<=k) && (1240>=k)
        nilai=7;
    elseif (1241<=k) && (1270>=k)
        nilai=8;
    elseif (1271<=k) && (1300>=k)
        nilai=9;
    end
    
    arr(iter,17)=nilai;
    
    iter = iter + 1;
    %dlmwrite('test4.csv', arr(2:end,:), '-append') ;
end
csvwrite('fitur.csv',arr)