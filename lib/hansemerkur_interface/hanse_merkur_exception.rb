class HanseMerkurException < StandardError
    def initialize(msg="There was an Error with the Hanse Merkur Interface", exception_type="hmerror")
        @exception_type = exception_type  
        super(msg)
    end
end