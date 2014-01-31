Puppet::Type.newtype(:logstashforwarder_fragment) do

  @doc = "Define an unicast node"

  newparam(:name, :namevar => true) do
    desc "Unique name"
  end

  newparam(:content) do
    desc "Content"
  end

  newparam(:tag) do
    desc "Tag name to be used"
  end

  validate do 
    self.fail Puppet::ParseError, "Required setting 'content' missing" if self[:content].nil?
    self.fail Puppet::ParseError, "Required setting 'tag' missing" if self[:tag].nil?
  end

end
