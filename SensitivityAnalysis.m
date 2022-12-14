%%% ======================================================================
%   Purpose: 
%   This function initializes a sensitivity analysis ....
%%% ======================================================================

function [zToUse, r, zBD, T0, ...
         Iterations, ...
         T, ...
         Rz, ...
         SigmaHF, ...
         qMin, ...
         qMax, ...
         ErrResultsSummary ...
         ] = SensitivityAnalysis(NumberOfSensors, ...
            kToUse, ...
            ~,...
            MaxSAIterations, ...
            Sigmak0, ...
            kMin, ...
            kMax, ...
            MinThickness, ...
            kAnisotropy, ...
            SensorsToUse, ...
            IgnoredSensors, ...
            ~, ...
            ~, ...
            Badk, ...
            ShiftedCTR, ...
            ~, ...
            ShiftedRelativeDepths, ...
            Slope, ...
            k0, ...
            MinimumFricEqTemp, ...
            h_axTempAboveBWT, ...
            SensorsUsedForBullardFit, ...
            HeatFlow, ...
            axes_SA_SDvIter, ...
            axes_SA_TCvDepth, ...
            axes_SA_TempvCTR, ...
            label_heatflowrange, ...
            label_meanheatflow, ...
            label_currentheatflow, ...
            label_initheatflow, ...
            label_standev, ...
            label_currentiteration, ...
            label_meandev, ...
            label_minthickness, ...
            label_thermconbounds, ...
            label_ThermConBoundsTitle, ...
            PulseData, ...
            loading, ...
            table_ErrorUncertaintySummary, ...
            ErrData, ...
            kDistribution, ...
            r, ...
            UseFrictional, ...
            figure_Main, ...
            FricTime, ...
            FricTemp, ...
            FrictionalDelays, ...
            FricMaxStep, ...
            TimeInc, ...
            HyndmanCoeffs, ...
            SensorRadius, ...
            FricTauMin, ...
            FricTauMax)
     

     qMin = HeatFlow;
     qMax = HeatFlow;

     % unused: Bins = 25;

     % Initialize arrays for iterative process
     % ---------------------------------------
     
     Iterations = NaN*zeros(MaxSAIterations,1);
     T = NaN*zeros(MaxSAIterations,length(SensorsUsedForBullardFit));
     Rz = NaN*zeros(MaxSAIterations,length(SensorsUsedForBullardFit));
     SigmaHF = NaN*zeros(MaxSAIterations,1);
     AllT = NaN*zeros(length(SensorsUsedForBullardFit),MaxSAIterations);
     AllBullardDepths = NaN*zeros(length(SensorsUsedForBullardFit),MaxSAIterations);
     AllHeatFlows = NaN*zeros(MaxSAIterations,1);
     AllHeatFlowsErr = NaN*zeros(MaxSAIterations,1);
     Q = NaN*zeros(MaxSAIterations,1);
     QErr = NaN*zeros(MaxSAIterations,1);

     % Define colors for plots
     % -----------------------
     Colors = cell(size(NumberOfSensors));
     for i = 1:NumberOfSensors
        Colors{i} = h_axTempAboveBWT(i).Color;
     end
    
     % Distribution of thermal conductivity values
     if kDistribution == 1
         DisCond = 'Normal';
         ThermBounds = ['[' num2str(min(min(r(:, SensorsToUse))), 2) ' - ' num2str(max(max(r(:, SensorsToUse))), 2) ']'];
     elseif kDistribution == 2
         DisCond = 'Gamma';
         ThermBounds =  ['[' num2str(min(min(r(:, SensorsToUse))), 2) ' - Infinity]'];
     end

%if ~PulseData

    % Generate Random boundaries given ShiftedRelativeDepths !
    % ---------------------------------------------------------
    
    zToUse = ShiftedRelativeDepths(kToUse);
    
    zLims = [zToUse(1:length(zToUse)-1) - MinThickness/2; ...
            zToUse(2:length(zToUse)) + MinThickness/2];
    
    zBD = repmat(zLims(1,:),MaxSAIterations,1) ...
        + rand(MaxSAIterations,length(zToUse)-1) ...
        .* repmat(diff(zLims),MaxSAIterations,1);

% ============================================
% Generate and Plot Conductivity distribution
% ============================================

% -----------------------------------------------------
% TWO OPTIONS:
%      If there IS NOT in situ thermal conductivity measurements 
%      OR 
%      If user chooses to use a normal or gamma distribution of thermal
%       conductivities, no need to correct for anisotropy because this 
%       uncertainty will be accounted for in the larger distribution of 
%       thermal conductivity values
% --------------------------------------------------------------------
% --------------------------------------------------------------------

if ~PulseData || kDistribution == 1 || kDistribution == 2
    k0 = [k0(kToUse(1)) k0(kToUse)];
    z = [ShiftedRelativeDepths(kToUse(1)) ShiftedRelativeDepths(kToUse(1:end-1)) ...
                + diff(ShiftedRelativeDepths(kToUse))/2 0];

    % unused: InitkLine = stairs(axes_SA_TCvDepth,k0,z,'k');
    hold(axes_SA_TCvDepth, 'on')
    
    for i=SensorsToUse
        plot(axes_SA_TCvDepth, r(:, i), ShiftedRelativeDepths(i), '.',...
            'Color',Colors{i})
        drawnow;
    end
        % OLD
        % =====
        Bins = 25;
        SensorDistance = 0.3;
        VarDist = 0;

        [N,X] = hist(r,Bins);
        Diffk = diff(X);
        X = [X(1)-Diffk(1)/2 X'-Diffk(1)/2 X(end)+Diffk(1)/2 X(end)+Diffk(1)/2];
        
        Diffk = diff(ShiftedRelativeDepths(kToUse));
        MaxN = max(max(N));
       
        % AF 9/02 max height of histograms - for variable spacing
        %
            PlotSpace = min(abs(diff(SensorDistance)));
        
        % AF 9/02 Scale histograms differently for constant or variable spacing
            for i = SensorsToUse
                if VarDist == 1
                   Y = ShiftedRelativeDepths(kToUse(i)) ...
                     - PlotSpace*[0 N(:,i)' N(end,i) 0]/MaxN;
                else
                   Y = ShiftedRelativeDepths(kToUse(i)) ...
                     - SensorDistance*[0 N(:,i)' N(end,i) 0]/MaxN;
                end
        
                Hist = stairs(axes_SA_TCvDepth, X,Y, 'linewidth', 4);
                Hist.Color = h_axTempAboveBWT(i).Color;
            end
        % =======
        % OLD


        kMinLine = line(axes_SA_TCvDepth, [min(min(r(:, SensorsToUse))) min(min(r(:, SensorsToUse)))],[0 max(ShiftedRelativeDepths(kToUse))+0.5], ...
            'color','k', ...
            'linestyle','--');
        kMaxLine = line(axes_SA_TCvDepth, [max(max(r(:, SensorsToUse))) max(max(r(:, SensorsToUse)))],[0 max(ShiftedRelativeDepths(kToUse))+0.5], ...
            'color','k', ...
            'linestyle','--');
    
        set(axes_SA_TCvDepth, ...
            'ydir','reverse', ...
            'box','on', ...
            'xaxislocation','top', ...
            'ylim',[0 max(ShiftedRelativeDepths(kToUse))+0.5])
        
        axes_SA_TCvDepth.XLim = [min(min(r(:, SensorsToUse)))-.05 max(max(r(:, SensorsToUse)))+.05];

        xlabel(axes_SA_TCvDepth, '\bfThermal Conductivity (W m^{-1} ^oC^{-1})', ...
            'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])

        ylabel(axes_SA_TCvDepth, '\bfDepth (m)', ...
            'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])

        %ylabel(axes_SA_TCvDepth, ['\bfRelative Depths (m)  -  Conductivity distributions: '  ...
        %        ' <=>  N = ' int2str(MaxN) ...
        %        ' (' int2str(Bins) ' bins)'], ...
        %    'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])

        for i = SensorsToUse
        % NEW
        % ===
        % unused: h = histfit(r(:,i), Bins);
        % unused: hLine = h(2);
        % unused: newY = hLine.YData/10 + ShiftedRelativeDepths(i);
        %plot(axes_SA_TCvDepth, hLine.XData, newY);
        % ===
        end

     % Update labels that describe sensitivity analysis parameters
     % -----------------------------------------------------------
       label_meandev.Interpreter = 'latex';
       label_minthickness.Interpreter = 'latex';
       label_thermconbounds.Interpreter = 'latex';
   
       label_meandev.Text = num2str(Sigmak0(1));
       label_minthickness.Text = [num2str(MinThickness) 'm'];
       label_thermconbounds.Text = ThermBounds;

% -------------------------------------------------------
% If there IS in situ thermal conductivity measurements
% -------------------------------------------------------
    
    % ---------------------------------------
    % Generate random thermal conductivities. 
    % ---------------------------------------

    % If user chooses to only use the measured in situ thermal 
    % conductivities instead of a normal or gamma distribution, correct for 
    % anisotropy. Measured is assumed to contain higher value that real vertical conductivity
    % due to anisotropy with higher values in the horizontal direction.
    % ---------------------------------------------------------

elseif kDistribution == 3
    
        k_AnChange = k0 - (1-kAnisotropy) * k0;
        k_Anisotropy = NaN(size(k0));
        
        i = 1;
        while i <= MaxSAIterations
        	randomk = k0 - (k_AnChange - k0).*rand(1,1);
        	k_Anisotropy(i, :) = randomk;
          i = i+1;
        end
    
        % Plot Conductivity distribution
        % ------------------------------
        
        	k = [k_Anisotropy(:,kToUse(1)) k_Anisotropy(:,kToUse)]; 
        	z = [zToUse(1)*ones(MaxSAIterations,1) zBD zeros(MaxSAIterations,1)];
            Dis = stairs(axes_SA_TCvDepth, k',z', 'm');
            set(Dis,'color',[0.75 0.75 0.75])
            hold(axes_SA_TCvDepth, 'on') 
        
        i=1;       
            while i<=length(kToUse)
                CurrentSensor = kToUse(i);
                
        		% Plot original k (no anisotropy)
                plot(axes_SA_TCvDepth, k0(CurrentSensor),ShiftedRelativeDepths(CurrentSensor),'o', ...
                    'Color',h_axTempAboveBWT(i).Color,'MarkerSize',10);
                
        
        		% Plot range of thermal conductivities with anisotropy correction
                j=1;
                while j<=MaxSAIterations
                    plot(axes_SA_TCvDepth, k_Anisotropy(j,CurrentSensor),ShiftedRelativeDepths(CurrentSensor),'.', ...
                        'color',h_axTempAboveBWT(i).Color);
                    
                    j=j+1;
                end
                
                i=i+1;
            end
        
        plot(k(intersect(Badk,SensorsUsedForBullardFit)), ...
                ShiftedRelativeDepths(intersect(Badk,SensorsUsedForBullardFit)),'k+','markersize',15);
        drawnow;
        
            set(axes_SA_TCvDepth, ...
                'ydir','reverse', ...
                'box','on', ...
                'xaxislocation','top', ...
                'ylim',[0 max(ShiftedRelativeDepths(kToUse))+0.5], ...
                'xlim',[kMin-0.05*kMin kMax+0.05*kMax]);
            xlabel(axes_SA_TCvDepth, '\bfThermal Conductivity (W m^{-1} ^oC^{-1})', ...
                'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])
        	ylabel(axes_SA_TCvDepth, '\bfRelative Depths (m)', ...
                'fontsize',18, ...
                'verticalalignment','bottom', 'Color',[0.00,0.45,0.74])
        
        % Update labels that describe sensitivity analysis parameters
            % ---- need to make these labels
         % -----------------------------------------------------------
           %unused: label_maxiterations.Interpreter = 'latex';
           label_meandev.Interpreter = 'latex';
           label_minthickness.Interpreter = 'latex';
           label_thermconbounds.Interpreter = 'latex';
        
           %unused: label_maxiterations.Text = num2str(MaxSAIterations);
           label_minthickness.Text = [num2str(MinThickness) ' m'];
    
           label_thermconbounds.Text = [num2str(abs(1-kAnisotropy)*100,'%1.0f') ' %'];
           label_ThermConBoundsTitle.Text = 'Thermal Conductivity Anisotropy:';
        
end

% ===========================
% Plot initial conductivity
% ===========================

 % Plot stairs connecting k points
    x = k0;
    y = ShiftedRelativeDepths(kToUse);
    y = [y(1) y(1:end-1) + diff(y)/2 0];
    h_axTCvDepthStairs = stairs(axes_SA_TCvDepth, x,y,'m-', 'LineWidth',2);

% ===========================
% Plot initial heat flow plot
% ===========================

    T0 = MinimumFricEqTemp;
    idx = isnan(T0);
    ShiftedCTR(idx) = nan;

    for i = SensorsToUse
        plot(axes_SA_TempvCTR, T0(i),ShiftedCTR(i),'o', ...
            'Color',h_axTempAboveBWT(i).Color, ...
            'MarkerFaceColor',h_axTempAboveBWT(i).Color, ...
            'MarkerSize',10)
        
        hold(axes_SA_TempvCTR, 'on');    
    end

    line_initialheatflow = plot(axes_SA_TempvCTR, [0 max(ShiftedCTR)+0.5]/Slope(2), ...
        [0 max(ShiftedCTR)+0.5],'m-','linewidth',2);
    drawnow;
    
    set(axes_SA_TempvCTR, ...
        'ydir','reverse', ...
        'box','on', ...
        'xaxislocation','top', ...
        'ylim',[0 max(ShiftedCTR)+0.5]);
    xlabel(axes_SA_TempvCTR,'\bfTemperature ( ^oC)', ...
        'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])
    ylabel(axes_SA_TempvCTR,'\bfCumulative Thermal Resistance (m^2 ^oC W^{-1})', ...
        'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])

 % Update labels that describe sensitivity analysis parameters
    % ---- need to make these labels
 % -----------------------------------------------------------
   label_heatflowrange.Interpreter = 'latex';
   label_initheatflow.Interpreter = 'latex';help
   label_currentheatflow.Interpreter = 'latex';

 
   label_heatflowrange.Text = ['[' num2str(qMin,'%1.1f') ...
            ' - ' num2str(qMax,'%1.1f') '] $mW m^{-2}$'];
   label_initheatflow.Text = [num2str(HeatFlow,'%1.0f') ' $mW m^{-2}$'];
   label_currentheatflow.Text = 'NaN $mW m^{-2}$';


% =======================================
% Plot iteration and standard deviation
% =======================================

% Initialize Iterations plot
% --------------------------
set(axes_SA_SDvIter, ...
        'ydir','reverse', ...
        'box','on', ...
        'xaxislocation','top', ...
        'ylim',[0 MaxSAIterations]);
    xlabel(axes_SA_SDvIter, '\bfHeat Flow \sigma (mW m^{-2})', ...
        'verticalalignment','bottom', 'FontSize',16, 'Color',[0.00,0.45,0.74])
    ylabel(axes_SA_SDvIter, '\bfIteration', ...
        'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])

 hold(axes_SA_SDvIter, 'on');

 % Update labels that describe sensitivity analysis parameters
    % ---- need to make these labels
 % -----------------------------------------------------------
   label_currentiteration.Interpreter = 'latex';
   label_meanheatflow.Interpreter = 'latex';
   label_standev.Interpreter = 'latex';

   label_currentiteration.Text = ['NaN/' int2str(MaxSAIterations)];
   label_meanheatflow.Text = 'NaN $mW m^{-2}$';
   label_standev.Text = 'NaN $mW m^{-2}$';
    


% Set plot invisible
% ------------------
for i = 1:length(axes_SA_SDvIter.Children)
    axes_SA_SDvIter.Children(i).Visible = 'off';
end

% ===========================
%      BEGIN ANALYSIS %
% ===========================

% Remove distributions of all sensors that are ignored
% ----------------------------------------------------
Allk = r;
r = r(:,SensorsToUse);

% Begin iterations
% ----------------
for n = 1:MaxSAIterations

% Define variables for conductivity distributions 
% ---------------------------------
if exist("k_Anisotropy", "var")
	k0 = k_Anisotropy(n, :);
end
    
    Iterations(n) = n;

    loading.Message = ['Iterating... ' num2str(n) '/' num2str(MaxSAIterations)];
    loading.Value = n/MaxSAIterations;

    % Plot Current profile
    % --------------------   
    remainder = rem(n,10);
    if remainder == 0 || n == 1
    
        if n>1 
            delete(PreviousProfile)
            delete(PreviousPoints)
        end
    
        if exist("k_Anisotropy", "var")
	        PreviousProfile = stairs(axes_SA_TCvDepth, k(n,:),z(n,:),'k:','linewidth',2);
            PreviousPoints  = plot(axes_SA_TCvDepth, k(n,:),z(n,:),'ko','MarkerSize',8);
            
        else
	        PreviousProfile = stairs(axes_SA_TCvDepth, [r(n,1) r(n,:)],[ShiftedRelativeDepths(kToUse(1)) zBD(n,:) 0], 'k:', 'linewidth', 2);
	        PreviousPoints = plot(axes_SA_TCvDepth, r(n,:),ShiftedRelativeDepths(kToUse),'ko', ...
                'markersize',8);  
        end
    end

     % Frictional Decay processing
     % ---------------------------
     
     if UseFrictional 
         Currentk = Allk(n,:); % use all random distributions of k values, even ignored sensors. these will be ignored in the frictional decay reduction. 
     
        [~, ...
        T0, ...
        ~, ...
        ~, ...
        ~, ...
        HPTooLow, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~, ...
        ~ ...
        ] = FrictionalDecay( ...
        figure_Main, ...
        FricTime, ...
        FricTemp, ...
        NumberOfSensors, ...
        FrictionalDelays, ...
        FricMaxStep, ...
        TimeInc, ...
        Currentk, ...
        HyndmanCoeffs, ...
        SensorRadius, ...
        FricTauMin, ...
        FricTauMax, ...
        SensorsToUse, ...
        loading);

         if HPTooLow
             return
         end
     end

% Compute cumulative thermal resistance and associated error
% -------------------------------------------------------------- 
CTR = NaN*zeros(length(kToUse),1);

    if exist("k_Anisotropy", "var")
        CTR(length(kToUse)) = zToUse(end)/k0(kToUse(end));
        
        for i = length(kToUse)-1:-1:1
        CTR(i) = CTR(i+1) + (zBD(n,i)-zToUse(i+1))/k0(kToUse(i+1)) ...
            + (zToUse(i)-zBD(n,i))/k0(kToUse(i));
        end
    else
        CTR(length(kToUse)) = zToUse(end)/r(n,end);

        for i = length(kToUse)-1:-1:1
        CTR(i) = CTR(i+1) + (zBD(n,i)-zToUse(i+1))/r(n,i+1) ...
            + (zToUse(i)-zBD(n,i))/r(n,i);
        end
    end

CurrentCTR = NaN*zeros(NumberOfSensors,1);
CurrentCTR(SensorsToUse) = CTR;

[p,~] = polyfit(T0(SensorsUsedForBullardFit)',CurrentCTR(SensorsUsedForBullardFit),1);

% ==================================================================
% from BP 2017 -- using chi squared fit requires data to be normally
% distributed (I think)
[Shift,Slope,ShiftErr,SlopeErr] = ChiSquaredFit(T0(SensorsUsedForBullardFit),CurrentCTR(SensorsUsedForBullardFit)); % BP
Shift=-Shift; % BP
Err=mean([abs(1/Slope - 1/(Slope+SlopeErr)),abs(1/Slope - 1/(Slope-SlopeErr))]); % BP
% =================================================================

ShiftCurrentCTR = -p(2);
SlopeCurrentCTR = p(1);

ShiftedCurrentCTR = CurrentCTR + ShiftCurrentCTR;

% Plot final iteration INSIDE LOOP
% ===================================
    % Remove colors of ignored sensors so that you can plot 
    % -----------------------------------------------------
    for i = 1:NumberOfSensors
        Colors{i} = h_axTempAboveBWT(i).Color;
    end
    
    Colors(IgnoredSensors) = [];

    % Plot new heat flow plot for each iteration
    % ------------------------------------------
    for i = 1:length(SensorsUsedForBullardFit)
        plot(axes_SA_TempvCTR, AllT(i,n),AllBullardDepths(i,n),'+', ...
            'markersize',14, ...
            'Color',h_axTempAboveBWT(i).Color)
        
    end
    plot(axes_SA_TempvCTR, [0 max(ShiftedCurrentCTR)+0.5]/SlopeCurrentCTR, ...
        [0 max(ShiftedCurrentCTR)+0.5],'k:')
    
    plot(axes_SA_SDvIter, SigmaHF,Iterations,'k-o', ...
        'markersize',8, 'MarkerFaceColor','k')
            
    % Set axes limits for the heat flow standard deviation plot
    % ---------------------------------------------------------
    if ~isnan(max(SigmaHF))
        axes_SA_SDvIter.XLim = [0 max(SigmaHF)+0.1];
    end


% Here is the sensitivity analysis !
% ------------------------------------
    
    AllT(:,n) = T0(SensorsUsedForBullardFit);
    AllBullardDepths(:,n) = ShiftedCurrentCTR(SensorsUsedForBullardFit)';
    AllHeatFlows(n) = (1/SlopeCurrentCTR)*1000;
    AllHeatFlowsErr(n) = Err; % BP %Testing from BP 2017
    T(n,:) = mean(AllT,2, 'omitnan')';
    SigmaTD = std(AllT,0,2, 'omitnan');
    Rz(n,:) = mean(AllBullardDepths,2, 'omitnan')';
    SigmaR = std(AllBullardDepths,0,2, "omitnan");
    Q(n) = mean(AllHeatFlows, 'omitnan');
    QErr(n) = mean(AllHeatFlowsErr, 'omitnan'); % BP
    SigmaTI = Q(n)*SigmaR;
    SigmaT = sqrt(SigmaTI.^2 + SigmaTD.^2);
    
    if any(SigmaT == 0)
        SigmaHF(n) = NaN;
    else
        Delta = sum(1./SigmaT.^2)*sum(Rz(n,:)'.^2./SigmaT.^2) ...
            -(sum(Rz(n,:)'./SigmaT.^2)).^2;
        SigmaHF(n) = sqrt(sum(1./SigmaT.^2)/Delta);
    end

    if AllHeatFlows(n)>qMax 
        qMax = AllHeatFlows(n);
    end
    if AllHeatFlows(n)<qMin
        qMin = AllHeatFlows(n);
    end 
    
% Update labels that describe sensitivity analysis parameters
% ---- need to make these labels for Temp. v CTR plot
% -----------------------------------------------------------
label_currentheatflow.Text = [num2str(AllHeatFlows(n),'%1.0f') ' $mW m^{-2}$'];
label_heatflowrange.Text = ['[' num2str(qMin,'%1.0f') ...
           ' - ' num2str(qMax,'%1.0f') ']  $mW m^{-2}$'];

% Update labels that describe sensitivity analysis parameters
% ---- need to make these labels for StandDev vs. Iter plot
% -----------------------------------------------------------
 label_currentiteration.Text = [num2str(n) '/' int2str(MaxSAIterations)];
 label_meanheatflow.Text =  [num2str(mean(AllHeatFlows, 'omitnan'), '%1.1f') ' $mW m^{-2}$'];
 label_standev.Text = [num2str(SigmaHF(n), '%1.2f') ' $mW m^{-2}$'];

drawnow;
        
end

delete(PreviousProfile)
delete(PreviousPoints)

for i = 1:length(SensorsUsedForBullardFit)
    plot(axes_SA_TCvDepth,T0(SensorsUsedForBullardFit(i)),ShiftedRelativeDepths(kToUse(i)),'o', ...
        'Color',h_axTempAboveBWT(i).Color, ...
        'markerfacecolor',h_axTempAboveBWT(i).Color)
    
    hold(axes_SA_TCvDepth, 'on');
end
ylabel(axes_SA_SDvIter, '\bfIterations', ...
        'verticalalignment','bottom', 'FontSize',18, 'Color',[0.00,0.45,0.74])

% Update legends
 legend(line_initialheatflow, {'Initial Bullard Best Fit Line'});
 legend([h_axTCvDepthStairs kMinLine kMaxLine], {'Initial k Values', 'Min k', 'Max k'});

% Format and fill results data table
% -----------------------------------
close(loading)
if kDistribution == 3
    % Table column names
    table_ErrorUncertaintySummary.ColumnName = {'Cruise'; 'Station'; ...
        'Penetration'; 'Trial Number'; 'Iterations';...
        'Thickness Distribution';'Min Thickness (m)'; 
        'k Distribution';'k Anisotropy Bias';
        'Initial q (mW/m^2)';'Initial q (mW/m^2)'; 
        'Final q (mW/m^2)';'Mean Heat Flow (mW/m^2)';
        'Total q Range (mW/m^2)';'q Standard Deviation (mW/m^2)'; 'Average Uncertainty'};

    % Table data
    Iter = num2str(MaxSAIterations);
    DisLayer = 'Uniform';
    MinThick = num2str(MinThickness);
    ThermAni = [num2str(abs(1-kAnisotropy)*100) '%'];
    InitHF = num2str(HeatFlow);
    FinalHF = num2str(AllHeatFlows(n));
    MeanHF = num2str(Q(n));
    TotHFR = ['[' num2str(qMin) ...
           ' - ' num2str(qMax) ']'];
    HFstd = num2str(SigmaHF(n));
    AvUncer = num2str(QErr(end));

    ErrData = [ErrData, Iter, DisLayer, MinThick, DisCond, ThermAni, InitHF, ...
        FinalHF, MeanHF, TotHFR, HFstd, AvUncer];
    
    table_ErrorUncertaintySummary.Data = [table_ErrorUncertaintySummary.Data; ErrData];


else
    % Table column names
    table_ErrorUncertaintySummary.ColumnName = {'Cruise'; 'Station'; ...
    'Penetration'; 'Trial'; 'Iterations';
    'Thickness Distribution';'Min Thickness (m)'; ...
    'k Distribution'; 'k Range (W/m??C)'; ...
    'k Standard Deviation'; ...
    'Initial q (mW/m^2)';'Final q (mW/m^2)';'Mean q (mW/m^2)';...
    'Total q Range (mW/m^2)'; 'q Standard Deviation (mW/m^2)'; 'Average Uncertainty'};
    % Table data
    Iter = num2str(MaxSAIterations);
    DisLayer = 'Uniform';
    MinThick = num2str(MinThickness);
   % kBounds = NaN*ones(1,length(SensorsToUse));
    for i = SensorsToUse
        kBounds{i} = ['[' num2str(kMin(i)) ' - ' num2str(kMax(i)) ']'];
    end
    kBoundsAll = strjoin(kBounds(SensorsToUse));
    kDev = strjoin(string(Sigmak0(SensorsToUse)));
    InitHF = num2str(HeatFlow);
    FinalHF = num2str(AllHeatFlows(n), '%1.0f');
    MeanHF = num2str(mean(AllHeatFlows, 'omitnan'), '%1.0f');
    TotHFR = ['[' num2str(qMin, '%1.0f') ...
           ' - ' num2str(qMax,'%1.0f') ']'];
    HFstd = num2str(SigmaHF(n));
    AvUncer = num2str(QErr(end));
    
    
    ErrData = [ErrData, Iter, DisLayer, MinThick, DisCond, kBoundsAll, ...
        kDev, InitHF, FinalHF, MeanHF, TotHFR, HFstd, AvUncer];
    
    table_ErrorUncertaintySummary.Data = [table_ErrorUncertaintySummary.Data; ErrData];
end

ErrResultsSummary = table_ErrorUncertaintySummary;

save('ErrResultsSummaryTable', "ErrResultsSummary");

drawnow;

% Report all results and inputs to RES and LOG files
% ==================================================

% TO DO ...............













