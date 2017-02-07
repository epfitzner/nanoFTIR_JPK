function CC = complexConjugateAvg(spectrum)
%%Calculate the Complex conjugate spectrum of a complex spectrum

    CC = (spectrum+fliplr(circshift(conj(spectrum),[-1 -1])))./2;

end