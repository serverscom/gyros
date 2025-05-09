RSpec.describe Gyros::Features::Filterable do
  let(:one_day_ago) { Time.now - 86400 }
  let(:two_days_ago) { Time.now - 172800 }
  let(:three_days_ago) { Time.now - 259200 }
  let(:four_days_ago) { Time.now - 345600 }

  let(:item_1) do
    OpenStruct.new(
      name: 'John',
      email: 'john@example.com',
      role: 'user',
      created_at: one_day_ago
    )
  end

  let(:item_2) do
    OpenStruct.new(
      name: 'Jane',
      email: 'jane@example.com',
      role: 'admin',
      created_at: two_days_ago
    )
  end

  let(:item_3) do
    OpenStruct.new(
      name: 'Bob',
      email: 'bob@example.com',
      role: 'user',
      created_at: three_days_ago
    )
  end

  let(:item_4) do
    OpenStruct.new(
      name: 'Alice',
      email: 'alice@example.com',
      role: 'user',
      created_at: four_days_ago
    )
  end

  let(:data) { [item_1, item_2, item_3, item_4] }

  before { allow(Gyros::Base).to receive(:model).and_return(data) }

  let(:klass) do
    Class.new(Gyros::Base) do
      collection :default do
        scope_for(:list) { self }

        filter :name do |name|
          select { |item| item.name == name }
        end

        filter :role do |role|
          select { |item| item.role == role }
        end

        filter :with_the_same_role do |_, context:|
          select { |item| item.role == context.current_user[:role] }
        end

        nested_filter :created_at do
          filter :from do |time|
            select { |item| item.created_at >= time }
          end

          filter :to do |time|
            select { |item| item.created_at <= time }
          end
        end

        any_of_filter :search_by do |params|
          next self if params.empty?
          
          result = []
          if params[:email]
            result.concat(select { |item| item.email.include?(params[:email]) })
          end
          if params[:name]
            result.concat(select { |item| item.name.downcase.include?(params[:name].downcase) })
          end
          result.uniq
        end
      end
    end
  end

  context Gyros::Filters::Filter do
    it 'applies filter' do
      collection = klass.new(:default)
      expect(collection.apply_with_scope(:list, { name: 'John' })).to eq([item_1])
    end

    context 'with multiple filters' do
      it 'applies multiple filters' do
        collection = klass.new(:default)
        expect(collection.apply_with_scope(:list, { name: 'John', role: 'user' })).to eq([item_1])
      end
    end

    context 'with context' do
      it 'applies filter' do
        collection = klass.new(:default).with_context(OpenStruct.new(current_user: { role: 'admin' }))
        expect(collection.apply_with_scope(:list, { with_the_same_role: true })).to eq([item_2])
      end
    end
  end

  context Gyros::Filters::NestedFilter do
    it 'applies nested filter' do
      collection = klass.new(:default)
      expect(collection.apply_with_scope(:list, { created_at: { from: two_days_ago } })).to eq([item_1, item_2])
    end

    it 'applies nested filter with multiple conditions' do
      collection = klass.new(:default)
      expect(collection.apply_with_scope(:list, { created_at: { from: four_days_ago, to: two_days_ago } })).to eq([item_2, item_3, item_4])
    end

    it 'skips nested filter if parent key is missing' do
      collection = klass.new(:default)
      expect(collection.apply_with_scope(:list, { from: four_days_ago })).to eq(data)
    end
  end

  context Gyros::Filters::AnyOfFilter do
    it 'applies any_of filter with email' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { search_by: { email: '@example' } })
      expect(result).to eq(data)
    end

    it 'applies any_of filter with name' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { search_by: { name: 'jo' } })
      expect(result).to eq([item_1])
    end

    it 'returns empty array when no matches found' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { search_by: { name: 'xyz' } })
      expect(result).to eq([])
    end

    it 'returns original data if no searchable parameters provided' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, { search_by: {} })
      expect(result).to eq(data)
    end
  end

  context 'complex filtering' do
    it 'combines any_of with nested filters' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, {
        search_by: { name: 'jo' },
        created_at: { from: one_day_ago }
      })
      expect(result).to eq([item_1])
    end

    it 'applies multiple filter types in correct order' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, {
        role: 'user',
        created_at: { from: two_days_ago },
        search_by: { email: '@example' }
      })
      expect(result).to eq([item_1])
    end

    it 'handles empty result in filter chain correctly' do
      collection = klass.new(:default)
      result = collection.apply_with_scope(:list, {
        role: 'admin',
        created_at: { from: one_day_ago }
      })
      expect(result).to eq([])
    end
  end
end
