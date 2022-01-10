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
for i=1:(size(list_cell)-1)
    dat=strsplit(list_cell{i});
    for j=1:size(dat,2)
        data{i,j}=dat{j};
    end
end
%%    
begin=find(strcmp(data,'ATOM'),1);
final=find(strcmp(data,'TER'),1);

for i = 1:(final-begin)
    for j = 1:size(data,2)
        atom(i,j)=data(i+begin-1,j);
    end
end