module StardustCompiler
	module Helper
		def self.number?(string)
			string =~ /[[:digit:]]/
		end

		def self.letter?(string)
			string =~ /[[:alpha:]]/
		end
	end
end