require "./member"

module Graphql
  class Schema
    class NonNull < Member
      getter of_type : Graphql::Schema::Member

      def initialize(@of_type : Graphql::Schema::Member)
      end
    end
  end
end
