module Sprinkle
  module Verifiers
    module User
      Sprinkle::Verify.register(Sprinkle::Verifiers::User)

      def has_user(name)
        @commands << "cat /etc/passwd | grep -q ^#{name}"
      end
    end
  end
end