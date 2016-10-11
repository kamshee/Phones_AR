function [ F1 ] = calc_f1( ConfMat )

    % Compute precision, recall, and F1 score for a given confusion matrix
    
    N=length(ConfMat);
    precision=zeros(1,N); recall=zeros(1,N); F1=zeros(1,N);
    
    for i=1:N
        precision(i)=ConfMat(i,i)/sum(ConfMat(:,i));
        recall(i)=ConfMat(i,i)/sum(ConfMat(i,:));
        if recall(i)==0
            F1(i)=0;
        else
            F1(i)=2*precision(i)*recall(i)/(precision(i)+recall(i));
        end
    end

end

