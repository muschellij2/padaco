%> @file PAController.m
%> @brief PAController serves as Padaco's controller component (i.e. in the model, view, controller paradigm).
% ======================================================================
%> @brief PAController serves as the UI component of event marking in
%> the Padaco.  
%
%> In the model, view, controller paradigm, this is the
%> controller. 


classdef PAController < handle
    
    properties
        %> acceleration activity object - instance of PAData
        accelObj;
        %> Instance of PASettings - this is brought in to eliminate the need for several globals
        SETTINGS; 
        %> Instance of PAView - Padaco's view component.
        VIEW;
        %> Instance of PAModel - Padaco's model component.  To be implemented. 
        MODEL;        

        %> Linehandle in Padaco that is currently selected by the user.
        current_linehandle;
        
        %> cell of string choices for the marking state (off, 'marking','general')
        state_choices_cell; 
        %> string of the current selected choice
        %> handle to the figure an instance of this class is associated with
        %> struct of handles for the context menus
        contextmenuhandle; 
        
        %> @brief struct with field
        %> - .x_minorgrid which is used for the x grid on the main axes
        linehandle;         
        
        %> struct of different time resolutions, field names correspond to the units of time represented in the field        
        epoch_resolution;
        num_epochs;
        display_samples; %vector of the samples to be displayed
        shift_display_samples_delta; %number of samples to adjust display by for moving forward or back
        startDateTime;
        study_duration_in_seconds;
        study_duration_in_samples;

        STATE; %struct to keep track of various Padaco states
        Padaco_loading_file_flag; %boolean set to true when initially loading a src file
        Padaco_mainaxes_ylim;
        Padaco_mainaxes_xlim;        
    end
    


    methods
        
        function obj = PAController(Padaco_fig_h,...
                rootpathname,...
                parameters_filename)
            if(nargin<1)
                Padaco_fig_h = [];
            end
            if(nargin<2)
                rootpathname = fileparts(mfilename('fullpath'));
            end
            
            %check to see if a settings file exists
            if(nargin<3)
                parameters_filename = '_padaco.parameters.txt';
            end;
            
            %create/intilize the settings object            
            obj.SETTINGS = PASettings(rootpathname,parameters_filename);

            if(ishandle(Padaco_fig_h))
                %let's create a VIEW class
                obj.VIEW = PAView(Padaco_fig_h);
                
                handles = guidata(Padaco_fig_h);
                
                obj.configureCallbacks();
                
                % Synthesize edit callback to trigger first display
                obj.edit_curEpochCallback(handles.edit_curEpoch,[]);
                
            end                
        end
        
        %% Shutdown functions        
        %> Destructor
        function close(obj)
            obj.saveParameters(); %requires SETTINGS variable
            obj.SETTINGS = [];
        end        
        
        function saveParameters(obj)
            obj.SETTINGS.saveParametersToFile();
        end
        
        function paramStruct = getSaveParametersStruct(obj)
            paramStruct = obj.SETTINGS.VIEW;
        end            
        

        %% Startup configuration functions and callbacks
        % --------------------------------------------------------------------
        %> @brief Configure callbacks for the figure, menubar, and widets.
        %> Called internally during class construction.
        %> @param Instance of PAController
        % --------------------------------------------------------------------        
        function configureCallbacks(obj)   
            figH = obj.VIEW.getFigHandle();
            
            % figure callbacks
            set(figH,'CloseRequestFcn',{@obj.figureCloseCallback,guidata(figH)});            
            set(figH,'KeyPressFcn',@obj.keyPressCallback);
            set(figH,'KeyReleaseFcn',@obj.keyReleaseCallback);
            set(figH,'WindowButtonDownFcn',@obj.windowButtonDownCallback);
            set(figH,'WindowButtonUpFcn',@obj.windowButtonUpCallback);
            

            %configure the menu bar
            obj.configureMenubar();
            
            %configure the user interface widgets
            obj.configureWidgetCallbacks();
        end
        
        % --------------------------------------------------------------------
        %> @brief Executes when user attempts to close figure_padaco.
        %> @param Instance of PAController
        %> @param hObject    handle to menu_file_quit (see GCBO)
        %> @param eventdata  reserved - to be defined in a future version of MATLAB
        %> @param handles    structure with handles and user data (see GUIDATA)
        % --------------------------------------------------------------------
        function figureCloseCallback(obj,hObject, eventdata, handles)
            try
                obj.close();
                delete(hObject);
            catch ME
                showME(ME);
                killall;
            end
        end
        
        % --------------------------------------------------------------------
        %> @brief  Executes on key press with focus on figure and no controls selected.
        %> @param Instance of PAController
        %> @param hObject    handle to figure (gcf)
        %> @param Structure of key press information.
        % --------------------------------------------------------------------
        function keyPressCallback(obj,hObject, eventdata)
            % key=double(get(hObject,'CurrentCharacter')); % compare the values to the list
            key=eventdata.Key;
            handles = guidata(hObject);
            epoch = obj.curEpoch;
            
            if(strcmp(key,'add'))
                
            elseif(strcmp(key,'subtract'))
                       
            elseif(strcmp(key,'leftarrow')||strcmp(key,'pagedown'))
                %go backward 1 epoch
                obj.setCurEpoch(epoch-1);                
            elseif(strcmp(key,'rightarrow')||strcmp(key,'pageup'))
                %go forward 1 epoch
                obj.setCurEpoch(epoch+1);                    
            elseif(strcmp(key,'uparrow'))
                %go forward 10 epochs
                obj.setCurEpoch(epoch+10);
            elseif(strcmp(key,'downarrow'))
                %go back 10 epochs
                obj.setCurEpoch(epoch-10);                
            end
            
            if(strcmp(eventdata.Key,'shift'))
                set(obj.VIEW.getFigHandle(),'pointer','ibeam');
            end
            if(strcmp(eventdata.Modifier,'control'))
                %kill the program            
                if(strcmp(eventdata.Key,'x'))
                    delete(hObject);
                    %take screen capture of figure
                elseif(strcmp(eventdata.Key,'p'))
                    screencap(hObject);
                    %take screen capture of main axes
                elseif(strcmp(eventdata.Key,'a'))
                    screencap(handles.axes1);
                elseif(strcmp(eventdata.Key,'h'))
                    screencap(handles.axes2);
                elseif(strcmp(eventdata.Key,'u'))
                    screencap(handles.axes3);
                end
            end;
        end
        
        
        % --------------------------------------------------------------------
        %> @brief  Executes on key press with focus on figure and no controls selected.
        %> @param Instance of PAController
        %> @param hObject    handle to figure (gcf), unused
        %> @param Structure of key press information.
        % --------------------------------------------------------------------
        function keyReleaseCallback(obj,~, eventdata)
            
            key=eventdata.Key;
            if(strcmp(key,'shift'))
                set(obj.VIEW.getFigHandle(),'pointer','arrow');
            end;
        end

        % --------------------------------------------------------------------
        %> @brief  Executes when user releases mouse click
        %> If the currentObject selected is the secondary axes, then 
        %> the current epoch is set to the closest epoch corresponding to
        %> the mouse's x-position.
        %> @param Instance of PAController
        %> @param hObject    handle to figure (gcf), unused
        %> @param Structure of mouse press information; unused
        % --------------------------------------------------------------------
        function windowButtonUpCallback(obj,hObject,eventData)
            
            selected_obj = get(hObject,'CurrentObject');            
            if(~isempty(selected_obj))
                if(selected_obj==obj.VIEW.axeshandle.secondary)
                    pos = get(selected_obj,'currentpoint');
                    clicked_epoch = round(pos(1));
                    obj.setCurEpoch(clicked_epoch);
                end;
            end;
        end
        
        % --------------------------------------------------------------------
        %> @brief  Executes when user first clicks the mouse.
        %> @param Instance of PAController
        %> @param hObject    handle to figure (gcf), unused
        %> @param Structure of mouse press information; unused
        % --------------------------------------------------------------------
        function windowButtonDownCallback(obj,hObject,eventData)
%             if(strcmpi(obj.marking_state,'off')) %don't want to reset the state if we are marking events
%                 if(~isempty(obj.current_linehandle))
%                     obj.restore_state();
%                 end;
%             else
%                 if(ishghandle(obj.hg_group))
%                     if(~any(gco==allchild(obj.hg_group))) %did not click on a member of the object being drawn...
%                         obj.clear_handles();
%                     end;
%                 end;
%             end;
%             if(~isempty(obj.current_linehandle)&&ishandle(obj.current_linehandle) && strcmpi(get(obj.current_linehandle,'selected'),'on'))
%                 set(obj.current_linehandle,'selected','off');
%             end
        end
        

        
        %-- Menubar configuration --
        % --------------------------------------------------------------------
        %> @brief Assign figure's menubar callbacks.
        %> Called internally during class construction.
        %> @param Instance of PAController
        % --------------------------------------------------------------------        
        function configureMenubar(obj)
            figH = obj.VIEW.getFigHandle();
            handles = guidata(figH);
            
            %% file
             %  open
            set(handles.menu_file_open,'callback',@obj.menuFileOpenCallback);
             %  quit - handled in main window.
            set(handles.menu_file_quit,'callback',{@obj.menuFileQuitCallback,guidata(figH)});
            
        end
        
        % --------------------------------------------------------------------
        %> @brief Assign callbacks to various user interface widgets.
        %> Called internally during class construction.
        %> @param Instance of PAController
        % --------------------------------------------------------------------
        function configureWidgetCallbacks(obj)
            handles = guidata(obj.VIEW.getFigHandle());
            set(handles.edit_curEpoch,'callback',@obj.edit_curEpochCallback);
            set(handles.edit_aggregate,'callback',@obj.edit_aggregateCallback);
            set(handles.edit_frameSize,'callback',@obj.edit_frameSizeCallback);
            
            set(handles.menu_windowDurSec,'callback',@obj.menu_windowDurSecCallback);
            % set(handles.menu_prefilter,'callback',@obj.menu_prefilterCallback);
            % set(handles.menu_extractor,'callback',@obj.menu_extractorCallback);
            
            set(handles.button_go,'callback',@obj.button_goCallback);
        end
        
        % --------------------------------------------------------------------
        %> @brief Callback for pressing the Go push button.  Method
        %> determines parameters from current view settings (i.e. menu
        %> selections for prefilter and aggregate methods).
        %> @param Instance of PAController
        %> @param Handle to the edit text widget
        %> @param Required by MATLAB, but not used
        % --------------------------------------------------------------------
        function button_goCallback(obj,hObject,eventdata)
            %obtain the prefilter and feature extraction methods
            prefilterMethod = obj.getPrefilterMethod();
            extractorMethod = obj.getExtractorMethod();
            
            %set the prefilter duration in minutes.  
            
            %Tell the model to prefilter and extract
            obj.accelObj.prefilter(prefilterMethod);
            obj.accelObj.extractFeature(extractorMethod);
        end
        
        % --------------------------------------------------------------------
        %> @brief Retrieves current prefilter method from the GUI
        %> @param Instance of PAController
        %> @param String value of the current prefilter method.
        % --------------------------------------------------------------------
        function prefilterMethod = getPrefilterMethod(obj)
            prefilterMethods = get(obj.VIEW.menuhandle.prefilterMethod,'string');
            prefilterIndex =  get(obj.VIEW.menuhandle.prefilterMethod,'value');
            if(~iscell(prefilterMethods))
                prefilterMethod = prefilterMethods;
            else
                prefilterMethod = prefilterMethods{prefilterIndex};
            end
        end
        
        % --------------------------------------------------------------------
        %> @brief Retrieves current extractor method from the GUI
        %> @param Instance of PAController
        %> @param String value of the current feature extraction method.
        % --------------------------------------------------------------------
        function extractorMethod = getExtractorMethod(obj)
            extractorMethods = get(obj.VIEW.menuhandle.extractorMethod,'string');
            extractorIndex =  get(obj.VIEW.menuhandle.extractorMethod,'value');
            if(~iscell(extractorMethods))
                extractorMethod = extractorMethods;
            else
                extractorMethod = extractorMethods{extractorIndex};
            end
        end
        
        
        % --------------------------------------------------------------------
        %> @brief Callback for menu with window duration selections (values
        %> are in seconds)
        %> @param Instance of PAController
        %> @param Handle to the edit text widget
        %> @param Required by MATLAB, but not used
        % --------------------------------------------------------------------
        function menu_windowDurSecCallback(obj,hObject,eventdata)
            %get the array of window sizes in seconds
            windowDurSec = get(hObject,'userdata');
            % grab the currently selected window size (in seconds)
            windowDurSec = windowDurSec(get(hObject,'value'));
            
            %change it - this internally recalculates the cur epoch
            obj.accelObj.setEpochDurSec(windowDurSec);
            
            %resize the secondary axes according to the new window
            %resolution
            obj.VIEW.updateSecondaryAxes(obj.accelObj.getEpochCount);
            obj.setCurEpoch(obj.curEpoch());
        end
        
        
        % --------------------------------------------------------------------
        %> @brief Callback for current epoch's edit textbox.
        %> @param Instance of PAController
        %> @param Handle to the edit text widget
        %> @param Required by MATLAB, but not used
        % --------------------------------------------------------------------
        function edit_curEpochCallback(obj,hObject,eventdata)
            epoch = str2double(get(hObject,'string'));
            obj.setCurEpoch(epoch);
        end
        
        % --------------------------------------------------------------------
        %> @brief Callback for aggregate size edit textbox.
        %> @param Instance of PAController
        %> @param Handle to the edit text widget
        %> @param Required by MATLAB, but not used
        %> @note Entered values are interepreted as minutes.
        % --------------------------------------------------------------------
        function edit_aggregateCallback(obj,hObject,eventdata)
            aggregateDuration = str2double(get(hObject,'string'));
            obj.setAggregateDuration(aggregateDuration);
        end
        
        % --------------------------------------------------------------------
        %> @brief Callback for aggregate size edit textbox.
        %> @param Instance of PAController
        %> @param Handle to the edit text widget
        %> @param Required by MATLAB, but not used
        %> @note Entered values are interepreted as minutes.
        % --------------------------------------------------------------------
        function edit_frameSizeCallback(obj,hObject,eventdata)
            frameDuration = str2double(get(hObject,'string'));
            obj.setFameDuration(frameDuration);
        end        
        
        % --------------------------------------------------------------------
        %> @brief Set the aggregate duration in minutes.
        %> @param Instance of PAController
        %> @param Aggregate duration in minutes.
        %> @retval True if the aggregate duration is changed, and false otherwise.
        % --------------------------------------------------------------------
        function success = setAggregateDuration(obj,new_aggregateDuration)
            success = false;
            if(~isempty(obj.accelObj))                
                cur_aggregateDuration = obj.accelObj.setAggregateDuration(new_aggregateDuration);
                obj.VIEW.setAggregateDuration(num2str(cur_aggregateDuration));
                if(new_aggregateDuration==cur_aggregateDuration)
                    success=true;
                end
            end
        end
        
        % --------------------------------------------------------------------
        %> @brief Set the frame size in minutes.
        %> @param Instance of PAController
        %> @param Aggregate duration in minutes.
        %> @retval True if the frame duration is changed, and false otherwise.
        % --------------------------------------------------------------------
        function success = setFrameDuration(obj,new_frameDuration)
            success = false;
            if(~isempty(obj.accelObj))                
                cur_frameDuration = obj.accelObj.setFrameDuration(new_frameDuration);
                obj.VIEW.setFrameDuration(num2str(cur_frameDuration));
                if(new_frameDuration==cur_frameDuration)
                    success=true;
                end
            end
        end
        
        
        % --------------------------------------------------------------------
        %> @brief Set the current epoch for the instance variable accelObj
        %> (PAData)
        %> @param Instance of PAController
        %> @param Value of the new epoch to set.
        %> @retval True if the epoch is set successfully, and false otherwise.
        %> @note Reason for failure include epoch values that are outside
        %> the range allowed by accelObj (e.g. negative values or those
        %> longer than the duration given.  
        % --------------------------------------------------------------------
        function success = setCurEpoch(obj,new_epoch)
            success= false;
            if(~isempty(obj.accelObj))                
                cur_epoch = obj.accelObj.setCurEpoch(new_epoch);
                obj.VIEW.setCurEpoch(num2str(cur_epoch));
                if(new_epoch==cur_epoch)
                    success=true;
                end
            end
        end
        
        % --------------------------------------------------------------------
        %> @brief Returns the current epoch of the instance variable accelObj
        %> (PAData)
        %> @param Instance of PAController
        %> @retval The  current epoch, or null if it has not been initialized.
        function epoch = curEpoch(obj)
            if(isempty(obj.accelObj))
                epoch = [];
            else
                epoch = obj.accelObj.getCurEpoch;
            end
        end
        
        % --------------------------------------------------------------------
        %> @brief Menubar callback for opening a file.
        %> @param Instance of PAController
        %> @param hObject    handle to menu_file_open (see GCBO)
        % --------------------------------------------------------------------
        function menuFileOpenCallback(obj,hObject,eventdata)
            f=uigetfullfile({'*.csv;*.raw','All (Count or raw)';'*.csv','Comma Separated Values';'*.raw','Raw Format (comma separated values)'},'Select a file','off',fullfile(obj.SETTINGS.DATA.lastPathname,obj.SETTINGS.DATA.lastFilename));
            
            if(~isempty(f))
                obj.VIEW.showBusy('Loading');
                obj.accelObj = PAData(f);
                
                %initialize the PAData object's visual properties
                obj.initView();
            end
        end
        
        % --------------------------------------------------------------------
        %> @brief Menubar callback for quitting the program.
        %> Executes when user attempts to close padaco fig.
        %> @param Instance of PAController
        %> @param hObject    handle to menu_file_quit (see GCBO)
        %> @param eventdata  reserved - to be defined in a future version of MATLAB
        %> @param handles    structure with handles and user data (see GUIDATA)
        % --------------------------------------------------------------------
        function menuFileQuitCallback(obj,hObject,eventdata,handles)
            obj.figureCloseCallback(gcbf,eventdata,handles);
        end
        

    end
    
    methods(Access=private)
        % --------------------------------------------------------------------
        %> @brief Initializes the display using instantiated instance
        %> variables VIEW (PAView) and accelObj (PAData)
        %> @param Instance of PAController
        % --------------------------------------------------------------------
        function initView(obj)
            %keep record of our settings
            obj.SETTINGS.DATA.lastPathname = obj.accelObj.pathname;
            obj.SETTINGS.DATA.lastFilename = obj.accelObj.filename;
            
            obj.VIEW.showReady();
            
            obj.VIEW.initWithAccelData(obj.accelObj);
            
            obj.setCurEpoch(1);
            obj.setFrameDuration(15);
            obj.setAggregateDuration(3);
        end
    end
    
end

