function[Q_rl,Q_wm,loss]=RLWM_Cooperative_model(keytable,para)

beta0=100;
LR_wm=para(1); %value=1
LR_rl=para(2); % fit range [0 1]
delay_wm=para(3); %fit range [0 1]
delay_rl=para(4); %fit range [0 1] 
pers=para(5); %fit range [0 1]
noise=para(6); %fit range [0 1]
rol=para(7); %fit range [0 1]
capacity=para(8);%value=[1,2,3,4,5]

num_choice=3;
true_key=keytable(1,:);
answer=keytable(2,:);
stimulus=keytable(3,:);
correct=answer==true_key;
correct(isnan(correct))=0;
Q_0=1/num_choice;
Weight_wm=rol.*min(1,capacity/length(unique(stimulus)));

Q_rl=ones(length(unique(stimulus)),num_choice).*Q_0;
Q_wm=ones(length(unique(stimulus)),num_choice).*Q_0;
prob=ones(length(unique(stimulus)),num_choice).*Q_0;
loss=0;
for i=1:length(stimulus)
    
    
    if i==1
        loss=loss-log(Q_0);
    elseif i>1 && ~isnan(answer(i))
        loss=loss-log(prob(stimulus(i),answer(i)));
    end

    
    if i>1 && correct(i)==1
    corr_with_WM=Weight_wm.* prob_wm(answer(i))+(1- Weight_wm).*Q_0;
    corr_with_RL=prob_RL(answer(i));
    Weight_wm=Weight_wm.*corr_with_WM./(Weight_wm.*corr_with_WM+(1-Weight_wm).*corr_with_RL);
    elseif i==1 && correct(i)==1
    corr_with_WM=Weight_wm.*Q_0+(1- Weight_wm).*Q_0;
    corr_with_RL=Q_0;
    Weight_wm=Weight_wm.*corr_with_WM./(Weight_wm.*corr_with_WM+(1-Weight_wm).*corr_with_RL);
    end
    
    if ~isnan(answer(i))
        
        %delay first
        Q_rl=Q_rl+delay_rl.*-1.*(Q_rl-Q_0);       
        Q_wm=Q_wm+delay_wm.*-1.*(Q_wm-Q_0);       
        
        PE_rl=correct(i)-(Q_rl(stimulus(i),answer(i)).*(1-Weight_wm)+Q_wm(stimulus(i),answer(i)).*Weight_wm); %interact step
        Q_rl(stimulus(i),answer(i))=Q_rl(stimulus(i),answer(i))+LR_rl.*PE_rl-~correct(i).*pers.*LR_rl.*PE_rl;

        prob_RL=exp(beta0.*Q_rl)./sum(exp(beta0.*Q_rl),2);    
        [prob_RL]=deal_nan(prob_RL);
        
        PE_wm=(correct(i)-Q_wm(stimulus(i),answer(i)));
        Q_wm(stimulus(i),answer(i))=Q_wm(stimulus(i),answer(i))+LR_wm.*PE_wm-~correct(i).*pers.*LR_wm.*PE_wm;

        prob_wm=exp(beta0.*Q_wm)./sum(exp(beta0.*Q_wm),2);    
        [prob_wm]=deal_nan(prob_wm);
        prob=Weight_wm.*prob_wm+(1-Weight_wm).*prob_RL;
        prob=(1-noise).*prob+noise.*Q_0;
     
    else
        Q_rl=Q_rl+delay_rl.*(Q_rl-Q_0);
        prob_RL=exp(beta0.*Q_rl)./sum(exp(beta0.*Q_rl),2); 
        
        Q_wm=Q_wm+delay_wm.*(Q_wm-Q_0);
        prob_wm=exp(beta0.*Q_wm)./sum(exp(beta0.*Q_wm),2);    
    
        prob=Weight_wm.*prob_wm+(1-Weight_wm).*prob_RL;
        prob=(1-noise).*prob+noise.*Q_0;
        
    end

end

if isnan(loss)
    display(para)
end





