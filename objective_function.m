% 定义目标函数，固定 capacity
function totlaloss = objective_function(para_fit, blockdata, capacity)
    LR_wm = 1; % 固定值
    LR_rl = para_fit(1);
    delay_wm = para_fit(2);
    delay_rl = para_fit(3);
    pers = para_fit(4);
    noise = para_fit(5);
    rol = para_fit(6);

    para = [LR_wm, LR_rl, delay_wm, delay_rl, pers, noise, rol, capacity];
    totlaloss=0;
    for i=1:length(blockdata)
    [~, ~, loss] = RLWM_Cooperative_model(blockdata{i}, para);
    totlaloss=totlaloss+loss;
    end
end
