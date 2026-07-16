function T = timing_organise(data,corr)
% if corr == 1, then the evs for stage 1 follows order [s1 l_rating un_rating]
% if corr == 0, then the rating for l and un are not differentiated during
% stage 1

% evs for stage 2 follows order [sti2(with target) un_rating sti1_repeat]

    DEC = data.output;
    TM = data.output.timing;
    
    ntrial = length(TM.start);
    
    t_s1_on = []; t_s1_off = [];
    t_s2_on = []; t_s2_off = [];
    for idx = 1:ntrial
        % timing for stage1
        if DEC.s1_order(idx) == 1
            t_s1_on(idx,:) = [TM.sti1_onset(idx) TM.l_rating1_onset(idx) TM.un_rating1_onset(idx)];
            t_s1_off(idx,:) = [TM.fixation2_onset(idx) TM.fixation3_onset(idx) TM.fixation4_onset(idx)]; 

            t_s1_m1(idx,:) = TM.l_rating1_end(idx);
            t_s1_m2(idx,:) = TM.un_rating1_end(idx);

        else
            if corr == 1
                t_s1_on(idx,:) = [TM.sti1_onset(idx) TM.l_rating1_onset(idx) TM.un_rating1_onset(idx)];
                t_s1_off(idx,:) = [TM.fixation2_onset(idx) TM.fixation4_onset(idx) TM.fixation3_onset(idx)]; 
                
                t_s1_m1(idx,:) = TM.l_rating1_end(idx);
                t_s1_m2(idx,:) = TM.un_rating1_end(idx);

            else                
                t_s1_on(idx,:) = [TM.sti1_onset(idx) TM.un_rating1_onset(idx) TM.l_rating1_onset(idx)];
                t_s1_off(idx,:) = [TM.fixation2_onset(idx) TM.fixation3_onset(idx) TM.fixation4_onset(idx)];  
                
                t_s1_m1(idx,:) = TM.un_rating1_end(idx);
                t_s1_m2(idx,:) = TM.l_rating1_end(idx);

            end
        end

        
        if idx < ntrial
            end_t = TM.start(idx+1);
        else
            if isfield(data.block, 'end') && ~isempty(data.block.end) 
                end_t = data.block.end;
                delete_last_row = 0;
            else
                end_t = rand();  % Assign a random number if 'data.block.end' does not exist (in case of incomplete data)
                delete_last_row = 1;
            end
        end

        % timing for stage 2
        if DEC.s2_order(idx) == 1
            t_s2_on(idx,:) = [TM.l_target_onset(idx) TM.un_rating2_onset(idx) TM.sti1_rep_onset(idx)];
            t_s2_off(idx,:) = [TM.fixation5_onset(idx) TM.fixation6_onset(idx) end_t];
        elseif DEC.s2_order(idx) == 2
            t_s2_on(idx,:) = [TM.l_target_onset(idx) TM.un_rating2_onset(idx) TM.sti1_rep_onset(idx)];
            t_s2_off(idx,:) = [TM.fixation5_onset(idx) end_t TM.fixation6_onset(idx)];
        else
            t_s2_on(idx,:) = [TM.l_target_onset(idx) TM.un_rating2_onset(idx) TM.sti1_rep_onset(idx)];
            t_s2_off(idx,:) = [TM.fixation6_onset(idx) end_t TM.fixation5_onset(idx)];
        end
        


    end
    

    if data.individual.id == 1
        % Combine and sort the non-zero elements in ascending order
        l_target_end = sort([TM.l_target_end(TM.l_target_end~=0);  TM.l_traget_end(TM.l_traget_end~=0)], 'ascend');
        TM.l_target_end = l_target_end;
    end

    t_m_tar = TM.l_target_end;
    t_s2_m = TM.un_rating2_end;


    % If we flagged that the last row should be deleted, do it here
    if delete_last_row == 1
        t_s1_on(end,:) = [];
        t_s1_off(end,:) = [];
        t_s2_on(end,:) = [];
        t_s2_off(end,:) = [];
    end

    
   
    if corr == 1
        T.SON.names = {'sti1','l_r1','un_r1','sti2','un_r2','sti1_re'};
    else
        T.SON.names = {'sti1','s1_r1','s1_r2','sti2','s2_r','sti1_re'};
    end
    T.SOFF.names = T.SON.names;

    T.SON.mat = [t_s1_on t_s2_on];
    T.SOFF.mat = [t_s1_off t_s2_off];
    
    if corr == 1
        T.MOTOR.names = {'m_l1','m_un1','m_tar','m_un2'};
    else
        T.MOTOR.names = {'m1_s1','m2_s2','m_tar','m_s2'};
    end

    T.MOTOR.mat = [t_s1_m1 t_s1_m2 t_m_tar t_s2_m];

end