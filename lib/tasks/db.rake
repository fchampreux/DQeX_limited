# coding: utf-8
namespace :db do
  desc 'Create database schemas before going for the first migration'
  task init: ['db:drop','db:create'] do
    ActiveRecord::Base.connection.execute("CREATE SCHEMA dqm_app AUTHORIZATION dqm")
    ActiveRecord::Base.connection.execute("CREATE SCHEMA dqm_dwh AUTHORIZATION dqm")
    puts 'Database initialised'
  end
end

namespace :db do
  desc 'Apply FSO specific language parameters'
  task load_FSO: :environment do
    ActiveRecord::Base.connection.execute("update dqm_app.parameters set property = property||'_OFS' where code in('fr','it','de')")
  end

    desc 'Initialise playgrounds for FSO'
    task load_FSO: :environment do
      ActiveRecord::Base.connection.execute("INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'00','Analyses multithématiques','Analyses multithématiques','01',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'01','Population','Population','02',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'02','Education et science','Education et science','03',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'03','Energie','Energie','04',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'04','Société','Société','05',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'05','Santé','Santé','06',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'06','Mobilité et transports','Mobilité et transports','07',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'07','Territoire, environnement et développement durable','Territoire, environnement et développement durable','08',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'08','Social','Social','09',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'09','Economie et finances publiques','Economie et finances publiques','10',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'10','Registres','Registres','11',1,false,true,true,1,'Admin','Admin',now(),now());
INSERT INTO dqm_app.playgrounds (playground_id,code,name,description,hierarchy,status_id,is_finalised,is_current,is_active,owner_id,created_by,updated_by,created_at,updated_at) VALUES (0,'11','OFS: Information, bases et infrastructures','OFS: Information, bases et infrastructures','12',1,false,true,true,1,'Admin','Admin',now(),now());
")
    end

    desc 'Insert playgrounds translations for FSO'
    task load_FSO: :environment do
      ActiveRecord::Base.connection.execute("INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='00'),'name','fr_OFS','Analyses multithématiques',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='00'),'description','fr_OFS','Analyses multithématiques',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='00'),'name','de_OFS','Multithematische Analysen',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='00'),'description','de_OFS','Multithematische Analysen',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='00'),'name','it_OFS','Analisi multitematiche',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='00'),'description','it_OFS','Analisi multitematiche',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='01'),'name','fr_OFS','Population',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='01'),'description','fr_OFS','Population',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='01'),'name','de_OFS','Bevölkerung',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='01'),'description','de_OFS','Bevölkerung',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='01'),'name','it_OFS','Popolazione',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='01'),'description','it_OFS','Popolazione',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='02'),'name','fr_OFS','Education et science',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='02'),'description','fr_OFS','Education et science',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='02'),'name','de_OFS','Bildung und Wissenschaft',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='02'),'description','de_OFS','Bildung und Wissenschaft',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='02'),'name','it_OFS','Formazione e scienza',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='02'),'description','it_OFS','Formazione e scienza',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='03'),'name','fr_OFS','Energie',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='03'),'description','fr_OFS','Energie',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='03'),'name','de_OFS','Energie',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='03'),'description','de_OFS','Energie',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='03'),'name','it_OFS','Energia',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='03'),'description','it_OFS','Energia',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='04'),'name','fr_OFS','Société',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='04'),'description','fr_OFS','Société',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='04'),'name','de_OFS','Gesellschaft',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='04'),'description','de_OFS','Gesellschaft',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='04'),'name','it_OFS','Società',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='04'),'description','it_OFS','Società',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='05'),'name','fr_OFS','Santé',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='05'),'description','fr_OFS','Santé',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='05'),'name','de_OFS','Gesundheit',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='05'),'description','de_OFS','Gesundheit',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='05'),'name','it_OFS','Salute',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='05'),'description','it_OFS','Salute',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='06'),'name','fr_OFS','Mobilité et transports',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='06'),'description','fr_OFS','Mobilité et transports',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='06'),'name','de_OFS','Mobilität und Verkehr',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='06'),'description','de_OFS','Mobilität und Verkehr',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='06'),'name','it_OFS','Mobilità e trasporti',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='06'),'description','it_OFS','Mobilità e trasporti',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='07'),'name','fr_OFS','Territoire, environnement et développement durable',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='07'),'description','fr_OFS','Territoire, environnement et développement durable',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='07'),'name','de_OFS','Raum, Umwelt und nachhaltige Entwicklung',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='07'),'description','de_OFS','Raum, Umwelt und nachhaltige Entwicklung',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='07'),'name','it_OFS','Territorio, ambiente e sviluppo sostenibile',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='07'),'description','it_OFS','Territorio, ambiente e sviluppo sostenibile',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='08'),'name','fr_OFS','Social',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='08'),'description','fr_OFS','Social',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='08'),'name','de_OFS','Soziales',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='08'),'description','de_OFS','Soziales',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='08'),'name','it_OFS','Affari sociali',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='08'),'description','it_OFS','Affari sociali',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='09'),'name','fr_OFS','Economie et finances publiques',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='09'),'description','fr_OFS','Economie et finances publiques',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='09'),'name','de_OFS','Wirtschaft und öffentliche Finanzen',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='09'),'description','de_OFS','Wirtschaft und öffentliche Finanzen',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='09'),'name','it_OFS','Economia e finanze pubbliche',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='09'),'description','it_OFS','Economia e finanze pubbliche',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='10'),'name','fr_OFS','Registres',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='10'),'description','fr_OFS','Registres',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='10'),'name','de_OFS','Register',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='10'),'description','de_OFS','Register',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='10'),'name','it_OFS','Registri',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='10'),'description','it_OFS','Registri',now(),now());
/* --- */
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='11'),'name','fr_OFS','OFS: Information, bases et infrastructures',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='11'),'description','fr_OFS','OFS: Information, bases et infrastructures',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='11'),'name','de_OFS','BFS: Information, Grundlagen und Infrastrukturen',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='11'),'description','de_OFS','BFS: Information, Grundlagen und Infrastrukturen',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='11'),'name','it_OFS','UST: Informazioni, basi e infrastrutture',now(),now());
INSERT INTO dqm_app.translations (document_type,document_id,field_name,language,translation,created_at,updated_at) VALUES ('Playground',(select max(id) from dqm_app.playgrounds where code='11'),'description','it_OFS','UST: Informazioni, basi e infrastrutture',now(),now());
")

  end
end
