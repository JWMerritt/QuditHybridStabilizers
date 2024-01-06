function [parentPath, filename, extension] = splitAbsolutePath(fullpath)

string_input = false;

if isstring(fullpath)
    string_input = true;
    fullpath = char(fullpath);
elseif ~ischar(fullpath)
    errMsg = sprintf('File path must be eigher a char or string.');
    errStrct = struct('message',errMsg,'identifier','splitAbsolutePath:InvalidInputType');
    error(errStrct)
end

slashPos = find(fullpath == '/');
if numel(slashPos)>0
    slashPresent = true;
else
    slashPresent = false;
end

dotPos = find(fullpath == '.');
dotPresent = false;
if numel(dotPos)>0
    if ~slashPresent || (slashPresent && slashPos(end)<dotPos(end))
        dotPresent = true;
    end
end

if slashPresent
    parentPath = fullpath(1:slashPos(end));
else
    parentPath = '';
end

if dotPresent
    extension = fullpath(dotPos(end):end);
else
    extension = '';
end

if slashPresent
    if dotPresent
        filename = fullpath(slashPos(end)+1:dotPos(end)-1);
    else
        filename = fullpath(slashPos(end)+1:end);
    end
else
    if dotPresent
        filename = fullpath(1:dotPos(end)-1);
    else
        filename = fullpath;
    end
end

if string_input
    parentPath = string(parentPath);
    filename = string(filename);
    extension = string(extension);
end

end