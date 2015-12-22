namespace :entry_tidy do
  desc "TODO"

  #quick task for some entries need their entry number changing; just  put in the info for the id and entry_no below
  task reorder: :environment do

	e = Entry.find('')
	e.entry_no = '2'
	e.save

	e = Entry.find('')
	e.entry_no = '3'
	e.save

	e = Entry.find('')
	e.entry_no = '1'
	e.save
  end
end
