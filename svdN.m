function data = svdN(data,n)
    %returns the svd analyzed data where the first n signualr values are 
    %taken for reconstruction components 
    
    
    [U,S,V] = svd(data);
    
    s = diag(S);
    
    S_new = zeros(size(S));
    
    for i = 1:n
       S_new(i,i) = S(i,i); 
    end
    
    data = U*S_new*V';
end