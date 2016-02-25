module LiveEditor
  module CLI
    module Validators
      class Validator
        # Attributes
        attr_accessor :messages

        # Constructor.
        def initialize
          @messages = []
        end

        # Returns all messages with a type of `:error`.
        def errors
          self.messages.select { |error| error[:type] == :error }
        end

        # Returns all messages with a type of `:warning`.
        def warnings
          self.messages.select { |error| error[:type] == :warning }
        end
      end
    end
  end
end
