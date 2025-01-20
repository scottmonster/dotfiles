-- A simple Lua script demonstrating some cool features

-- Function to calculate factorial of a number
function factorial(n)
  if n == 0 then
    return 1
  else
    return n * factorial(n - 1)
  end
end

-- Function to check if a number is prime
function is_prime(n)
  if n <= 1 then return false end
  for i = 2, math.sqrt(n) do
    if n % i == 0 then return false end
  end
  return true
end

-- Function to generate Fibonacci sequence up to n terms
function fibonacci(n)
  local a, b = 0, 1
  for i = 1, n do
    print(a)
    a, b = b, a + b
  end
end

-- Demonstrate the functions
print("Factorial of 5: " .. factorial(5))
print("Is 7 prime? " .. tostring(is_prime(7)))
print("Fibonacci sequence up to 10 terms:")
fibonacci(10)
