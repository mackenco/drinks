require_relative 'evernote_config.rb'

class String
  def titleize
    self.split.map(&:capitalize).join(' ')
  end
end

class Pantry
  attr_accessor :data, :source

  def initialize(source)
    @source = source
    @data = JSON.parse(File.read(source)).sort
  end

  def sort
    @data.sort
  end

  def add(ingredient)
    @data << ingredient
    File.write(@source, @data.uniq.sort.to_json, { mode: "w+" } )
    self
  end

  def remove(ingredient)
    @data.delete(ingredient)
    File.write(@source, @data.to_json, { mode: "w+" } )
    self
  end
end

class Recipes
  attr_accessor :data, :source

  def initialize(source)
    @source = source
    @data = JSON.parse(File.read(source))
  end

  def all_ingredients
    @data.values.flatten.uniq
  end

  def sort
    @data.sort
  end

  def titles
    @data.keys.map(&:titleize)
  end

  def add(name, ingredients)
    @data[name] = ingredeints
    File.write(@source, @data.to_json, { mode: "w+" } )
    self
  end
end

class EvernoteData

  attr_accessor :data

  def initialize

    client = EvernoteOAuth::Client.new(token: DEVELOPER_TOKEN, sandbox: false)
    note_store = client.note_store
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.notebookGuid = "9ad5c9c9-8018-451d-95ed-0c7223983c4e"
    drink_notes = note_store.findNotes(DEVELOPER_TOKEN, filter, nil, 1000)
    @data = {}
    drink_notes.notes.map do |note|
      title = note.title.split("|")
      if title[1]
        made = title[1].include?("X")
        favorite = title[1].include?("!")
      end

      @data[title[0].strip] = {
        url: note.attributes.sourceURL,
        made: made || false,
        favorite: favorite || false
      }
    end
  end

  def titles
    @data.keys.map(&:titleize)
  end
end
