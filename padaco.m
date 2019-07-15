function padaco()
    mPathname = pathsetup();
    hObject = padacoFig('visible','off');    
    try
        parametersFile = '_padaco.parameters.txt';
        PAController(hObject,mPathname,parametersFile);
    catch me
        showME(me);
        fprintf(1,['The default settings file may be corrupted or inaccessible.',...
            '  This can occur when installing the software on a new computer or from editing the settings file externally.',...
            '\nChoose OK in the popup dialog to correct the settings file.\n']);
        resetDlg(hObject,fullfile(mPathname,parametersFile));
    end
end


