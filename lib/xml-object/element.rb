module XMLObject::Element
  def self.new(xml) # :nodoc:
    element = xml.value
    element.instance_variable_set :@__raw_xml,    xml.raw
    element.instance_variable_set :@__children,   {}
    element.instance_variable_set :@__attributes, {}
    element.extend self
  end

  # The raw, unadapted XML object. Whatever this is, it really depends on
  # the currently chosen adapter.
  def raw_xml
    @__raw_xml
  end

  # Will traverse all the child nodes and return if any of them contain a node with a specific name
  # An example of the usage would be
  #   xml_object = XMLObject.new(File.open('/path/to/file'))
  #   xml_object.has_child_node?(:SomeNodeName)
  def has_child_node?(node_name)
    return true if @__children.keys.include?(node_name)
    answer = false    
    @__children.keys.each do |key|
      if self[key].class.eql?(Array)
        self[key].each do |e|
          answer = e.has_child_node?(node_name)
        end
      else
        if self[key].has_child_node?(node_name)
          answer = true
          break
        end
      end
    end
    return answer
  end

  # Will traverse all the child nodes and return if any of them contain an attribute with a specific name
  # An example of the usage would be
  #   xml_object = XMLObject.new(File.open('/path/to/file'))
  #   xml_object.child_nodes_have_attribute?(:SomeAttributeName)
  def child_nodes_have_attribute?(attribute_name)
    return true if @__attributes.keys.include?(attribute_name)
    answer = false
    @__children.keys.each do |key|
      if self[key].class.eql?(Array)
        self[key].each do |e|
          answer = e.child_nodes_have_attribute?(attribute_name)
        end
      else
        if self[key].child_nodes_have_attribute?(attribute_name)
          answer = true
          break
        end
      end     
    end
    return answer
  end


  private ##################################################################

  def method_missing(m, *a, &b) # :nodoc:
    dispatched = __question_dispatch(m, *a, &b)
    dispatched = __dot_notation_dispatch(m, *a, &b) if dispatched.nil?

    dispatched.nil? ? raise(NameError.new(m.to_s)) : dispatched
  end
end