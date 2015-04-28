require 'json'
require 'colorize'
require 'readline'
require 'launchy'
require_relative 'evernote'

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
    break if input == "quit"

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

while (true)

  unsynced = @evernote_drinks.titles - @recipes.titles
  if (unsynced.length > 0)
    puts "You have not synced \(press number to sync\):".colorize(:red)
    unsynced.each_with_index do |name, i| 
      print "#{i + 1}.".ljust(3).colorize(:light_yellow)
      print "#{name.titleize}".colorize(:light_yellow)
      puts ""
    end
  end

  puts ""
  puts "[m]ake | [p]antry | [r]ecipe | [q]uit"
  action = gets.chomp.downcase[0]

  if action.to_i > 0
    drink = unsynced[action.to_i - 1]
    add_drink(drink) if drink
  elsif action == "m"
    one_off = []
    puts ""
    puts "You can make:"
    idx = 1
    order = []

    @recipes.sort.each do |name, ingreds|
      diff = ingreds - @pantry.data
      
      if (diff).empty?
        print "#{idx}. #{name.titleize}".ljust(20).colorize(:red)
        print "#{ingreds.join(", ").titleize}".colorize(:light_blue)
        puts ""

        order << name
        idx += 1
      end

      one_off << [name.titleize, diff[0].titleize] if (diff.length == 1)
    end

    puts ""
    puts "You are one off from:"

    one_off.sort! do |a, b|
      comp = (a[1] <=> b[1])
      comp.zero? ? (a[0] <=> b[0]) : comp
    end

    one_off.each do |r|
      print "#{i}. #{r[0]}".ljust(20).colorize(:red)
      print "#{r[1]}".colorize(:light_yellow)
      puts ""

      order << r[0]
      i += 1
    end
    puts ""
    puts "Enter number for recipe".colorize(:light_cyan)
    puts ""
    
    index = gets.chomp.to_i
    title = order[index - 1]
    Launchy.open(@evernote_drinks[title][:url])

  elsif action == "p"
    puts "[a]dd [ingredient] | [r]emove [ingredient] | [s]how"
    input = gets.chomp.split(" ")
    pantry_action = input[0]
    ingredient = input[1..-1].join(" ")

    case pantry_action

    when "a"
      @pantry = @pantry.add(ingredient)
    when "r"
      @pantry = @pantry.remove(ingredient);
    end

    puts ""
    puts @pantry.sort

  elsif action == "r"
    puts "[a]dd [name] | [r]emove | [s]how"
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
        print "#{i + 1}.".ljust(5).colorize(:light_yellow)
        print "#{t}".colorize(:light_yellow)
        puts ""
      end
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
missing ingreds for unmade
highlight make based on like or not
launchy
=end
