module Sprinkle
  module Verifiers
    module Command
      Sprinkle::Verify.register(Sprinkle::Verifiers::Command)

      def returns_success(command)
        @commands << command
      end
    end
  end
end

