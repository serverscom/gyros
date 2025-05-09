require 'spec_helper'
require 'ostruct'

RSpec.describe Gyros::Features::Sortable do
  let(:item_1) do
    OpenStruct.new(
      id: 1,
      name: 'John',
      email: 'john@example.com',
      created_at: Time.new(2025, 1, 1),
      score: 100
    )
  end

  let(:item_2) do
    OpenStruct.new(
      id: 2,
      name: 'Alice',
      email: 'alice@example.com',
      created_at: Time.new(2025, 2, 1),
      score: 50
    )
  end

  let(:item_3) do
    OpenStruct.new(
      id: 3,
      name: 'Bob',
      email: 'bob@example.com',
      created_at: Time.new(2025, 3, 1),
      score: 75
    )
  end

  let(:data) { [item_1, item_2, item_3] }

  before { allow(Gyros::Base).to receive(:model).and_return(data) }

  let(:klass) do
    Class.new(Gyros::Base) do
      collection :default do
        scope_for(:list) { self }

        # Базовая сортировка по одному полю
        order_by :name do |field, direction|
          direction == :asc ? 
            sort_by { |item| item.name } :
            sort_by { |item| item.name }.reverse
        end

        # Сортировка по числовому полю
        order_by :score do |field, direction|
          direction == :asc ?
            sort_by { |item| item.score } :
            sort_by { |item| item.score }.reverse
        end

        # Сортировка по дате
        order_by :created_at do |field, direction|
          direction == :asc ?
            sort_by { |item| item.created_at } :
            sort_by { |item| item.created_at }.reverse
        end

        # Сортировка с учетом контекста
        order_by :relevance do |field, direction, context:|
          next self unless context[:query]
          
          # Сортировка по релевантности относительно поискового запроса
          sort_by do |item|
            [
              -(item.name.downcase.include?(context[:query].downcase) ? 1 : 0),
              item.name
            ]
          end
        end
      end
    end
  end

  describe 'basic sorting' do
    it 'sorts by string field ascending' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :name, dir: :asc })
      expect(result.map(&:name)).to eq(['Alice', 'Bob', 'John'])
    end

    it 'sorts by string field descending' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :name, dir: :desc })
      expect(result.map(&:name)).to eq(['John', 'Bob', 'Alice'])
    end

    it 'sorts by numeric field' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :score, dir: :desc })
      expect(result.map(&:score)).to eq([100, 75, 50])
    end

    it 'sorts by date field' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :created_at, dir: :asc })
      expect(result.map(&:name)).to eq(['John', 'Alice', 'Bob'])
    end
  end

  describe 'sorting with context' do
    it 'sorts by relevance using context' do
      collection = klass.new(:default)
      collection.with_context(query: 'bob')
      result = collection.apply_with_scope(:list, { sort: :relevance })
      expect(result.first.name).to eq('Bob')
    end

    it 'returns original order if context is missing' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :relevance })
      expect(result).to eq(data)
    end
  end

  describe 'sorting behavior' do
    it 'uses ascending direction by default' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :name })
      expect(result.map(&:name)).to eq(['Alice', 'Bob', 'John'])
    end

    it 'ignores invalid sort field' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :invalid_field })
      expect(result).to eq(data)
    end

    it 'ignores invalid direction' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { sort: :name, dir: :invalid })
      expect(result.map(&:name)).to eq(['Alice', 'Bob', 'John'])
    end

    it 'preserves original data if no sort params' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, {})
      expect(result).to eq(data)
    end
  end
end