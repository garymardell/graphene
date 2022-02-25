require "../../src/graphene"
require "./models/*"
require "./resolvers/*"

class TransactionTypeResolver < Graphene::TypeResolver
  def resolve_type(object : Charge, context)
    ChargeType
  end

  def resolve_type(object : Refund, context)
    RefundType
  end
end

TransactionInterface = Graphene::Types::Interface.new(
  name: "Transaction",
  type_resolver: TransactionTypeResolver.new,
  fields: [
    Graphene::Field.new(
      name: "id",
      type: Graphene::Types::Id.new
    ),
    Graphene::Field.new(
      name: "reference",
      type: Graphene::Types::String.new
    )
  ]
)

ChargeType = Graphene::Types::Object.new(
  name: "Charge",
  resolver: ChargeResolver.new,
  interfaces: [TransactionInterface],
  fields: [
    Graphene::Field.new(
      name: "status",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::Enum.new(
          name: "ChargeStatus",
          values: [
            Graphene::Types::EnumValue.new(name: "PENDING", value: "pending"),
            Graphene::Types::EnumValue.new(name: "PAID", value: "paid")
          ]
        )
      )
    ),
    Graphene::Field.new(
      name: "refund",
      type: RefundType
    )
  ]
)

RefundType = Graphene::Types::Object.new(
  name: "Refund",
  resolver: RefundResolver.new,
  interfaces: [TransactionInterface],
  fields: [
    Graphene::Field.new(
      name: "status",
      type: Graphene::Types::Enum.new(
        name: "RefundStatus",
        values: [
          Graphene::Types::EnumValue.new(name: "PENDING", value: "pending"),
          Graphene::Types::EnumValue.new(name: "REFUNDED", value: "refunded")
        ]
      )
    ),
    Graphene::Field.new(
      name: "partial",
      type: Graphene::Types::Boolean.new
    ),
    Graphene::Field.new(
      name: "payment_method",
      type: PaymentMethodType
    )
  ]
)

CreditCardType = Graphene::Types::Object.new(
  name: "CreditCard",
  resolver: CreditCardResolver.new,
  fields: [
    Graphene::Field.new(
      name: "id",
      type: Graphene::Types::Id.new
    ),
    Graphene::Field.new(
      name: "last4",
      type: Graphene::Types::String.new
    )
  ]
)

BankAccountType = Graphene::Types::Object.new(
  name: "BankAccount",
  resolver: BankAccountResolver.new,
  fields: [
    Graphene::Field.new(
      name: "id",
      type: Graphene::Types::Id.new
    ),
    Graphene::Field.new(
      name: "accountNumber",
      type: Graphene::Types::String.new
    )
  ]
)

class PaymentMethodTypeResolver < Graphene::TypeResolver
  def resolve_type(object : CreditCard, context)
    CreditCardType
  end

  def resolve_type(object : BankAccount, context)
    BankAccountType
  end
end

PaymentMethodType = Graphene::Types::Union.new(
  name: "PaymentMethod",
  type_resolver: PaymentMethodTypeResolver.new,
  possible_types: [
    CreditCardType.as(Graphene::Type),
    BankAccountType.as(Graphene::Type)
  ]
)

DummySchema = Graphene::Schema.new(
  query: Graphene::Types::Object.new(
    name: "Query",
    resolver: QueryResolver.new,
    fields: [
      Graphene::Field.new(
        name: "charge",
        type: Graphene::Types::NonNull.new(of_type: ChargeType),
        arguments: [
          Graphene::Argument.new(
            name: "id",
            type: Graphene::Types::Id.new
          )
        ]
      ),
      Graphene::Field.new(
        name: "charges",
        type: Graphene::Types::NonNull.new(
          of_type: Graphene::Types::List.new(of_type: ChargeType)
        )
      ),
      Graphene::Field.new(
        name: "transactions",
        type: Graphene::Types::NonNull.new(
          of_type: Graphene::Types::List.new(of_type: TransactionInterface)
        )
      ),
      Graphene::Field.new(
        name: "paymentMethods",
        type: Graphene::Types::NonNull.new(
          of_type: Graphene::Types::List.new(of_type: PaymentMethodType)
        )
      ),
      Graphene::Field.new(
        name: "nullList",
        type: Graphene::Types::List.new(
          of_type: Graphene::Types::NonNull.new(of_type: ChargeType)
        )
      )
    ]
  ),
  mutation: nil,
  orphan_types: [
    RefundType.as(Graphene::Type)
  ]
)