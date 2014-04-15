if defined?(ChefSpec)

    def set_ssh_known_hosts_for(resource)
      ChefSpec::Matchers::ResourceMatcher.new(:append_to_ssh_known_hosts, :create, resource)
    end

end
