function Out = Clip(In,Hdim,PureState)
    %puts matrix 'In' into the clipped gauge, mod d. Expecting an 2LxL matrix with columns describing the operators in the Pauli string, already modulo d.
    
    %works with the operators as columns, as it seems to improve
    %computation speed
    
    %v1.0
    
    %{
        Pseudocode:
Note: it was conceptually easier to think of the operators as being
rows, but computationally easier to treat them as columns; the
variables are named as if the operators are rows, and so with the
pseudocode
    
    First, we work the left endpoints:
        - Start at column CurrentColumn, check 'checklist' to find first row to have a nonzero entry
            > We don't move the columns around in-place, we copy them to another matrix, so 'checklist' marks the rows we haven't worked on yet.
            > if no nonzero, CurrentColumn++, repeat
        - call nonzero entry row RowIndex. Find  the value's (*) inverse mod d, and multiply (makes leading entry = 1)
        - for all later rows, subtract (leading entry)*(RowIndex value) {makes all other leading entries = 0}
        - place row RowIndex at row CurrentRow in Out
        - check off RowIndex in checklist
        - CurrentColumn++, repeat
    Then, the right endpoints:
    (the checklist is important here, as we need to keep track of which
    strings are shorter)
        - reset the checklist
        - set CurrentColumn=length
        - start at CurrentColumn, check 'checklist' to find last row to have a nonzero entry
            > if no nonzero, CurrentColumn--, repeat
        - call row RowIndex, multiply by (*) inverse mod d
        - for all rows above with nonzero leading term, subtract (leading value)*(RowIndex)
        - place row RowIndex at height-CurrentRow in Out
        - check off RowIndex in checklist
        - CurrentCoumn--, repeat
    end
    
    %}
    
    if nargin<=2
        PureState=false;
    end
   
    [NumRows,NumColumns] = size(In);     %intentionally backwards, as per current calculating convention
    if 2*NumRows == NumColumns
        %
    elseif 2*NumColumns==NumRows
        In=In';
        [NumRows,NumColumns] = size(In);
    else
        fprintf('Unexpected dimensions in "Clip". Expects 2LxL list of column generators. Returning...\n')
        return
    end
    if NumRows==0 || NumColumns==0
        fprintf('Zero dimension in "Clip"! Returning....\n');
        return
    end

    
    IterativeColumnIndex=1; IterativeRowIndex=1;  %Row and Column indicators
    CurrentOutRowIndex = 1;     % current row that we're copying In(RowFoundIndex) to
    RowFoundIndex=0;                     %RowIndex = 0 means it found no row with nonzero leading entry
    inverse=0;                      %mod-inverse of a leading power
    Out = zeros(NumRows,NumColumns);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% part 1
    
    checklist = ones(NumRows,1,'single');

    for IterativeColumnIndex=1:NumColumns

        RowFoundIndex=0;
        for IterativeRowIndex=1:NumRows

            if checklist(IterativeRowIndex)  %find nonzero starting entry
                if mod(In(IterativeRowIndex,IterativeColumnIndex),Hdim)~=0

                    RowFoundIndex=IterativeRowIndex;
                    break

                end
            end

        end

        if RowFoundIndex
            inverse = ModInverse(In(RowFoundIndex,IterativeColumnIndex),Hdim);
            Out(CurrentOutRowIndex,:) = mod(inverse*In(RowFoundIndex,:),Hdim);    %row Out(CurrentOutRowIndex,:) now leads with 1

            for IterativeRowIndex=(RowFoundIndex+1):NumRows  %only search these, because we know the higher ones have zero leading entries

                if checklist(IterativeRowIndex)
                    if mod(In(IterativeRowIndex,IterativeColumnIndex),Hdim)~=0

                        In(IterativeRowIndex,:) = mod(In(IterativeRowIndex,:)-In(IterativeRowIndex,IterativeColumnIndex)*Out(CurrentOutRowIndex,:),Hdim);
                        %   The first entry of Out(CurrentOutRowIndex) row is 1.
                        %   We multiply to get an independent generator with the same content as In(IterativeRowIndex,:) in the column IterativeColumnIndex.
                        %   We can then subtract them to make the In(IterativeRowIndex,:) entry in IterativeColumnIndex vanish.
                        %   It vanishes even without modulo.

                    end
                end

            end

            checklist(RowFoundIndex) = 0;
            %   Ticks this row off of our checklist
            CurrentOutRowIndex = CurrentOutRowIndex+1;
            %   Now, we'll send the next important row to the next available row in Out.

        end

    end
    
    if PureState && (CurrentOutRowIndex-1~=NumRows)
        fprintf('Problem in "Clip": zero-row in output. Row vectors probably do not form a spanning set. Returning...\n')
        return
    end

 %Out = mod(Out,d);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% part 2

    %CurrentOutRowIndex=NumRows;
    checklist = ones(NumRows,1,'single');

    for IterativeColumnIndex=NumColumns:-1:1   %decrease from 2*L to 1

        RowFoundIndex=0;
        for IterativeRowIndex=NumRows:-1:1           %order very important here; leftmost generators are at the top of the list

            if checklist(IterativeRowIndex) %find nonzero starting entry, starting at bottom
                if mod(Out(IterativeRowIndex,IterativeColumnIndex),Hdim)~=0

                    RowFoundIndex=IterativeRowIndex;
                    break

                end
            end

        end

        if RowFoundIndex

            inverse = ModInverse(Out(RowFoundIndex,IterativeColumnIndex),Hdim);
            Out(RowFoundIndex,:) = mod(inverse*Out(RowFoundIndex,:),Hdim);    %row RowIndex now leads with 1
            %   We don't move the row to another matrix, because the order of the rows now matters - 
            %   The rows are ordered by right endpoint, and we should only add rows to the rows above them, to preserve this ordering.

            %   Note that we can't generally order the rows by both left _and_ right endpoint. So, we still have to check all the rows every time - 
            %   we can't skip rows below the one we found, in later loops.

            for IterativeRowIndex=(RowFoundIndex-1):-1:1    %only search these;
                %   the lower rows have zero leading entries, since they didn't trigger the above loop.
                if checklist(IterativeRowIndex) && mod(Out(IterativeRowIndex,IterativeColumnIndex),Hdim)~=0

                    Out(IterativeRowIndex,:) = mod(Out(IterativeRowIndex,:)-Out(IterativeRowIndex,IterativeColumnIndex)*Out(RowFoundIndex,:),Hdim);

                end
            end
            %we're only going to look at rows above CurrentRow-1 now, so we
            %don't have to worry about the old CurrentRow

            checklist(RowFoundIndex) = 0;

        end

    end

    %Out = mod(Out,d);
    
end