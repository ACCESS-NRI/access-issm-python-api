%Test Name: RoundSheetShelfGLMigrationSSA3d
radius=1.e6;
shelfextent=2.e5;

md=roundmesh(model(),radius,50000.);
%fix center node to 0,0
rad=sqrt(md.mesh.x.^2+md.mesh.y.^2);
pos=find(rad==min(rad));
md.mesh.x(pos)=0.; md.mesh.y(pos)=0.; %the closest node to the center is changed to be exactly at the center
xelem=mean(md.mesh.x(md.mesh.elements), 2);
yelem=mean(md.mesh.y(md.mesh.elements), 2);
rad=sqrt(xelem.^2+yelem.^2);
flags=zeros(md.mesh.numberofelements,1);
pos=find(rad>=(radius-shelfextent));
flags(pos)=1;
md=setmask(md,flags,''); 
md=parameterize(md,'../Par/RoundSheetShelf.par');
md=setflowequation(md,'SSA','all');
md=extrude(md,3,1);
md.cluster=generic('name',oshostname(),'np',3);

md.transient.isthermal=0;
md.transient.ismasstransport=0;
md.transient.issmb=1;
md.transient.isstressbalance=0;
md.transient.isgroundingline=1;

%test different grounding line dynamics.
md.groundingline.migration='AggressiveMigration';
md=solve(md,'Transient');
element_on_iceshelf_agressive=(md.results.TransientSolution.MaskOceanLevelset);

md.groundingline.migration='SoftMigration';
md=solve(md,'Transient');
element_on_iceshelf_soft=(md.results.TransientSolution.MaskOceanLevelset);

md.groundingline.migration='SubelementMigration';
md=solve(md,'Transient');
element_on_iceshelf_subelement=(md.results.TransientSolution.MaskOceanLevelset);

md.groundingline.migration='SubelementMigration';
md.groundingline.friction_interpolation='SubelementFriction2';
md.transient.isstressbalance=1;
md=setflowequation(md,'SSA','all');
md=solve(md,'Transient');
element_on_iceshelf_subelement2=(md.results.TransientSolution.MaskOceanLevelset);

%Fields and tolerances to track changes
field_names     ={'ElementOnIceShelfAggressive','ElementOnIceShelfSoft','ElementOnIceShelfSubelement','ElementOnIceShelfSubelement'};
field_tolerances={1e-13,1e-13,1e-13,1e-13};
field_values={element_on_iceshelf_agressive,element_on_iceshelf_soft,element_on_iceshelf_subelement,element_on_iceshelf_subelement2};
