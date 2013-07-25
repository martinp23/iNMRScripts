-- Dinit.lua 	semi-automatic deconvolution of a kinetic experiment

-- DEFINITIONS

HOME = HOME or "/Users/martinp23/Desktop/"		 -- define here your home directory
						-- never forget the initial slash !
filename = "MPTEST.txt"	--here we save the table of integrals

NumSpectra = 74	-- number of points for the kinetic study
NumRegions = 3	-- regions to deconvolute

doDeconv = false
phased = true
baselineparams = false
baseline = true

P = 1		-- first spectrum to process
R = 1		-- first region to process
			-- you can start from higher values, if you wish
			
F = {}		-- central frequencies
par = {}	-- parameter for the deconvolution
-- they must be obtained from a preliminary deconvolution performed on the first spectrum
dx = {}	

defaultDx = 0.05   -- you can change this - (constant) region to zoom in, in ppm units, based upon experience and observation

startRegion = -114 -- lower bound of ppm range in which all resonances are found
endRegion = -112 -- upper bound of ppm range (ditto)
local i = 1	-- progressive index, simplifies the editing of this script
-- for example, you can reorder the definitions below and they will still work


-- needs filling in!!!

-- resonance 1
F[i] = -112.59     -- ppm
par[i] = [[
Parameters for 1 peaks
  frequency (Hz)     intensity       width (Hz)   Lorentzian %

    -52955.0621	      103.5150	        3.4458	      100.0000
]]
dx[i] = defaultDx
i = i + 1

-- resonance 2
F[i] = -113.36    --ppm
par[i] = [[
Parameters for 1 peaks
  frequency (Hz)     intensity       width (Hz)   Lorentzian %

    -53320.8306	      102.1714	        3.3724	      100.0000
]]
dx[i] = defaultDx
i = i + 1

-- resonance 3
F[i] = -113.49    --ppm
par[i] = [[
Parameters for 1 peaks
  frequency (Hz)     intensity       width (Hz)   Lorentzian %

    -53368.3374	      152.7645	       34.9686	      100.0000
]]
dx[i] = defaultDx
i = i + 1

-- end of definitions ----------------------------------------

-- ************->    HERE WE GO:    <-***************

io.output(HOME..filename)		-- create/open the file where the results will be stored
io.write("\tpoint")	-- header
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
extract()			-- extract the corresponding 1D spectrum
delint()			-- we need to normalize the intensities
region( startRegion, endRegion )	-- region containing resonances no. 1 to 9
press 'i'			-- first integral, automatically set to 1
intreg( 1, 300 )	-- we set it to 300 to have manageable numbers (>1 and <300)
ppmPerPoint = 1   -- just set this, 1 is absolute nonsense 

print("Fix the phasing and do the baseline correction then press prep_DSTEP")

