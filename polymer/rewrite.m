%rewrite
%%Progressive scanning
tline = fgetl(fid);
list_cell={};
while ischar(tline)
    %disp(tline)
    tline = fgetl(fid);
    list_cell = [list_cell;tline];
end
fclose(fid);
%%
clear data
for i=1:(size(list_cell)-1)
    dat=strsplit(list_cell{i});
    for j=1:size(dat,2)
        data{i,j}=dat{j};
    end
end
%%    
