function [trl, event] = hx_trialfun_average(cfg)
%http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "Stimulus" events
ind = find(strcmp('Stimulus', {event.type}));
eventValue = {event.value};
value  = [eventValue(ind)]';
sample = [event(ind).sample]';

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);

% look for the trigger 'S  1'
trl = [];
for j = 1:(length(value))
  trg = value(j);
  if strcmpi(trg, 'S  1')
    trlbegin = sample(j) + pretrig;       
    trlend   = sample(j) + posttrig;       
    offset   = pretrig;
    newtrl   = [trlbegin trlend offset];
    trl      = [trl; newtrl];
  end
end