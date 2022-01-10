%%polymer  = ࣬missing residual/complete

%%  dir

path = '/home/user/Documents/wjm/PDBbind/refined-set/monomer/C_N_com';                
path_com = '/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/complete'; %complete residue copy
path_mis = '/home/user/Documents/wjm/PDBbind/refined-set/monomer/missing/missing';  %missing residual copy

%%  
namelist  = dir(path);
for i = 3:size(namelist,1)
    clear atom;
    folden_name =  namelist(i).name;
    protein_name = strcat(folden_name,'_protein.pdb');  
    protein_path = strcat(path,'/',folden_name,'/');
    path_missing = strcat(path_mis,'/',folden_name);
    path_complete = strcat(path_com,'/',folden_name);
    file_name=[protein_path,protein_name];     
    fid = fopen(file_name,'rt');
    rewrite;
    N_path = find(strcmp(atom(:,3),'N'));
    C_path = find(strcmp(atom(:,3),'C'));
    count=0;
    for j = 1:(size(N_path,1)-1)
        
        if strlength(atom(C_path(j),5))==1
            C_point = atom(C_path(j),7:9);
        elseif strlength(atom(C_path(j),5))==5||strlength(atom(C_path(j),5))==6                
            C_point = atom(C_path(j),6:8);
        else
            fprintf('%s-Exception appeared\n',folden_name);
        end
        
        if strlength(atom(N_path(j+1),5))==1
            N_point = atom(N_path(j+1),7:9);
        elseif strlength(atom(N_path(j+1),5))==5||strlength(atom(N_path(j+1),5))==6
            N_point = atom(N_path(j+1),6:8);
        else
            fprintf('%s-Exception appeared\n',folden_name);
        end
            
        
            
        N_atom(1) = str2num(N_point{1});
        N_atom(2) = str2num(N_point{2});
        N_atom(3) = str2num(N_point{3});
            
        C_atom(1) = str2num(C_point{1});
        C_atom(2) = str2num(C_point{2});
        C_atom(3) = str2num(C_point{3});
        dist_CN = dist(C_atom,N_atom);
        if(dist_CN>1.8)
            fprintf('%s-missing\n',folden_name);
            copyfile(protein_path,path_missing);
            break
        else
            count = count + 1;
        end
    end
        
    if(count==(size(N_path,1)-1))
        fprintf('%s-complete\n',folden_name);
        copyfile(protein_path,path_complete);
    end
    
end