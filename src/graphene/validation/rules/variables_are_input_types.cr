
module Graphene
  module Validation
    class VariablesAreInputTypes < Rule
      def enter(node : Graphene::Language::Nodes::VariableDefinition, context)
        if variable = node.variable
          type = begin
            context.schema.get_type_from_ast(node.type)
          rescue
            nil
          end

          if type && !type.input_type?
            context.errors << Error.new("#{type.name} isn't a valid input type (on $#{variable.name})")
          end
        end
      end
    end
  end
end