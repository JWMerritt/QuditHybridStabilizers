function Mat = RowReduceMod(Mat,Hdim)
%   Row reduces a matrix modulo some number. Needed to check row vector independence. Does not order the rows in decreasing size.

[NumRows,NumColumns] = size(Mat);

RowChecklist = ones(NumRows,1);

for IterativeColumnIndex=1:NumColumns

    NonzeroRows = find(Mat(:,IterativeColumnIndex).*RowChecklist);

    if numel(NonzeroRows)==0
        % move on
    else

        CurrentRowIndex = NonzeroRows(1);
        %   Get the row for reducing
        CurrentRow = mod(ModInverse(Mat(CurrentRowIndex,IterativeColumnIndex),Hdim)*Mat(CurrentRowIndex,:),Hdim);
        %   Make the leading entry equal to 1
        Mat(NonzeroRows,:) = mod(Mat(NonzeroRows,:) - Mat(NonzeroRows,IterativeColumnIndex)*CurrentRow,Hdim);
        %   Make the other row leading entries equal to 0
        Mat(CurrentRowIndex,:) = CurrentRow;
        %   Replace the current row, since it was set to all 0 in the last line.
        RowChecklist(CurrentRowIndex) = 0;
        %   Remove the row from the checklist
    end

end


end