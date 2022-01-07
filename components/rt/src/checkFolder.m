function checkFolder(folder)

    if isfolder(folder)
        addpath(genpath(folder))
    else
        error(['The directory ' folder ' cannot be found.']);
    end

end