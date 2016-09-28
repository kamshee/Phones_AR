function [ accur ] = calc_classacc( ConfMat )

    % Compute classifier accuracy from a confusion matrix
    N=length(ConfMat);
    
    numInst = sum(ConfMat,2);    
    accur=diag(ConfMat./repmat(numInst,[1,N]));

end

