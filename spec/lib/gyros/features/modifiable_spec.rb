require 'spec_helper'
require 'ostruct'

RSpec.describe Gyros::Features::Modifiable do
  let(:item_1) do
    OpenStruct.new(
      id: 1,
      name: 'John',
      role: 'admin',
      department: 'IT'
    )
  end

  let(:item_2) do
    OpenStruct.new(
      id: 2,
      name: 'Alice',
      role: 'user',
      department: 'HR'
    )
  end

  let(:item_3) do
    OpenStruct.new(
      id: 3,
      name: 'Bob',
      role: 'user',
      department: 'IT'
    )
  end

  let(:data) { [item_1, item_2, item_3] }

  before { allow(Gyros::Base).to receive(:model).and_return(data) }

  let(:klass) do
    Class.new(Gyros::Base) do
      collection :default do
        scope_for(:list) { self }

        # Basic modifier
        modifier :by_department do |department|
          select { |item| item.department == department }
        end

        # Modifier with context
        modifier :visible_for do |user|
          if user[:role] == 'admin'
            self
          else
            select { |item| item.role != 'admin' }
          end
        end

        # Final modifier
        modifier :only_department, final: true do |department|
          select { |item| item.department == department }
        end

        # Modifier with multiple arguments
        modifier :with_roles do |*roles|
          select { |item| roles.include?(item.role) }
        end
      end
    end
  end

  describe 'basic modifiers' do
    it 'applies simple modifier' do
      collection = klass.new(:default)
      result = collection.by_department('IT').apply_with_scope(:list, {})
      expect(result.map(&:name)).to contain_exactly('John', 'Bob')
    end

    it 'applies modifier with context' do
      collection = klass.new(:default)
      admin_result = collection.visible_for(role: 'admin').apply_with_scope(:list, {})
      user_result = collection.visible_for(role: 'user').apply_with_scope(:list, {})

      expect(admin_result.size).to eq(3)
      expect(user_result.map(&:role)).not_to include('admin')
    end

    it 'applies modifier with multiple arguments' do
      collection = klass.new(:default)
      result = collection.with_roles('admin', 'user').apply_with_scope(:list, {})
      expect(result).to eq(data)
    end
  end

  describe 'modifier chaining' do
    it 'allows chaining multiple modifiers' do
      collection = klass.new(:default)
      result = collection
        .by_department('IT')
        .visible_for(role: 'user')
        .apply_with_scope(:list, {})

      expect(result.map(&:name)).to contain_exactly('Bob')
    end

    it 'prevents modifiers after final modifier' do
      collection = klass.new(:default)
      collection = collection.only_department('IT')

      expect {
        collection.by_department('HR')
      }.to raise_error(/No more modifiers can be applied/)
    end
  end

  describe 'deep duplication' do
    it 'creates independent copies when chaining' do
      collection = klass.new(:default)
      it_dept = collection.by_department('IT')
      hr_dept = collection.by_department('HR')

      it_result = it_dept.apply_with_scope(:list, {})
      hr_result = hr_dept.apply_with_scope(:list, {})

      expect(it_result.map(&:name)).to contain_exactly('John', 'Bob')
      expect(hr_result.map(&:name)).to contain_exactly('Alice')
    end

    it 'preserves finalized state in copies' do
      collection = klass.new(:default)
      finalized = collection.only_department('IT')
      copy = finalized.dup

      expect {
        copy.by_department('HR')
      }.to raise_error(/No more modifiers can be applied/)
    end
  end

  describe 'frozen collections' do
    it 'creates new instance when applying modifier to frozen collection' do
      collection = klass.new(:default).freeze
      modified = collection.by_department('IT')

      expect(modified).not_to be_frozen
      expect(collection).to be_frozen
    end

    it 'preserves modifications in new instance' do
      collection = klass.new(:default).freeze
      modified = collection.by_department('IT')
      result = modified.apply_with_scope(:list, {})

      expect(result.map(&:name)).to contain_exactly('John', 'Bob')
    end
  end
end