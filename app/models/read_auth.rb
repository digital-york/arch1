require 'json'

class ReadAuth

	def lookup(authority)
		#source = open('http://dlib.york.ac.uk/ontologies/borthwick/lists/' + authority).read
		#DOESN'T WORK IN DEV MODE
		source = open(ENV["QA_DIR"] + authority).read
		authfile = JSON.parse(source)
		#puts authfile
		authfile
	end
end
