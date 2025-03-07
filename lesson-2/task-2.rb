def foobar(a, b)
    if(a == 20 || b == 20 )
        puts "Второе число: #{b}"
    else
        puts "Сумма двух введенных чисел: #{a + b}"
    end
end

print "Введите первое число: "
a = gets.to_i
print "Введите второе число: "
b = gets.to_i

foobar(a, b)