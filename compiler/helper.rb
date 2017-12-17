module StardustCompiler
	module Helper
		def self.number?(string)
			!(string =~ /[[:digit:]]/).nil?
		end

		def self.letter?(string)
			!(string =~ /[[:alpha:]]/).nil?
		end

		def self.lowercase?(string)
			(string =~ /[[:lower:]]/) == 0
		end

		def self.valid_id_character?(string)
			number?(string) || letter?(string) || string == "_"
		end
	end
end