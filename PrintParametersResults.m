%%% ======================================================================
%   Purpose: 
%   This function PRINTS parameters of RES file. LOG file to be added later by
%   KD if desired
%%% ======================================================================

function    PrintParametersResults(...
			NumberOfColumns, ...
			NumberOfSensors, ...
            TimeScalingFactor, ...
            SensorRadius, ...
            SensorDistance, ...
            CalibrationCoeffs, ...
            HyndmanCoeffs, ...
            FrictionalDelays, ...
            FricMaxStep, ...
            TimeInc, ...
            FricTauMin, ...
            FricTauMax, ...
            PulseDelays, ...
            kInit, ...
            ktype, ...
            PulsePower, ...
            TimeShiftInc, ...
            PulseMaxStep, ...
            kTolerance, ...
            PulseTauMin, ...
            PulseTauMax, ...
            HeatPulseLength, ...
            MinTotalkChange, ...
            MaxNumberOfIterations, ...
            MaxSAIterations, ...
            Sigmak0, ...
            kMin, ...
            kMax, ...
            MinThickness, ...
            UseFrictional, ...
            kAnisotropy, ...
            TopSensorDepth, ProgramLogId, ...
            LogFileId, ResFileId)


% ==========================================================================
%             Printing parameters to LOG file and RESULTS files
% ==========================================================================
	NC = NumberOfColumns;

  % Results (RES) file
  % ---------------------------------

  Id = ResFileId;

  String = 'PARAMETERS READ IN PAR FILE';
  fprintf(Id,'%s\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
           repmat('-',1,length(String))]);
  fprintf(Id,'%s\n',[repmat(' ',1,fix((NC-length(String))/2)) String]);
  fprintf(Id,'%s\n\n\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
           repmat('-',1,length(String))]);

  fprintf(Id,'%s\t\t%02d\n','Number Of Sensors:',NumberOfSensors);
  fprintf(Id,'%s\t%1.1f\n','Time Scaling Factor (s):',TimeScalingFactor);
  fprintf(Id,'%s\t\t%1.2e\n','Sensor Radius (m):',SensorRadius);
  fprintf(Id,'%s\t%1.2f\n','Inter-sensor spacing (m):',SensorDistance);
  fprintf(Id,'\n%s\n\n','Calibration Coefficients ( T = 1000*[a.x^2 + b.x + c] degC ):');
  Dim = size(CalibrationCoeffs);
  fprintf(Id,['  a: ' repmat('%1.1f  ',1,Dim(2)) '\n'],CalibrationCoeffs(1,:));
  fprintf(Id,['  b: ' repmat('%1.1f  ',1,Dim(2)) '\n'],CalibrationCoeffs(2,:));
  fprintf(Id,['  c: ' repmat('%1.1f  ',1,Dim(2)) '\n'],CalibrationCoeffs(3,:));
  fprintf(Id,'\n%s\n\n','Hyndman Coefficients ( Kappa = k/[a - b.k + c.k^2] 10^-6 m^2/s ):');
  fprintf(Id,'  a: %1.3f\n',HyndmanCoeffs(1));
  fprintf(Id,'  b: %1.3f\n',HyndmanCoeffs(2));
  fprintf(Id,'  c: %1.3f\n',HyndmanCoeffs(3));
  fprintf(Id,'\n%s\n\n','Initial Frictional Delays (s):');
  fprintf(Id,['  ' repmat('%1.1f  ',1,length(FrictionalDelays)) '\n'],FrictionalDelays);
  fprintf(Id,'\n%s\t%d\n','Time Shift Increment (s):  ',TimeInc);
  fprintf(Id,'%s\t%d\n','Maximum Frictional Step:  ',FricMaxStep);
  fprintf(Id,'%s\t%1.1f\n','Minimum Frictional Tau:  ',FricTauMin);
  fprintf(Id,'%s\t%1.1f\n','Maximum Fricional Tau:  ',FricTauMax);
  fprintf(Id,'\n%s\n\n','Assumed Initial Conductivities (W/m/degC):  ');
  if ktype == 99
      fprintf(Id,'  k(z) =');
      if kInit(1)~=0; fprintf(Id,' %+1.3f',kInit(1)); end
      if kInit(2)~=0; fprintf(Id,' %+1.3fz',kInit(2)); end 
      if kInit(3)~=0; fprintf(Id,' %+1.3fz^2',kInit(3)); end
      if kInit(4)~=0; fprintf(Id,' %+1.3fexp(%+1.3fz)',kInit(4:5)); end
      if kInit(6)~=0; fprintf(Id,' %+1.3flog10(z)',kInit(6)); end
      fprintf(Id,'\n');
  else
      fprintf(Id,['  ' repmat('%1.2f  ',1,length(kInit)) '\n'],kInit);
  end
  fprintf(Id,'\n%s\n\n','Initial Heat Pulse Delays (s):');
  fprintf(Id,['  ' repmat('%1.1f  ',1,length(PulseDelays)) '\n'],PulseDelays);
  fprintf(Id,'\n%s\t%1.1f\n','Time Shift Increment (s): ',TimeShiftInc);
  fprintf(Id,'%s\t%d\n','Maximum Heat Pulse Step:  ',PulseMaxStep);
  fprintf(Id,'%s\t%1.1f\n','Minimum Heat Pulse Tau:  ',PulseTauMin);
  fprintf(Id,'%s\t%1.1f\n','Maximum Heat Pulse Tau:  ',PulseTauMax);
  fprintf(Id,'%s\t%1.1f\n','Heat Pulse Power (J/m):  ',PulsePower);
  fprintf(Id,'%s\t%1.1f\n','Heat Pulse Length (s):  ',HeatPulseLength);
  fprintf(Id,'%s\t%1.1f\n','Tolerance on k (degC):  ',kTolerance);

  %%% New parameters added by KD %%%
  fprintf(Id,'%s\t%1.1f\n','Minimum change of Sigma(k):  ',MinTotalkChange);
  fprintf(Id,'%s\t%1.1f\n','Maximum number of iterations for k computations:  ',MaxNumberOfIterations);
  fprintf(Id,'%s\t%1.1f\n','Number of Iterations for Sensitivity analysis:  ',MaxSAIterations );
  fprintf(Id,'%s\t%1.1f\n','Standard deviation in thermal conductivity for Sensitivity analysis:  ',Sigmak0 );
  fprintf(Id,'%s\t%1.1f\n','Minimum thermal conductivity cutoff for Sensitivity analysis:  ',kMin);
  fprintf(Id,'%s\t%1.1f\n','Maximum thermal conductivity cutoff for Sensitivity analysis:  ',kMax);
  fprintf(Id,'%s\t%1.1f\n','Mininum layer thickness for Sensitivity analysis:  ',MinThickness);
  fprintf(Id,'%s\t%1.1f\n','Use Frictional decay for No Heat pulse Sensitivity analysis ?:  ',UseFrictional);
  fprintf(Id,'%s\t%1.1f\n','Horizontal thermal conductivity Anisotropy:  ',kAnisotropy);
  fprintf(Id,'%s\t%1.3f\n\n\n','Depth of first thermistor below weight stand:  ',TopSensorDepth); 


%  % LOG file
%  % ------------------------
%
%  Id = LogFileId;
%  
%  String = 'PARAMETERS READ IN PAR FILE';
%  fprintf(Id,'\n%s\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
%          repmat('-',1,length(String))]);
%  fprintf(Id,'%s\n',[repmat(' ',1,fix((NC-length(String))/2)) String]);
%  fprintf(Id,'%s\n\n\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
%          repmat('-',1,length(String))]);
%  
%  fprintf(Id,'%s\t\t%02d\n','Number Of Sensors:',NumberOfSensors);
%  fprintf(Id,'%s\t%1.1f\n','Time Scaling Factor (s):',TimeScalingFactor);
%  fprintf(Id,'%s\t\t%1.2e\n','Sensor Radius (m):',SensorRadius);
%  fprintf(Id,'%s\t%1.2f\n','Inter-sensor spacing (m):',SensorDistance);
%  fprintf(Id,'\n%s\n\n','Calibration Coefficients ( T = 1000*[a.x^2 + b.x + c] degC ):');
%  Dim = size(CalibrationCoeffs);
%  fprintf(Id,['  a: ' repmat('%1.1f  ',1,Dim(2)) '\n'],CalibrationCoeffs(1,:));
%  fprintf(Id,['  b: ' repmat('%1.1f  ',1,Dim(2)) '\n'],CalibrationCoeffs(2,:));
%  fprintf(Id,['  c: ' repmat('%1.1f  ',1,Dim(2)) '\n'],CalibrationCoeffs(3,:));
%  fprintf(Id,'\n%s\n\n','Hyndman Coefficients ( Kappa = k/[a - b.k + c.k^2] 10^-6 m2 s-1 ):');
%  fprintf(Id,'  a: %1.3f\n',HyndmanCoeffs(1));
%  fprintf(Id,'  b: %1.3f\n',HyndmanCoeffs(2));
%  fprintf(Id,'  c: %1.3f\n',HyndmanCoeffs(3));
%  fprintf(Id,'\n%s\n\n','Initial Frictional Delays (s):');
%  fprintf(Id,['  ' repmat('%1.1f  ',1,length(FrictionalDelays)) '\n'],FrictionalDelays);
%  fprintf(Id,'\n%s\t%d\n','Time Shift Increment (s):  ',TimeInc);
%  fprintf(Id,'%s\t%d\n','Maximum Frictional Step:  ',FricMaxStep);
%  fprintf(Id,'%s\t%1.1f\n','Minimum Frictional Tau:  ',FricTauMin);
%  fprintf(Id,'%s\t%1.1f\n','Maximum Fricional Tau:  ',FricTauMax);
%  fprintf(Id,'\n%s\n\n','Assumed Initial Conductivities (W/m/degC):  ');
%  if ktype == 99
%      fprintf(Id,'  k(z) =');
%      if kInit(1)~=0; fprintf(Id,' %+1.3f',kInit(1)); end
%      if kInit(2)~=0; fprintf(Id,' %+1.3fz',kInit(2)); end 
%      if kInit(3)~=0; fprintf(Id,' %+1.3fz^2',kInit(3)); end
%      if kInit(4)~=0; fprintf(Id,' %+1.3fexp(%+1.3fz)',kInit(4:5)); end
%      if kInit(6)~=0; fprintf(Id,' %+1.3flog10(z)',kInit(6)); end
%      fprintf(Id,'\n');
%  else
%      fprintf(Id,['  ' repmat('%1.2f  ',1,length(kInit)) '\n'],kInit);
%  end
%  fprintf(Id,'\n%s\n\n','Initial Heat Pulse Delays (s):');
%  fprintf(Id,['  ' repmat('%1.1f  ',1,length(PulseDelays)) '\n'],PulseDelays);
%  fprintf(Id,'\n%s\t%1.1f\n','Time Shift Increment (s): ',TimeShiftInc);
%  fprintf(Id,'%s\t%d\n','Maximum Heat Pulse Step:  ',PulseMaxStep);
%  fprintf(Id,'%s\t%1.1f\n','Minimum Heat Pulse Tau:  ',PulseTauMin);
%  fprintf(Id,'%s\t%1.1f\n','Maximum Heat Pulse Tau:  ',PulseTauMax);
%  fprintf(Id,'%s\t%1.1f\n','Heat Pulse Power (J/m):  ',PulsePower);
%  fprintf(Id,'%s\t%1.1f\n','Heat Pulse Length (s):  ',HeatPulseLength);
%  fprintf(Id,'%s\t%1.1f\n','Tolerance on k (degC):  ',kTolerance);
%  
%    %%% New parameters added by KD %%%
%    fprintf(Id,'%s\t%1.1f\n','Minimum change of Sigma(k):  ',MinTotalkChange);
%    fprintf(Id,'%s\t%1.1f\n','Maximum number of iterations for k computations:  ',MaxNumberOfIterations);
%    fprintf(Id,'%s\t%1.1f\n','Number of Iterations for Sensitivity analysis:  ',MaxSAIterations );
%    fprintf(Id,'%s\t%1.1f\n','Standard deviation in thermal conductivity for Sensitivity analysis:  ',Sigmak0 );
%    fprintf(Id,'%s\t%1.1f\n','Minimum thermal conductivity cutoff for Sensitivity analysis:  ',kMin);
%    fprintf(Id,'%s\t%1.1f\n','Maximum thermal conductivity cutoff for Sensitivity analysis:  ',kMax);
%    fprintf(Id,'%s\t%1.1f\n','Mininum layer thickness for Sensitivity analysis:  ',MinThickness);
%    fprintf(Id,'%s\t%1.1f\n','Use Frictional decay for No Heat pulse Sensitivity analysis ?:  ',UseFrictional);
%    fprintf(Id,'%s\t%1.1f\n','Horizontal thermal conductivity Anisotropy:  ',kAnisotropy);
%    fprintf(Id,'%s\t%1.3f\n\n\n','Depth of first thermistor below weight stand:  ',TopSensorDepth); 
%