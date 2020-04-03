function [trl, event] = hx_trialfun_resting(cfg)
%http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);
dat = ft_read_data(cfg.dataset); % nChan x nSamples

% down sampling 512 Hz
freq = hdr.Fs;
interval = freq / 512;
dat1 = dat(:,1:interval:end);

% search for "STATUS" events
ind = find(strcmp('STATUS', {event.type}));
eventValue = event.value;
value  = eventValue(ind);
sample = event(ind).sample;

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * 512);
posttrig =  round(cfg.trialdef.post * 512);

trl = [];
for j = 1:(length(value))
  trg = value(j);
  if trg==64767
    trlbegin = round(trg/interval) + pretrig;       
    trlend   = round(trg/interval) + posttrig;   
    offset   = pretrig;
    newtrl   = [trlbegin trlend offset];
    trl      = [trl; newtrl];
  end
end