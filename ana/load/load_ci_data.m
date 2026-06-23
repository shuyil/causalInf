function [DF, subNos] = load_ci_data(subNos, PATH, corr)

% if corr == 1, then the evs for stage 1 follows order [s1 l_rating un_rating]
% if corr == 0, then the rating for l and un are not differentiated during
% stage 1


nsub = numel(subNos);
% load raw data
DF = {};

for isub = 1:nsub
    for session = 1:2
        load(fullfile(PATH.masterlog,['S' num2str(subNos(isub))],['S' num2str(subNos(isub)) '_CI_b' num2str(session)]));
        DF{isub,session}.ids = subNos(isub);
        DF{isub,session}.run = session;
        
        DF{isub,session}.individual = data.individual;

        % get timing information for fmri analysis
        DF{isub,session}.trigger = [data.tTrig1 data.tTrig2];
        
        T = timing_organise(data,corr);
        DF{isub,session}.SON = T.SON;
        DF{isub,session}.SOFF = T.SOFF;
        DF{isub,session}.MOTOR = T.MOTOR;

        % get behavioural data
        DF{isub,session}.BD = sort_behav(data,corr);

    end
end

end