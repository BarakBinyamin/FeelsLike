function matOut = cleanUp(matIn)
% cleanUp removes rows from matrix with -9999
rowSize = size(matIn,1);
restart = 0;
for row=1:rowSize
    if (restart==1)
        break
    end
    for col=1:size(matIn,2)
        if (matIn(row,col) <= -9999)
            matIn(row,:) = [ ];
            restart = 1;
            %disp("removed index")
            %disp(row)
            break
        end
    end
end

if (restart==1)
    matOut = cleanUp(matIn);
else
    matOut = matIn;
end

end