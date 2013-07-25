-- D_STEP.lua 	Semi-automatic deconvolution of a kinetic experiment

-- notes
----- iNMR Lua commands:             http://www.inmr.net/Help3/ref/commands.html
----- A worse version of the above:  http://www.inmr.net/Help/pgs/commands.html
----- iNMR deconvolution scripting:  http://www.inmr.net/Help3/ref/deconv.html#SCRIPT
----- Lua docs                       http://www.lua.org/pil/

if not P or not R then
	print("P or R are not defined!")
	return
end

if doDeconv == false then
	print "Run prep_DStep first"
	return
end

if selection and doDeconv then
	cliptext( par[R] )
	onv = dec()
	NumPeaks = 0
	if onv then
		--if P > 3 then  -- it's annoying that it tries to paste an empty clipboard for P<4
		dec( onv, "paste" )		-- input our starting parameters
	--	end
		dec( onv, "++++" )		-- fit all parameters
		dec( onv, "SAME" )		-- Lorentzian line-shapes
		selectionRegion = copy()   -- int selectionRegion(x)  is the width in points
		dx[R] = 0.5 * selectionRegion.x * ppmPerPoint     -- update dx to be the selected region, *assuming* centred correctly
		selection = false
		print("FIT manually and/or by pressing auto, then run D_Step")
			
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
		_, _, F, A = string.find( str, "([%-%w.]+)%s+([.%-%w.]+)", pos )
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
--if P > 2 then
	par[R] = str
--end
io.write( string.format("%0.3f\t%0.3f\t", frequency, area ) )
F[R] = frequency  -- since signals often drift, change the frequency we're looking at, so the auto-region-selection for deconvolution works.
R = R + 1
if R > NumRegions then
	R = 1
	closex()
	Y = Y - step		-- position of the next spectrum
	print("Point", P, "completed")
	P = P + 1
	if P > NumSpectra then
		io.close()
		print "Finished. Pub?"
		P = nil; R = nil; Y = nil; Fi = nil; Ff = nil; par = nil; HalfSpan = nil; step = nil;
		return
	else
		io.write( string.format("\n\t%02d\t", P ) )	-- report the experiment no.
		mark('h', Y )		-- choose a row
		extract()			-- extract the coresponding 1D spectrum
		delint()			-- we need to normalize the intensities
		region( startRegion, endRegion )	-- region containing resonances no. 1 to 9
		press 'i'			-- first integral, automatically set to 1
		intreg( 1, 300 )	-- we set it to 300 to have manageable numbers (>1 and <300)
		amp( 5 ) -- amplify so we can see the phase clearly
		baseline = false
		doDeconv = false
		print "Phase ok (press prep_DStep in console when yes)?"
		adjIntegral = intreg(i)  -- set adjustedIntegral to the latest change for comparison next time
	end
end

if R > 1 then
	region( F[R] + dx[R], F[R] - dx[R] )
	press "z"
	adj()
	print("select the signal, then run D_STEP")
	selection = true
	region( F[R] + dx[R], F[R] - dx[R]) -- select a peak region for deconvolution automatically
end

