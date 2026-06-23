function BD = sort_behav(data, corr)
% if corr == 1, then the evs for stage 1 follows order [s1 l_rating un_rating]
% if corr == 0, then the rating for l and un are not differentiated during
% stage 1

%%% 1. organise behavioural data
    
    D = data.output; 
    struct = data.schedule.struct;
    ntrials = length(D.l_rating1);
    bmat = [D.l_rating1 D.un_rating1 D.un_rating2 struct(1:ntrials) nan(ntrials,1)];
    
    % initialise block index
    b_idx = 1;
    bmat(1,end) = b_idx;
    last_unzero_struct = -1;
    previous_struct = -1;

    for idx = 2:ntrials
        current_struct = struct(idx);

        if current_struct ~=0
            if current_struct ~= last_unzero_struct
                b_idx = b_idx + (previous_struct ~= -1 & last_unzero_struct ~= -1);
                bmat(idx,end) = b_idx;
            else
                bmat(idx,end) = b_idx;
            end
        else
            bmat(idx,end) = b_idx;
        end
        
        previous_struct = struct(idx-1);
        if current_struct ~=0
            last_unzero_struct = current_struct;
        end


    end
    BD.raw.mat = bmat;
    BD.raw.names = {'l_rating1','un_rating1','un_rating2','struct','block'};

%%% 2. organise behavioural data for fMRI analysis
    beh_mat = [];

   for idx = 1:ntrials
       if D.s1_order(idx) == 1
           beh_mat(idx,:) = [D.l_rating1(idx) D.un_rating1(idx) D.un_rating2(idx)];
       else
           if corr == 1
                beh_mat(idx,:) = [D.l_rating1(idx) D.un_rating1(idx) D.un_rating2(idx)];
           else
              beh_mat(idx,:) = [D.un_rating1(idx) D.l_rating1(idx) D.un_rating2(idx)];
           end
       end
   end

   BD.beh.mat = beh_mat;
   
   if corr == 1
       BD.beh.names = {'l_r1','un_r1','un_r2'};
   else
       BD.beh.names = {'s1_r1','s1_r2','s2_r'};
   end
    

%%% 3. create matrices for causal properties
    %%% Create binary versions of ratings before the loop
    l_rating1_bin = 100 * (D.l_rating1 >= 0) + -100 * (D.l_rating1 < 0);
    un_rating1_bin = 100 * (D.un_rating1 >= 0) + -100 * (D.un_rating1 < 0);
    un_rating2_bin = 100 * (D.un_rating2 >= 0) + -100 * (D.un_rating2 < 0);

    % Initialize matrices for causal properties of each stimulus
    cmat = zeros(ntrials, 6);  % subjective matrix
    cmat_obj = zeros(ntrials, 6);  % objective matrix
    cmat_bin = zeros(ntrials, 6);  % binary matrix based on rating values

    for idx = 1:ntrials
        switch struct(idx)
            case 0
                % Case when struct == 0
                cmat(idx,:) = [-100 D.l_rating1(idx) D.un_rating1(idx) -100 D.un_rating2(idx) -100];
                cmat_obj(idx,:) = repmat(-100, 1, 6);
                cmat_bin(idx,:) = [-100 l_rating1_bin(idx) un_rating1_bin(idx) -100 un_rating2_bin(idx) -100];
            case 1
                % Case when struct == 1
                cmat(idx,:) = [100 D.l_rating1(idx) D.un_rating1(idx) 100 D.un_rating2(idx) 100];
                cmat_obj(idx,:) = [100 50 50 100 -100 100];
                cmat_bin(idx,:) = [100 l_rating1_bin(idx) un_rating1_bin(idx) 100 un_rating2_bin(idx) 100];
            case 2
                % Case when struct == 2
                cmat(idx,:) = [100 D.l_rating1(idx) D.un_rating1(idx) -100 D.un_rating2(idx) 100];
                cmat_obj(idx,:) = [100 50 50 -100 100 100];
                cmat_bin(idx,:) = [100 l_rating1_bin(idx) un_rating1_bin(idx) -100 un_rating2_bin(idx) 100];
            case 3
                % Case when struct == 3
                cmat(idx,:) = [100 D.l_rating1(idx) D.un_rating1(idx) 100 D.un_rating2(idx) 100];
                cmat_obj(idx,:) = [100 0 100 100 100 100];
                cmat_bin(idx,:) = [100 l_rating1_bin(idx) un_rating1_bin(idx) 100 un_rating2_bin(idx) 100];
        end
    end
    
    if corr == 0
        for idx = 1:ntrials
            if D.s1_order(idx) == 2
                % Swap the ratings order in cmat and cmat_bin for the second order
                cmat(idx,:) = [cmat(idx,1) cmat(idx,3) cmat(idx,2) cmat(idx,4:6)];
                cmat_bin(idx,:) = [cmat_bin(idx,1) cmat_bin(idx,3) cmat_bin(idx,2) cmat_bin(idx,4:6)];
            end
        end
        names = {'sti1','s1_r1','s1_r2','sti2','s2_r','sti1_re'};
    else
        names = {'sti1','l_r1','un_r1','sti2','un_r2','sti1_re'};
    end

    cmat = cmat ./ 100;
    cmat_obj = cmat_obj ./ 100;
    cmat_bin = cmat_bin ./ 100;
   
    BD.cmat.mat = cmat;
    BD.cmat.names = names;

    BD.cmat_obj.mat = cmat_obj;
    BD.cmat_obj.names = names;
   
    % Add the binary matrix to the output
    BD.cmat_bin.mat = cmat_bin;
    BD.cmat_bin.names = names;

    %%% 4. log schedule information (e.g., colour frames)

    col_mat = data.schedule.color;
    % Mapping (key-value pairs)
    keys = {'img/color1.png', 'img/color2.png', 'img/color3.png', ...
            'img/color4.png', 'img/color5.png', 'img/color6.png', 'img/color7.png'};
    values = [1, 2, 3, 4, 5, 6, 7];

    % Initialize output matrix
    [nRows, nCols] = size(col_mat);
    codes = zeros(nRows, nCols);
    
    % Perform mapping for each element
    for i = 1:nRows
        for j = 1:nCols
            idx = find(strcmp(keys, col_mat{i, j})); % Find index in keys
            if ~isempty(idx)
                codes(i, j) = values(idx); % Map to corresponding value
            else
                codes(i, j) = NaN; % Optional: handle unmapped entries
            end
        end
    end

    BD.schedule.color.mat = codes;
    BD.schedule.color.names = {'sti1','sti2','other'};
    

    %%% 5. calculate causal structure 

    cau_struct = zeros(ntrials, 3);
    
    % Define symbolic variables for the equations
    syms one_cau two_cau
    
    % Loop through trials
    for idx = 1:ntrials
    
        % Check the condition using a switch-case structure
        switch struct(idx)
            case 0
                % When struct(idx) == 0, assign [1 0 0] to `cau_struct`
                cau_struct(idx,:) = [1 0 0];
            
            case 1
                % When struct(idx) == 1, solve the system of equations
                eq1 = one_cau + two_cau == 1;
                eq2 = two_cau * 100 - one_cau * 100 == D.un_rating2(idx);
                solution = solve([eq1, eq2], [one_cau, two_cau]);
    
                % Store the solutions in the struct
                cau_struct(idx,:) = [0 double(solution.one_cau) double(solution.two_cau)];
    
            case 2
                % When struct(idx) == 2, solve the system of equations
                eq1 = one_cau + two_cau == 1;
                eq2 = one_cau * 100 - two_cau * 100 == D.un_rating2(idx);
                solution = solve([eq1, eq2], [one_cau, two_cau]);
    
                % Store the solutions in the struct
                cau_struct(idx,:) = [0 double(solution.one_cau) double(solution.two_cau)];
    
            case 3
                % When struct(idx) == 3, assign [0 0 1] to `cau_struct`
                %cau_struct(idx,:) = [0 0 1];

                eq1 = one_cau + two_cau == 1; 
                eq2 = two_cau * 100 - one_cau * 100 == D.l_rating1(idx);
                solution = solve([eq1, eq2], [one_cau, two_cau]);
                cau_struct(idx,:) = [0 double(solution.one_cau) double(solution.two_cau)];
        end
    end

    BD.cau_struct = cau_struct;





end
