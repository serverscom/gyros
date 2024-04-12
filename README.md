# Gyros

Gyros is a Ruby library designed to simplify data handling, specifically focusing on streamlining data filtering processes. This library provides an intuitive way to manage and query data efficiently.

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

- **Scope Management:** Gyros allows for the comprehensive management of scopes, enabling you to define and apply different data scopes based on your requirements.

- **Dynamic Filtering:** The library provides the ability to create dynamic filters that can adjust based on the parameters passed, facilitating a more flexible data querying experience.

- **Sorting Capabilities:** With Gyros, you have the control to define sorting logic, ensuring that your data is presented in the order you need.

- **Use of Modifiers:** Enhance your queries with modifiers, allowing for additional customization and refinement of the returned data sets.

- **Code Organization with Collections:** Gyros supports the organization of your code through the use of different collections, enabling a cleaner and more modular approach to data handling.

## Usage

Define base class:

```ruby
class BaseRepository < Gyros::Base
  def list(params = {})
    apply_with_scope(:list, params)
  end

  def show!(id, params = {})
    apply_with_scope(:show, params).find(id)
  end
end
```

Desribe your repository:

```ruby
class UserRepository < BaseRepository
  model { User.all }

  collection :default do
    # Define default conditions for all queries in collection
    default_scope do
      where(deleted_at: nil)
    end

    modifier :visible do |user|
      if user.admin?
        self
      else
        user.where.not(role: 'admin')
      end
    end

    scope_for(:show) do
      # Apply something for the show query
    end

    scope_for(:list) do
      # Apply something for the list query
    end

    # Define sortable fields
    %i[id name email created_at updated_at].each do |key|
      order_by(key) do |_column, dir|
      	order(key => dir)
      end
    end

    # Define filters
    filter :email do |email|
      where('email ILIKE ?', "%#{email}%")
    end

    filter :created_from do |from|
      where('created_at >= ?', from)
    end

    filter :created_to do |to|
      where('created_at <= ?', to)
    end
  end
end
```

Use it:

```ruby
repository = UserRepository.new(:default).visible(current_user)
repository.list(email: '@example.com', created_from: 1.year.ago, created_to: Time.now, sort: 'created_at', dir: :desc) 
```

## License

The gem is available as open source under the terms of the MIT License.
