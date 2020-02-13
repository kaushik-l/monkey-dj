function B = goodcolormap(map,N)

switch map
    case 'wr'    
        B(1,:)= [ones(1,N/2) ones(1,N/2)]; 
        B(2,:)= 1:-1/(N - 1):0; 
        B(3,:)= 1:-1/(N - 1):0;
    case 'bwr'
        B(1,:)= [0:1/(N/2 - 1):1 ones(1,N/2)]; 
        B(2,:)= [0:1/(N/2 - 1):1 1:-1/(N/2 - 1):0];
        B(3,:)= [ones(1,N/2) 1:-1/(N/2 - 1):0];
end
B = B';