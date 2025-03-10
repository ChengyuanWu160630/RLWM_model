function[Q]=deal_nan(Q)

Qsize=size(Q);

for i=1:Qsize(1)
    if sum(isnan(Q(i,:)))>0
        temQ=Q(i,:);
        temQ(isnan(temQ))=0;
        
        if sum(temQ)<0.1
            Q(i,isnan(Q(i,:)))=1;
        else
            Q(i,isnan(Q(i,:)))=0;
        end
    end

end