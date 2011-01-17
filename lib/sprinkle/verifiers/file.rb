module Sprinkle
  module Verifiers
    # = File Verifier
    #
    # Contains a verifier to check the existance of a file.
    # 
    # == Example Usage
    #
    #   verify { has_file '/etc/apache2/apache2.conf' }
    #
    #   verify { file_contains '/etc/apache2/apache2.conf', 'mod_gzip'}
    #
    module File
      Sprinkle::Verify.register(Sprinkle::Verifiers::File)
      
      # Checks to make sure <tt>path</tt> is a file on the remote server.
      def has_file(path, md5 = nil)
        if md5
          if md5 =~ /\/|\./
            require 'md5'
            newmd5 = MD5.new
            ::File.open(md5, 'rb') do |input|
              while bytes = input.read(4096)
                newmd5.update(bytes)
              end
            end
            md5 = newmd5.hexdigest
          end

          @commands << "echo \"#{md5}  #{path}\" | md5sum -c"
        else
          @commands << "test -f #{path}"
        end
      end
      
      def file_contains(path, text)
        @commands << "grep '#{text}' #{path}"
      end
    end
  end
end
