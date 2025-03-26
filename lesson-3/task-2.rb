def pokemons_input(index)
    print "Введите название покемона #{index + 1}: "
    name = gets.chomp
    print "Введите цвет покемона #{index + 1}: "
    color = gets.chomp
    {name: name, color: color}
end

def out(pokemons)
    puts pokemons.inspect
end

def number_of_pokemons
    print "Введите число покемонов: "
    gets.to_i
end

def collect_pokemons()
    num = number_of_pokemons()
    pokemons = [num]

    num.times do |index|
        pokemons << pokemons_input(index)
    end
    out(pokemons)
end

collect_pokemons()