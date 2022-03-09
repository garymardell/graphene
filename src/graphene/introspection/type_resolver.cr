module Graphene
  module Introspection
    struct FieldInfo
      property name : String
      property field : Graphene::Field

      def initialize(@name, @field)
      end
    end

    class TypeResolver < Graphene::Resolver
      # [x] kind must return __TypeKind.NON_NULL.
      # [x] ofType must return a type of any kind except Non-Null.
      # [x] All other fields must return null.
      def resolve(object : Graphene::Types::NonNullType, field_name, argument_values, context, resolution_info)
        case field_name
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      # [x] kind must return __TypeKind.LIST.
      # [x] ofType must return a type of any kind.
      # [x] All other fields must return null.
      def resolve(object : Graphene::Types::ListType, field_name, argument_values, context, resolution_info)
        case field_name
        when "kind"
          object.kind
        when "ofType"
          object.of_type
        end
      end

      # [x] kind must return __TypeKind.OBJECT.
      # [x] name must return a String.
      # [x] description may return a String or null.
      # [x] fields must return the set of fields that can be selected for this type.
      # [x] Accepts the argument includeDeprecated which defaults to false. If true, deprecated fields are also returned.
      # [x] interfaces must return the set of interfaces that an object implements (if none, interfaces must return the empty set).
      # [x] All other fields must return null.
      def resolve(object : Graphene::Types::ObjectType, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "fields"
          if argument_values["includeDeprecated"]?
            object.fields.map do |name, field|
              FieldInfo.new(name, field)
            end
          else
            object.fields.reject { |_, field| field.deprecated? }.map do |name, field|
              FieldInfo.new(name, field)
            end
          end
        when "interfaces"
          object.interfaces
        end
      end

      # [x] kind must return __TypeKind.SCALAR.
      # [x] name must return a String.
      # [x] description may return a String or null.
      # [x] specifiedByURL may return a String (in the form of a URL) for custom scalars, otherwise must be null.
      # [x] All other fields must return null.
      def resolve(object : Graphene::Types::ScalarType, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "specifiedByURL"
          if object.responds_to?(:specified_by_url)
            object.specified_by_url
          end
        end
      end

      # [x] kind must return __TypeKind.ENUM.
      # [x] name must return a String.
      # [x] description may return a String or null.
      # [x] enumValues must return the set of enum values as a list of __EnumValue. There must be at least one and they must have unique names.
      # [x] Accepts the argument includeDeprecated which defaults to false. If true, deprecated enum values are also returned.
      # [x] All other fields must return null.
      def resolve(object : Graphene::Types::EnumType, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "enumValues"
          if argument_values["includeDeprecated"]?
            object.values
          else
            object.values.reject(&.deprecated?)
          end
        end
      end

      # [x] kind must return __TypeKind.UNION.
      # [x] name must return a String.
      # [x] description may return a String or null.
      # [x] possibleTypes returns the list of types that can be represented within this union. They must be object types.
      # [x] All other fields must return null.
      def resolve(object : Graphene::Types::UnionType, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "possibleTypes"
          object.possible_types
        end
      end

      # [x] kind must return __TypeKind.INTERFACE.
      # [x] name must return a String.
      # [x] description may return a String or null.
      # [x] fields must return the set of fields required by this interface.
      # [x] Accepts the argument includeDeprecated which defaults to false. If true, deprecated fields are also returned.
      # [x] interfaces must return the set of interfaces that an object implements (if none, interfaces must return the empty set).
      # [x] possibleTypes returns the list of types that implement this interface. They must be object types.
      # [x] All other fields must return null.
      def resolve(object : Graphene::Types::InterfaceType, field_name, argument_values, context, resolution_info)
        case field_name
        when "name"
          object.name
        when "description"
          object.description
        when "kind"
          object.kind
        when "fields"
          if argument_values["includeDeprecated"]?
            object.fields.map do |name, field|
              FieldInfo.new(name, field)
            end
          else
            object.fields.reject { |_, field| field.deprecated? }.map do |name, field|
              FieldInfo.new(name, field)
            end
          end
        when "interfaces"
          object.interfaces
        when "possibleTypes"
          resolution_info.schema.not_nil!.type_map.each_with_object([] of Graphene::Type) do |(_, type), memo|
            if type.responds_to?(:interfaces) && type.interfaces.includes?(object)
              memo << type
            end
          end
        end
      end

      def resolve(object : Graphene::Types::LateBoundType, field_name, argument_values, context, resolution_info)
        unwrapped_type = get_type(resolution_info.schema, object.typename)

        resolve(unwrapped_type, field_name, argument_values, context, resolution_info)
      end

      private def get_type(schema, typename)
        case typename
        when "__Schema", "__Type", "__InputValue", "__Directive", "__EnumValue", "__Field"
          IntrospectionSystem.types[typename]
        else
          schema.get_type(typename)
        end
      end
    end
  end
end