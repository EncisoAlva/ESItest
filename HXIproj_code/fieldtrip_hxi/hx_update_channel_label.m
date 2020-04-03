function label = hx_update_channel_label(filename)

a = textread(filename,'%s');
label = a(2:2:end);

end