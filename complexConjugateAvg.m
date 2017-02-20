function CC = complexConjugateAvg(spectrum)
%%Calculate the average of a symmetric Complex conjugate spectrum

    CC = (spectrum+flip(circshift(conj(spectrum),-1,2),2))./2;

end