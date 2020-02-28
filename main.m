%% add monkeys
insert(firefly.Monkey,{'Bruno',51,"M"});
insert(firefly.Monkey,{'Schro',53,"M"});
insert(firefly.Monkey,{'Quigley',44,"M"});
insert(firefly.Monkey,{'Sparky',70,"M"});

%% add sessions
insert(firefly.Session,{'Bruno','2017-08-03',41,'Erin Neyhart'});
insert(firefly.Session,{'Bruno','2017-08-04',42,'Erin Neyhart'});
insert(firefly.Session,{'Bruno','2017-08-05',43,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-08',33,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-09',34,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-12',35,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-13',36,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-14',37,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-15',38,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-16',39,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-19',40,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-20',41,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-21',42,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-26',43,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-27',44,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-02-28',45,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-03-01',46,'Erin Neyhart'});
insert(firefly.Session,{'Schro','2018-03-02',47,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-02-25',61,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-02-27',62,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-02-28',63,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-01',64,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-02',65,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-05',66,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-07',68,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-08',69,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-09',70,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-13',71,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-14',72,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-15',73,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-16',74,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-17',75,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-03-20',76,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-08-01',145,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-08-02',146,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-08-03',147,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-08-04',148,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-08-08',149,'Erin Neyhart'});
insert(firefly.Session,{'Quigley','2017-08-09',150,'Erin Neyhart'});
insert(firefly.Session,{'Sparky','2020-01-31',1,'Sina Salehi'});

%% populate static tables
firefly.SessionList;
firefly.ElectrodeParam;
firefly.DataAcquisitionParam;
firefly.StimulusParam;
firefly.AnalysisParam;

%% populate basic tables - behavior, events, neuron, lfp (imported)
populate(firefly.Behaviour);
populate(firefly.Event);
populate(firefly.Neuron);
populate(firefly.Lfp);

%% populate tables with segmented trials (computed)
populate(firefly.TrialBehaviour);
populate(firefly.TrialNeuron);
populate(firefly.TrialLfp);
populate(firefly.TrialLfpbeta);
populate(firefly.TrialLfptheta);

%% populate results tables (computed)
populate(firefly.StatsBehaviour);
populate(firefly.StatsBehaviourAll); % quick version - analyse all trials without splitting into conditions
populate(firefly.StatsEye);
populate(firefly.StatsEyeAll); % quick version - analyse all trials without splitting into conditions
populate(firefly.StatsLfpAll);
populate(firefly.StatsLfpthetaAll);
populate(firefly.StatsLfpbetaAll);
populate(firefly.StatsNeuronAll);