require "../../spec_helper"

describe Graphene::Validation::AllVariableUsesDefined do
  it "example #173" do
    query_string = <<-QUERY
      query variableIsDefined($atOtherHomes: Boolean) {
        dog {
          isHouseTrained(atOtherHomes: $atOtherHomes)
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::AllVariableUsesDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end

  it "counter example #174" do
    query_string = <<-QUERY
      query variableIsNotDefined {
        dog {
          isHouseTrained(atOtherHomes: $atOtherHomes)
        }
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::AllVariableUsesDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Variable \"atOtherHomes\" has not been defined"))
  end

  it "example #175" do
    query_string = <<-QUERY
      query variableIsDefinedUsedInSingleFragment($atOtherHomes: Boolean) {
        dog {
          ...isHouseTrainedFragment
        }
      }

      fragment isHouseTrainedFragment on Dog {
        isHouseTrained(atOtherHomes: $atOtherHomes)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::AllVariableUsesDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end

  it "counter example #176" do
    query_string = <<-QUERY
      query variableIsNotDefinedUsedInSingleFragment {
        dog {
          ...isHouseTrainedFragment
        }
      }

      fragment isHouseTrainedFragment on Dog {
        isHouseTrained(atOtherHomes: $atOtherHomes)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::AllVariableUsesDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Variable \"atOtherHomes\" has not been defined"))
  end

  it "counter example #177" do
    query_string = <<-QUERY
      query variableIsNotDefinedUsedInNestedFragment {
        dog {
          ...outerHouseTrainedFragment
        }
      }

      fragment outerHouseTrainedFragment on Dog {
        ...isHouseTrainedFragment
      }

      fragment isHouseTrainedFragment on Dog {
        isHouseTrained(atOtherHomes: $atOtherHomes)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::AllVariableUsesDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Variable \"atOtherHomes\" has not been defined"))
  end

  it "example #178" do
    query_string = <<-QUERY
      query houseTrainedQueryOne($atOtherHomes: Boolean) {
        dog {
          ...isHouseTrainedFragment
        }
      }

      query houseTrainedQueryTwo($atOtherHomes: Boolean) {
        dog {
          ...isHouseTrainedFragment
        }
      }

      fragment isHouseTrainedFragment on Dog {
        isHouseTrained(atOtherHomes: $atOtherHomes)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::AllVariableUsesDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(0)
  end

  it "counter example #179" do
    query_string = <<-QUERY
      query houseTrainedQueryOne($atOtherHomes: Boolean) {
        dog {
          ...isHouseTrainedFragment
        }
      }

      query houseTrainedQueryTwoNotDefined {
        dog {
          ...isHouseTrainedFragment
        }
      }

      fragment isHouseTrainedFragment on Dog {
        isHouseTrained(atOtherHomes: $atOtherHomes)
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::AllVariableUsesDefined.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Error.new("Variable \"atOtherHomes\" has not been defined"))
  end
end