function Out = Clip(In,Hdim,PureState)
%CLIP  Convert a generating set into the clipped gauge.
%
%   OUT = CLIP(IN, HDIM, PURE_STATE) returns a generating set OUT which
%   generates the same stabilizer group (rowspace) as IN, but in the
%   clipped gauge.
%
%   --IN is a N-by-2N matrix of integers modulo HDIM. Each row describes
%   the operators of the Pauli string. The rows should be independent, or
%   the function will throw an error.
%
%   --PURE_STATE is a boolean, TRUE if the state is a pure state (i.e.
%   there are no nonzero rows; the number of generators equals the number
%   of sites) and FALSE if not. If FALSE, it suppresses an error that would
%   otherwise occur if OUT had a row of zeros.
%

%{
    Pseudocode:

First, we work the left endpoints:
    - Start at column CurrentColumn, check 'checklist' to find first row to have a nonzero entry.
        > We don't move the columns around in-place, we copy them to another matrix, so 'checklist' marks the rows we haven't worked on yet.
        > If there are no nonzero entries, CurrentColumn++, repeat
    - Let the first nonzero entry in the column have the index RowIndex. Find that value's multiplicative inverse mod d, and multiply {makes
    leading entry = 1}
    - For all later rows, subtract (leading entry)*(RowIndex value) {makes all other leading entries = 0}
    - Place the row at RowIndex into row at CurrentRow in Out
    - Check off RowIndex in checklist
    - CurrentColumn++, repeat
Then, the right endpoints:
(the checklist is important here, as we need to keep track of which
generators are shorter)
    - Reset the checklist
    - Set CurrentColumn=length
    - Starting at CurrentColumn, check 'checklist' to find last row with a nonzero entry in the column CurrentColumn
        > If there are no nonzero entries, CurrentColumn--, repeat
    - Call row RowIndex, multiply by (*) inverse mod d
    - For all rows above with nonzero entry, subtract (leading value)*(RowIndex)
        > Since we work from the bottom up, these entries will be the rightmost nonzero entries of these rows.
    - Place row RowIndex at (height-CurrentRow) in Out
    - Check off RowIndex in checklist
    - CurrentCoumn--, repeat
end

%}
    
    if nargin<=2
        PureState=false;
    end
   
    [NumRows,NumColumns] = size(In);
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
    
    col_idx=1; row_idx=1;       % Row and Column indicators
    CurrentOutRowIndex = 1;     % Current row that we're copying In(RowFoundIndex) to
    RowFoundIndex=0;            % RowIndex = 0 means it found no row with nonzero leading entry
    CurrentInverse=0;           % mod-inverse of a leading power
    Out = zeros(NumRows,NumColumns);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% part 1
    
    checklist = ones(NumRows,1,'logical');

    for col_idx=1:NumColumns

        RowFoundIndex=0;
        for row_idx=1:NumRows
            if checklist(row_idx)  %find nonzero starting entry
                if mod(In(row_idx,col_idx),Hdim)~=0
                    RowFoundIndex = row_idx;
                    break
                end
            end
        end

        if RowFoundIndex~=0
            CurrentInverse = ModInverse(In(RowFoundIndex,col_idx),Hdim);
            Out(CurrentOutRowIndex,:) = mod(CurrentInverse*In(RowFoundIndex,:),Hdim);    %row Out(CurrentOutRowIndex,:) now leads with 1

            for row_idx=(RowFoundIndex+1):NumRows  %only search these, because we know the higher ones have leading entries of zero
                if checklist(row_idx)
                    if mod(In(row_idx,col_idx),Hdim)~=0
                        In(row_idx,:) = mod(In(row_idx,:)-In(row_idx,col_idx)*Out(CurrentOutRowIndex,:),Hdim);
                        %   The first entry of Out(CurrentOutRowIndex) row is 1.
                        %   We multiply to get an independent generator with the same content as In(IterativeRowIndex,:) in the column col_idx.
                        %   We can then subtract it to make the In(IterativeRowIndex,:) entry in IterativeColumnIndex vanish.
                        %   It vanishes even without modulo.
                    end
                end
            end

            checklist(RowFoundIndex) = false;
            %   Ticks this row off of our checklist
            CurrentOutRowIndex = CurrentOutRowIndex+1;
            %   Now, we'll send the next important row to the next available row in Out.

        end

    end
    
    if PureState && (CurrentOutRowIndex-1~=NumRows)
        ErrSct = struct('message','Zero-row in output. Row vectors probably do not form a spanning set.','identifier','Clip:ZeroRowInOutput');
        error(ErrSct);
    end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% part 2

    %CurrentOutRowIndex=NumRows;
    checklist = ones(NumRows,1,'logical');

    for col_idx=NumColumns:-1:1   % Start from the right: decrease from 2*N to 1
        RowFoundIndex=0;
        for row_idx=NumRows:-1:1           
            % The order is very important here; the leftmost generators are at the top
            % of the list (smallest row index).
            % We want to find a nonzero entry, starting from the bottom (largest column
            % row index ).
            if checklist(row_idx)
                if mod(Out(row_idx,col_idx),Hdim)~=0
                    RowFoundIndex=row_idx;
                    break
                end
            end
        end

        if RowFoundIndex
            CurrentInverse = ModInverse(Out(RowFoundIndex,col_idx),Hdim);
            Out(RowFoundIndex,:) = mod(CurrentInverse*Out(RowFoundIndex,:),Hdim);    %row RowIndex now leads with 1
                % We don't move the row to another matrix, because the order of the rows now matters - 
                % The rows are ordered by left endpoint, and we should only add rows to the rows above them, to preserve this ordering.
            for row_idx=(RowFoundIndex-1):-1:1    %only search these
                    % The lower rows have zero leading entries, since they didn't trigger the above loop.
                if checklist(row_idx) && mod(Out(row_idx,col_idx),Hdim)~=0
                    Out(row_idx,:) = mod(Out(row_idx,:)-Out(row_idx,col_idx)*Out(RowFoundIndex,:),Hdim);
                end
            end
                % we're only going to look at rows above CurrentRow-1 now, so we
                % don't have to worry about the old CurrentRow
            checklist(RowFoundIndex) = false;
        end
    end
    
end