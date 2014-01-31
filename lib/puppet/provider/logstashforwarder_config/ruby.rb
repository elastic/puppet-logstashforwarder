Puppet::Type.type(:logstashforwarder_config).provide(:ruby, :parent => Puppet::Type.type(:file).provider(:posix)) do

  def exists?
    resource.stat ? true : false
  end

  def create
    send("content=", resource.should_content)
    resource.property_fix
  end

  def destroy
    File.unlink(resource[:path]) if exists?
  end

  def content
    actual = File.read(resource[:path]) rescue nil
    (actual == resource.should_content) ? resource.no_content : actual
  end

  def content=(value)
    File.open(resource[:path], 'w') do |fh|
      fh.print resource.should_content
    end
  end
end
