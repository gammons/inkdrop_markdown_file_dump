require "http"
require "byebug"
# require "dir"

# get all docs
# http://admin:password@127.0.0.1:5984/inkdrop/_all_docs

# get all books
# http://admin:password@127.0.0.1:5984/inkdrop/_design/index_books/_view/index_books

# get all notes
# http://admin:password@127.0.0.1:5984/inkdrop/_design/index_notes/_view/index_notes

class Book
  attr_accessor :id, :parent_book_id, :name, :created_at, :updated_at, :children, :directory_name

  def initialize(attrs)
    @id = attrs[:id]
    @parent_book_id = attrs[:parent_book_id]
    @name = attrs[:name]
    @created_at = attrs[:created_at]
    @updated_at = attrs[:updated_at]
    @children = []
  end
end

class Books
  include Enumerable

  attr_accessor :members

  def initialize
    @members = []
  end

  def each &block
    @members.each{|member| block.call(member) }
  end

  def << book
    @members.push(book)
  end

  def build_hierarchy
    books.each do |book|
      parent = books.find {|b| b.id == book.parent_book_id }
      parent.children << book if parent
    end
  end

  def directory_name(book)
    dn = [book.name]
    while !book.parent_book_id.nil? do
      book = members.find{|b| b.id == book.parent_book_id }
      dn.push(book.name)
    end
    dn.reverse.join("/")
  end
end

class Note
  attr_accessor :id, :book_id, :created_at, :updated_at, :name, :body

  def initialize(attrs)
    @id = attrs[:id]
    @book_id = attrs[:book_id]
    @created_at = attrs[:created_at]
    @updated_at = attrs[:updated_at]
    @name = attrs[:name]
    @body = attrs[:body]
  end
end

class Inkdrop
  attr_accessor :books, :notes
  def initialize
    @books = Books.new
    @notes = []
  end

  def get_books
    res = fetch("http://admin:password@127.0.0.1:5984/inkdrop/_design/index_books/_view/index_books")
    res["rows"].each do |doc|
      res = fetch("http://admin:password@127.0.0.1:5984/inkdrop/#{doc['id']}")
      books << Book.new(
        id: res["_id"],
        parent_book_id: res["parentBookId"],
        name: res["name"],
        created_at: Time.at(res["createdAt"][0..9].to_i),
        updated_at: Time.at(res["updatedAt"][0..9].to_i),
      )
    end
  end

  def get_notes
    res = fetch("http://admin:password@127.0.0.1:5984/inkdrop/_design/index_notes/_view/index_notes")
    res["rows"].each do |doc|
      res = fetch("http://admin:password@127.0.0.1:5984/inkdrop/#{doc['id']}")
      notes << Note.new(
        id: res["_id"],
        book_id: res["bookId"],
        name: res["title"],
        body: res["body"],
        created_at: Time.at(res["createdAt"][0..9].to_i),
        updated_at: Time.at(res["updatedAt"][0..9].to_i),
      )
    end

  end

  def create_book_directories
    initialize_directory

    # start with books with no parent id
    books.each do |book|
      system "mkdir -p 'inkdrop/#{books.directory_name(book)}'"
    end
  end

  def create_note_files
    notes.each do |note|
      book = books.find{|b| b.id == note.book_id }
      directory = books.directory_name(book)

      f = File.open("inkdrop/#{directory}/#{note.name}","w")
      f << note.body
      f.close
    end
  end

  private

  def fetch(url)
    res = HTTP.basic_auth(user: "admin", pass: "password").get(url)
    JSON.parse(res.body.to_s)
  end

  def initialize_directory
    if Dir.exists?("inkdrop")
      raise RuntimeError, "The inkdrop dir exists.  Please remove it before continuing"
    end

    Dir.mkdir("inkdrop")
  end
end

i = Inkdrop.new
i.get_books
i.get_notes
i.create_book_directories
i.create_note_files


