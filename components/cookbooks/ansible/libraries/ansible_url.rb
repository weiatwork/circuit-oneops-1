require 'psych'
require 'uri'

module AnsibleUrl
  include Chef::Mixin::ShellOut

  def parse_url(content=nil,multi=true)
    unless content.nil?
      # try to parse yaml content, if valid it is inline yaml,
      # return string untouch
      begin
        yml = Psych.load(content)

        if yml.kind_of?(String)
		parsed_urls = []
		begin
			content.each_line do |line|
				begin
					uri = URI.split(URI.escape(line))
					scheme = uri[0]
					user_info = uri[1].nil? ? '' : "#{uri[1]}@"
					host = uri[2]
					port = uri[3].nil? ? '' : ":#{uri[3]}"
					path = uri[5].nil? ? '' : uri[5]
					query = uri[7].nil? ? '' : URI.decode(uri[7])

					queries = query.split('&')

					query_hash = Hash.new

					queries.each do |q|
						(k,v) = q.split('=')
						query_hash[k] = v
					end

					if path.end_with? ".git"
						query_hash['scm'] = 'git'
					end

					url = "#{scheme}://#{user_info}#{host}#{port}#{path}"

					parsed_urls.push({:url => url,:query => query_hash})
					return parsed_urls
				rescue URI::InvalidURIError => e
					Chef::Log.fatal("**FAULT:FATAL=You've provided invalid URL: #{line}")
					_raise_exception()
				end
			end
		end
        elsif yml.kind_of?(Hash)
		return content
        elsif yml.nil?
		Chef::Log.fatal("***FAULT:FATAL=Your content is neither a valid YAML or a valid URL")
		_raise_exception()
        end
      rescue Psych::SyntaxError => e
	Chef::Log.fatal("***FAULT:FATAL=Your content is neither a valid YAML or a valid URL")
	_raise_exception()
      end
    end
  end

  def _raise_exception()
	e = Exception.new("no backtrace")
	e.set_backtrace("")
	raise e
  end

end

Chef::Recipe.send(:include, AnsibleUrl)