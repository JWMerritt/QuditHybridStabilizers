function DoneFile(JobPath,JobName,CKPT_Name_Fullpath)
    %just creates a file called output/filename.done
    
    
    if nargin==2 	% This is the original code.

        fprintf('\n\n EXECUTION ENDED. WRITING .done FILE\n\n')
        try
            FileID = fopen(cat(2,JobPath,'/ExitFiles/',JobName,'.done'),'w');
        catch
            fprintf('ERROR: .done file could not be opened. Maybe the ./ExitFiles/ directory does not exist?')
            return
        end
        c = clock;
        fprintf(FileID,JobName);
        fprintf(FileID,'\n Date: %.4d/%.2d/%.2d, %.2d:%.2d\n',c(1),c(2),c(3),c(4),c(5));
        fclose(FileID);
    
        fprintf('DONE.\n')

    elseif nargin==3 	% This is the new code, which checks to see if the code is *actually* done

        writeTheFile = false;
        loadFailed = false;
        fprintf('\n\n EXECUTION ENDED SUCCESSFULLY. Doing consistency check...')
        try
            Check = load(CKPT_Name_Fullpath,'RealizationsPerSystemSize_Counter','SystemSize_Index','Number_SystemSizes');
            loadFailed = false;
            %	circuits = 1; N_i = N_i + 1; happens at the end of each NVal.
            %	So, if we've successfully finished the job, N_i=Nnum+1 and circuits=1.
        catch LoadFail
            fprintf('\n   CKPT load failed...')
            fprintf('\n  ~~  %s',LoadFail.identifier)
            fprintf('\n  ~~  "%s"',LoadFail.message)
            fprintf('\n	  writing file anyway...')
            loadFailed = true;
            writeTheFile = true;
        end
            
        if (~loadFailed)&&(Check.RealizationsPerSystemSize_Counter==1)&&(Check.SystemSize_Index==(Check.Number_SystemSizes+1))
            fprintf('consistent with completion. Writing .done file.')
            writeTheFile = true;
        elseif ~loadFailed
            fprintf('not consistent with completion.')
            fprintf('\n->		$circuits=%d, $N_i=%d, $Nnum=%d',Check.circuits,Check.N_i,Check.Nnum)
            fprintf('\n-> 		should be $circuits=1, $N_i=$Nnum+1')
            fprintf('\n.done file not written.')
            writeTheFile = false;
        end
        
        if writeTheFile
            try
                FileID = fopen(cat(2,JobPath,'/ExitFiles/',JobName,'.done'),'w');
            catch
                fprintf('ERROR: .done file could not be opened. Maybe the ./ExitFiles/ directory does not exist?')
                return
            end
            c = clock;
            fprintf(FileID,JobName);
            fprintf(FileID,'\n Date: %.4d/%.2d/%.2d, %.2d:%.2d\n',c(1),c(2),c(3),c(4),c(5));
            fclose(FileID);
    
            fprintf('DONE.\n')
        end
    end
    
    
    end
    
    %13/Sep/2021 - Doubled the file, adding code that attempts to check the CKPT
    %	file to see if the Job has actually completed running.
    %28/Feb/2023 - Dragged the file into ParafermionComponents and updated the terminology.