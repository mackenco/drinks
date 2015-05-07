require 'json'
require 'colorize'
require 'readline'
require 'launchy'
require_relative 'data_classes'

@pantry = Pantry.new("pantry.json")
@recipes = Recipes.new("recipes.json") 
@all_ingreds = @recipes.all_ingredients 
@evernote_drinks = EvernoteData.new

def add_drink(name)
  ingreds = []

  comp = proc { |s| @all_ingreds.grep( /^#{Regexp.escape(s)}/) }
  Readline.completion_proc = comp
  Readline.completion_append_character = ""

  while (true)
    puts "[ingredient] | quit"
    input = Readline.readline('', true)
    break if input == "quit" || input == "q"

    if (@all_ingreds.include?(input))
      ingreds << input
    else
      puts "are you sure you want to add a new ingredient? [y] | [n]"
      action = gets.chomp
      ingreds << input if action == "y"
    end
  end

  @recipes = @recipes.add(name, ingreds)
  puts ""
  p "#{name} - #{ingreds.join(", ")}"
end

def print_recipes(recipes)
  recipes.each_with_index do |(name, ingreds), i|
    made = @evernote_drinks[name][:made]
    favorite = @evernote_drinks[name][:favorite]

    if favorite
      bkg, color = :blue, :light_white
    elsif !made
      bkg, color = :black, :red
    else
      bkg, color = :black, :light_blue
    end

    print "#{i + 1}. #{name}".ljust(25).colorize(background: bkg, color: color)

    part = ingreds.partition { |ing| @pantry.data.include?(ing)}
    print " #{part[1].map(&:upcase).join(", ")}".yellow
    print " "
    print "#{part[0].join(", ")}".white
    puts ""
  end
end

while (true)

  unsynced = @evernote_drinks.titles - @recipes.titles
  if (unsynced.length > 0)
    puts "You have not synced \(press number to sync\):".red
    unsynced.each_with_index do |name, i| 
      print "#{i + 1}.".ljust(3).light_yellow
      print "#{name}".light_yellow
      puts ""
    end
  end

  puts ""
  puts "[m]ake | [p]antry | [r]ecipe | [q]uit"
  selection = gets.chomp.split(" ")
  action = selection[0].downcase[0]

  if action.to_i > 0
    drink = unsynced[action.to_i - 1]
    Launchy.open(@evernote_drinks[drink][:url])
    add_drink(drink) if drink

  elsif action == "m"
    ingredient = selection[1]

    puts ""
    puts "You can make (Enter number for recipe)"

    makeable = @recipes.missing_ingredients(@pantry, 0, ingredient)
    one_off = @recipes.missing_ingredients(@pantry, 1, ingredient)

    print_recipes(makeable)
    puts ""

    if (one_off.length > 0)
      puts "You are one off from:"
      print_recipes(one_off)
    end
    
    index = gets.chomp.to_i
    if (index > 0)
      title = makeable[index - 1][0]
      Launchy.open(@evernote_drinks[title][:url])
    end

  elsif action == "p"
    puts "[a]dd [ingredient] | [r]emove [ingredient] | shopping [l]ist | [s]how"
    input = gets.chomp.split(" ")
    pantry_action = input[0]
    ingredient = input[1..-1].join(" ")

    case pantry_action

    when "a"
      @pantry = @pantry.add(ingredient)
      puts @pantry.sort
    when "r"
      @pantry = @pantry.remove(ingredient)
      puts @pantry.sort
    when "l"
      puts (@all_ingreds - @pantry.data).sort
    else 
      puts @pantry.sort
    end

  elsif action == "r"
    puts "[a]dd [name] | [r]emove | [s]how | [u]nmade"
    input = gets.chomp.split(" ")
    recipe_action = input[0]
    name = input[1..-1].join(" ")

    case recipe_action

    when "a"
      add_drink(name)
    when "r"
      comp = proc { |s| @recipes.titles.grep( /^#{Regexp.escape(s)}/) }
      Readline.completion_proc = comp
      Readline.completion_append_character = ""

      puts @recipes.titles
      input = Readline.readline('', true)
      @recipes = @recipes.remove(input)
    when "s"
      @recipes.titles.sort.each_with_index do |t, i|
        print "#{i + 1}.".ljust(5).light_yellow
        print "#{t}".light_yellow
        puts ""
      end

      puts ""
      puts "Enter number for recipe:".light_cyan

      index = gets.chomp.to_i
      if (index > 0)
        title = @recipes.titles.sort[index - 1]
        Launchy.open(@evernote_drinks[title][:url]) 
      end
    when "u"
      unmade = @evernote_drinks.titles.reject{ |t| @evernote_drinks[t][:made] }
      print_recipes(unmade)
    end

  elsif action == "q"
    break

  else 
    p "I don't recognize that"
  end
end
=begin
TODO
unmade drinks
=end
