module Sprinkle
  module Verifiers
    # = Dpkg Verifiers
    #
    # This verifier checks if a dpkg package is installed
    module Dpkg
      Sprinkle::Verify.register(Sprinkle::Verifiers::Dpkg)
        
      def has_dpkg(name)
        @commands << "dpkg -s #{name} | grep -e '^Status:.*installed"
      end
    end
  end
end
