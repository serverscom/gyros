# Gyros

Gyros is a powerful Ruby library designed to simplify data handling and querying. It provides a flexible and intuitive way to build complex queries dynamically while keeping your code clean and maintainable.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gyros'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install gyros
```

## Features

### Collection Management
- **Multiple Collections**: Define multiple collections within a single repository for different query contexts
- **Context Awareness**: Pass context data to your queries that can be used by filters and modifiers
- **Deep Cloning**: Collections are safely cloned when modified, preventing unintended side effects

### Scoping System
- **Default Scopes**: Define base conditions that apply to all queries in a collection
- **Action Scopes**: Create specific scopes for different actions (list, show, etc.)
- **Parameterized Scopes**: Scopes can accept parameters for dynamic behavior

### Filtering System

#### Basic Filters
Simple single or multi-parameter filters for exact matching:

```ruby
filter :name do |name|
  where(name: name)
end

filter :role, :active do |role, active|
  where(role: role, active: active)
end
```

#### Nested Filters
Group related filters under a namespace for better organization:

```ruby
nested_filter :created_at do
  filter :from do |date|
    where('created_at >= ?', date)
  end

  filter :to do |date|
    where('created_at <= ?', date)
  end
end
```

#### Any-of Filters
Match any of multiple conditions for flexible searching:

```ruby
any_of_filter :search_by, :email, :phone do |params|
  result = []
  result.concat(where('email LIKE ?', "%#{params[:email]}%")) if params[:email]
  result.concat(where('phone LIKE ?', "%#{params[:phone]}%")) if params[:phone]
  result.uniq
end
```

### Sorting System
- **Field-based Sorting**: Define sortable fields with custom logic
- **Direction Control**: Support for ascending and descending order
- **Context-aware Sorting**: Implement complex sorting logic using context

```ruby
order_by :relevance do |field, direction, context:|
  next self unless context[:query]
  
  order_by_relevance(context[:query])
end
```

### Modifiers System
Modifiers provide a way to customize queries with chainable methods:

- **Basic Modifiers**: Simple query modifications
- **Context-aware Modifiers**: Access context in modifiers
- **Final Modifiers**: Prevent further modifications after application
- **Frozen State Handling**: Safe handling of frozen collections

```ruby
modifier :visible_for do |user|
  if user.admin?
    self
  else
    where.not(role: 'admin')
  end
end

modifier :only_department, final: true do |department|
  where(department: department)
end
```

## Usage Example

First, define your base repository:

```ruby
class BaseRepository < Gyros::Base
  def list(params = {})
    apply_with_scope(:list, params)
  end

  def show(id, params = {})
    apply_with_scope(:show, params).find(id)
  end
end
```

Then create your specific repository:

```ruby
class UserRepository < BaseRepository
  model { User.all }

  collection :default do
    # Default scope for all queries
    default_scope do
      where(deleted_at: nil)
    end

    # Modifiers
    modifier :visible_for do |user|
      if user.admin?
        self
      else
        where.not(role: 'admin')
      end
    end

    # Scopes
    scope_for(:list) do
      where(active: true)
    end

    # Sorting
    order_by :name, :email, :created_at do |field, direction|
      order(field => direction)
    end

    # Basic filters
    filter :role do |role|
      where(role: role)
    end

    # Nested filters
    nested_filter :date_range do
      filter :from do |date|
        where('created_at >= ?', date)
      end

      filter :to do |date|
        where('created_at <= ?', date)
      end
    end

    # Any-of filters
    any_of_filter :search do |params|
      next self if params.empty?
      
      result = []
      result.concat(where('email LIKE ?', "%#{params[:email]}%")) if params[:email]
      result.concat(where('name LIKE ?', "%#{params[:name]}%")) if params[:name]
      result.uniq
    end
  end
end
```

Use your repository:

```ruby
repository = UserRepository.new(:default)
  .visible_for(current_user)
  .with_context(query: 'search term')

# Apply filters, sorting and scopes
users = repository.list(
  role: 'manager',
  date_range: { from: 1.month.ago, to: Time.now },
  search: { email: '@company.com' },
  sort: 'created_at',
  dir: :desc
)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
