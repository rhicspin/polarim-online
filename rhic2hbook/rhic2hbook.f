	subroutine Usage

	print *, 'Usage: rhic2hbook [options] filein [fileout]'
	print *, '       -s <device name> to send results to CDEV database'
	print *, '       -n to write ntuples, otherwise only histograms'
	print *, '       -r to write raw data ntuples'
	print *, '       -l to calculate least square asymmetries'
	print *, '       -p not to process data for the polarization'
	print *, '       -N <subrun number> to extract (default = 0)'
	print *, '	    if <subrun number> >=0, only it is processed and the result is'
	print *, '	    send as for a single measurement, otherwize all subruns are'
	print *, '	    processed and send as array for the ramp measurement'
	print *, '       -c <channel number> write channel to n-tuple. This option can be repeated.'
	print *, '       -S <number> skip number of events before writing waveforms'
	print *, '       -B <number> select bunch number for waveforms'
	print *, '       -v <number> start with revolution number for waveforms'
	print *, '       -d <number> disable detectors. default is 63 = 111111'
	
	return
	end

c
	program rhic2hbook
	common/pawc/pawc(8000000)
	common/quest/ iquest(100)
	common/runpars/ intp, iraw, iproc, ilsas, trigmin, iskip, ichanntp(96)
	common/wfsel/ ibunch, irevfirst
	common/subrun/ nofsubruns, itimestamp(500), asymX(500), asymErrX(500), 
     +      asymX90(500), asymErrX90(500), asymX45(500), asymErrX45(500)
	common /poldat/ runIdS, startTimeS, stopTimeS,
     +	    daqVersionS, cutIdS, targetIdS, encoderPositionS,
     +      statusS, statusStringS, totalCountsS, upCountsS,
     +	    downCountsS, unpolCountsS, countsUpLeftS,
     + 	    countsLeftS, countsDownLeftS, countsDownRightS,
     +	    countsRightS, countsUpRightS, avgAsymXS,
     +	    avgAsymX45S, avgAsymX90S, avgAsymYS,
     +	    avgAsymErrorXS, avgAsymErrorX45S, avgAsymErrorX90S,
     +      avgAsymErrorYS, bunchAsymXS, bunchAsymYS,
     +	    bunchAsymErrorXS, bunchAsymErrorYS, beamEnergyS,
     +      analyzingPowerS, analyzingPowerErrorS, numberEventsS,
     +	    maxTimeS
        double precision runIdS
	integer startTimeS, stopTimeS
	character daqVersionS(80), cutIdS(80), targetIdS(80)
	integer encoderPositionS(2), statusS
	character statusStringS(80)
	integer totalCountsS, upCountsS, downCountsS, unpolCountsS
	integer countsUpLeftS(360), countsLeftS(360)
	integer countsDownLeftS(360), countsDownRightS(360)
	integer countsRightS(360), countsUpRightS(360)
	real avgAsymXS, avgAsymX45S, avgAsymX90S, avgAsymYS
	real avgAsymErrorXS, avgAsymErrorX45S, avgAsymErrorX90S
	real avgAsymErrorYS, bunchAsymXS(360), bunchAsymYS(360)
	real bunchAsymErrorXS(360), bunchAsymErrorYS(360)
	real beamEnergyS, analyzingPowerS, analyzingPowerErrorS
	integer numberEventsS, maxTimeS
        integer detMask

	character*256 fin, fout, str, device

ccommon /
	
	fin       = '?'
	fout      = '?'
	isend     = 0
	intp      = 0
	iraw      = 0
	iproc     = 1
	ilsas     = 0
	iskip     = 0
	nsubrun   = 0
	ipar      = 0
	irevfirst = 0
	ibunch    = -1
	detMask   = 63
	NumArgs   = IArgC()

	call vzero(ichanntp, 96)
	
	do i = 1, NumArgs
	    call getarg(i, str)
	    
	    if (ipar.eq.1) then
c	ipar=1 - get device name
		device = str
		ipar = 0
	    else if (ipar.eq.2) then
c	ipar=2 - get subrun number
		read (str, *) nsubrun
		ipar = 0
	    else if (ipar.eq.3) then
c	ipar=3 - get channel number to be included into n-tuple
		read (str, *) j
		if (j.gt.0.and.j.le.96) then
		    ichanntp(j) = 1
		endif
		ipar = 0
	    else if (ipar.eq.4) then
c	ipar=4 - get number of events skipped for n-tuple
		read (str, *) iskip
		ipar = 0
	    else if (ipar.eq.5) then
c	ipar=5 - get bunch number for n-tuple
		read (str, *) ibunch
		ipar = 0
	    else if (ipar.eq.6) then
c	ipar=6 - get revolution number before which we skip
		read (str, *) irevfirst
		ipar = 0
	    else if (ipar.eq.7) then
c	ipar=7 - get mask of disable detectors
		read (str, *) detMask
		ipar = 0
	    else if (str.eq.'-s') then
c	send result, get <device name>
		isend = 1
		ipar = 1
	    else if (str.eq.'-n') then
c	create n-tuple
		intp = 1
	    else if (str.eq.'-r') then
c	create raw n-tuple
		iraw = 1
		intp = 1
	    else if (str.eq.'-p') then
c	DO NOT process data for polarization
		iproc = 0
	    else if (str.eq.'-l') then
c	calculate least square asymmetries
		ilsas = 1
	    else if (str.eq.'-N') then
c	get <subrun number>
		ipar = 2
	    else if (str.eq.'-c') then
c	get <chan number> for n-tuple
		ipar = 3
	    else if (str.eq.'-S') then
c	get <skip events> before writing to n-tuple
		ipar = 4
	    else if (str.eq.'-B') then
c	get <bunch number> for n-tuple
		ipar = 5
	    else if (str.eq.'-v') then
c	get <revolution skip> for n-tuple
		ipar = 6
	    else if (str.eq.'-d') then
c get disabled detectors
		ipar = 7
	    else if (fin.eq.'?') then
c	input filename
		fin = str
	    else if (fout.eq.'?') then
c	output filename
		fout = str
	    else
		print *, 'Unknown option '//str
		call Usage
		stop 	
	    endif
	enddo

	if (fin.eq.'?') then
	    print *, 'No input file'
	    call Usage
	    stop
	endif	

	if (isend.ne.0) call cdevinit();

	if (fout.eq.'?') fout = fin(1:len_trim(fin)) // '.hbook'

c Make that if no '-c' option given but n-tuple requested than all channels go to n-tuple

	j = 0
	do i=1, 96
	    j = j + ichanntp(i)
	enddo

	if (j.eq.0) then
	    do i=1, 96
	        ichanntp(i) = 1
	    enddo
	endif

c Hook for test 90-degree detectors in yel1 and blu2 (run 2010/2011)
c	if ((device(13:16).eq.'yel1').or.(device(13:16).eq.'blu2')) then
c	    i90OK = 0
c	else
c	    i90OK = 1
c	endif

c Run 2012: We use a more general detMask to disable detectors
c blu2 det 1 and 6 are experimental
c	if (device(13:16).eq.'blu2') then
c	   detMask = 30
c	endif

	i90OK = 1

c Initialize hbook
	call hlimit(8000000)
	call mninit(5, 6, 7)
	iquest(10) = 65000

c Single subrun processing (also normal measurement)
	if (nsubrun.ge.0) then

	    if (icopen(fin(1:len_trim(fin))).ne.0) then
		print *, 'Cannot open input file ', fin(1:len_trim(fin))
		stop
	    endif
	    print *, 'Openning output file ', fout(1:len_trim(fout))
	    call hropen(10, 'data', fout(1:len_trim(fout)), 'NP', 1024, irc)

c Flush the output buffers
	    call flush(6)
	    call flush(7)
	    call readandfill(nsubrun)

	    if (iproc.ne.0) call process(i90OK, device, detMask)
	
	    call hrout(0, irc, ' ')
	    call hrend('data')
	    call icclose

	    if (isend.ne.0) call sendresult(device(1:len_trim(device)))

c Process ramp measurement - all subruns found
	else
	    isubr = 0
	    call vzero(itimestamp,500)

10	    if (icopen(fin(1:len_trim(fin))).ne.0) then
		print *, 'Cannot open input file ', fin(1:len_trim(fin))
		stop
    	    endif

    	    write(*,*) 'RHIC2HBOOK-INFO : isubr = ', isubr
    	    iquest(10) = 65000
	    call hdelet(0)
	    write(str,'(''_'', I4.4)') isubr+1
	    print *, 'Openning output file 2 ', fout(1:len_trim(fout))//str(1:len_trim(str))
	    call hropen(10, 'data', fout(1:len_trim(fout))//str(1:len_trim(str)), 'NP', 1024, irc)

	    call flush(6)
	    call flush(7)
	    call readandfill(isubr)
c   	    print *, 'After readandfill (nsubrun<0) isubr = ',isubr

	    if (iproc.ne.0) then
		call process(i90OK, device, detMask)

		asymX(isubr+1)      = avgAsymXS
		asymX90(isubr+1)    = avgAsymX90S
		asymX45(isubr+1)    = avgAsymX45S
		asymErrX(isubr+1)   = avgAsymErrorXS
		asymErrX90(isubr+1) = avgAsymErrorX90S
		asymErrX45(isubr+1) = avgAsymErrorX45S
		
	    endif

	    call hrout(0, irc, ' ')
	    call hrend('data')
	    call icclose
	    call addtosummary(isubr, i90OK, fout)
	    if (itimestamp(isubr+1).eq.0.or.isubr.ge.499) goto 99
	    isubr = isubr + 1
	    goto 10
	    	    
99	    if (isend.ne.0) call sendsubresult(device(1:len_trim(device)))

	endif
	
	print *,'The end of RHIC2HBOOK.'
	stop
	end

c book channel histograms. i >= 1
	subroutine mybook(i)
	
	character chname*5
	common /atdata/ a, t, tmax, s, ib, id, irev, ijet
	common /atraw/ ia, it, itmax, is, iib, iid, iirev, iijet
	common /runpars/ intp, iraw, iproc, ilsas, trigmin, iskip, ichanntp(96)
	common /sipar/ idiv, rnsperchan, emin, etrg, ifine, ecoef(96), edead(96), tmin(96), mark(96)
	
	write(chname, '(I4)') i

	if (intp.eq.1.and.ichanntp(i).ne.0) then
	    if (iraw.eq.1) then
		call hbnt(i, 'AT events RAW for Si'//chname, ' ')
		call hbname(i, 'ATRAW', ia, 'A:U:8, T:U:8, TMAX:U:8, S:I, B:U:7, D:U, REV:U, P:U:2')
	    else
		call hbnt(i, 'AT events for Si'//chname, ' ')
		call hbname(i, 'AT', a, 'A:R:10:[0.,2048.], T:R:10:[0.,1024.], TMAX:R:10:[0.,1024.], S:R, B:U:7, D:U, REV:U, P:U:2')
	    endif
	endif
	
c Histograms filled from scalers
	call hbook1(200+i, 'Bunch No for Si'//chname, 120, 0., 120., 0)
	call hbook1(300+i, 'Energy keV, unpol, for Si'//chname, 128, edead(i), 256.*ecoef(i)+edead(i), 0)
	call hbook1(400+i, 'Energy keV, pol plus, for Si'//chname, 128, edead(i), 256.*ecoef(i)+edead(i), 0)
	call hbook1(500+i, 'Energy keV, pol minus, for Si'//chname, 128, edead(i), 256.*ecoef(i)+edead(i), 0)

	if (ifine.eq.0) then
	    call hbook2(600+i, 'ET (keV ns) internal hist (coarse) for Si'//chname, 
     ,	    32, edead(i), 256.*ecoef(i)+edead(i), 32, tmin(i), tmin(i) + 32.*rnsperchan, 0)
	else
	    call hbook2(700+i, 'ET (keV ns) internal hist (fine) for Si'//chname, 
     ,	    16, etrg, etrg+128*ecoef(i), 64, tmin(i), tmin(i) + 32.*rnsperchan, 0)
	endif

	call hbook1(800+i, 'Low time cut for Si'//chname, 256, edead(i), 256*ecoef(i)+edead(i), 0)
	call hbook1(900+i, 'Up  time cut for Si'//chname, 256, edead(i), 256*ecoef(i)+edead(i), 0)

	call hbook1(1300+i, 'Amplitude, unpol, for Si'//chname, 128, 0., 256., 0)
	call hbook1(1400+i, 'Amplitude, pol plus, for Si'//chname, 128, 0., 256., 0)
	call hbook1(1500+i, 'Amplitude, pol minus, for Si'//chname, 128, 0., 256., 0)

	if (ifine.eq.0) then
	    call hbook2(1600+i, 'AT (raw) internal hist (coarse) for Si'//chname, 
     ,	    32, 0., 256., 32, tmin(i)/rnsperchan, tmin(i)/rnsperchan + 32., 0)
	else
	    call hbook2(1700+i, 'AT (raw) internal hist (fine) for Si'//chname, 
     ,	    16, (etrg-edead(i))/ecoef(i), (etrg-edead(i))/ecoef(i)+128., 64, 2*tmin(i)/rnsperchan, 2*tmin(i)/rnsperchan + 64., 0)
	endif
	call hbook1(1800+i, 'Low time cut (raw) for Si'//chname, 256, 0., 256., 0)
	call hbook1(1900+i, 'Up  time cut (raw) for Si'//chname, 256, 0., 256., 0)

	call hbook1(2000+i, 'Low integral cut (raw) for Si'//chname, 256, 0., 256., 0)
	call hbook1(2100+i, 'Up  integral cut (raw) for Si'//chname, 256, 0., 256., 0)
	
	call hbook1(2200+i, 'Baseline for prompt estimate for Si'//chname, 240, 0., 240., 0)
	call hbook1(2300+i, 'Prompts for Si'//chname, 240, 0., 240., 0)

	return
	end


c	Here we make summary bananas for each subrun
c	5000+isubr - 2-dim banana (from 700+N)
c	6000+isubr - low cut (from 800+N)
c	7000+isubr - high cut (from 900+N)
c
	subroutine addtosummary(isubr, i90OK, fname)
	common /sipar/ idiv, rnsperchan, emin, etrg, ifine, ecoef(96), edead(96), tmin(96), mark(96)
	character*256 fname
	logical HEXIST
	
c		make histograms like the 6th Si channel - middle of the 1st detector
	if (ifine.eq.0) then
	    call hbook2(5000+isubr, 'ET (keV ns) internal hist (coarse) for all channels', 
     ,	    32, edead(6), 256.*ecoef(6)+edead(6), 32, tmin(6), tmin(6) + 32.*rnsperchan, 0)
	else
	    call hbook2(5000+isubr, 'ET (keV ns) internal hist (fine) for all channels', 
     ,	    16, etrg, etrg+128*ecoef(6), 64, tmin(6), tmin(6) + 32.*rnsperchan, 0)
	endif
	call hbook1(6000+isubr, 'Low time cut', 256, edead(6), 256*ecoef(6)+edead(6), 0)
	call hbook1(7000+isubr, 'Up  time cut', 256, edead(6), 256*ecoef(6)+edead(6), 0)
c		Sum everything ...
	N = 0
	if (ifine.eq.0) then
	    N2D = 600
	else
	    N2D = 700
	endif
	do i = 1, 72
	    if (HEXIST(N2D+i).and.((i90OK.ne.0).or.(i.le.12).or.((i.gt.24).and.(i.le.48)).or.(i.gt.60))) then
		call HOPERA(N2D+i, '+', 5000+isubr, 5000+isubr, 1.0, 1.0)
		call HOPERA(800+i, '+', 6000+isubr, 6000+isubr, 1.0, 1.0)
		call HOPERA(900+i, '+', 7000+isubr, 7000+isubr, 1.0, 1.0)
		N = N + 1
	    endif
	enddo
	if (N.gt.0) then
	    call HOPERA(6000+isubr, '+', 6000+isubr, 6000+isubr, 1.0/N, 0.0)
	    call HOPERA(7000+isubr, '+', 7000+isubr, 7000+isubr, 1.0/N, 0.0)
	endif
c
	if (isubr.eq.0) then
c		we are running the first time - create file
            print *, 'Openning output file 3 ', fname(1:len_trim(fname))
	    call hropen(10, 'sum', fname(1:len_trim(fname)), 'NP', 1024, irc)
	else
            print *, 'Openning output file 4 ', fname(1:len_trim(fname))
	    call hropen(10, 'sum', fname(1:len_trim(fname)), 'UP', 1024, irc)
	endif
c
	call hrout(5000+isubr, irc, ' ')
	call hrout(6000+isubr, irc, ' ')
	call hrout(7000+isubr, irc, ' ')
	call hrend('sum')
	
	return
	end
c
	subroutine histdelim(IPOS, LEN)
	integer ipos(4*LEN)

	call hbook1(3000, 'Horizontal target linear position', LEN, 0., 1.0*LEN, 0)
	call hbook1(3001, 'Horizontal target rotary position', LEN, 0., 1.0*LEN, 0)
	call hbook1(3002, 'Vertical target linear position', LEN, 0., 1.0*LEN, 0)
	call hbook1(3003, 'Vertical target rotary position', LEN, 0., 1.0*LEN, 0)

	print *, 'Target data length = ', LEN
	do i=1,LEN
	    do j=1,4
		call hfill(2999+j, 1.*i-0.5, 0., 1.0*IPOS(4*(i-1)+j))
C	print *, i,' histdelim: Filling ',2999+j,'  ',1.*i-0.5,'  ',1.0*IPOS(4*(i-1)+j)
	    enddo
	enddo

	return
	end


c
	subroutine histrate(IPOS, LEN)
	integer ipos(LEN)
	call hbook1(3010, 'Count rate', LEN+1, 0., 1.0*LEN+1., 0)

	do i=1,LEN
	    call hfill(3010, 1.*i+0.5, 0., 1.0*IPOS(i))
	enddo
	return
	end


c
	subroutine histtagmov(IPOS, LEN)
	integer ipos(2*LEN)
	call hbook1(3020, 'Target rotary position', LEN, 0., 1.0*LEN, 0)
	call hbook1(3021, 'Position change time', LEN, 0., 1.0*LEN, 0)
	do i=1,LEN
	    do j=1,2
		call hfill(3019+j, 1.*i-0.5, 0., 1.0*IPOS(2*(i-1)+j))
	    enddo
	enddo
	return
	end

c
	subroutine process(i90OK, polName, detMask)
	character*256 polName
        integer detMask
	real x(128), y(128), ex(128), ey(128)
	common /sscal/ ssscal(288)
	integer ssscal
	common /RHIC/ fillpat(120), polpat(120)
	common /poldat/ runIdS, startTimeS, stopTimeS,
     +	    daqVersionS, cutIdS, targetIdS, encoderPositionS,
     +      statusS, statusStringS, totalCountsS, upCountsS,
     +	    downCountsS, unpolCountsS, countsUpLeftS,
     + 	    countsLeftS, countsDownLeftS, countsDownRightS,
     +	    countsRightS, countsUpRightS, avgAsymXS,
     +	    avgAsymX45S, avgAsymX90S, avgAsymYS,
     +	    avgAsymErrorXS, avgAsymErrorX45S, avgAsymErrorX90S,
     +      avgAsymErrorYS, bunchAsymXS, bunchAsymYS,
     +	    bunchAsymErrorXS, bunchAsymErrorYS, beamEnergyS,
     +      analyzingPowerS, analyzingPowerErrorS, numberEventsS,
     +	    maxTimeS
        double precision runIdS
	integer startTimeS, stopTimeS
	character daqVersionS(80), cutIdS(80), targetIdS(80)
	integer encoderPositionS(2), statusS
	character statusStringS(80)
	integer totalCountsS, upCountsS, downCountsS, unpolCountsS
	integer countsUpLeftS(360), countsLeftS(360)
	integer countsDownLeftS(360), countsDownRightS(360)
	integer countsRightS(360), countsUpRightS(360)
	real avgAsymXS, avgAsymX45S, avgAsymX90S, avgAsymYS
	real avgAsymErrorXS, avgAsymErrorX45S, avgAsymErrorX90S
	real avgAsymErrorYS, bunchAsymXS(360), bunchAsymYS(360)
	real bunchAsymErrorXS(360), bunchAsymErrorYS(360)
	real beamEnergyS, analyzingPowerS, analyzingPowerErrorS
	integer numberEventsS, maxTimeS
	
	dimension cnt(6, 3), ecnt(6,3), scnt(6,3)
	dimension bassX(120), ebassX(120), bassY(120), ebassY(120)
	integer fillpat, polpat
	character*10 siname(6)
	logical hexist
	character*30 str
	integer totalE, unpolE, upE, downE
	integer totalS, unpolS, upS, downS
	
	common/runpars/ intp, iraw, iproc, ilsas, trigmin, iskip, ichanntp(96)
	common /sipar/ idiv, rnsperchan, emin, etrg, ifine, ecoef(96), edead(96), tmin(96), mark(96)
	
c	names as from upstream of the beam
c	Si           1-12      23-24	 25-36       37-48	    49-60    61-72
	data siname/'UpRight', '90Right', 'DownRight', 'DownLeft', '90Left', 'UpLeft'/

c Print out some messages about the target...

	if (targetIdS(1) .eq. 'H') then
	    print *, '>>>' 
	    print *, '>>>  INFO: horizonal target used --> ignoring 90-degree detectors'
	    print *, '>>>' 
	else if (targetIdS(1) .eq. 'V') then
	    print *, '>>>'
	    print *, '>>>  INFO: vertical target used'
	    print *, '>>>' 
	else
	    print *, '>>>'
	    print *, '>>>  INFO: did not understand targetIdS(1) = ', targetIdS(1)
	    print *, '>>>'
	endif

c Book histogramms

c Information histogram...
	call hbook1(10, 'polDat Information', 1, 0., 1., 0)
	call hfill(10, 0.5, 0., beamEnergyS)

c Counts per bunch for each detector
	do i=1,6
	    call hbook1(9290+i, 'Bunch No for '//siname(i), 120, 0., 120., 0)
	    call hbook1(9390+i, 'Energy keV, unpol, for '//siname(i), 128, 
     ,		0., 1280., 0)
	    call hbook1(9490+i, 'Energy keV, pol plus, for '//siname(i), 128, 
     ,		0., 1280., 0)
	    call hbook1(9590+i, 'Energy keV, pol minus, for '//siname(i), 128, 
     ,    	0., 1280., 0)
	enddo

	call hbook1(397, 'Energy keV, unpol, for ALL Si', 128, 0., 1280., 0)
	call hbook1(497, 'Energy keV, pol plus, for ALL Si', 128, 0., 1280., 0)
	call hbook1(597, 'Energy keV, pol minus, for ALL Si', 128, 0., 1280., 0)
	call hbook1(600, 'Energy keV, ALL pol for ALL Si', 128, 0., 1280., 0)

c	Flag out bad channels (run 2012 addition) 05.04.2012 Igor
c	call FlagOut(polName)
c	Fill histogramms
	do i=1,6
c Do not process 90-degree detectors with horizontal targets
	    if (.not.((i.eq.2 .or. i.eq.5) .and. (targetIdS(1).eq.'H'))) then 
		do j=1,12
		    if (hexist(200+12*(i-1)+j).and.mark(12*(i-1)+j).eq.0) then
c	Bunch #
			call hunpak(200+12*(i-1)+j, X, ' ', ' ')
			call hpakad(9290+i, X)

c	Energy keV, unpol 
			call hrebin(300+12*(i-1)+j, X, Y, EX, EY, 128, 1, 128)

			do l = 1, 128
			    call hfill(9390+i, X(l), 0., Y(l))
			    call hfill(397, X(l), 0., Y(l))
			    call hfill(600, X(l), 0., Y(l))
			enddo

c	Energy keV, pol up
			call hrebin(400+12*(i-1)+j, X, Y, EX, EY, 128, 1, 128)
			do l = 1, 128
			    call hfill(9490+i, X(l), 0., Y(l))
			    call hfill(497, X(l), 0., Y(l))
			    call hfill(600, X(l), 0., Y(l))
			enddo

c	Energy keV, pol down
			call hrebin(500+12*(i-1)+j, X, Y, EX, EY, 128, 1, 128)
			do l = 1, 128
			    call hfill(9590+i, X(l), 0., Y(l))
			    call hfill(597, X(l), 0., Y(l))
			    call hfill(600, X(l), 0., Y(l))
			enddo
		    endif
		enddo
	    endif
	enddo

c		call this for debugging only
c	call testpol

c Get various counts

c Counts from WFD special scalers
	call vzero(scnt, 18)
	totalS = 0
	upS = 0
	downS = 0
	unpolS = 0

	do i=1,6
	    if (.not.((i.eq.2 .or. i.eq.5) .and. (targetIdS(1).eq.'H' ))) then
		do j=1, 12
		    if (mark(12*(i-1)+j).eq.0) then
			totalS    = totalS    + ssscal(3*(12*(i-1)+j-1)+3)
    			unpolS    = unpolS    + ssscal(3*(12*(i-1)+j-1)+3)
			scnt(i,1) = scnt(i,1) + ssscal(3*(12*(i-1)+j-1)+3)
			totalS    = totalS    + ssscal(3*(12*(i-1)+j-1)+1)
			upS       =    upS    + ssscal(3*(12*(i-1)+j-1)+1)
			scnt(i,2) = scnt(i,2) + ssscal(3*(12*(i-1)+j-1)+1)
			totalS    = totalS    + ssscal(3*(12*(i-1)+j-1)+2)
			downS     =  downS    + ssscal(3*(12*(i-1)+j-1)+2)
			scnt(i,3) = scnt(i,3) + ssscal(3*(12*(i-1)+j-1)+2)
		    endif
		enddo
	    endif
	enddo

C	Counts from energy histograms
	call vzero(ecnt, 18)
	totalE = 0
	upE = 0
	downE = 0
	unpolE = 0
	do i=1,6
	    if (.not.((i.eq.2 .or. i.eq.5) .and. (targetIdS(1).eq.'H' ))) then
		do j=1, 12
		    if (mark(12*(i-1)+j).eq.0) then
			if (hexist(300+12*(i-1)+j)) then
			    hn=0
			    do k=1,128
				hn= hn + hi(300+12*(i-1)+j,k)
			    enddo
			    totalE = totalE + hn
			    unpolE = unpolE + hn
			    ecnt(i,1) = ecnt(i,1) + hn
			endif
			if (hexist(400+12*(i-1)+j)) then
			    hn=0
			    do k=1,128
				hn=hn+hi(400+12*(i-1)+j,k)
			    enddo
			    totalE = totalE + hn
			    upE = upE + hn
			    ecnt(i,2) = ecnt(i,2) + hn
			endif
			if (hexist(500+12*(i-1)+j)) then
			    hn=0
			    do k=1,128
				hn=hn+hi(500+12*(i-1)+j,k)
			    enddo
			    totalE = totalE + hn
			    downE = downE + hn
			    ecnt(i,3) = ecnt(i,3) + hn
			endif
		    endif
		enddo
	    endif
	enddo

		
c	call AnaPow
	if (analyzingPowerErrorS.lt.0.0) call AnaPow(polName)

c	Counts which are sent to the ADO and used for asymmetry
c	calculations are from bunch # histograms and rely on
c	polarization and fill pattern got from RHIC ADO

c		fill counts for ADO
	do i=1, 120
	    countsUpLeftS(3*i-2)    = hi(9296, i)
	    countsLeftS(3*i-2)      = hi(9295, i)
	    countsDownLeftS(3*i-2)  = hi(9294, i)
	    countsDownRightS(3*i-2) = hi(9293, i)
	    countsRightS(3*i-2)     = hi(9292, i)
	    countsUpRightS(3*i-2)   = hi(9291, i)
	enddo
	
	call vzero(cnt, 18)
	totalCountsS = 0
	upCountsS    = 0
	downCountsS  = 0
	unpolCountsS = 0
		
	do i=1,6
	    if (.not.((i.eq.2 .or. i.eq.5) .and. (targetIdS(1).eq.'H' ))) then
		do j=1, 120
		    if (fillpat(j).ne.0) then
			hn = hi(9290+i, j)
			totalCountsS = totalCountsS + hn
			if (polpat(j).eq.0) then
		    	    unpolCountsS = unpolCountsS + hn
		    	    cnt(i, 1) = cnt(i, 1) + hn
			endif
			if (polpat(j).gt.0) then
		    	    upCountsS = upCountsS + hn
		    	    cnt(i, 2) = cnt(i, 2) + hn
			endif
			if (polpat(j).lt.0) then
		    	    downCountsS = downCountsS + hn			
		    	    cnt(i, 3) = cnt(i, 3) + hn
			endif
		    endif
		enddo
	    endif
	enddo

c Test for disabled detectors, and suppress up/down/unpol counts
	do i=1,6
	   if (.NOT.BTEST(detMask, i-1)) then
	      cnt(i, 1) = 0
	      cnt(i, 2) = 0
	      cnt(i, 3) = 0
	   endif
	enddo
   	   
	print 302, totalS, unpolS, upS, downS
302	format('WFD scalers: Tot:', I10, ' ( U ', I9, ', + ', I9, ', - ', I9, ')')
	if ((totalS.NE.totalE).OR.(totalS.NE.totalCountsS)) then
	    print 200, scnt
	endif
c
	print 301, totalE, unpolE, upE, downE
301	format('Energy hist: Tot:', I10, ' ( U ', I9, ', + ', I9, ', - ', I9, ')')
	if (totalS.NE.totalE) then
	    print 200, ecnt
	    print *, ' '
	    print *, '>>> Internal WFD error or readout problem -- different counts: scalers <-> energy'
    	    print *, ' '
	    if (abs(totalS - totalE).gt.totalS/1000) then
		statusS = IOR(statusS, Z'40000')
		statusS = IOR(statusS, Z'80000000')
	    else
		statusS = IOR(statusS, Z'10')	    		
	    endif
	endif
c
	print 300, totalCountsS, unpolCountsS, upCountsS, downCountsS
300	format('Bunch histo: Tot:', I10, ' ( U ', I9, ', + ', I9, ', - ', I9, ')')
	print 200, cnt
200	format('Cnt 0 ', 6F12.0, /, 'Cnt + ', 6F12.0, /, 'Cnt - ', 6F12.0)

	if (totalS.NE.totalCountsS) then
	    print *, ' '
	    print *, '>>> Internal WFD error or readout problem -- different counts: scalers <-> bunch'
	    print *, ' '
	    if (abs(totalS - totalCountsS).gt.totalS/1000) then
		statusS = IOR(statusS, Z'40000')
		statusS = IOR(statusS, Z'80000000')
	    else
		statusS = IOR(statusS, Z'10')	    		
	    endif
	endif

c	calculate sqare root asymmetries
c	left-right 90 deg det. (2-5)
c	actually right - left, because we are looking at recoiled particle
	print *, '>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<'
	print *, '>>>>> Square root asymmetries <<<<<' 
	print *, '>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<'	
	print *, '            TYPE           PHYSICS                LUMINOSITY             ACCEPTANCE'
100	format(A20, F10.6, '+-', F8.6, 3X, F10.6, '+-', F8.6, 3X, F10.6, '+-', F8.6)

c	left-right 90 deg det. (2-5)
        call sqass(cnt(2,2), cnt(5,3), cnt(2,3), cnt(5,2), assp, eassp)
     	avgAsymX90S = assp
	avgAsymErrorX90S = eassp
	call sqass(cnt(2,2), cnt(5,2), cnt(2,3), cnt(5,3), assl, eassl)
	call sqass(cnt(5,2), cnt(5,3), cnt(2,3), cnt(2,2), assa, eassa)
	print 100, 'X90 :',assp,eassp,assl,eassl,assa,eassa

c	left-right 45 deg det. (13-46)
	call sqass(cnt(1,2) + cnt(3,2), cnt(4,3) + cnt(6,3), 
     ,		   cnt(4,2) + cnt(6,2), cnt(1,3) + cnt(3,3), assp, eassp)
        avgAsymX45S = assp
	avgAsymErrorX45S = eassp

	call sqass(cnt(1,2) + cnt(3,2), cnt(4,2) + cnt(6,2), 
     ,		   cnt(4,3) + cnt(6,3), cnt(1,3) + cnt(3,3), assl, eassl)
	call sqass(cnt(1,2) + cnt(3,2), cnt(1,3) + cnt(3,3), 
     ,		   cnt(4,2) + cnt(6,2), cnt(4,3) + cnt(6,3), assa, eassa)	

	print 100, 'X45 :',assp,eassp,assl,eassl,assa,eassa

c	up-down 45 deg det (34-16)
	call sqass(cnt(4,2) + cnt(3,2), cnt(1,3) + cnt(6,3), 
     ,		   cnt(4,3) + cnt(3,3), cnt(1,2) + cnt(6,2), assp, eassp)
	call sqass(cnt(4,2) + cnt(3,2), cnt(1,2) + cnt(6,2), 
     ,		   cnt(4,3) + cnt(3,3), cnt(1,3) + cnt(6,3), assl, eassl)
	call sqass(cnt(1,2) + cnt(6,2), cnt(1,3) + cnt(6,3), 
     ,		   cnt(4,3) + cnt(3,3), cnt(4,2) + cnt(3,2), assa, eassa)

	print 100, 'Y45 :',assp,eassp,assl,eassl,assa,eassa

c	cross (forbidden) 45 deg det. (14-36)
	call sqass(cnt(4,2) + cnt(1,2), cnt(3,3) + cnt(6,3), 
     ,		   cnt(4,3) + cnt(1,3), cnt(3,2) + cnt(6,2), assp, eassp)
	call sqass(cnt(6,2) + cnt(3,2), cnt(1,2) + cnt(4,2), 
     ,		   cnt(4,3) + cnt(1,3), cnt(3,3) + cnt(6,3), assl, eassl)
	call sqass(cnt(4,2) + cnt(1,2), cnt(4,3) + cnt(1,3), 
     ,		   cnt(6,3) + cnt(3,3), cnt(3,2) + cnt(6,2), assa, eassa)

	print 100, 'CR45 :',assp,eassp,assl,eassl,assa,eassa
	print *,' '

c Cross 45 deg (1-4) 
	call sqass(cnt(1,2), cnt(4,3),  cnt(1,3), cnt(4,2), assp, eassp)
	call sqass(cnt(1,2), cnt(4,2),  cnt(1,3), cnt(4,3), assl, eassl)
	call sqass(cnt(4,2), cnt(4,3),  cnt(1,3), cnt(1,2), assa, eassa)
	print 100, '1-4 :',assp,eassp,assl,eassl,assa,eassa

c Cross 45 deg (3-6) 
	call sqass(cnt(3,2), cnt(6,3),  cnt(3,3), cnt(6,2), assp, eassp)
	call sqass(cnt(3,2), cnt(6,2),  cnt(3,3), cnt(6,3), assl, eassl)
	call sqass(cnt(6,2), cnt(6,3),  cnt(3,3), cnt(3,2), assa, eassa)
	print 100, '3-6 :',assp,eassp,assl,eassl,assa,eassa

c Bunch per bunch polarizations - given bunch versus sum of all
	print *,'Bunch asymmetries: X90, X45, Y45 physics'
	do i=1,120
	    if (fillpat(i).ne.0.and.polpat(i).ne.0) then
		call sqass(hi(9292,i), cnt(5,2) + cnt(5,3), hi(9295,i), 
     ,			cnt(2,2) + cnt(2,3), assx90, eassx90)
		call sqass(hi(9291,i) + hi(9293,i), cnt(4,2) + cnt(6,2) + cnt(4,3) + cnt(6,3),
     ,			hi(9294,i) + hi(9296,i), cnt(1,2) + cnt(3,2) + cnt(1,3) + cnt(3,3),
     ,			assx45, eassx45)
		call sqass(hi(9293,i) + hi(9294,i), cnt(1,2) + cnt(6,2) + cnt(1,3) + cnt(6,3),
     ,			hi(9291,i) + hi(9296,i), cnt(3,2) + cnt(4,2) + cnt(3,3) + cnt(4,3) ,
     ,			assy45, eassy45)
		write(str, *) 'Bunch', i
		print 100, str, 2*assx90, 2*eassx90, 2*assx45, 2*eassx45, 2*assy45, 2*eassy45
c	01.02.2015 - moved to sqrt asymmetries here
		bunchAsymXS(3*i-2) = 2*assx45
		bunchAsymErrorXS(3*i-2) = 2*eassx45
		bunchAsymYS(3*i-2) = 2*assy45
		bunchAsymErrorYS(3*i-2) = 2*eassy45
	    endif
	enddo	

	if (ilsas.eq.0) return

	print *, '>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<'
	print *, '>>>>> Least squares asymmetries <<<<<' 
	print *, '>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<'

c We suppress 90-degree test detectors if requested
	if (i90OK.eq.0) then
	    cnt(2, 1) = 0
	    cnt(2, 2) = 0
	    cnt(2, 3) = 0
	    cnt(5, 1) = 0
	    cnt(5, 2) = 0
	    cnt(5, 3) = 0
	endif

	call lssqrasym(cnt, avgAsymXS, avgAsymYS, avgAsymErrorXS, avgAsymErrorYS)

     	print 100, 'X :', avgAsymXS, avgAsymErrorXS
     	print 100, 'Y :', avgAsymYS, avgAsymErrorYS

	if (analyzingPowerS .ne. 0.) then
	   	print *, ' '
		xpol  = avgAsymXS/analyzingPowerS
		expol = avgAsymErrorXS/analyzingPowerS
	   	print 100, 'Polarization : ', xpol, expol
	   	print *, ' '
	endif

	if (unpolCountsS.gt.1000) then
	    call lssqrbasym(bassX, bassY, ebassX, ebassY)
	    do i=1,120
		write(str, *) 'Bunch', i
c	01.02.2015 - moved to sqrt asymmetries
c		bunchAsymXS(3*i-2) = bassX(i)
c		bunchAsymErrorXS(3*i-2) = ebassX(i)
		print 100, str, bassX(i), ebassX(i)

		write(str, *) 'Bunch', i
c		bunchAsymYS(3*i-2) = bassY(i)
c		bunchAsymErrorYS(3*i-2) = ebassY(i)
		print 100, str, bassY(i), ebassY(i)
	    enddo
	endif

	return
	end


c
	subroutine sqass(A, B, C, D, ASS, ERR)
c	A - LeftUp, B - RightDown, C - LeftDown, D - RightUp
	den = sqrt(A*B) + sqrt(C*D)
	ASS = 0
	ERR = 1
	if (den.gt.0.1) then
	    ASS = (sqrt(A*B) - sqrt(C*D))/den
	    ERR = sqrt(A*B*(C+D) + C*D*(A+B)) / den**2
	endif
	return
	end


c Calculate square root asymmetry
	subroutine lssqrasym(cnt, ax, ay, eax, eay)
	common/chi2p1/ counts(6, 3)
	external chi2, chutil
	double precision counts, par, epar, bup, blo, cpol, summ
	dimension cnt(6, 3)
	dimension cpol(3)
	character*80 str

	summ = 0.D0
	cpol(1) = 0.D0
	cpol(2) = 0.D0
	cpol(3) = 0.D0

	do i=1,6
	    do j=1,3
		counts(i,j) = cnt(i,j)
		cpol(j)     = cpol(j) + cnt(i,j)
		summ        = summ + cnt(i,j)
	    enddo
	enddo

	call mncomd(chi2, 'set pri -1', irc, chutil)
	call mncomd(chi2, 'clear', irc, chutil)
	call mnseti('Square root avarage asymmetry')

	call mnparm(1, 'AsymX', 0.D0, 0.1D0, 0.D0, 0.D0, irc)
	call mnparm(2, 'AsymY', 0.D0, 0.1D0, 0.D0, 0.D0, irc)
	call mnparm(3, 'Lum0', cpol(1)/6, 0.1*summ, 0.D0, 0.D0, irc)
	call mnparm(4, 'Lum+', cpol(2)/6, 0.1*summ, 0.D0, 0.D0, irc)
	call mnparm(5, 'Lum-', cpol(3)/6, 0.1*summ, 0.D0, 0.D0, irc)

	do i=1,6
	    write(str, *) 'AccDt ', i
	    call mnparm(5+i, str, 1.D0, 0.1D0, 0.D0, 0.D0, irc)
	enddo

c Our normalization
	call mncomd(chi2, 'fix 6', irc, chutil)
	call mncomd(chi2, 'migr', irc, chutil)

	call mnpout(1, str, par, epar, blo, bup, irc)
	ax  = par
	eax = epar

	call mnpout(2, str, par, epar, blo, bup, irc)
	ay  = par
	eay = epar

	call mncomd(chi2, 'show fcnvalue', irc, chutil)
	return
	end


c calculates predicted number of counts
	subroutine chutil(xval, Npos, ipol, result)

	double precision xval(11), result, cs(6), sn(6)
	data sn /0.707106781D0, 1.D0, 0.707106781D0,
     ,		-0.707106781D0, -1.D0, -0.707106781D0/
	data cs /-0.707106781D0, 0.D0, 0.707106781D0,
     ,		0.707106781D0, 0.D0, -0.707106781D0/

c polarization effect
	result = xval(1)*sn(Npos) + xval(2)*cs(Npos)

c luminosity and acceptence
	if (ipol.eq.1) result = xval(3)*xval(5+Npos)
	if (ipol.eq.2) result = (1.D0 + result)*xval(4)*xval(5+Npos)
	if (ipol.eq.3) result = (1.D0 - result)*xval(5)*xval(5+Npos)

	return
	end



	subroutine chi2(npar, grad, fval, xval, iflag, util)
	common/chi2p1/ counts(6, 3)
	external util
	double precision grad(11), fval, xval(11), counts, ccc

	do i=1,11
	    grad(i) = 0.D0
	enddo
	fval = 0.D0
	do i=1,6
	    do j=1,3
		call util(xval, i, j, ccc)
		if (counts(i, j).ne.0) then
		    fval = fval + ((ccc - counts(i, j))**2)/counts(i, j)
		endif
	    enddo
	enddo

	return
	end


c
	subroutine lssqrbasym(ax, ay, eax, eay)
	common /RHIC/ fillpat(120), polpat(120)
	integer fillpat, polpat
	common/chi2b1/ counts(6, 120)
	external chi2b, chbutil
	double precision counts, par, epar, bup, blo, summ
	dimension cnt(6, 3)
	dimension ax(120), ay(120), eax(120), eay(120)
	character*80 str
c	
	summ =0.D0
	do i=1,6
	    do j=1,120
		counts(i,j) = hi(9290+i, j)
	    enddo
	    summ = summ + hsum(9290+i)
	enddo
	summ = summ/720
c
	call mncomd(chi2b, 'clear', irc, chbutil)
	call mnseti('Square root bunch asymmetry')
c		asymmetries and luminosities per bunch
	do i=1, 120
	    write(str, *) 'AsXbn ', i
	    call mnparm(i, str, 0.D0, 0.1D0, 0.D0, 0.D0, irc)
	    write(str, *) 'AsYbn ', i
	    call mnparm(i+120, str, 0.D0, 0.1D0, 0.D0, 0.D0, irc)
	    if (fillpat(i).eq.0.or.polpat(i).eq.0) then
		write(str, *) 'fix ', i, i+120
		call mncomd(chi2b, str, irc, chbutil)
	    endif
	    write(str, *) 'Lumbn ', i
	    if (fillpat(i).eq.0) then
		call mnparm(i+240, str, 0.D0, 0.D0, 0.D0, 0.D0, irc)
		write(str, *) 'fix ', i+240
		call mncomd(chi2b, str, irc, chbutil)		
	    else
		call mnparm(i+240, str, summ, 0.1*summ, 0.D0, 0.D0, irc)		
	    endif	    
	enddo
c	acceptencies per detector
	do i=1,6
	    write(str, *) 'Accdt ', i
		call mnparm(i+360, str, 1.D0, 0.1D0, 0.D0, 0.D0, irc)		
	enddo
c	always fix 1st detector acceptence as general normalization
	call mncomd(chi2b, 'fix 361', irc, chbutil)
c
	call mncomd(chi2b, 'migr', irc, chbutil)
c	get asymmetries
	do i=1,120
    	    call mnpout(i, str, par, epar, blo, bup, irc)
	    ax(i) = par
	    eax(i) = epar
	    call mnpout(i+120, str, par, epar, blo, bup, irc)
	    ay(i) = par
	    eay(i) = epar
	enddo
c
	return
	end
c	
	subroutine chi2b(npar, grad, fval, xval, iflag, util)
	common /RHIC/ fillpat(120), polpat(120)
	integer fillpat, polpat
	common/chi2b1/ counts(6, 120)
	external util
	double precision grad(366), fval, xval(366), counts, ccc
c
	do i=1,366
	    grad(i) = 0.D0
	enddo
	fval = 0.D0
	do i=1,6
	    do j=1,120
		call util(xval, i, j, ccc)
		if (counts(i, j).ne.0.and.fillpat(j).ne.0)
     +		  fval = fval + ((ccc - counts(i, j))**2)/counts(i, j)
	    enddo
	enddo
c		
	return
	end
c
	subroutine chbutil(xval, Npos, ib, result)
c		calculates predicted number of counts
	double precision xval(186), result, cs(6), sn(6)
	data sn /0.707106781D0, 1.D0, 0.707106781D0,
     ,		-0.707106781D0, -1.D0, -0.707106781D0/
	data cs /-0.707106781D0, 0.D0, 0.707106781D0,
     ,		0.707106781D0, 0.D0, -0.707106781D0/
c		polarization effect
	result = xval(ib)*sn(Npos) + xval(ib+120)*cs(Npos)
c		luminosity and acceptence
	result = (1.D0 + result)*xval(240+ib)*xval(360+Npos)
c
	return
	end
C	
	subroutine testpol
	common /RHIC/ fillpat(120), polpat(120)
	integer fillpat, polpat
	real icnt(120)
	dimension alum(120), acc(6), cs(6), sn(6)
	parameter (ap = 0.005)
	parameter (N = 1000000)
	integer itm(3)
	data sn /0.707106781, 1., 0.707106781,
     ,		-0.707106781, -1., -0.707106781/
C 
	call itime(itm)
	call srand(itm(3) + 60*(itm(2) + 60*itm(3)))
	do i=1,120
	    alum(i) = 0.5 + rand(0)
	enddo
	do i=1,6
	    acc(i) = 0.5 + rand(0)
	enddo
	do i=1,6
	    do j=1,120
		result = N*(1.0 + ap*sn(i)*polpat(j))*acc(i)*alum(j)*fillpat(j)
		icnt(j) = int(result + sqrt(result)*(rand(0) - 0.5))
	    enddo
	    call hpak(290+i, icnt)
	enddo
c
	print *, '!!! TEST DATA INIT DONE !!!'
c
	return
	end
c	

	subroutine wfana(rdata, length, ichan)
	real rdata(*)
	common /runpars/ intp, iraw, iproc, ilsas, trigmin, iskip, ichanntp(96)
	common /atraw/ ia, it, itmax, is, iib, iid, iirev, iijet
	common/wfsel/ ibunch, irevfirst
	character chnum*10, chchan*10, chbrev*30
	save icnt
	data icnt /0/
	save ihcnt
	data ihcnt /0/
	real rbase(96) 
	save rbase
	data rbase /96*-1/
c 
	if ((ihcnt.lt.10000).and.(icnt.ge.iskip).and.((ibunch.lt.0).or.(ibunch.eq.iib)).and.(iirev.ge.irevfirst)) then
	    write (chnum, '(I5)') ihcnt
	    write (chchan, '(I3)') ichan
	    write (chbrev, '(I8,'':'',I3)') iirev, iib
	    flength = length
	    call hbook1(10000+ihcnt, 'Waveform No '//chnum//' of chan No '//chchan//' at '//chbrev, length, 0., flength, 0)
	    call hpak(10000+ihcnt, rdata)
	    ihcnt=ihcnt+1
	endif

	if (rbase(ichan).lt.0..and.iirev.ge.irevfirst) then
	    call hnoent(2200+ichan, k)
	    if (k.lt.200) then
		call hfill(2200+ichan, rdata(34), 0., 1.)
	    else
		rbase(ichan) = HSTATI(2200+ichan, 1, 'HIST', 0)
	    endif
	else
	    if (abs(rdata(34) - rbase(ichan)).lt.3) then
		call hfill(2300+ichan, rbase(ichan) - rdata(41), 0., 1.)
	    endif
	endif
    	icnt = icnt + 1
c
	end
c
c   Average analyzing power from Larry Trueman's fit 2004
c   We use 24-GeV version below 50 GeV and 100 GeV above
c
	subroutine AnaPow(polName)

	character*256 polName

	common /poldat/ runIdS, startTimeS, stopTimeS,
     +	    daqVersionS, cutIdS, targetIdS, encoderPositionS,
     +      statusS, statusStringS, totalCountsS, upCountsS,
     +	    downCountsS, unpolCountsS, countsUpLeftS,
     + 	    countsLeftS, countsDownLeftS, countsDownRightS,
     +	    countsRightS, countsUpRightS, avgAsymXS,
     +	    avgAsymX45S, avgAsymX90S, avgAsymYS,
     +	    avgAsymErrorXS, avgAsymErrorX45S, avgAsymErrorX90S,
     +      avgAsymErrorYS, bunchAsymXS, bunchAsymYS,
     +	    bunchAsymErrorXS, bunchAsymErrorYS, beamEnergyS,
     +      analyzingPowerS, analyzingPowerErrorS, numberEventsS,
     +	    maxTimeS
        double precision runIdS
	integer startTimeS, stopTimeS
	character daqVersionS(80), cutIdS(80), targetIdS(80)
	integer encoderPositionS(2), statusS
	character statusStringS(80)
	integer totalCountsS, upCountsS, downCountsS, unpolCountsS
	integer countsUpLeftS(360), countsLeftS(360)
	integer countsDownLeftS(360), countsDownRightS(360)
	integer countsRightS(360), countsUpRightS(360)
	real avgAsymXS, avgAsymX45S, avgAsymX90S, avgAsymYS
	real avgAsymErrorXS, avgAsymErrorX45S, avgAsymErrorX90S
	real avgAsymErrorYS, bunchAsymXS(360), bunchAsymYS(360)
	real bunchAsymErrorXS(360), bunchAsymErrorYS(360)
	real beamEnergyS, analyzingPowerS, analyzingPowerErrorS
	integer numberEventsS, maxTimeS
	real scale250

	real x(128), y(128), ex(128), ey(128)

*	real*4 anth(10)
* A_N values from L. Trueman - old 2003 version
*	data anth/0.034445, 0.026340, 0.020389, 0.016051, 0.012707,
*    +            0.010014, 0.007777, 0.005875, 0.004233, 0.002799/
*        t values: 0.0030,   0.0055,   0.0080,   0.0105,   0.0130, 
*                  0.0155,   0.0180,   0.0205,   0.0230,   0.0255
	
*	t = e * 22.18 / 1000000.
*	Emin = (0.0030-0.0025/2.)*1e6/22.18
*	Emax = (0.0255+0.0025/2.)*1e6/22.18
*
*	New 2004 L. Trueman version
*----------------------------------------------------------------
* analyzing power
*
* A_N values from L. Trueman (new for Run-04)
*      t = e * 22.18 / 1000000.
*      Emin = (0.0010-0.001/2.)*1e6/22.18 = 22.5
*      Emax = (0.0255+0.001/2.)*1e6/22.18 = 1172.2
*
* first point: t = - 0.001
* last  point: t = - 0.025
* step size:  Dt =   0.001 (DE = 45.1 keV)

	real*4 anth(25)
        data anth/ 
     +    0.0324757, 0.0401093, 0.0377283, 0.0339981, 0.0304917,
     +    0.0274323, 0.0247887, 0.0224906, 0.020473,  0.0186837,
     +    0.0170816, 0.0156351, 0.0143192, 0.0131145, 0.0120052,
     +    0.0109786, 0.0100245, 0.00913435, 0.00830108, 0.00751878,
     +    0.00678244, 0.00608782, 0.00543127, 0.00480969, 0.00422038/

* A_N @ 100 GeV from Osamu SPIN 2004 fit

       real*4 anth100(25)
       data anth100/
     +   0.0297964,  0.0372334,  0.0345393,  0.0306988,  0.0272192,
     +   0.0242531,  0.0217307,  0.0195634,  0.0176770,  0.0160148,  
     +   0.0145340,  0.0132021,  0.0119941,  0.0108907,  0.00987651,
     +   0.00893914, 0.00806877, 0.00725722, 0.00649782, 0.00578491,
     +   0.00511384, 0.00448062, 0.00388186, 0.00331461, 0.00277642/

	Emin = 22.5
	Emax = 1172.2
	DeltaE = (Emax - Emin)/25.

*	Emin = 78.9
*	Emax = 1206.0
*	DeltaE = (Emax - Emin)/10.
	call hrebin(600, X, Y, EX, EY, 128, 1, 128)
	
	s = 0.
	sa = 0.
	do i = 1,128
	    j = INT((X(i) - Emin)/DeltaE)+1
	    s = s + Y(i)
            if (beamEnergyS.lt.50.0) then 
              sa = sa + Y(i)*anth(j)
            else
              sa = sa + Y(i)*anth100(j)
            endif
	enddo

C	20% error
	analyzingPowerS = sa * GetRenorm(polName) / s
	analyzingPowerErrorS = 0.2 * analyzingPowerS
	
	print *, 'Average analyzing power from L.Trueman''s fit=', analyzingPowerS
	
	end
c
c   Analyzing power correction based on HJET normalization
c   We read it from file $CONFDIR/polName.normalization
c
	Function GetRenorm(polName)

	character*256  polName
        character*512  confDir
        character*1024 fileName
        real CORR
c
        CORR = 1
        Call GetEnv('POLCONF', confDir)
        fileName = confDir(1:len_trim(confDir))//'/'//
     *      polName(1:len_trim(polName))//'.normalization'
c        print *, 'Correction file:'//fileName(1:len_trim(fileName))
        open(unit=20, file=fileName, form='formatted', 
     *          type='old', err=20)
        read (20, *) CORR
        close(20)
        print *, 'Correction file:'//fileName(1:len_trim(fileName))
c
20      continue
        print *, 'This run correction for '//
     *         polName(1:len_trim(polName))//' is ', CORR
        GetRenorm = CORR
        return
        end
c
c
c
	subroutine FlagOut(polName)
	character*256 polName
c		maximum relative sigma
	parameter (sigmax = 0.05)
c		minimum number of channels untill killing the whole detector
	parameter (nmin = 6)
c		Flag out too offset channels following logic of W. Schmidke's repol.f
	common /sipar/ idiv, rnsperchan, emin, etrg, ifine, ecoef(96), edead(96), tmin(96), mark(96)
	double precision sumplus, sumplus2, summinus, summinus2, sigplus, sigminus
c		Cicle over detectors 
	do i = 1, 6
c		Run 12: blu2 det 1 and 6 have vertical orientation, so must have enequal distribution
	    if (.not.((polName(13:16).eq.'blu2').and.((i.eq.1).or.(i.eq.6)))) then
100		continue
c		count events
		n = 0
		sumplus = 0
		summinus = 0
		sumplus2 = 0
		summinus2 = 0
		do j = 1, 12
		    id = 12*(i-1) + j
		    if (mark(id).eq.0) then
			n = n + 1
			sumplus  = sumplus + hsum(400 + id)
			summinus = summinus + hsum(500 + id)
			sumplus2  = sumplus2 + hsum(400 + id)**2
			summinus2 = summinus2 + hsum(500 + id)**2
		    endif
		enddo
c	Kill the detector if there is no events or number of good channels below minimum
		if (n.lt.nmin.or.sumplus.lt.1.or.summinus.lt.1) then
		    do j = 1, 12
			mark(12*(i-1) + j) = 1
		    enddo
		    print *, '****** >>> Whole detector ', i, ' flagged out'
		    goto 200
		endif
c		calculate relative sigma
		sumplus  = sumplus / n
		sumplus2 = sumplus2 / n
		sigplus = sqrt(sumplus2 - sumplus**2) / sumplus
		summinus  = summinus / n
		summinus2 = summinus2 / n
		sigminus = sqrt(summinus2 - summinus**2) / summinus
		if (sigplus.le.sigmax.and.sigminus.le.sigmax) goto 200
c	Kill the most outstanding channel
		delta = 0
		n = 12*i - 11
		do j = 1, 12
		    id = 12*(i-1) + j
		    d = max(abs(sumplus - hsum(400 + id)), abs(summinus - hsum(500 + id)))
		    if ((mark(id).eq.0).and.(d.gt.delta)) then
			delta = d
			n = id
		    endif
		enddo
		mark(n) = 1
		print *, '*** >>> Flag out strip : ', n
		goto 100
200		continue
	    endif
	enddo
c
	return
	end
