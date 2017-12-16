module StardustCompiler
	class SyntaxError < StandardError
		def initialize(message)
			@message = message
		end

		def to_s
			return @message
		end
	end
end