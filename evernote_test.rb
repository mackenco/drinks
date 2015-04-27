require_relative 'evernote_config.rb'

client = EvernoteOAuth::Client.new(token: DEVELOPER_TOKEN, sandbox: false)
note_store = client.note_store
# notebooks = note_store.listNotebooks 
filter = Evernote::EDAM::NoteStore::NoteFilter.new
filter.notebookGuid = "9ad5c9c9-8018-451d-95ed-0c7223983c4e"
results = note_store.findNotes(DEVELOPER_TOKEN, filter, nil, 1000)
results.notes.each do |note|
  puts note.title
  puts note.attributes.sourceURL
end
