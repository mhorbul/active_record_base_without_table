require File.dirname(__FILE__) + '/abstract_unit'

class Person < ActiveRecord::BaseWithoutTable
  column :name, :string
  column :lucky_number, :integer, 4

  validates_presence_of :name
end

class AnotherPerson < Person
  column :lucky_number, :integer, 3
  column :login, :string

  validates_presence_of :login
end

class ActiveRecordBaseWithoutTableTest < Test::Unit::TestCase
  def test_default_value
    assert_equal 3, AnotherPerson.new.lucky_number
    assert_equal 4, Person.new.lucky_number
  end

  def test_validation
    p1 = Person.new
    p2 = AnotherPerson.new

    assert !p1.save
    assert !p2.save

    assert p1.errors[:name]
    assert p2.errors[:name]

    assert_nil p1.errors[:login]
    assert p2.errors[:login]

    assert p1.update_attributes(:name => 'Name')
    assert p2.update_attributes(:name => 'Name', :login => "Login")
  end

  def test_typecast
    assert_equal 1, Person.new(:lucky_number => "1").lucky_number
    assert_equal 2, AnotherPerson.new(:lucky_number => "2").lucky_number
  end

  def test_cached_column_variables_reset_when_column_defined
    cached_variables = %w(column_names columns_hash content_columns dynamic_methods_hash generated_methods)

    Person.column_names
    Person.columns_hash
    Person.content_columns
    Person.column_methods_hash
    Person.generated_methods

    cached_variables.each { |v| assert_not_nil Person.instance_variable_get("@#{v}") }
    Person.column :new_column, :string
    cached_variables.each { |v| assert Person.instance_variable_get("@#{v}").blank? }
  end
end
