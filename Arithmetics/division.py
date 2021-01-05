"""
A python file to check that division is supposed to work.
the division function is less intuitive for me so I implemented
it here first,
"""

def main():
	while True:
		divident = int(input("enter first number: "))
		divisor = int(input("enter divisor: "))
		print(f"{a}/{b} = {div2(a,b)}\n")


"""
function name: 	div2
purpose: 		implementation of divide function in assembly
input:
	- divident- the divident
	- divisor- the divisor
"""
def div2(divident, divisor):

	
	remainder = divident			# dx
	result = 0 				# stack
	
	while(remainder -= divisor): 	# cmp dx, divisor
		addition_to_result = 1  			# mov cx, 1
		twos_power_times_divisor = divisor		
		remainder -= twos_power_times_divisor
		"""
		find max number that is a power of 2 and still divisor*that_number
		is less than remainder
		"""
		while(remainder >= twos_power_times_divisor):
			c <<= 1
			remainder -= twos_power_times_divisor
			addition_to_result <<= 1
		result += c
	return y, rem

			
if __name__ == '__main__':
	main()