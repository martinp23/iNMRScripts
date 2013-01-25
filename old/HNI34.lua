-- Dinit.lua 	semi-automatic deconvolution of a kinetic experiment

-- DEFINITIONS

HOME = HOME or "/Users/izzaty/Desktop/NMR2012/Kinetics/1H_HNI34/"		 -- define here your home directory
						-- never forget the initial slash !
filename = "HNI34.txt"	--here we save the table of integrals

NumSpectra = 33	-- number of points for the kinetic study
NumRegions = 2	-- regions to deconvolute

P = 1		-- first spectrum to process
R = 1		-- first region to process
			-- you can start from higher values, if you wish
			
F = {}		-- central frequencies
par = {}	-- parameter for the deconvolution
-- they must be obtained from a preliminary deconvolution performed on the first spectrum
dx = 0.5	-- (constant) region to zoom in, in ppm units, based upon experience and observation

local i = 1	-- progressive index, simplifies the editing of this script
-- for example, you can reorder the definitions below and they will still work


-- proton 1
F[i] = 10.009
par[i] = [[

Parameters for 1 peaks
  frequency (Hz)     intensity       width (Hz)   Lorentzian %

      5003.7549	       97.7874	        1.5638	      100.0000

]]
i = i + 1


-- proton 2
F[i] = 8.423
par[i] = [[
Parameters for 1 peaks
  frequency (Hz)     intensity       width (Hz)   Lorentzian %

      4210.7303	        0.7651	        1.9043	       84.7195

]]
i = i + 1


-- end of definitions ----------------------------------------

-- ************->    HERE WE GO:    <-***************

io.output(HOME..filename)		-- create/open the file were the results will be stored
io.write("point")	-- header
for i = 1,NumRegions do
	io.write("\tppm\tarea")
end
io.write("\n")

spectral = getf("x")				-- read some experimental parameters 
conversion = 1.0 / spectral.MHz		-- useful to convert from Hz to ppm
spectral = getf("y")
step = spectral.width / spectral.size
Y = spectral.start + step * (spectral.size -0.1 -P+1)	-- position of the first row on its dummy ppm scale

io.write( string.format("\n\t%02d\t", P ) )	-- report the experiment no.
mark('h', Y )		-- choose a row
extract()			-- extract the coresponding 1D spectrum
delint()			-- we need to normalize the intensities
region( 0, 12.0 )	-- region containing protons no. 1 and 9
press 'i'			-- first integral, automatically set to 1
intreg( 1, 300 )	-- we set it to 300 to have manageable numbers (>1 and <300)

region( F[R] + dx, F[R] - dx )
press "z"
adj()
print("select the signal, then run D_STEP")
selection = true
