function fig = plateauAnalysis()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% This problem is solved by saving the output as a FIG-file.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.
% 
% NOTE: certain newer features in MATLAB may not have been saved in this
% M-file due to limitations of this format, which has been superseded by
% FIG-files.  Figures which have been annotated using the plot editor tools
% are incompatible with the M-file/MAT-file format, and should be saved as
% FIG-files.

load plateauAnalysis

h0 = figure('Color',[0.8 0.8 0.8], ...
	'Colormap',mat0, ...
	'FileName','D:\plateau\plateauAnalysis.m', ...
	'MenuBar','none', ...
	'Name','Plateau Analysis', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperType','a4letter', ...
	'PaperUnits','points', ...
	'Position',[164 58 156 632], ...
	'Resize','off', ...
	'Tag','PlateauControlBox', ...
	'ToolBar','none');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[10.5 426 99 40.5], ...
	'Style','frame', ...
	'Tag','Frame2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontAngle','italic', ...
	'FontName','Helvetica', ...
	'FontSize',14, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[11.25 446.25 95.25 14.25], ...
	'String','Held Variable', ...
	'Style','text', ...
	'Tag','StaticText4');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[13.5 429.75 90 15], ...
	'String',' ', ...
	'Style','popupmenu', ...
	'Tag','ChooseHoldVar', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[9 321.75 101.25 100.5], ...
	'Style','frame', ...
	'Tag','Frame3');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[68.25 364.5 22.5 10.5], ...
	'String','Max', ...
	'Style','text', ...
	'Tag','StaticText8');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[38.25 366.75 18 9], ...
	'String','Min', ...
	'Style','text', ...
	'Tag','StaticText7');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[23.25 330.75 9 12], ...
	'String','Y', ...
	'Style','text', ...
	'Tag','StaticText6');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[23.25 349.5 9.75 11.25], ...
	'String','X', ...
	'Style','text', ...
	'Tag','StaticText5');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Enable','off', ...
	'ListboxTop',0, ...
	'Position',[67.5 329.25 27 15], ...
	'Style','edit', ...
	'Tag','MaxYAxis');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Enable','off', ...
	'ListboxTop',0, ...
	'Position',[35.25 329.25 27 15], ...
	'Style','edit', ...
	'Tag','MinYAxis');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Enable','off', ...
	'ListboxTop',0, ...
	'Position',[67.5 348.75 27 15], ...
	'Style','edit', ...
	'Tag','MaxXAxis');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Enable','off', ...
	'ListboxTop',0, ...
	'Position',[35.25 348.75 27 15], ...
	'Style','edit', ...
	'Tag','MinXAxis');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback',mat1, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[16.5 374.25 79.5 15.75], ...
	'String','Manual', ...
	'Style','radiobutton', ...
	'Tag','SelectManAxis');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback',mat2, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[16.5 391.5 81.75 14.25], ...
	'String','Automatic', ...
	'Style','radiobutton', ...
	'Tag','SelectAutoAxis');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontAngle','italic', ...
	'FontName','Helvetica', ...
	'FontSize',14, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[19.5 405 78.75 15.75], ...
	'String','Axis Scale', ...
	'Style','text', ...
	'Tag','StaticText9');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[9 8.25 102 254.25], ...
	'Style','frame', ...
	'Tag','Frame4');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[9.75 270 99 46.5], ...
	'Style','frame', ...
	'Tag','Frame5');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontAngle','italic', ...
	'FontName','Helvetica', ...
	'FontSize',14, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[20.25 299.25 73.5 14.25], ...
	'String','Noise', ...
	'Style','text', ...
	'Tag','StaticText14');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Enable','off', ...
	'ListboxTop',0, ...
	'Position',[62.25 273 34.5 15.75], ...
	'Style','edit', ...
	'Tag','UserNoiseValue');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback',mat3, ...
	'ListboxTop',0, ...
	'Position',[16.5 276 36 9.75], ...
	'String','Other', ...
	'Style','radiobutton', ...
	'Tag','ChooseUserNoise');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback',mat4, ...
	'ListboxTop',0, ...
	'Position',[17.25 288 34.5 10.5], ...
	'String','Zero', ...
	'Style','radiobutton', ...
	'Tag','ChooseZeroNoise');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[14.25 44.25 89.25 15.75], ...
	'String','Find/Update Plateau', ...
	'Style','checkbox', ...
	'Tag','FindPlateau');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[15 67.5 37.5 20.25], ...
	'String','% of Max', ...
	'Style','text', ...
	'Tag','StaticText15');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[0 1 0], ...
	'ListboxTop',0, ...
	'Position',[58.5 71.25 44.25 14.25], ...
	'Style','edit', ...
	'Tag','Plateau%Box');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[16.5 91.5 39.75 20.25], ...
	'String','Plateau Level', ...
	'Style','text', ...
	'Tag','StaticText3');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[44.25 165 13.5 10.5], ...
	'String','at', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[0 1 0], ...
	'ListboxTop',0, ...
	'Position',[58.5 96 44.25 14.25], ...
	'Style','edit', ...
	'Tag','PlateauBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[15.75 18.75 44.25 15.75], ...
	'String',' ', ...
	'Style','popupmenu', ...
	'Tag','PlotFileTypeMenu', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[60.75 18 39.75 16.5], ...
	'String','Save Plot', ...
	'Tag','SavePlotButton');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontAngle','italic', ...
	'FontName','Helvetica', ...
	'FontSize',14, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[12 243.75 94.5 16.5], ...
	'String','Tuning Curves', ...
	'Style','text', ...
	'Tag','StaticText13');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[19.5 228 81.75 12], ...
	'String','Start/Reset', ...
	'Tag','StartRefresh');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[66 212.25 10.5 12], ...
	'String','=', ...
	'Style','text', ...
	'Tag','StaticText10');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[16.5 198.75 89.25 12], ...
	'Style','slider', ...
	'Tag','ChooseHeldVarValue');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[15 189 36.75 9.75], ...
	'String','Previous', ...
	'Style','text', ...
	'Tag','StaticText11');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[78 188.25 24.75 9.75], ...
	'String','Next', ...
	'Style','text', ...
	'Tag','StaticText11');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[0 1 0], ...
	'ListboxTop',0, ...
	'Position',[58.5 161.25 45 14.25], ...
	'Style','edit', ...
	'Tag','OptimumBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[11.25 156.75 40.5 10.5], ...
	'String','Optimum', ...
	'Style','text', ...
	'Tag','StaticText12');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[44.25 143.25 13.5 13.5], ...
	'String','is', ...
	'Style','text', ...
	'Tag','StaticText12');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[0.501960784313725 1 0], ...
	'ListboxTop',0, ...
	'Position',[58.5 143.25 45 14.25], ...
	'Style','edit', ...
	'Tag','OptimumHeightBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[14.25 126 93 12.75], ...
	'String','Find/Update Optimum', ...
	'Style','checkbox', ...
	'Tag','FindOptimum');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[0.501960784313725 1 0], ...
	'ListboxTop',0, ...
	'Position',[17.25 211.5 48.75 12], ...
	'Style','edit', ...
	'Tag','HeldVarName');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[0.501960784313725 1 0], ...
	'ListboxTop',0, ...
	'Position',[77.25 211.5 25.5 12.75], ...
	'Style','edit', ...
	'Tag','HeldVarValue');
if nargout > 0, fig = h0; end
