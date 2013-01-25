-- D_STEP.lua 	Semi-automatic deconvolution of a kinetic experiment
if not P or not R then
	print("P or R are not defined!")
	return
end

if selection then
	cliptext( par[R] )
	onv = dec()
	NumPeaks = 0
	if onv then
		dec( onv, "paste" )		-- input our starting parameters
		dec( onv, "sall" )		-- fit all parameters
		dec( onv, "SAME" )		-- Lorentzian line-shapes
		selection = false
		print("FIT manually, then run D_STEP")
	end
	return
end

dec( onv, "copy" )		-- output refined parameters
NumPeaks = dec( onv )
dec( onv, "close" )
onv = nil
local str = cliptext()
local area = 0
local frequency = 0
local pos = string.find( str, "\n\n" )
local mistake = not pos
if pos then
	pos = pos + 1
	for i = 1,NumPeaks do
		pos = string.find( str, "\n", pos )
		mistake = not pos
		if mistake then print 'no endline' break end
		pos = pos + 1
		local F
		local A
		_, _, F, A = string.find( str, "([%w.]+)%s+([%w.]+)", pos )
		mistake = not F or not A
		if mistake then print 'no values' break end
		frequency = frequency + F
		area = area + A
	end
	if NumPeaks > 0 then
		frequency = conversion * frequency / NumPeaks
	end
end
if mistake then		-- information for debugging
	print("Error Processing Region no.", R, "of Spectrum no.", P)
	print("deconvolution returned:")
	print( str )
end
if P > 2 then
	par[R] = str
end
io.write( string.format("%0.3f\t%0.3f\t", frequency, area ) )
R = R + 1
if R > NumRegions then
	R = 1
	closex()
	Y = Y - step		-- position of the next spectrum
	print("Point", P, "completed")
	P = P + 1
	if P > NumSpectra then
		io.close()
		print "you have FINISHED"
		P = nil; R = nil; Y = nil; Fi = nil; Ff = nil; par = nil; HalfSpan = nil; step = nil;
		return
	else
		io.write( string.format("\n\t%02d\t", P ) )	-- report the experiment no.
		mark('h', Y )		-- choose a row
		extract()			-- extract the coresponding 1D spectrum
		delint()			-- we need to normalize the intensities
		region( -100, -130)	-- region containing protons no. 1 and 9
		press 'i'			-- first integral, automatically set to 1
		intreg( 1, 300 )	-- we set it to 300 to have manageable numbers (>1 and <300)
	end
end

region( F[R] + dx, F[R] - dx )
press "z"
adj()
print("select the signal, then run F Step")
selection = true

