require 'json'

class ReadAuth2

	def lookup(authority)
		#source = open('http://dlib.york.ac.uk/ontologies/borthwick/lists/' + authority).read
		#DOESN'T WORK IN DEV MODE
		source = open(ENV["QA_DIR"] + authority).read
		authfile = JSON.parse(source)
		return authfile
	end
end
