require 'json'

class ReadAuth

	def lookup(authority)
		# to allow this to work in dev mode, see
		# https://wiki.york.ac.uk/display/dlib/Rails#Rails-EnablingMulti-threadedModeinDevelopment
		source = open(ENV["QA_DIR"] + authority).read
		#source = open(ENV["QA_DIR"] + authority).read
		JSON.parse(source)
	end
end
