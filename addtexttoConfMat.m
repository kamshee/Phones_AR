function [ ] = addtexttoConfMat(ConfMat)
% Add value text to confusion matrix

    numAct=length(ConfMat);
    correctones = sum(ConfMat,2);
    correctones = repmat(correctones,[1 numAct]);

    for i=1:numAct
        for j=1:numAct
            conf_str=num2str(.01*round(10000*ConfMat(j,i)/correctones(j,i)),'%10.3g');
            % Add trailing zeros
            if length(conf_str)<4 && ~strcmp('0',conf_str)
                if isempty(regexp(conf_str,'\.','once'))
                    if length(conf_str)==2
                        conf_str=[conf_str '.0'];
                    elseif length(conf_str)==1
                        conf_str=[conf_str '.00'];
                    end
                else
                    conf_str=[conf_str '0'];
                end
            end 

            if ConfMat(j,i)/correctones(j,i)<0.15
                txtclr='w';
            else
                txtclr='k';
            end
            text(i-0.25,j,conf_str,'Color',txtclr);
        end
    end


end

