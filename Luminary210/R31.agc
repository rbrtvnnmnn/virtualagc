### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    R31.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 706-710
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##		2016-12-01 RSB	Completed.  Other than correction of typos
##				in comments and change in the positioning
##				of the constant V16N54, there were no changes.
##              2016-12-01 HG   fix operand V15N54  -> V16N54
##                              remove V16N54 from its old location 
##		2016-12-25 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.

## Page 706
		BANK	40
		SETLOC	R31LOC
		BANK

		COUNT*	$$/R31

R31CALL		CAF	PRIO3
		TC	FINDVAC
		EBANK=	SUBEXIT
		2CADR	V83CALL

DSPDELAY	TC	FIXDELAY
		DEC	100
		CA	EXTVBACT
		MASK	BIT12
		EXTEND
		BZF	DSPDELAY

		CAF	PRIO5
		TC	NOVAC
		EBANK=	TSTRT
		2CADR	DISPN5X

		TCF	TASKOVER

V16N54		VN	1654
DISPN5X		CAF	V16N54
		TC	BANKCALL
		CADR	GOMARKF
		TC	B5OFF
		TC	B5OFF
		TCF	DISPN5X

		BANK	37
		SETLOC	R31
		BANK

V83CALL		CS	FLAGWRD7	# TEST AVERAGE G FLAG
		MASK	AVEGFBIT
		EXTEND
		BZF	MUNG?		# ON - TEST MUNFLAG

		CS	FLAGWRD8
		MASK	SURFFBIT
		EXTEND
		BZF	ONEBASE		# ON SURFACE - BYPASS LEMPREC

		TC	INTPRET		# EXTRAPOLATE BOTH STATE VECTORS
		RTB
## Page 707
			LOADTIME
		STCALL	TDEC1
			LEMPREC		# PRECISION BASE VECTOR FOR LM
		VLOAD
			RATT1
		STOVL	BASETHP
			VATT1
		STODL	BASETHV
			TAT
DOCMBASE	STORE	BASETIME	# PRECISION BASE VECTOR FOR CM
		STCALL	TDEC1
			CSMPREC
		VLOAD
			RATT1
		STOVL	BASEOTP
			VATT1
		STORE	BASEOTV
		EXIT

REV83		CS	FLAGWRD7
		MASK	AVEGFBIT
		EXTEND
		BZF	GETRVN		# IF AVEGFLAG SET, USE RN,VN

		CS	FLAGWRD8
		MASK	SURFFBIT
		EXTEND
		BZF	R31SURF		# IF ON SURFACE, USE LEMAREC

		TC	INTPRET		# DO CONIC EXTRAPOLATION FOR BOTH VEHICLES
		RTB
			LOADTIME
		STCALL	TDEC1
			INTSTALL
		VLOAD	CLEAR
			BASETHP
			MOONFLAG
		STOVL	RCV
			BASETHV
		STODL	VCV
			BASETIME
		BOF	SET		# GET APPROPRIATE MOONFLAG SETTING
			MOONTHIS
			+2
			MOONFLAG
		SET
			INTYPFLG	# CONIC EXTRAP.
		STCALL	TET
			INTEGRVS	# INTEGRATION --- AT LAST---
OTHCONIC	VLOAD
## Page 708
			RATT
		STOVL	RONE
			VATT
		STCALL	VONE		# GET SET FOR CONIC EXTRAP.,OTHER.
			INTSTALL
		SET	DLOAD
			INTYPFLG
			TAT
OTHINT		STORE	TDEC1
		VLOAD	CLEAR
			BASEOTP
			MOONFLAG
		STOVL	RCV
			BASEOTV
		STODL	VCV
			BASETIME
		BOF	SET
			MOONTHIS
			+2
			MOONFLAG
		STCALL	TET
			INTEGRVS
COMPDISP	VLOAD	VSU
			RATT
			RONE
		RTB	PDDL
			NORMUNX1	# UNIT(RANGE) TO PD 0-5
			36D
		SL*			# RESCALE AFTER NORMUNIT
			0,1
		STOVL	RANGE		# SCALED 2(29)M
			VATT
		VSU	DOT		# (VCM-VLM).UNIT(LOS), PD=0
			VONE
		SL1			# SCALED 2(7)M/CS
		STOVL	RRATE
			RONE
		UNIT	PDVL		# UNIT(R) TO PD 0-5
			UNITZ
		CALL
			CDU*NBSM
		VXM	PUSH		# UNIT(Z)/4 TO PD 6-11
			REFSMMAT
		VPROJ	VSL2		# UNIT(P)=UNIT(UZ-(UZ)PROJ(UR))
			0D
		BVSU	UNIT
			6D
		PDVL	VXV		# UNIT(P) TO PD 12-17
			0D		# UNIT(RL)
			VONE
## Page 709
		VXV	DOT		# (UR * VL)*UR . U(P)
			0D
			12D
		PDVL			# SIGN TO 12-13 , LOAD U(P)
		DOT	SIGN
			6D
			12D
		SL2	ACOS		# ARCCOS(UP.UZ(SIGN))
		STOVL	RTHETA
			0D
		DOT	BPL		# IF UR.UZ NEG,
			6D		#   RTHETA = 1 - RTHETA
			+5
		DLOAD	DSU
			DPPOSMAX
			RTHETA
		STORE	RTHETA
		EXIT

		CA	BIT5
		MASK	EXTVBACT
		EXTEND			# IF ANSWERED,
		BZF	ENDEXT		#	 TERMINATE

		CS	EXTVBACT
		MASK	BIT12
		ADS	EXTVBACT	# SET BIT 12
		TCF	REV83		# AND START AGAIN.

GETRVN		CA	PRIO22		# INHIBIT SERVICER
		TC	PRIOCHNG
		TC	INTPRET
		VLOAD	SETPD
			RN		# LM STATE VECTOR IN RN,VN
			0
		STOVL	RONE
			VN
		STOVL	VONE		# LOAD R(CSM),V(CSM) IN CASE MUNFLAG SET
			V(CSM)		# (TO INSURE TIME COMPATABILITY)
		PDVL	PDDL
			R(CSM)
			PIPTIME
		EXIT
		CA	PRIO3
		TC	PRIOCHNG
		TC	INTPRET
		BOFF	VLOAD
			MUNFLAG
			GETRVN2		# IF MUNFLAG RESET, DO CM DELTA PRECISION
## Page 710
		VXM	VSR4		# CHANGE TO REFERENCE SYSTEM AND RESCALE
			REFSMMAT
		PDVL			# R TO PD 0-5
		VXM	VSL1
			REFSMMAT
		PUSH	SETPD		# V TO PD 5-11
			0
		GOTO
			COMPDISP

GETRVN2		CALL
			INTSTALL
		CLEAR	GOTO
			INTYPFLG	# PREC EXTRAP FOR OTHER
			OTHINT
R31SURF		TC	INTPRET
		RTB			# LM IS ON SURFACE, SO PRECISION
			LOADTIME	# INTEGRATION USES PLANETARY INERTIAL
		STCALL	TDEC1		# ORIENTATION SUBROUTINE
			LEMPREC
		GOTO			# DO CSM CONIC
			OTHCONIC
MUNG?		CS	FLAGWRD6
		MASK	MUNFLBIT
		EXTEND
		BZF	GETRVN		# IF MUNFLAG SET, CSM BASE NOT NEEDED

ONEBASE		TC	INTPRET		# GET CSM BASE VECTOR
		RTB	GOTO
			LOADTIME
			DOCMBASE
                        