%Test Name: SquareShelfSMBGemb
md=triangle(model(),'../Exp/Square.exp',350000.);
md=setmask(md,'all','');
md=parameterize(md,'../Par/SquareShelf.par');
md=setflowequation(md,'SSA','all');
md.materials.rho_ice=910;
md.cluster=generic('name',oshostname(),'np',3);

% Use of Gemb method for SMB computation
md.smb = SMBgemb(md.mesh);
md.smb.dsnowIdx = 1;
md.smb.swIdx = 1;

%load hourly surface forcing date from 1979 to 2009:
inputs=load('../Data/gemb_input.mat');

%setup the inputs: 
md.smb.Ta=[repmat(inputs.Ta0',md.mesh.numberofelements,1);inputs.dateN'];
md.smb.V=[repmat(inputs.V0',md.mesh.numberofelements,1);inputs.dateN'];
md.smb.dswrf=[repmat(inputs.dsw0',md.mesh.numberofelements,1);inputs.dateN'];
md.smb.dlwrf=[repmat(inputs.dlw0',md.mesh.numberofelements,1);inputs.dateN'];
md.smb.P=[repmat(inputs.P0',md.mesh.numberofelements,1);inputs.dateN'];
md.smb.eAir=[repmat(inputs.eAir0',md.mesh.numberofelements,1);inputs.dateN'];
md.smb.pAir=[repmat(inputs.pAir0',md.mesh.numberofelements,1);inputs.dateN'];
md.smb.Vz=repmat(inputs.LP.Vz,md.mesh.numberofelements,1);
md.smb.Tz=repmat(inputs.LP.Tz,md.mesh.numberofelements,1);
md.smb.Tmean=repmat(inputs.LP.Tmean,md.mesh.numberofelements,1);
md.smb.C=repmat(inputs.LP.C,md.mesh.numberofelements,1);

%smb settings
md.smb.requested_outputs={'SmbDz','SmbT','SmbD','SmbRe','SmbGdn','SmbGsp','SmbEC',...
	'SmbA','SmbMassBalance','SmbMAdd','SmbDzAdd','SmbFAC','SmbMeanSHF','SmbMeanLHF',...
	'SmbMeanULW','SmbNetLW','SmbNetSW','SmbWAdd','SmbRunoff','SmbRefreeze','SmbMelt',...
	'SmbEC','SmbPrecipitation','SmbRain','SmbAccumulatedMassBalance','SmbAccumulatedRunoff',...
	'SmbAccumulatedMelt','SmbAccumulatedEC','SmbAccumulatedPrecipitation','SmbAccumulatedRain',...
	'SmbAccumulatedPrecipitation','SmbAccumulatedRefreeze'};

%only run smb core: 
md.transient.isstressbalance=0;
md.transient.ismasstransport=0;
md.transient.isthermal=0;

%time stepping: 
md.timestepping.start_time=1965;
md.timestepping.final_time=1966;
md.timestepping.time_step=1/365.0;
md.timestepping.interp_forcing=0;

%Run transient
md=solve(md,'Transient');

nlayers=size(md.results.TransientSolution(1).SmbT,2);
for i=2:length(md.results.TransientSolution)
   nlayers=min(size(md.results.TransientSolution(i).SmbT,2), nlayers);
end

%Fields and tolerances to track changes
field_names      ={'Layers','SmbDz','SmbT','SmbD','SmbRe','SmbGdn','SmbGsp','SmbA' ,'SmbEC','SmbMassBalance','SmbMAdd','SmbDzAdd','SmbFAC','SmbMeanSHF','SmbMeanLHF','SmbMeanULW','SmbNetLW','SmbNetSW','SmbAccumulatedMassBalance','SmbAccumulatedRunoff','SmbAccumulatedMelt','SmbAccumulatedEC','SmbAccumulatedPrecipitation','SmbAccumulatedRain','SmbAccumulatedRefreeze','SmbRunoff','SmbMelt','SmbEC','SmbPrecipitation','SmbRain','SmbRefreeze','SmbWAdd'};
field_tolerances ={1e-12,4e-11,2e-11,3e-11,6e-11,8e-11,8e-11,1e-12,5e-11,2e-12,1e-12,1e-12,4e-11,2e-11,5e-11,1e-11,9e-10,2e-11,1e-11,9e-10,2e-11,2e-09,1e-11,1e-11,1e-11,8e-10,2e-11,2e-11,1e-11,1e-11,1e-11,1e-11};

field_values={...
	(nlayers),...
	(md.results.TransientSolution(end).SmbDz(1,1:nlayers)),...
	(md.results.TransientSolution(end).SmbT(1,1:nlayers)),...
	(md.results.TransientSolution(end).SmbD(1,1:nlayers)),...
	(md.results.TransientSolution(end).SmbRe(1,1:nlayers)),...
	(md.results.TransientSolution(end).SmbGdn(1,1:nlayers)),...
	(md.results.TransientSolution(end).SmbGsp(1,1:nlayers)),...
	(md.results.TransientSolution(end).SmbA(1,1:nlayers)),...
	(md.results.TransientSolution(end).SmbEC(1)),...
	(md.results.TransientSolution(end).SmbMassBalance(1)),...
	(md.results.TransientSolution(end).SmbMAdd(1)),...
	(md.results.TransientSolution(end).SmbDzAdd(1)),...
	(md.results.TransientSolution(end).SmbFAC(1)),...
	(md.results.TransientSolution(end).SmbMeanSHF(1)),...
	(md.results.TransientSolution(end).SmbMeanLHF(1)),...
	(md.results.TransientSolution(end).SmbMeanULW(1)),...
	(md.results.TransientSolution(end).SmbNetLW(1)),...
	(md.results.TransientSolution(end).SmbNetSW(1)),...
	(md.results.TransientSolution(end).SmbAccumulatedMassBalance(1)),...
	(md.results.TransientSolution(end).SmbAccumulatedRunoff(1)),...
	(md.results.TransientSolution(end).SmbAccumulatedMelt(1)),...
	(md.results.TransientSolution(end).SmbAccumulatedEC(1)),...
	(md.results.TransientSolution(end).SmbAccumulatedPrecipitation(1)),...
	(md.results.TransientSolution(end).SmbAccumulatedRain(1)),...
	(md.results.TransientSolution(end).SmbAccumulatedRefreeze(1)),...
	(md.results.TransientSolution(200).SmbRunoff(1)),...
	(md.results.TransientSolution(200).SmbMelt(1)),...
	(md.results.TransientSolution(200).SmbEC(1)),...
	(md.results.TransientSolution(200).SmbPrecipitation(1)),...
	(md.results.TransientSolution(200).SmbRain(1)),...
	(md.results.TransientSolution(200).SmbRefreeze(1)),...
	(md.results.TransientSolution(200).SmbWAdd(1))...
};
