%% CHANGELOG
% 2020-05-20
%    Modified to use the whole trial + prestim + poststim
%
function [trl, event] = ea_trialfun_general(cfg)
%http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition

% read header info, events
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "Stimulus" events
ind = find(strcmp('Stimulus', {event.type}));
eventValue = {event.value};
value  = [eventValue(ind)]';
sample = [event(ind).sample]';

% determine num samples before/after each trial
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);

% look for trigger 'S  1', then for 'S  2'
trl = [];
for j = 1:(length(value))
  trg = value(j);
  if strcmpi(trg, 'S  1')
    trlbegin = sample(j) + pretrig;       
    offset   = pretrig; 
  end
  for k = (j+1):(length(value))
      if strcmpi(trg, 'S  1') || strcmpi(trg, 'S  2')
          disp('ERROR')
      end
    if strcmpi(trg, 'S  3')
      trlend = sample(j) + posttrig;
      newtrl   = [trlbegin trlend offset];
      trl      = [trl; newtrl];
      break
    end
  end
end