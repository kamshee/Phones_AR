function [ ] = plotpca_byAct(score, ind_Lab1,ind_Lab2,ind_Home, Activities )

numAct=length(Activities);

numRow=2;
numCol=ceil(numAct/2);

% Each instance value
figure(100);
for indAct=1:numAct
    
    subplot(numRow,numCol,indAct); hold on;

        eval(['A=[score.' Activities{indAct} '(ind_Lab1.' Activities{indAct} ',1),score.' Activities{indAct} '(ind_Lab1.' Activities{indAct} ',2)];']);  % Lab1 to Lab2
        eval(['B=[score.' Activities{indAct} '(ind_Lab2.' Activities{indAct} ',1),score.' Activities{indAct} '(ind_Lab2.' Activities{indAct} ',2)];']);  % Lab1 to Home
        eval(['C=[score.' Activities{indAct} '(ind_Home.' Activities{indAct} ',1),score.' Activities{indAct} '(ind_Home.' Activities{indAct} ',2)];']);  % Home to Home

        plot(A(:,1),A(:,2),'k+'); 
        plot(B(:,1),B(:,2),'b+'); 
        plot(C(:,1),C(:,2),'r+'); 

        % 95% CI ellipse
        error_ellipse(cov(A),'conf',0.95,'style','k-');
        error_ellipse(cov(B),'conf',0.95,'style','b-');
        error_ellipse(cov(C),'conf',0.95,'style','r-');
        
        axis square
        xlabel('Component 1'); ylabel('Component 2');
        legend('Lab1','Lab2','Home')
        title(Activities(indAct));
end

% Ellipses only
figure(101);
minX=-40; maxX=40; minY=-20; maxY=20;
for indAct=1:numAct
    
    subplot(numRow,numCol,indAct); hold on;

        eval(['A=[score.' Activities{indAct} '(ind_Lab1.' Activities{indAct} ',1),score.' Activities{indAct} '(ind_Lab1.' Activities{indAct} ',2)];']);  % Lab1 to Lab2
        eval(['B=[score.' Activities{indAct} '(ind_Lab2.' Activities{indAct} ',1),score.' Activities{indAct} '(ind_Lab2.' Activities{indAct} ',2)];']);  % Lab1 to Home
        eval(['C=[score.' Activities{indAct} '(ind_Home.' Activities{indAct} ',1),score.' Activities{indAct} '(ind_Home.' Activities{indAct} ',2)];']);  % Home to Home

        error_ellipse(cov(A),'conf',0.95,'style','k-');
        error_ellipse(cov(B),'conf',0.95,'style','b-');
        error_ellipse(cov(C),'conf',0.95,'style','r-');
        
        plot([minX maxX],[0 0],'k--')
        plot([0 0],[minY maxY],'k--')

        axis([minX maxX minY maxY])
        axis square
        xlabel('Component 1'); ylabel('Component 2');
        legend('Lab1','Lab2','Home')
        title(Activities(indAct));
end

% Subject mean/std
figure(102);
for indAct=1:numAct
    
    subplot(numRow,numCol,indAct); hold on;

        % Mean
        eval([...
            'plot(score.bySub.' Activities{indAct} 'mean(:,1,1),score.bySub.' Activities{indAct} 'mean(:,1,2),''ks'',''MarkerFaceColor'',''k'',''MarkerSize'',8);'...
            'plot(score.bySub.' Activities{indAct} 'mean(:,2,1),score.bySub.' Activities{indAct} 'mean(:,2,2),''bs'',''MarkerFaceColor'',''b'',''MarkerSize'',8);'...
            'plot(score.bySub.' Activities{indAct} 'mean(:,3,1),score.bySub.' Activities{indAct} 'mean(:,3,2),''rs'',''MarkerFaceColor'',''r'',''MarkerSize'',8);'...
            ]);

        axis square
        xlabel('Component 1'); ylabel('Component 2');
        legend('Lab1','Lab2','Home')
        title(Activities(indAct));

end

