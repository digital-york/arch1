## ARCH1

Arch1 is a Hydra-based, Ruby on Rails application built for the 'York's Archbishops' Registers Revealed' project. The project was funded by the Andrew W. Mellon Foundation. 

The application enables indexing of the entries in the Archbishops' Registers. The application is in active use, but is password protected.
 
This code is made freely available, without warranty. It relies on the existence of a Fedora4 repository and solr instance containing data structured according the models here.

For further information on the underlying data model, please see: https://docs.google.com/document/d/1U3sLgaJr07d7LfvyDPT2rUnVAI1ccWp-Zeon_rlBd6o/edit

This application provides data to power the arch1_search codebase: https://github.com/digital-york/arch1_search and application: http://archbishopsregisters.york.ac.uk 
 
Please contact us if you would like to make use of the codebase: dti-group@york.ac.uk

## rake tasks

### BIA

#### Before ingest

Check if any duplicate places (due to the lack of county info, the code cannot locate an unique place from the authority list) in the spreadsheet.

    bundle exec rake duplicateplaces:excel[/home/frank/dlib/nw_data/Reg7_156-191_Clev_EHW.xlsx]


#### Ingest

    bundle exec rake ingest:excel[FULL_PATH_OF_xlsx,true]

The second parameter tells the ingest code overwrite the existing Entry or not.

#### After ingest

After ingestion, validate entries from excel against solr.

    bundle exec rake validate:excel[FULL_PATH_OF_xlsx]

#### Batch deletion

If a range of folios is know, run:

    bundle exec rake batch:delete_entries_range['Abp Reg 12 f.1 (recto)','Abp Reg 12 f.12 (verso)']

If delete entries within a folio:

    bundle exec rake batch:delete_entries['','Abp Reg 12 f.1 (recto)']
    
If all entries within a Register need to be deleted:

    bundle exec rake batch:delete_entries['Reg 9A']    

### TNA

#### Before ingest

Format TNA spreadsheet and generate a new spreadsheet. The new spreadsheet is ONLY used for manual checking, not for ingest.

    bundle exec rake data_formatter:tna[SRC_xlsx,TARGET_xlsx]

Validate TNA places from excel against solr and report missing ones.

    bundle exec rake validate:tna_place[FULL_PATH_OF_xlsx]

#### Ingest

Ingest TNA departments:

    bundle exec rake ingest:tna_departments

Ingest TNA series:

    bundle exec rake ingest:tna_series

Ingest TNA documents from Excel spreadsheet:

    bundle exec rake ingest:tna_documents[FULL_PATH_OF_xlsx]

#### After ingest

After ingestion, validate documents from excel against solr.

    bundle exec rake validate:tna_excel[FULL_PATH_OF_xlsx]



    