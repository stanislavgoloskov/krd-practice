def greeting(name, surname, age)
    if(age < 18)
        puts "Привет, #{name} #{surname}. Тебе меньше 18, но научиться программировать никогда не рано"
    else
        puts "Привет, #{name} #{surname}. Самое время заняться делом!"
    end
end

print "Введите имя: "
name = gets
print "Введите фамилию: "
surname = gets
print "Введите возраст: "
age = gets.to_i

greeting(name, surname, age)