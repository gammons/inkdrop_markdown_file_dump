require "./notes.rb"

desc "Exports Inkdrop content to a directory, as markdown files."
task :export do
  i = Inkdrop.new
  p "Getting books..."
  i.get_books

  p "Getting notes..."
  i.get_notes

  p "Creating book directories..."
  i.create_book_directories

  p "Creating note files..."
  i.create_note_files
end
