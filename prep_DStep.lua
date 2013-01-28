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
	region(2,1)  -- here we establish the points-to-ppm conversion factor. The easiest way is to take a reference region
	press "z"    -- since it seems like using the extract's spectral properties gives a misleading answer
	selection = true
	region(2,1)
	S = copy()
	ppmPerPoint = 1/S.x
	region()      -- return to full view
	full()
	if phased == false then     -- sort the phasing
		amp(50)
		print "When phase is ok press prep_dstep"
		phased = true
	end
	if baselineparams == false then     -- then sort the baseline
         baselineY = ask "Do you want a baseline correction? (Y/N)"
         if baselineY == "Y" then
              doBaseLine = true
      		blineOrder = ask "What is the order of the baseline correction? (0,1,2,3...)"
      		blineFilter = ask "What filter is applied to the baseline correction? (16,32,64,128etc)"
              baselineparams = true
         else 
              doBaseLine = false
              baselineparams = true
         end
	end
	if baseline == false then
		if doBaseLine == true then
      		bline( blineOrder, blineFilter ) -- perform baseline correction according to parameters input earlier
      		print ("Integral for spectrum " .. P .. " is " .. intreg(1) .. ".")
      	end
		baseline = true
	end
	if phased and baseline then -- now we start the fun.
		region( F[R] + dx[R], F[R] - dx[R] )
		press "z"
		adj()
		print("select the signal, then run D_Step1-MP")
		selection = true
		region( F[R] + dx[R], F[R] - dx[R])
		doDeconv = true
	end

end
