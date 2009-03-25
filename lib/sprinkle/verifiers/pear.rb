module Sprinkle
  module Verifiers
    # = Dpkg Verifiers
    #
    # This verifier checks if a dpkg package is installed
    module Pear
      Sprinkle::Verify.register(Sprinkle::Verifiers::Pear)

      def has_pear(name, version = nil)
        version = version.nil? ? '' : version.gsub('.', '\.')
        @commands << "pear list --allchannels 2>&1 | grep -e '^#{name}\\s*#{version}.*$'"
      end
    end
  end
end
