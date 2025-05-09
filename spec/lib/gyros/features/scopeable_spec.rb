require 'spec_helper'
require 'ostruct'

RSpec.describe Gyros::Features::Scopeable do
  let(:item_1) do
    OpenStruct.new(
      id: 1,
      name: 'John',
      role: 'admin',
      deleted_at: nil,
      active: true
    )
  end

  let(:item_2) do
    OpenStruct.new(
      id: 2,
      name: 'Alice',
      role: 'user',
      deleted_at: Time.now,
      active: true
    )
  end

  let(:item_3) do
    OpenStruct.new(
      id: 3,
      name: 'Bob',
      role: 'user',
      deleted_at: nil,
      active: false
    )
  end

  let(:data) { [item_1, item_2, item_3] }

  before { allow(Gyros::Base).to receive(:model).and_return(data) }

  let(:klass) do
    Class.new(Gyros::Base) do
      collection :default do
        # Base scope for all queries
        default_scope do
          select { |item| item.deleted_at.nil? }
        end

        # Main scope for list
        scope_for(:list) do
          select { |item| item.active }
        end

        # Scope with parameters
        scope_for(:by_role) do |scope|
          scope.select { |item| item.role == 'admin' }
        end

        # Multiple scopes
        scope_for(:active_admins) do
          select { |item| item.role == 'admin' }
        end

        scope_for(:active_admins) do
          select { |item| item.active }
        end

        # Scope for different methods
        scope_for(:admins, :users) do
          select { |item| ['admin', 'user'].include?(item.role) }
        end
      end
    end
  end

  describe 'default scope' do
    it 'applies default scope to all queries' do
      collection = klass.new(:default)
      result = collection.scope_for(:list)
      expect(result.map(&:name)).to contain_exactly('John')
    end

    it 'stacks with other scopes' do
      collection = klass.new(:default)
      result = collection.scope_for(:by_role)
      expect(result.map(&:name)).to contain_exactly('John')
    end
  end

  describe 'basic scopes' do
    it 'applies scope without parameters' do
      collection = klass.new(:default)
      result = collection.scope_for(:list)
      expect(result.map(&:name)).to contain_exactly('John')
    end

    it 'applies scope with parameters' do
      collection = klass.new(:default)
      result = collection.scope_for(:by_role)
      expect(result.map(&:name)).to contain_exactly('John')
    end
  end

  describe 'multiple scopes' do
    it 'applies multiple scopes for same method in order' do
      collection = klass.new(:default)
      result = collection.scope_for(:active_admins)
      expect(result.map(&:name)).to contain_exactly('John')
    end

    it 'applies same scope to multiple methods' do
      collection = klass.new(:default)
      admins_result = collection.scope_for(:admins)
      users_result = collection.scope_for(:users)
      
      expect(admins_result).to eq(users_result)
      expect(admins_result.map(&:name)).to contain_exactly('John', 'Bob')
    end
  end

  describe 'scope chaining' do
    it 'preserves scope chain order' do
      collection = klass.new(:default)
      # default_scope -> active_admins (role) -> active_admins (active)
      result = collection.scope_for(:active_admins)
      expect(result.map(&:name)).to contain_exactly('John')
    end
  end
end