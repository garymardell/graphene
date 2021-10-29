module Graphene
  class Schema
    module Directives
      class SkipDirective < Graphene::Schema::Directive
        def name : String
          "skip"
        end

        def arguments : Array(Graphene::Schema::Argument)
          [
            Graphene::Schema::Argument.new(
              name: "if",
              type: Graphene::Type::NonNull.new(
                of_type: Graphene::Type::Boolean.new
              )
            )
          ]
        end

        def locations : Array(Directive::Location)
          [Directive::Location::FIELD, Directive::Location::FRAGMENT_SPREAD, Directive::Location::INLINE_FRAGMENT]
        end

        def include?(object, context, argument_values) : Bool
          !argument_values["if"]
        end
      end
    end
  end
end