L = size(au_in, 1)* oesr/sr;
button = input('Start Song? Hit 1 followed by Return');
duration = L/oesr;
player = audioplayer(au_in, sr);

if button ==1;
    play(player);
    %soundsc(au_in, sr);
    start_time = tic;
    i = 1;
    while(toc(start_time) < duration)
        [ch(i), t(i, 1)] = getkey;
        if ch(i) == 27
            stop(player);
            break;
        end
        i=i+1;
    end
end

t = t(1:end-1);
for i=2:1:size(t, 1)
    t(i, 1) =  t(i-1, 1) + t(i, 1);
end

t = fix(t*250);
user_input = zeros(L, 1);
for i=1:1:size(t,1)
    user_input(t(i), 1) = 1;  
end

diff_t = diff(t);
hist_t = hist(diff_t, 0:10:400);
[tmax_count, tmax_loc] = max(hist_t);
startbpm = fix((60*oesr)/(10*(tmax_loc-0.5)));
startbpm = [startbpm, startbpm*2];