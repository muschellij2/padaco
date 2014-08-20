%> @file PAView.m
%> @brief PAView serves as Padaco's controller component (i.e. in the model, view, controller paradigm).
% ======================================================================
%> @brief PAView serves as the UI component of event marking in
%> the Padaco.  
%
%> In the model, view, controller paradigm, this is the
%> controller. 

classdef PAView < handle
    
    properties
        %> for the patch handles when editing and dragging
        hg_group; 

        %>linehandle in Padaco currently selected;
        current_linehandle;
        
        %>cell of string choices for the marking state (off, 'marking','general')
        state_choices_cell; 
        %>string of the current selected choice
        marking_state; 
        %> figure handle that the class instance is associated with
        figurehandle;
        
        %> @brief struct whose fields are axes handles.  Fields include:
        %> - @b.primary handle to the main axes an instance of this class is associated with
        %> - @b.secondary Epoch view of events (over view)
        axeshandle;

        %> @brief struct whose fields are structs with names of the axes and whose fields are property values for those axes.  Fields include:
        %> - @b.primary handle to the main axes an instance of this class is associated with
        %> - @b.secondary Epoch view of events (over view)
        axesproperty;
        
        %> @brief struct of text handles.  Fields are: 
        %> - .status; %handle to the text status location of the Padaco figure where updates can go
        %> - .src_filename; %handle to the text box for display of loaded filename
        %> - .edit_epoch;  %handle to the editable epoch handle        
        texthandle; 
        
        %> @brief struct of menu handles.  Fields are: 
        %> - .menu_windowDurSec The window display duration in seconds
        %> - .menu_prefilter The selection of prefilter methods
        %> - .menu_extractor The selection of feature extraction methods
        menuhandle;
        %> @brief Struct of line handles (graphic handle class) for showing
        %> activity data.
        linehandle;
        
        %> @brief struct of line handles with matching fieldnames of
        %> instance variable linehandle which are used to draw a dotted reference
        %> line corresponding to zero.
        referencelinehandle;
        %> @brief Struct of text handles (graphic handle class) that display the 
        %> the name or label of the line held at the corresponding position
        %> of linehandle.        
        labelhandle;
        
        %> @brief Graphic handle of the vertical bar which provides a
        %> visual reference of where the epoch is comparison to the entire
        %> study.
        positionBarHandle;
        
        %> struct of handles for the context menus
        contextmenuhandle; 
         
        %> PAData instance
        dataObj;
        epoch_resolution;%struct of different time resolutions, field names correspond to the units of time represented in the field        
        %> The epoch currently in view.
        current_epoch;
        display_samples; %vector of the samples to be displayed
        shift_display_samples_delta; %number of samples to adjust display by for moving forward or back
        startDateTime;
    end
    

    methods
        
        % --------------------------------------------------------------------
        %> PAView class constructor.
        %> @param Figure handle to assign PAView instance to.
        %> @retval Instance of PAView
        % --------------------------------------------------------------------
        function obj = PAView(Padaco_fig_h)
            if(ishandle(Padaco_fig_h))
                obj.figurehandle = Padaco_fig_h;
                obj.createView();                
            else
                obj = [];
            end
        end 
        
                
        % --------------------------------------------------------------------
        %> @brief Creates line handles and maps figure tags to PAView instance variables.
        %> @param Instance of PAView.
        % --------------------------------------------------------------------
        function createView(obj)
            handles = guidata(obj.getFigHandle());
            
            set(handles.panel_left,'backgroundcolor',[0.75,0.75,0.75]);
            set(handles.panel_study,'backgroundcolor',[0.95,0.95,0.95]);
            
            whiteHandles = [handles.text_aggregate
                handles.text_frameSize
                handles.panel_features_prefilter
                handles.panel_features_aggregate
                handles.panel_features_frame
                handles.panel_features_extractor];
            set(whiteHandles,'backgroundcolor',[0.95,0.95,0.95]);
            
            obj.texthandle.status = handles.text_status;
            obj.texthandle.filename = handles.text_filename;
            obj.texthandle.studyinfo = handles.text_studyinfo;
            obj.texthandle.curEpoch = handles.edit_curEpoch;
            obj.texthandle.aggregateDuration = handles.edit_aggregate;
            obj.texthandle.frameDuration = handles.edit_frameSize;
            
            obj.menuhandle.extractorMethod = handles.menu_extractor;
            obj.menuhandle.prefilterMethod = handles.menu_prefilter;
            
            obj.axeshandle.primary = handles.axes_primary;
            obj.axeshandle.secondary = handles.axes_secondary;

            % Clear the figure and such.
            obj.clearAxesHandles();
            obj.clearTextHandles(); 
            obj.clearWidgets();
            
            %creates and initializes line handles (obj.linehandle fields)
            % However, all lines are invisible.
            obj.createLineAndLabelHandles();
            
        end
        
        % --------------------------------------------------------------------
        %> @brief Sets current epoch edit box string value
        %> @param Instance of PAView.
        %> @param A string.
        % --------------------------------------------------------------------
        function setCurEpoch(obj,epochStr)
           set(obj.texthandle.curEpoch,'string',epochStr); 
           epochNum = str2double(epochStr);
           set(obj.positionBarHandle,'xdata',repmat(epochNum,1,2));
           obj.draw();
        end
        
        
        
        % --------------------------------------------------------------------
        %> @brief Sets aggregate duration edit box string value
        %> @param Instance of PAView.
        %> @param A string representing the aggregate duration as minutes.
        % --------------------------------------------------------------------
        function setAggregateDuration(obj,aggregateDurationStr)
           set(obj.texthandle.aggregateDuration,'string',aggregateDurationStr);            
        end
        
        % --------------------------------------------------------------------
        %> @brief Sets aggregate duration edit box string value
        %> @param Instance of PAView.
        %> @param A string representing the frame duration as minutes.
        % --------------------------------------------------------------------
        function setFrameDuration(obj,frameDurationStr)
           set(obj.texthandle.frameDuration,'string',frameDurationStr);            
        end
        
        
        
        % --------------------------------------------------------------------
        % --------------------------------------------------------------------
        %
        %   Initializations
        %
        % --------------------------------------------------------------------
        % --------------------------------------------------------------------
        
       
        % --------------------------------------------------------------------
        % --------------------------------------------------------------------
        function clearFigure(obj)
            
            %clear the figure handle
            set(0,'showhiddenhandles','on');
            
            cf = get(0,'children');
            for k=1:numel(cf)
                if(cf(k)==obj.getFigHandle())
                    set(0,'currentfigure',cf(k));
                else
                    delete(cf(k)); %removes other children aside from this one
                end
            end;
            
            set(0,'showhiddenhandles','off');
        end
        
        % --------------------------------------------------------------------
        %> @brief Initialize text handles that will be used in the view.
        %> resets the currentEpoch to 1.
        %> @param obj Instance of PAView
        % --------------------------------------------------------------------
        function clearTextHandles(obj)
            textProps.visible = 'on';
            textProps.string = '';
            obj.recurseHandleInit(obj.texthandle,textProps);
        end
        
        % --------------------------------------------------------------------
        %> @brief Clears axes handles of any children and sets default properties.
        %> Called when first creating a view.  See also initAxesHandles.
        %> @param obj Instance of PAView
        % --------------------------------------------------------------------
        function clearAxesHandles(obj)
            
            cla(obj.axeshandle.primary);
            cla(obj.axeshandle.secondary);
            
            axesProps.units = 'normalized'; %normalized allows it to resize automatically
            axesProps.drawmode = 'normal'; %fast does not allow alpha blending...
            axesProps.xgrid='on';
            axesProps.ygrid='off';
            axesProps.xminortick='on';
            axesProps.xlimmode='manual';
            axesProps.xtickmode='manual';
            axesProps.xticklabelmode='manual';
            axesProps.xtick=[];
            axesProps.ytickmode='manual';
            axesProps.ytick=[];
            axesProps.nextplot='replacechildren';
            axesProps.box= 'on';
            axesProps.plotboxaspectratiomode='auto';
            
            %initialize axes
            set(obj.axeshandle.primary,axesProps);
            
            axesProps.xgrid = 'off';
            axesProps.xminortick = 'off';
            
            set(obj.axeshandle.secondary,axesProps);             
        end
        
        % --------------------------------------------------------------------
        %> @brief Disable user interface widgets and clear contents.
        %> @param obj Instance of PAView
        % --------------------------------------------------------------------
        function clearWidgets(obj)            
            handles = guidata(obj.getFigHandle());            
            obj.initWidgets();
            widgetList = [handles.edit_curEpoch
                handles.menu_windowDurSec
                handles.menu_prefilter
                handles.edit_aggregate
                handles.edit_frameSize
                handles.text_aggregate
                handles.text_frameSize
                handles.menu_extractor
                handles.button_go];  
            set(widgetList,'enable','off'); 
            
        end
        
        % --------------------------------------------------------------------
        %> @brief Set the acceleration data instance variable and assigns
        %> line handle y values to those found with corresponding field
        %> names in PADataObject.
        %> resets the currentEpoch to 1.
        %> @param obj Instance of PAView
        %> @param PADataObject Instance of PAData
        % --------------------------------------------------------------------
        function obj = initWithAccelData(obj, PADataObject)
            obj.dataObj = PADataObject;          
            axesProps.primary.xlim = obj.dataObj.getCurEpochRangeAsSamples();
            axesProps.primary.ylim = obj.dataObj.getDisplayMinMax();
            
            axesProps.secondary.xlim = [1 obj.dataObj.getEpochCount()];
            axesProps.secondary.ylim = [0 1];
            
            labelProps = obj.dataObj.getLabel();
            labelPosStruct = obj.getLabelhandlePosition();            
            labelProps = PAData.mergeStruct(labelProps,labelPosStruct);
            
            visibleProp.visible = 'on';
            labelProps = PAData.appendStruct(labelProps,visibleProp);
            
            obj.initView(axesProps,obj.dataObj.getStruct('dummydisplay'),labelProps);
            
            obj.setLinehandleColor(PADataObject.getColor());
            obj.setFilename(obj.dataObj.getFilename());  
            
            obj.setStudyPanelContents(PADataObject.getHeaderAsString);
        end        
        
        % --------------------------------------------------------------------
        %> @brief Initializes the graphic handles and maps figure tag names
        %> to PAView instance variables.
        %> @param obj Instance of PAView
        %> @param (Optional) PAData display struct that matches the linehandle struct of
        %> obj and whose values will be assigned to the 'ydata','xdata', and 'color' fields of the
        %> line handles.  
        %> @param (Optional) PAData label struct containing string labels and whose fields match
        %> the linehandle struct of obj.  A label property struct will be created
        %> using the string values of labelStruct and the initial x, y value of the line
        %> props to initialize the 'string' and 'position' properties of 
        %> obj's corresponding label handles.          
        % --------------------------------------------------------------------
        function initView(obj,axesProps,lineProps,labelProps)
            if(nargin<4 || isempty(labelProps))
                labelProps = [];
            end
            
            if(nargin<3 || isempty(lineProps))
                lineProps = PAData.getDummyDisplayStruct();
            end
            
            if(nargin>1 && ~isempty(axesProps))
                obj.initAxesHandles(axesProps);
            end
            
            if(~isempty(lineProps))
                obj.initLineHandles(lineProps);
            end
            
            if(~isempty(labelProps))                
                obj.initLabelHandles(labelProps);
            end
            
            obj.initMenubar();
            obj.initWidgets();
            
            obj.restore_state();
        end       
        
        % --------------------------------------------------------------------
        %> @brief Initialize data specific properties of the axes handles.
        %> Set the x and y limits of the axes based on limits found in
        %> dataStruct struct.
        %> @param obj Instance of PAView
        %> @param Structure of axes property structures.  First fields
        %> are:
        %> - primary (for the primary axes);
        %> - secondary (for the secondary axes, lower, timeline axes)
        % --------------------------------------------------------------------
        function initAxesHandles(obj,axesProps)
            axesNames = fieldnames(axesProps);
            for a=1:numel(axesNames)
                axesName = axesNames{a};
                set(obj.axeshandle.(axesName),axesProps.(axesName));
            end
            %             set(obj.axeshandle.primary,axesProps.primary);
            %             set(obj.axeshandle.secondary,axesProps.secondary);
        end

        % --------------------------------------------------------------------
        %> @brief Configures the figure's menubar
        %> @param obj Instance of PAView
        % --------------------------------------------------------------------
        function initMenubar(obj)

            %turn on the appropriate menu items still for initial use
            %before any files are loaded
            handles = guidata(obj.getFigHandle());
            
            set(handles.menu_file,'enable','on');
            set(handles.menu_file_open,'enable','on');
            set(handles.menu_file_quit,'enable','on');
            
            set(handles.menu_settings,'enable','on');
            
            obj.restore_state();
        end

        % --------------------------------------------------------------------
        %> @brief Initialize user interface widgets on start up.
        %> @param obj Instance of PAView        
        % --------------------------------------------------------------------
        function initWidgets(obj)
            handles = guidata(obj.getFigHandle());
            
            widgetList = [handles.menu_windowDurSec
                handles.edit_curEpoch
                handles.menu_windowDurSec
                handles.menu_prefilter
                handles.edit_aggregate
                handles.edit_frameSize
                handles.text_aggregate
                handles.text_frameSize
                handles.menu_extractor
                handles.button_go];                
            
            set(handles.edit_aggregate,'string','1');
            set(handles.edit_frameSize,'string','4');
            set(handles.edit_curEpoch,'string','0');
            
            prefilterSelection = PAData.getPrefilterMethods();
            set(handles.menu_prefilter,'string',prefilterSelection,'value',1);
            
            % feature extractor
            extractorMethods = PAData.getExtractorMethods();
            set(handles.menu_extractor,'string',extractorMethods,'value',1);
            
            % Window display resolution
            windowMinSelection = {30,'30 s';
                60,'1 min';
                120,'2 min';
                300,'5 min';
                600,'10 min';
                900,'15 min';
                1800,'30 min';
                3600,'1 hour';
                7200,'2 hours';
                14400,'4 hours';
                28800,'8 hours';
                43200,'12 hours';
                57600,'16 hours';
                86400,'24 hours'};
            
            set(handles.menu_windowDurSec,'userdata',cell2mat(windowMinSelection(:,1)), 'string',windowMinSelection(:,2),'value',1);
            set(widgetList,'enable','on','visible','on');
        end
        
        
        % --------------------------------------------------------------------
        %> @brief Updates the secondary axes x and y axes limits.
        %> @param obj Instance of PAView
        %> @param The total number of windows that can be displayed in the
        %> primary axes.  This will be xlim(2) for the secondary axes (i.e.
        %> timeline/overview axes).
        % --------------------------------------------------------------------
        function updateSecondaryAxes(obj,epochCount)
            axesProps.secondary.xlim = [1 epochCount];
            axesProps.secondary.ylim = [0 1];
            obj.initAxesHandles(axesProps);
        end
        
        % --------------------------------------------------------------------
        %> @brief Create the line handles and text handles that describe the lines,
        %> that will be displayed by the view.
        %> This is based on the structure template generated by member
        %> function getStruct('dummydisplay').
        %> @param obj Instance of PAView
        % --------------------------------------------------------------------
        function createLineAndLabelHandles(obj)
            handleProps.Parent = obj.axeshandle.primary;

            handleProps.visible = 'off';
            dataStruct = PAData.getDummyStruct();
            
            handleType = 'line';
            obj.linehandle = obj.recurseHandleGenerator(dataStruct,handleType,handleProps);
            
            obj.referencelinehandle = obj.recurseHandleGenerator(dataStruct,handleType,handleProps);
            
            handleType = 'text';
            obj.labelhandle = obj.recurseHandleGenerator(dataStruct,handleType,handleProps);
            
            obj.positionBarHandle = line('parent',obj.axeshandle.secondary,'visible','off');%annotation(obj.figurehandle.sev,'line',[1, 1], [pos(2) pos(2)+pos(4)],'hittest','off');
        end
        
        % --------------------------------------------------------------------
        %> @brief Initialize the line handles that will be used in the view.
        %> Also turns on the vertical positioning line seen in the
        %> secondary axes.
        %> @param Instance of PAView.
        %> @param Structure of line properties corresponding to the
        %> fields of the linehandle instance variable.
        %> If empty ([]) then default PAData.getDummyDisplayStruct is used.
        % --------------------------------------------------------------------
        function initLineHandles(obj,lineProps)
            
            if(nargin<2 || isempty(lineProps))
                lineProps = PAData.getDummyDisplayStruct();
            end
            
            obj.recurseHandleSetter(obj.linehandle, lineProps);
            obj.recurseHandleSetter(obj.referencelinehandle, lineProps);
            
            set(obj.positionBarHandle,'visible','on','ydata',[0 1]);            
        end
        
        % --------------------------------------------------------------------
        %> @brief Initialize the label handles that will be used in the view.
        %> Also turns on the vertical positioning line seen in the
        %> secondary axes.
        %> @param Instance of PAView.
        %> @param Structure of label properties corresponding to the
        %> fields of the labelhandle instance variable.
        % --------------------------------------------------------------------
        function initLabelHandles(obj,labelProps)
            obj.recurseHandleSetter(obj.labelhandle, labelProps);
        end
        
        % --------------------------------------------------------------------
        %> @brief Displays the string argument in the view.
        %> @param PADataObject Instance of PAData
        %> @param String that will be displayed in the view as the source filename when provided.
        % --------------------------------------------------------------------
        function setFilename(obj,sourceFilename)
            set(obj.texthandle.filename,'string',sourceFilename,'visible','on');
        end
        
        % --------------------------------------------------------------------
        %> @brief Displays the contents of cellString in the study panel
        %> @param PADataObject Instance of PAData
        %> @param Cell of string that will be displayed in the study panel.  Each 
        %> cell element is given its own display line.
        % --------------------------------------------------------------------
        function setStudyPanelContents(obj,cellString)
            set(obj.texthandle.studyinfo,'string',cellString,'visible','on');
        end
        
        % --------------------------------------------------------------------
        %> @brief Draws the view
        %> @param PADataObject Instance of PAData
        % --------------------------------------------------------------------
        function draw(obj)
            axesRange   = obj.dataObj.getCurEpochRangeAsUncorrectedSamples();
            
            offsetProps = obj.dataObj.getStruct('displayoffset');
            style.LineStyle = '--';
            %style.LineWidth = 0.1;
            style.color = [0.6 0.6 0.6];
            
            offsetProps = PAData.appendStruct(offsetProps,style);

            
            lineProps   = obj.dataObj.getStruct('currentdisplay');
            set(obj.axeshandle.primary,'xlim',axesRange);  

            % draw the reference lines first so that the regular lines
            % appear on top (or set a z-value, but this is easier for now
            obj.recurseHandleSetter(obj.referencelinehandle,offsetProps);

            obj.recurseHandleSetter(obj.linehandle,lineProps);
            
            
            % update label text positions based on the axes position...
            % link the x position with the axis x-position ...            
            obj.initLabelHandles(obj.getLabelhandlePosition());
        end

        % --------------------------------------------------------------------
        %> @brief Sets the color of the line handles.
        %> @param Instance of PAView
        %> @param Struct with field organization corresponding to that of
        %> instance variable linehandle.  The values are the colors to set
        %> the matching line handle to.
        % --------------------------------------------------------------------
        function setLinehandleColor(obj,colorStruct)
            obj.setStructWithStruct(obj.linehandle,colorStruct);
        end
        
        % --------------------------------------------------------------------
        %> @brief Calculates the 'position' property of the labelhandle
        %> instance variable.
        %> @param Instance of PAView.        
        %> @retval A struct of 'position' properties that can be assigned
        %> to labelhandle instance variable.
        % --------------------------------------------------------------------
        function labelPosStruct = getLabelhandlePosition(obj)    
            labelPosStruct = PAData.structEval('calculateposition',obj.dataObj.offset,obj.dataObj.getStruct('displayoffset'));
            xOffset = 1/120*diff(get(obj.axeshandle.primary,'xlim'));            
            offset = [xOffset, 15, 0];
            labelPosStruct = PAData.structScalarEval('plus',labelPosStruct,offset);            
        end

        % --------------------------------------------------------------------
        %> @brief Get the view's figure handle.
        %> @param obj Instance of PAView
        %> @retval figHandle View's figure handle.
        % --------------------------------------------------------------------
        function figHandle = getFigHandle(obj)
            figHandle = obj.figurehandle;
        end
        
        % --------------------------------------------------------------------
        %> @brief Get the view's line handles as a struct.
        %> @param obj Instance of PAView
        %> @retval View's line handles as a struct.
        % --------------------------------------------------------------------
        function lineHandle = getLinehandle(obj)
            lineHandle = obj.linehandle;
        end
        
        
        function showBusy(obj,status_label)
            set(obj.getFigHandle(),'pointer','watch');
            if(nargin>1)
                set(obj.texthandle.status,'string',status_label);
            end
            drawnow();
        end  
        
        function showReady(obj)
            set(obj.getFigHandle(),'pointer','arrow');
            set(obj.texthandle.status,'string','');
            drawnow();
        end
        
     
        %VIEW parts of the class....        
        function obj = restore_state(obj)
            obj.clear_handles();
            
            set(obj.getFigHandle(),'pointer','arrow');
            obj.marking_state = 'off';
        end
        
        function obj = clear_handles(obj)
            obj.showReady();
        end

        
    end
    methods(Static)
        
        %==================================================================
        %> @brief Recursively fills in the template structure dummyStruct
        %> with matlab lines and returns as a new struct.  If dummyStruct
        %> has numeric values in its deepest nodes, then these values are
        %> assigned as the y-values of the corresponding line handle, and the
        %> x-value is a vector from 1 to the number of elements in y.
        %> @param obj Instance of PAView
        %> @param dummyStruct Structure with arbitrarily deep number fields.
        %> @param String name of the type of handle to be created:
        %> - @c line
        %> - @c text
        %> @param Struct of line handle properties to initialize line handles with.  
        %> @retval destStruct The filled in struct, with the same field
        %> layout as dummyStruct but with line handles filled in at the
        %> deepest nodes.
        %> @note If destStruct is included, then lineproperties must also be included, even if only as an empty place holder.
        %> For example as <br>
        %> destStruct = PAView.recurseHandleGenerator(dummyStruct,handleType,[],destStruct)
        %> @param destStruct The initial struct to grow to (optional and can be different than the output node).
        %> For example<br> desStruct = PAView.recurseLineGenerator(dummyStruct,'line',proplines,diffStruct)
        %> <br>Or<br> recurseHandleGenerator(dummyStruct,'line',[],diffStruct)
        %==================================================================
        function destStruct = recurseHandleGenerator(dummyStruct,handleType,handleProperties,destStruct)
            if(nargin < 4 || isempty(destStruct))
                destStruct = struct();
                if(nargin<3)
                    handleProperties = [];
                end
            
            end
            
            fnames = fieldnames(dummyStruct);
            for f=1:numel(fnames)
                fname = fnames{f};

                if(isstruct(dummyStruct.(fname)))
                    destStruct.(fname) = [];
                    
                    %recurse down
                    destStruct.(fname) = PAView.recurseHandleGenerator(dummyStruct.(fname),handleType,handleProperties,destStruct.(fname));
                else
                    if(strcmpi(handleType,'line'))
                        destStruct.(fname) = line();
                    elseif(strcmpi(handleType,'text'))
                        destStruct.(fname) = text();
                    else
                        destStruct.(fname) = [];
                        fprintf('Warning!  Handle type %s unknown!',handleType);
                    end
                    if(nargin>1 && ~isempty(handleProperties))
                        set(destStruct.(fname),handleProperties);
                    end                    
                end
            end
        end

        %==================================================================
        %> @brief Recursively sets struct of graphic handles with a matching struct
        %> of handle properties.
        %> @param handleStruct The struct of matlab graphic handles.  This
        %> is searched recursively until a handle is found (i.e. ishandle())
        %> @param Structure of property/value pairings to set the graphic
        %> handles found in handleStruct to.
        %==================================================================
        function recurseHandleSetter(handleStruct, propertyStruct)
            fnames = fieldnames(handleStruct);
            for f=1:numel(fnames)
                fname = fnames{f};
                curField = handleStruct.(fname);
                try
                if(isstruct(curField))
                    PAView.recurseHandleSetter(curField,propertyStruct.(fname));
                else
                    if(ishandle(curField))                        
                       set(curField,propertyStruct.(fname));
                    end
                end
                catch me
                    showME(me);
                end
            end
        end
        
        %==================================================================
        %> @brief Recursively initializes the graphic handles found in the
        %> provided structure with the properties found at corresponding locations
        %> in the propStruct argument.
        %> @param handleStruct The struct of line handles to set the
        %> properties of.  
        %> @param Structure of property structs (i.e. property/value pairings) to set the graphic
        %> handles found in handleStruct to.
        %==================================================================
        function setStructWithStruct(handleStruct,propertyStruct)
            fnames = fieldnames(handleStruct);
            for f=1:numel(fnames)
                fname = fnames{f};
                curHandleField = handleStruct.(fname);
                curPropertyField = propertyStruct.(fname);
                if(isstruct(curHandleField))
                    PAView.setStructWithStruct(curHandleField,curPropertyField);
                else
                    if(ishandle(curHandleField))
                        set(curHandleField,curPropertyField);
                    end
                end
            end
        end
        
        
        %==================================================================
        %> @brief Recursively initializes the graphic handles found in the
        %> provided structure with the handle properties provided.
        %> @param handleStruct The struct of line handles to set the
        %> properties of.  
        %> @param Structure of property/value pairings to set the graphic
        %> handles found in handleStruct to.
        %==================================================================
        function recurseHandleInit(handleStruct,properties)
            fnames = fieldnames(handleStruct);
            for f=1:numel(fnames)
                fname = fnames{f};
                curField = handleStruct.(fname);
                if(isstruct(curField))
                    PAView.recurseHandleInit(curField,properties);
                else
                    if(ishandle(curField))
                        set(curField,properties);
                    end
                end
            end
        end
        
        % --------------------------------------------------------------------
        function popout_axes(~, ~, axes_h)
            % hObject    handle to context_menu_pop_out (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            fig = figure;
            copyobj(axes_h,fig); %or get parent of hObject's parent
        end
    end
end

