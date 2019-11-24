extends Node

class_name GaussSolver

# solves a linear equation system based on gaussian elimination
# based on the implementation here https://martin-thoma.com/solving-linear-equations-with-gaussian-elimination/

# Ab is the augmented matrix. because we don't have matrices
# in GDScript, it's an array of arrays
func solve(Ab: Array) -> Array:
	var n = Ab.size()
	for i in range(0, n):
		# search for maximum in this column
		
		var maxEl = abs(Ab[i][i])
		var maxRow = i
		for k in range(i+1, n):
			if abs(Ab[k][i]) > maxEl:
				maxEl = abs(Ab[k][i])
				maxRow = k
		
		# swap maximum row with current row (column by column)
		for k in range(i, n+1):
			var tmp = Ab[maxRow][k]
			Ab[maxRow][k] = Ab[i][k]
			Ab[i][k] = tmp
			
		# make all rows below this one 0 in current column
		for k in range(i+1, n):
			var c = float(-Ab[k][i])/float(Ab[i][i])
			for j in range(i, n+1):
				if i == j:
					Ab[k][j] = 0
				else:
					Ab[k][j] += c * float(Ab[i][j])
	
	# solve equation for an upper triangular matrix Ab
	var x = []
	for i in range(n):
		x.append(0)

	for i in range(n-1, -1, -1):
		x[i] = float(Ab[i][n])/float(Ab[i][i])
		for k in range(i-1, -1, -1):
			Ab[k][n] -= float(Ab[k][i]) * x[i]
	
	return x
	
