require 'json'
require 'colorize'
require 'readline'

class String
  def titleize
    self.split.map(&:capitalize).join(' ')
  end
end

while (true)
  puts "[m]ake | [p]antry | [r]ecipe | [e]xit"
  action = gets.chomp.downcase
  pantry = JSON.parse(File.read("pantry.json")).sort
  recipes = JSON.parse(File.read("recipes.json"))
  all_ingreds = recipes.values.flatten.uniq

  case action[0]

  when "m"
    one_off = []
    puts ""
    puts "You can make:"

    recipes.sort.each do |name, ingreds|
      diff = ingreds - pantry
      
      if (diff).empty?
        print "#{name.titleize}".ljust(20).colorize(:red)
        print "#{ingreds.join(", ").titleize}".colorize(:light_blue)
        puts ""
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
      print "#{r[0]}".ljust(20).colorize(:red)
      print "#{r[1]}".colorize(:light_yellow)
      puts ""
    end
    puts ""

  when "p"
    puts "[a]dd [ingredient] | [r]emove [ingredient] | [s]how"
    input = gets.chomp.split(" ")
    pantry_action = input[0]
    ingredient = input[1..-1].join(" ")

    case pantry_action

    when "a"
      pantry << ingredient
      File.write("pantry.json", pantry.uniq.sort.to_json, { mode: "w+" } )
    when "r"
      pantry.delete(ingredient)
      File.write("pantry.json", pantry.to_json, { mode: "w+" } )
    end

    puts ""
    puts pantry.sort

  when "r"
    puts "[a]dd [name] | [r]emove [name] | [s]how"
    input = gets.chomp.split(" ")
    recipe_action = input[0]
    name = input[1..-1].join(" ")

    case recipe_action

    when "a"
      ingreds = []

      comp = proc { |s| all_ingreds.grep( /^#{Regexp.escape(s)}/) }
      Readline.completion_proc = comp
      Readline.completion_append_character = ""

      while (true)
        puts "[ingredient] | exit"
        input = Readline.readline('', true)
        break if input == "exit"

        if (all_ingreds.include?(input))
          ingreds << input
        else
          puts "are you sure you want to add a new ingredient? [y] | [n]"
          action = gets.chomp
          ingreds << input if action == "y"
        end
      end

      recipes[name] = ingreds
      File.write("recipes.json", recipes.to_json, { mode: "w+" } )
      puts ""
      p "#{name} - #{ingreds.join(", ")}" 
    end

  when "e"
    break

  else 
    p "I don't recognize that"
  end
end
=begin
TODO
autocomplete
evernote API
=end
