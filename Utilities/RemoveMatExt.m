function strOut = RemoveMatExt(strIn)
%REMOVEMATEXT remove '.mat' extension on a file name/path. If input is too
% short or does not end in '.mat', return the original input.
%
%   OUT = REMOVEMATEXT(IN) takes a char array or string IN and removes the
%   '.mat' extension from the end, if available. The output will be of the
%   same type as the imput (char to char, string to string).

In_is_string = false;

if ~ischar(strIn)
    if isstring(strIn)
        In_is_string = true;
        strIn = char(strIn);
    else
        ErrMsg = "Error in RemoveMatExt: input must be either string or char array.";
        ErrStruct = struct('message', ErrMsg, 'identifier', 'RemoveMatExt:InvalidInputFormat');
        error(ErrStruct);
    end
end

if numel(strIn)>4
    if strIn(end-3:end)=='.mat'
        strOut = strIn(1:end-4);
    else
        strOut = strIn;
    end
else
    strOut = strIn;
end

if In_is_string
    strOut = string(strOut);
end

end

