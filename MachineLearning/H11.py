class ComplexNumbers:
    def __init__(self,real=0, imag=0):
        self.real=real
        self.imag=imag
    
    def __str__(self):
        return"{}{}{}i".format(self.real, "+" if self.imag>= 0 else 0, abs(self.imag))

    def __add__(self,other):
        return ComplexNumbers(self.real + other.real, self.imag + other.imag)

    def __sub__(self, other):
        return ComplexNumbers(self.real - other.real, self.imag - other.imag)
    
    def __abs__(self):
        return ((self.real**2 + self.imag**2))**(1/2)

a=ComplexNumbers(2,3)
b=ComplexNumbers(3,6)
c=ComplexNumbers(-2)
d=ComplexNumbers(1)

print("{} \n{} \n{} \n{}".format(a,b,c,d))
print("\n{} + {} = {}".format(a,b,a+b))
print("{} - {} = {}".format(b,a,b-a))
print("\n{} - {} = {}".format(c,b,c-b))
print("{} + {} = {}".format(c,d,c+d))
print("\n{} module:{}".format(a, abs(a)))
print("{} module:{}".format(c, abs(c)))


