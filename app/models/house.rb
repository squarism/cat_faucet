class House
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  max_versions 100
  
  field :name                 # friendly name
  embeds_many :sinks          # sink / faucet states
  embeds_many :pressures      # pressure plates (cat bed)
  embeds_many :temperatures   # can be inside or outside with many sensors
  embeds_many :humidities     # can have many data points
end