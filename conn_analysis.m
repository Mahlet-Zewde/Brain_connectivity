
%where the conn and the spm are
addpath('C:\Users\Mahi\Desktop\School work 2016-2017\brain connectivity\conn');
addpath('C:\Users\Mahi\Desktop\School work 2016-2017\brain connectivity\conn\spm12');

%name of the project file
connfile = 'conn_CMU.mat';
%where the data is
dataPath = 'C:\Users\Mahi\Desktop\School work 2016-2017\brain connectivity\CMU';
RUNPARALLEL = true; %not needed atm
NSUBJECTS = 20;
NJOBS = 2; %not needed atm
COPYFILES = false;
OVERWRITE = true;
TR = 2;

%% FINDS the FILES
clear FUNCTIONAL_FILE* PAR_FILE;
subs=dir(regexprep(dataPath,'%s.*$','*')); 
subs=subs([subs.isdir]>0);
subs={subs.name};
subs=subs(cellfun(@(s)all(s>='0'&s<='9'),subs));
if isempty(NSUBJECTS), NSUBJECTS=numel(subs); 
else subs=subs(1:NSUBJECTS);
end
if isempty(NJOBS), NJOBS=NSUBJECTS; end
NJOBS=min(NSUBJECTS,NJOBS);

for n=1:numel(subs)
    fprintf('Locating subject %s files\n',subs{n});
    
    f1=fullfile(dataPath, '/', subs{n},'epi_preprocessed.nii');   % FUNCTIONAL VOLUME
    r1=fullfile(dataPath, '/', subs{n},'epi_MCF.nii.par');        %  FILE
    if isempty(dir(f1)), error('file %s not found',f1); end
    if isempty(dir(r1)), error('file %s not found',r1); end
     
    FUNCTIONAL_FILE{n} = f1;
    PAR_FILE{n} = r1;
end
nsessions=1;
fprintf('%d subjects, %d sessions\n',NSUBJECTS,nsessions);


%% Prepares batch structure
clear batch;
batch.filename=connfile;            % New conn_*.mat experiment name
batch.parallel.N=0;    

%% setup
batch.Setup.isnew=1;
batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;                                        % TR (seconds)
batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       % Point to functional volumes for each subject/session
batch.Setup.covariates.names={'covariates_in_file'};
for nsub=1:NSUBJECTS
    batch.Setup.functionals{nsub}{1}{1} = FUNCTIONAL_FILE{nsub}; 
    batch.Setup.covariates.files{1}{nsub}{1} = PAR_FILE{nsub}; %Not sure about this one
end

batch.Setup.subjects.group_names = {'Autistic','Control'};
batch.Setup.subjects.groups = [ones(10,1); 2.*ones(10,1)];

nconditions=1;                                  % treats each session as a different condition (comment the following three lines and lines 84-86 below if you do not wish to analyze between-session differences)
for nsub = 1:NSUBJECTS
    batch.Setup.conditions.names={'rest'};
    batch.Setup.conditions.onsets{1}{nsub}{1} = 0; 
    batch.Setup.conditions.durations{1}{nsub}{1} = inf; % rest condition (all sessions)
end    

%batch.Setup.preprocessing.steps='default_mni';
%batch.Setup.preprocessing.sliceorder='interleaved (Siemens)';
batch.Setup.done=1;
batch.Setup.overwrite='Yes';             

%% DENOISING step
% CONN Denoising                                    % Default options (uses White Matter+CSF+realignment+conditions as confound regressors); see conn_batch for additional options 
batch.Denoising.filter=[0.01, 0.1];                 % frequency filter (band-pass values, in Hz)
batch.Denoising.done=1;
batch.Denoising.overwrite='Yes';


%% FIRST-LEVEL ANALYSIS step
% CONN Analysis                                     % Default options (uses all ROIs in conn/rois/ as connectivity sources); see conn_batch for additional options 
batch.Analysis.done=1;
batch.Analysis.overwrite='Yes';

batch.vvAnalysis.done=1;
batch.vvAnalysis.overwrite='Yes';

%% Run all analyses
tic;
conn_batch(batch);
disp(['CONN batch running Results took ', num2str(round(toc / 60)), ' minutes']);


%% CONN Display
% launches conn gui to explore results
%conn
%
conn('load', connfile);
%
conn gui_results






