function CC = complexConjugateAvg(spectrum,dim)
%%Calculate the average of a symmetric Complex conjugate spectrum with
%%the spectral dimension being dim

    CC = (spectrum+flip(circshift(conj(spectrum),-1,dim),dim))./2;

end