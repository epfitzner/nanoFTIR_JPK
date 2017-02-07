function CC = complexConjugateAvg(spectrum)
%%Calculate the average of a symmetric Complex conjugate spectrum

    CC = (spectrum+fliplr(circshift(conj(spectrum),[-1 -1])))./2;

end