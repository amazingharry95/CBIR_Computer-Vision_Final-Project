function correlationFeatureSelection = featureSelection()
    filename = 'fitur.csv';
    arr = csvread(filename);
    correlationFitur(16,16) = 0;

    for i=1:16
        iter=1;
        for j=i+1:16
             [ranked,weight] = relieff(arr(:,i), arr(:,j),10);
             correlationFitur(i,iter) = abs(weight);
             iter = iter+1;
        end 
    end

    correlationClass(16,1)=0;
    for x=1:16
        [ranked,weight] = relieff(arr(:,x), arr(:,17), 10);
        correlationClass(x) = abs(weight);
    end

    rii(16,1)=0; %untung simpan rata-rata korelasi per fitur

    iter=1;
    for x=16:-1:1
        rii(iter) = sum(correlationFitur(iter,:))/x;
        iter=iter+1;
    end

    rzc(16,2) = 0;
    k = 16;
    rzi = sum(correlationClass)/16;
    for a=1:16
        rzc(a,1) = (k*correlationClass(a))/sqrt((k+k*(k-1)*rii(a)));
        %rzc(a,1) = (k*rzi)/sqrt((k+k*(k-1)*rii(a)));
        rzc(a,2) = a;
    end

    [values, order] = sort(rzc(:,1));
    sortedMatrix = rzc(order,:);
    
    fiturTerpilih(9) = 0;
    flag = 1;
    for f=1:16
        if sortedMatrix(f,1) > 0.005
            fiturTerpilih(flag)=sortedMatrix(f,2);
            flag = flag+1;
        end
    end

    correlationFeatureSelection = fiturTerpilih;
end


