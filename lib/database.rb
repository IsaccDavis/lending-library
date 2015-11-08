require 'sequel'

DB = Sequel.connect('sqlite://library.db')


Sequel::Model.plugin :json_serializer

# If you want to delete the tables and remake them change the ? to a !
# The ? makes tables if they don't exist
DB.create_table? :books do
  primary_key :book_id
  String :title, :text=>true
  String :subtitle, :text=>true
  String :author
  String :isbn
  String :edition
  String :publication_year
  Integer :user_id
  String :location
end

DB.create_table? :checkouts do
  primary_key :checkout_id
  Integer :book_id
  Integer :user_id
  Date :checkout_date
  Date :due_date
  Date :return_date
  Integer :return_condition
end

DB.create_table? :@users do
  primary_key :user_id
  String :username
  String :email
  String :password
  String :password_reset_hash
  String :token
  Integer :permissions
  String :first_name
  String :last_name
  String :location
end

class Books < Sequel::Model
end

class Checkouts < Sequel::Model
end

class Users < Sequel::Model
end

class Database
  # Start Database API
  def self.addBook(title, subtitle, author, isbn, edition, publication_year, user_id, location)
    query = 'INSERT INTO books (title, subtitle, author, isbn, edition, publication_year, user_id, location)'
    query += "VALUES ('#{title}', '#{subtitle}', '#{author}', '#{isbn}', '#{edition}', '#{publication_year}', #{user_id}, '#{location}')"
    dataset = DB[query].all
    dataset.to_json
    return dataset.to_s
  end

  def self.removeBook(book_id)
    dataset = DB["DELETE FROM books where book_id = #{book_id}"].all
    dataset.to_json
    return dataset.to_s
  end

  # Get Info for a Single Book
  def self.getBook(book_id)
    dataset = DB["SELECT b.*, u.first_name, u.last_name FROM books b join users u on u.user_id = b.user_id WHERE b.book_id = #{book_id}"].all
    dataset.to_json
    return dataset.to_s
  end

  # Get all books in DB
  def self.getBooks()
    dataset= DB['SELECT b.*, u.first_name, u.last_name FROM books b join users u on u.user_id = b.user_id'].all
    dataset.to_json
    return dataset.to_s
  end

  # Get all books a certain user owns
  def self.getUserBooks(user_id)
    dataset= DB["SELECT b.*, u.first_name, u.last_name FROM books b join users u on u.user_id = b.user_id WHERE b.user_id = #{user_id}"].all
    dataset.to_json
    return dataset.to_s
  end

  # Search All books by a field and search text
  def self.searchBooks(search_field, search_by)
    dataset= DB["SELECT b.*, u.first_name, u.last_name FROM books b join users u on u.user_id = b.user_id where b.#{search_field} like '%#{search_by}%'"].all
    dataset.to_json
    return dataset.to_s
  end

  # Search All books by titles
  def self.searchBooksByTitle(search_by)
    dataset = DB["SELECT b.*, u.first_name, u.last_name FROM books b join users u on u.user_id = b.user_id where b.title like '%#{search_by}%' or b.subtitle like '%#{search_by}%'"].all
    dataset.to_json
    return dataset.to_s
  end

  ## Checkout Related
  def self.getCheckout(checkout_id)
    dataset= DB["SELECT c.*, b.title, b.subtitle, u.first_name, u.last_name FROM ((checkouts c ((join users u on u.user_id = c.user_id) join books b on b.book_id = c.book_id) WHERE c.checkout_id = #{checkout_id}"].all
    dataset.to_json
    return dataset.to_s
  end

  def self.getUserCheckouts(user_id)
    dataset= DB["SELECT c.*, b.title, b.subtitle, u.first_name, u.last_name FROM ((checkouts c join users u on u.user_id = c.user_id) join books b on b.book_id = c.book_id) WHERE c.user_id = #{user_id}"].all
    dataset.to_json
    return dataset.to_s
  end

  def self.getCheckouts()
    dataset= DB['SELECT c.*, b.title, b.subtitle, u.first_name, u.last_name FROM ((checkouts c join users u on u.user_id = c.user_id) join books b on b.book_id = c.book_id)'].all
    dataset.to_json
    return dataset.to_s
  end

  def self.checkoutBook(book_id, user_id, checkout_date, due_date)
    dataset = DB["INSERT INTO checkouts (book_id, user_id, checkout_date, due_date) VALUES (#{book_id}, #{user_id}, '#{checkout_date}', '#{due_date}')"].all
    dataset.to_json
    return dataset.to_s
  end

  def self.returnBook(checkout_id, return_date, return_condition)
    dataset = DB["UPDATE checkouts SET return_date = '#{return_date}', return_condition = #{return_condition} WHERE checkout_id = #{checkout_id}"].all
    dataset.to_json
    return dataset.to_s
  end
  # End Database API
end
