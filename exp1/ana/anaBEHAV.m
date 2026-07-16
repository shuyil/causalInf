clear all;
PATH = setPATH();
addpath(genpath(PATH.root))

corr = 1;

% Read in data
subNos = [2,3,4,5,6,7,8,9,10,11,12,14,15,17,18,19,20,23,24,25,26,28,29,30,31,32,33,34,35,36,37,38];


nsub = numel(subNos);
DF = load_ci_data(subNos, PATH, corr);
structOrder = [1 2 1 3 1 2 1];
mat = [];
data = [];

% Initialize arrays to hold results
un_r1_all = zeros(nsub, max(structOrder), 2);
un_r2_all = zeros(nsub, max(structOrder), 2);
se_r1_all = zeros(nsub, max(structOrder), 2);
se_r2_all = zeros(nsub, max(structOrder), 2);
corr1 = zeros(nsub, 2);
corr2 = zeros(nsub, 2);

for s = 1:nsub
    for session = 1:2
        D = array2table(DF{s, session}.BD.raw.mat, 'VariableNames', DF{s, session}.BD.raw.names);
        
        C = array2table(DF{s, session}.BD.cmat_obj.mat, 'VariableNames', DF{s, session}.BD.cmat_obj.names);

        D.l_revalue = C.sti2 * 100 - D.l_rating1;
      
        % Calculate un_revalue
        D.un_revalue = D.un_rating2 - D.un_rating1;
        
        % Calculate correlation coefficients

        R3 = corrcoef(D.un_revalue, D.l_revalue);
        corr3(s, session) = R3(1, 2);


        for block = 1:max(D.block)
            block_indices = find(D.block == block & D.struct == structOrder(block));
            un_r1 = D.un_rating1(block_indices);
            un_r2 = D.un_rating2(block_indices);
            PlY(block, 1) = mean(un_r1);
            PlY(block, 2) = mean(un_r2); 
            
            l_r1 = D.l_rating1(block_indices);
            l_r2 = C.sti2(block_indices)*100;


            
            % Store mean values for all subjects and blocks
            un_r1_all(s, block, session) = mean(un_r1);
            un_r2_all(s, block, session) = mean(un_r2);
            
            % Calculate standard error for each block for each subject
            se_r1_all(s, block, session) = sqrt(var(un_r1) / length(un_r1));
            se_r2_all(s, block, session) = sqrt(var(un_r2) / length(un_r2));
            
            n_t = length(un_r1); 
            if block < 4 
                before = 1; 
            else
                before = 2; 
            end
            
            if subNos(s) == 30
                l_r1_v2 = mean([l_r1 un_r1],2);
                un_r1_v2 = mean([l_r1 un_r1],2);

                l_r1 = l_r1_v2;
                un_r1 = un_r1_v2;
            end
            
            data_sub = [repmat(s, n_t, 1), repmat(session, n_t, 1), repmat(block, n_t, 1), (1:n_t)', l_r1, l_r2, un_r1, un_r2, repmat(before, n_t, 1), repmat(structOrder(block), n_t, 1)];
            
            if subNos(s) == 24 && session == 1 && block == 1
                data_sub = data_sub(2:end,:);
            elseif subNos(s) == 31 && session == 1 && block == 1
                data_sub(2,:) = []; 
            end
            
            data = [data; data_sub];
        end


    end
    un_r1_allrun(s, :) = mean(un_r1_all(s, :, :), 3);
    un_r2_allrun(s, :) = mean(un_r2_all(s, :, :), 3);
end



% Convert data to table and save
data = array2table(data, 'VariableNames', {'subject', 'session', 'block', 'problem', 'l_r1', 'l_r2', 'un_r1', 'un_r2', 'post_2cause','struct'});
writetable(data, 'ci_data.csv');

