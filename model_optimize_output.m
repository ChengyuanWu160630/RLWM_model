
% rng('default'); 
% blockidx=4;
subidx=1;
CollinsEtAl2018PNAS.choice(CollinsEtAl2018PNAS.rt==-1)=nan;
block_list=unique(CollinsEtAl2018PNAS.block(CollinsEtAl2018PNAS.subno==subidx));
blockdata=cell(length(block_list),1);
for i=1:length(blockdata)
    
keytable = ones(3, sum(CollinsEtAl2018PNAS.block==block_list(i) & CollinsEtAl2018PNAS.subno==subidx));    
keytable(3, :)=CollinsEtAl2018PNAS.stimseq(CollinsEtAl2018PNAS.block==block_list(i) & CollinsEtAl2018PNAS.subno==subidx);
keytable(2, :)=CollinsEtAl2018PNAS.choice(CollinsEtAl2018PNAS.block==block_list(i) & CollinsEtAl2018PNAS.subno==subidx);
keytable(1, :)=CollinsEtAl2018PNAS.corAseq(CollinsEtAl2018PNAS.block==block_list(i) & CollinsEtAl2018PNAS.subno==subidx);
blockdata{i}=keytable;
end
clear keytable;

global_best_loss = Inf;
global_best_para = [];
global_best_capacity = NaN;

lb = [0,  % LR_rl 
      0,  % delay_wm 
      0,  % delay_rl 
      0,  % pers 
      0,  % noise 
      0]; % rol 

ub = [1,  % LR_rl 
      1,  % delay_wm 
      1,  % delay_rl 
      1,  % pers 
      1,  % noise 
      1]; % rol 

options = optimoptions('fmincon', ...
    'Display', 'off', ... 
    'MaxIterations', 5000);
capa_loss=[];

for capacity = 1:5
    fprintf('Optimizing for capacity = %d\n', capacity);

    capacity_best_loss = Inf;
    capacity_best_para = [];

    for trial = 1:1000
        x0 = (lb + rand(length(lb),1) .* (ub - lb))';
        objective_fn = @(para_fit) objective_function(para_fit, blockdata, capacity);     
        [para_opt, loss_opt] = fmincon(objective_fn, x0, [], [], [], [], lb, ub, [], options); 
        if loss_opt < capacity_best_loss
            capacity_best_loss = loss_opt;
            capacity_best_para = para_opt;
        end
    end
    capa_loss(capacity)= capacity_best_loss;
    fprintf('Capacity = %d, Best Loss = %f\n', capacity, capacity_best_loss);
    
    if capacity_best_loss < global_best_loss
        global_best_loss = capacity_best_loss;
        global_best_para = capacity_best_para;
        global_best_capacity = capacity;
    end
end

disp('Optimal parameters:');
disp(['LR_rl: ', num2str(global_best_para(1))]);
disp(['delay_wm: ', num2str(global_best_para(2))]);
disp(['delay_rl: ', num2str(global_best_para(3))]);
disp(['pers: ', num2str(global_best_para(4))]);
disp(['noise: ', num2str(global_best_para(5))]);
disp(['rol: ', num2str(global_best_para(6))]);
disp(['capacity: ', num2str(global_best_capacity)]);
disp('Minimum loss:');
disp(global_best_loss);

input_para=[1,global_best_para,global_best_capacity];
Q_rl_bytrial=cell(length(blockdata),1);
Q_wm_bytrial=cell(length(blockdata),1);
for i=1:length(blockdata)
[~,~,~,Q_rl_bytrial{i},Q_wm_bytrial{i}]=outputbytrial(blockdata{i},input_para);
end