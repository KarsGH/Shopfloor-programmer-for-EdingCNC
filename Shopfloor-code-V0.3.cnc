;############################################################################################
;#################        BEGIN SHOPFLOOR PROGRAMMER FOR EDINGCNC      ######################
;############################################################################################

: V0.3 (changes made by Kars Schaapman)
; New functions: Side milling and Slitting
; Extended functions:
:		Drilling is now Square-Drilling, it supports drilling a line or a matrix of holes.
;		The function circular drilling now also allows drilling holes on an Arc.
; 		The function Flatten now allows to select the milling direction.
; The input fields "Mist" and "Flood" are combined into one input field.
; Basic checks on some input parameters have been added. If a check fails, the message 
; 		"Input parameters incorrect!!!" will appear. Take care; only some easy made mistakes are covered!	
; Parameter useage is compacted to #3000..#3154 for volatile and #4700..#4920 for non-volatile parameters
; Various small bugfixes.

; v0.2.2 (Written by Niels Saarloos, originator of the Shopfloor Programmer for EdingCNC)
; Minor bugfixes:
; Square contour coordinates changed to sizes instead. Overshootcompensation was calculated wrong.
; Added brackets to variables conform interpreter needs.
; Stepover Helix lead in changed to half the radius from centerpoint.

; v0.2.1
; Stepover changed in percentage: 1 = 100%  0.5 = 50%
; Circular drilling starting point moved from Y axis to X axis.
; Toolcompensation was not read but filled by the number entered.
; New features: Tapping and machine warm-up.

;############################################################################################



Sub SHOPFLOOR_HEADER
LogMsg ";-------------------------------------------------------------------------------"
LogMsg "; Shopfloor programmer for Eding-CNC "
LogMsg "; v0.3.0"
LogMsg ";-------------------------------------------------------------------------------"
Endsub

Sub user_19
#3154=0
    Gosub SHOPFLOOR_HEADERS
Endsub
Sub user_20
    Gosub SHOPFLOOR_FLATTEN
Endsub
Sub user_21
    Gosub SHOPFLOOR_SIDEMILLING
Endsub
Sub user_22
    Gosub SHOPFLOOR_SQUARECONTOUR
Endsub
Sub user_23
    Gosub SHOPFLOOR_ROUNDCONTOUR
Endsub
Sub user_24
    Gosub SHOPFLOOR_SQUAREPOCKET
Endsub
Sub user_25
    Gosub SHOPFLOOR_ROUNDPOCKET
Endsub
Sub user_26
    Gosub SHOPFLOOR_SLOTTING
Endsub
Sub user_27
    Gosub SHOPFLOOR_SLITTING
Endsub
Sub user_28
    Gosub SHOPFLOOR_SQUARE_DRILLING
Endsub
Sub user_29
    Gosub SHOPFLOOR_CIRCULAR_DRILLING
Endsub
Sub user_30
    Gosub SHOPFLOOR_TAPPING
Endsub
Sub user_31
    Gosub SHOPFLOOR_PARTPROGRAM
Endsub
Sub user_32
    Gosub WARM_UP
Endsub

;#### DIALOG SUBS ########

Sub SHOPFLOOR_PARTPROGRAM
#3154=1
DLGMSG "Shopfloor new program" "1=YES 0=NO" 3153
	If [#5398 == 1]
		If [#3153==1]
			LOGFILE _shopfloor_part.cnc 0
			LOGFILE _shopfloor_part.cnc 1
			Gosub SHOPFLOOR_HEADER
		Endif
		#3153=0
		If [#3150==1]
			Gosub SHOPFLOOR_HEADERS
		Endif
		If [#3150==2]
			Gosub SHOPFLOOR_FLATTEN
		Endif
		If [#3150==3]
			Gosub SHOPFLOOR_SIDEMILLING
		Endif
		If [#3150==4]
			Gosub SHOPFLOOR_SQUARECONTOUR
		Endif
		If [#3150==5]
			Gosub SHOPFLOOR_ROUNDCONTOUR
		Endif
		If [#3150==6]
			Gosub SHOPFLOOR_SQUAREPOCKET
		Endif
		If [#3150==7]
			Gosub SHOPFLOOR_ROUNDPOCKET
		Endif
		If [#3150==8]
			Gosub SHOPFLOOR_SLOTTING
		Endif
		If [#3150==9]
			Gosub SHOPFLOOR_SLITTING
		Endif	
		If [#3150==10]
			Gosub SHOPFLOOR_SQUARE_DRILLING
		Endif
		If [#3150==11]
			Gosub SHOPFLOOR_CIRCULAR_DRILLING
		Endif
		If [#3150==12]
			Gosub SHOPFLOOR_TAPPING
		Endif
		If [#3150<1]
			DLGMSG "NO CYCLE SPECIFIED"
		Endif
	Else
		msg "SHOPFLOOR_PARTPROGRAM User canceled"
	Endif
	#3154=0
Endsub	

Sub SHOPFLOOR_HEADERS
	#3150=1
	DlgMsg "shopfloor Header" "Select" 4700 
	If [#5398 == 1]
		If [#3154==1]
			LOGFILE _shopfloor_part.cnc 1
		Else
			Gosub FileNew
			LOGFILE _shopfloor_teach.cnc 1
		Endif
		LOGMSG "(CYCLE DEFINITION Headers)"
		LOGMSG "	#3000=1			(CYCLE INDEX)"
		LOGMSG "	#4700=" [#4700] "	(Header)"
		LOGMSG "M99"
		Gosub FileEnd
	Else
		#3154=0
		msg "SHOPFLOOR_HEADERS User canceled"
	Endif
Endsub	
	
Sub SHOPFLOOR_FLATTEN
	#3150=2
	dlgmsg "shopfloor Flatten" "Direction: 0=auto, 1=X, 2=Y" 4919 "X start" 4901 "Y start" 4902 "X size" 4911 "Y size" 4912 "Z start" 4903 "Z End" 4913 "Stepover (0..1)" 4905 "Z Increment" 4906 "Tool (1..99)" 4914 "Speed (rpm)" 4916 "Coolant (0,1,2)" 4918 "Feed (mm/min)" 4904 "Safe Z" 4907
	If [#5398 == 1]
		If [[#4919>=0] AND [#4919<=2] AND [#4903>#4913] AND [#4911>0] AND [#4912>0] AND [#4905>0] AND [#4905<=1] AND [#4906>0] AND [#4907>=[#4903+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Flatten)"
			LOGMSG "	#3000=2			(CYCLE INDEX)"
			LOGMSG "	#4919=" [#4919] "	(Direction)"
			LOGMSG "	#4901=" [#4901] "	(X start)"
			LOGMSG "	#4902=" [#4902] "	(Y start)"
			LOGMSG "	#4911=" [#4911] "	(X size)"
			LOGMSG "	#4912=" [#4912] "	(Y size)"
			LOGMSG "	#4905=" [#4905] "	(Stepover)"
			LOGMSG "	#4903=" [#4903] "	(Z start)"
			LOGMSG "	#4913=" [#4913] "	(Z End)"
			LOGMSG "	#4906=" [#4906] "	(Z Increment)"
			LOGMSG "	#4914=" [#4914] "	(Tool)"
			LOGMSG "	#4916=" [#4916] "	(Speed)"
			LOGMSG "	#4918=" [#4918] "	(Coolant)"
			LOGMSG "	#4904=" [#4904] "	(Feed)"
			LOGMSG "	#4907=" [#4907] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_FLATTEN User canceled"
	Endif
Endsub 

Sub SHOPFLOOR_SIDEMILLING
	#3150=3
	dlgmsg "shopfloor SideMilling" "Side (1..4)" 4759 "X start" 4741 "Y start" 4742 "X size" 4751 "Y size" 4752 "Z start" 4743 "Z End" 4753 "Stepover (0..1)" 4745 "Z Increment" 4746 "Tool (1..99)" 4754 "Speed (rpm)" 4756 "Coolant (0,1,2)" 4758 "Feed (mm/min)" 4744 "Safe Z" 4747
	If [#5398 == 1]
		If [[#4759>=1] AND [#4759<=4] AND [#4743>#4753] AND [#4751>0] AND [#4752>0] AND [#4745>0] AND [#4745<=1] AND [#4746>0] AND [#4747>=[#4743+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION SIDEMILLING)"
			LOGMSG "	#3000=3			(CYCLE INDEX)"
			LOGMSG "	#4759=" [#4759] "	(Side?)"
			LOGMSG "	#4741=" [#4741] "	(X start)"
			LOGMSG "	#4742=" [#4742] "	(Y start)"
			LOGMSG "	#4751=" [#4751] "	(X size)"
			LOGMSG "	#4752=" [#4752] "	(Y size)"
			LOGMSG "	#4745=" [#4745] "	(Hor. Stepover)"
			LOGMSG "	#4743=" [#4743] "	(Z start)"
			LOGMSG "	#4753=" [#4753] "	(Z End)"
			LOGMSG "	#4746=" [#4746] "	(Z Increment)"
			LOGMSG "	#4754=" [#4754] "	(Tool)"
			LOGMSG "	#4756=" [#4756] "	(Speed)"
			LOGMSG "	#4758=" [#4758] "	(Coolant)"
			LOGMSG "	#4744=" [#4744] "	(Feed)"
			LOGMSG "	#4747=" [#4747] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_SIDEMILLING User canceled"
	Endif
Endsub 

Sub SHOPFLOOR_SQUARECONTOUR
	#3150=4
	dlgmsg "shopfloor SQUARECONTOUR" "X start" 4781 "Y start" 4782 "X size" 4791 "Y size" 4792 "Z start" 4783 "Z End" 4793 "Z Increment" 4786 "Tool (1..99)" 4794 "Outside (0/1)" 4795 "Speed (rpm)" 4796 "Coolant (0,1,2)" 4798 "Feed (mm/min)" 4784 "Safe Z" 4787
	If [#5398 == 1]
		If [[#4783>#4793] AND [#4791>#[5500+#4794]] AND [#4792>#[5500+#4794]] AND [#4791>0] AND [#4792>0] AND [#4786>0] AND [#4787>=[#4783+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Square Contour)"
			LOGMSG "	#3000=4			(CYCLE INDEX)"
			LOGMSG "	#4781=" [#4781] "	(X start)"
			LOGMSG "	#4782=" [#4782] "	(Y start)"
			LOGMSG "	#4791=" [#4791] "	(X size)"
			LOGMSG "	#4792=" [#4792] "	(Y Size)"
			LOGMSG "	#4783=" [#4783] "	(Z start)"
			LOGMSG "	#4793=" [#4793] "	(Z End)"
			LOGMSG "	#4786=" [#4786] "	(Z Increment)"
			LOGMSG "	#4794=" [#4794] "	(Tool)"
			LOGMSG "	#4795=" [#4795] "	(Outside)"
			LOGMSG "	#4796=" [#4796] "	(Speed)"
			LOGMSG "	#4798=" [#4798] "	(Coolant)"
			LOGMSG "	#4784=" [#4784] "	(Feed)"
			LOGMSG "	#4787=" [#4787] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_SQUARECONTOUR User canceled"
	Endif
Endsub

Sub SHOPFLOOR_ROUNDCONTOUR
	#3150=5
	dlgmsg "shopfloor ROUNDCONTOUR" "Diameter " 4825 "X center" 4831 "Y center" 4832 "Z start" 4823 "Z End" 4833 "Z Increment" 4826 "Tool (1..99)" 4834 "Outside (0/1)" 4835 "Speed (rpm)" 4836 "Coolant (0,1,2)" 4838 "Feed (mm/min)" 4824 "Safe Z " 4827 ;#/# values
	If [#5398 == 1]
		If [[#4823>#4833] AND [#4825>#[5500+#4834]] AND [#4826>0] AND [#4827>=[#4823+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Round Contour)"
			LOGMSG "	#3000=5			(CYCLE INDEX)"
			LOGMSG "	#4825=" [#4825] "	(diameter)"
			LOGMSG "	#4831=" [#4831] "	(X center)"
			LOGMSG "	#4832=" [#4832] "	(Y center)"
			LOGMSG "	#4823=" [#4823] "	(Z start)"
			LOGMSG "	#4833=" [#4833] "	(Z End)"
			LOGMSG "	#4826=" [#4826] "	(Z Increment)"
			LOGMSG "	#4834=" [#4834] "	(Tool)"
			LOGMSG "	#4835=" [#4835] "	(Outside)"
			LOGMSG "	#4836=" [#4836] "	(Speed)"
			LOGMSG "	#4838=" [#4838] "	(Coolant)"
			LOGMSG "	#4824=" [#4824] "	(Feed)"
			LOGMSG "	#4827=" [#4827] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_ROUNDCONTOUR User canceled"
	Endif
Endsub

Sub SHOPFLOOR_SQUAREPOCKET
	#3150=6
	dlgmsg "shopfloor SQUAREPOCKET" "X start" 4851 "Y start" 4852 "X size" 4841 "Y size" 4842 "Z start" 4843 "Z End" 4853 "Z increment" 4846 "Stepover (0..1)" 4845 "Tool (1..99)" 4854 "Speed (rpm)" 4856 "Coolant (0,1,2)" 4858 "Feed (mm/min)" 4844 "Z lead-in increment" 4848 "Lead-in feed (mm/min)" 4849 "Safe Z" 4847
	If [#5398 == 1]
		If [[#4843>#4853] AND [#4846>0] AND[#4845>0] AND [#4845<=1] AND [#4848>0] AND [#4847>=[#4843+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Square Pocket)"
			LOGMSG "	#3000=6			(CYCLE INDEX)"
			LOGMSG "	#4851=" [#4851] "	(X start)"
			LOGMSG "	#4852=" [#4852] "	(Y start)"
			LOGMSG "	#4841=" [#4841] "	(X Size)"
			LOGMSG "	#4842=" [#4842] "	(Y Size)"
			LOGMSG "	#4843=" [#4843] "	(Z Start)"
			LOGMSG "	#4853=" [#4853] "	(Z End)"
			LOGMSG "	#4846=" [#4846] "	(Z Increment)"
			LOGMSG "	#4845=" [#4845] "	(Stepover)"
			LOGMSG "	#4854=" [#4854] "	(Tool)"
			LOGMSG "	#4856=" [#4856] "	(Speed)"
			LOGMSG "	#4858=" [#4858] "	(Coolant)"
			LOGMSG "	#4844=" [#4844] "	(Feed)"
			LOGMSG "	#4848=" [#4848] "	(Z lead in increment)"
			LOGMSG "	#4849=" [#4849] "	(Z feed)"
			LOGMSG "	#4847=" [#4847] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd	
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_SQUAREPOCKET User canceled"
	Endif
Endsub

Sub SHOPFLOOR_ROUNDPOCKET ; check minimum diameter versus tooldiameter!!!
	#3150=7
	dlgmsg "shopfloor ROUNDPOCKET" "Diameter" 4861 "X center" 4871 "Y center" 4872 "Z Start" 4863 "Z End" 4873 "Z Increment" 4866 "Stepover (0..1)" 4865 "Tool (1..99)" 4874 "Speed (rpm)" 4876 "Coolant (0,1,2)" 4878 "Feed (mm/min)" 4864 "Z lead-in increment" 4868 "Lead-in feed (mm/min)" 4869 "Safe Z" 4867
	If [#5398 == 1]
		If [[#4863>#4873] AND [#4866>0] AND [#4865>0] AND [#4865<=1] AND [#4868>0] AND [#4867>=[#4863+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Round Pocket"
			LOGMSG "	#3000=7			(CYCLE INDEX)"
			LOGMSG "	#4861=" [#4861] "	(diameter)"
			LOGMSG "	#4871=" [#4871] "	(X center)"
			LOGMSG "	#4872=" [#4872] "	(Y center)"
			LOGMSG "	#4863=" [#4863] "	(Z start)"
			LOGMSG "	#4873=" [#4873] "	(Z End)"
			LOGMSG "	#4866=" [#4866] "	(Z Increment)"
			LOGMSG "	#4865=" [#4865] "	(Stepover)"
			LOGMSG "	#4874=" [#4874] "	(Tool)"
			LOGMSG "	#4876=" [#4876] "	(Speed)"
			LOGMSG "	#4878=" [#4878] "	(Coolant)"
			LOGMSG "	#4864=" [#4864] "	(Feed)"
			LOGMSG "	#4868=" [#4868] "	(Z lead in increment)"
			LOGMSG "	#4869=" [#4869] "	(Z feed)"
			LOGMSG "	#4867=" [#4867] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_ROUNDPOCKET User canceled"
	Endif
Endsub

Sub SHOPFLOOR_SLOTTING
	#3150=8
	dlgmsg "shopfloor SLOTTING" "X center" 4891 "Y center" 4892 "X size" 4881 "Y size" 4882 "Z start" 4883 "Z End" 4893 "Z Increment" 4886 "Tool (1..99)" 4894 "Speed (rpm)" 4896 "Coolant (0,1,2)" 4898 "Feed (mm/min)" 4884 "Safe Z" 4887
	If [#5398 == 1]
		If [[#4883>#4893] AND [#4881>#[5500+#4894]] AND [#4882>#[5500+#4894]] AND [#4886>0] AND [#4887>=[#4883+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Slotting"
			LOGMSG "	#3000=8			(CYCLE INDEX)"
			LOGMSG "	#4891=" [#4891] "	(X center)"
			LOGMSG "	#4892=" [#4892] "	(Y center)"
			LOGMSG "	#4881=" [#4881] "	(X size)"
			LOGMSG "	#4882=" [#4882] "	(Y size)"
			LOGMSG "	#4883=" [#4883] "	(Z start)"
			LOGMSG "	#4893=" [#4893] "	(Z End)"
			LOGMSG "	#4886=" [#4886] "	(Z Increment)"
			LOGMSG "	#4894=" [#4894] "	(Tool)"
			LOGMSG "	#4896=" [#4896] "	(Speed)"
			LOGMSG "	#4898=" [#4898] "	(Coolant)"
			LOGMSG "	#4884=" [#4884] "	(Feed)"
			LOGMSG "	#4887=" [#4887] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_SLOTTING User canceled"
	Endif
Endsub

Sub SHOPFLOOR_SLITTING
	#3150=9
	dlgmsg "shopfloor SLITTING" "X start" 4721 "Y start" 4722 "X End" 4731 "Y End" 4732 "Z start" 4723 "Z End" 4733 "Z Increment" 4726 "Tool (1..99)" 4734 "Speed (rpm)" 4736 "Coolant (0,1,2)" 4738 "Feed (mm/min)" 4724 "Z-Feed (mm/min)" 4729 "Safe Z" 4727
	If [#5398 == 1]
		If [[#4723>#4733] AND [#4726>0] AND [#4729>0] AND [#4727>=[#4723+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Slitting"
			LOGMSG "	#3000=9			(CYCLE INDEX)"
			LOGMSG "	#4721=" [#4721] "	(X start)"
			LOGMSG "	#4722=" [#4722] "	(Y start)"
			LOGMSG "	#4731=" [#4731] "	(X End)"
			LOGMSG "	#4732=" [#4732] "	(Y End)"
			LOGMSG "	#4723=" [#4723] "	(Z start)"
			LOGMSG "	#4733=" [#4733] "	(Z End)"
			LOGMSG "	#4726=" [#4726] "	(Z Increment)"
			LOGMSG "	#4734=" [#4734] "	(Tool)"
			LOGMSG "	#4736=" [#4736] "	(Speed)"
			LOGMSG "	#4738=" [#4738] "	(Coolant)"
			LOGMSG "	#4724=" [#4724] "	(Feed)"
			LOGMSG "	#4729=" [#4729] "	(Z-Feed)"		
			LOGMSG "	#4727=" [#4727] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_SLITTING User canceled"
	Endif
Endsub

Sub SHOPFLOOR_SQUARE_DRILLING
	#3150=10
	Dlgmsg "Shopfloor Square Drilling" "X start" 4701 "Y start" 4702 "X increment" 4711 "Y increment" 4712 "X nr. of holes" 4709 "Y nr. of holes" 4710 "Z start" 4703 "Z End" 4713  "Retract (R)" 4705 "Peck increment (Q)" 4706 "Tool (0..99))" 4714 "Speed (rpm)" 4716 "Coolant (0,1,2)" 4718 "Feed (mm/min)" 4704 "Safe Z" 4707
	If [#5398 == 1]
		If [[#4703>#4713] AND [ABS[#4711]>=#[5500+#4814]] AND [ABS[#4712]>=#[5500+#4814]] AND [#4709>=1] AND [#4710>=1] AND [#4705>0] AND [#4706>0] AND [#4707>=[#4703+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Square Drilling"
			LOGMSG "	#3000=10			(CYCLE INDEX)"
			LOGMSG "	#4701=" [#4701] "	(X start)"
			LOGMSG "	#4702=" [#4702] "	(Y start)"
			LOGMSG "	#4711=" [#4711] "	(X increment)"
			LOGMSG "	#4712=" [#4712] "	(Y increment)"
			LOGMSG "	#4709=" [#4709] "	(X nr. of holes)"
			LOGMSG "	#4710=" [#4710] "	(Y nr. of holes)"
			LOGMSG "	#4703=" [#4703] "	(Z start)"
			LOGMSG "	#4713=" [#4713] "	(Z End)"
			LOGMSG "	#4705=" [#4705] "	(Retract R)"
			LOGMSG "	#4706=" [#4706] "	(Peck Increment Q)"
			LOGMSG "	#4714=" [#4714] "	(Tool)"
			LOGMSG "	#4716=" [#4716] "	(Speed)"
			LOGMSG "	#4718=" [#4718] "	(Coolant)"
			LOGMSG "	#4704=" [#4704] "	(Feed)"
			LOGMSG "	#4707=" [#4707] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_SQUARE_DRILLING User canceled"
	Endif
Endsub

Sub SHOPFLOOR_CIRCULAR_DRILLING
	#3150=11
	dlgmsg "shopfloor CIRCULAR DRILLING" "X center" 4811 "Y center" 4812 "Diameter" 4801 "number of holes (>=2)" 4802 "Start angle (deg.)" 4805 "Arc angle (deg.)" 4817 "Z start" 4803 "Z End" 4813 "Peck increment (Q)" 4806 "Retract (R)" 4819 "Tool (1..99)" 4814 "Speed (rpm)" 4816 "Coolant (0,1,2)" 4818 "Feed (mm/min)" 4804 "Safe Z" 4807
	If [#5398 == 1]
		If [[#4803>#4813] AND [#4801>=#[5500+#4814]] AND [#4802>=2] AND [#4805>=0] AND [#4805<360] AND [#4817>0] AND [#4817<=360] AND [#4806>0] AND [#4819>0] AND [#4807>=[#4803+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Circular drilling)"
			LOGMSG "	#3000=11			(CYCLE INDEX)"
			LOGMSG "	#4811=" [#4811] "	(X center)"
			LOGMSG "	#4812=" [#4812] "	(Y center)"
			LOGMSG "	#4801=" [#4801] "	(Diameter)"
			LOGMSG "	#4802=" [#4802] "	(Number of holes)"
			LOGMSG "	#4805=" [#4805] "	(Start angle (deg.)"
			LOGMSG "	#4817=" [#4817] "	(Arc angle (360=circle)"
			LOGMSG "	#4803=" [#4803] "	(Z start)"
			LOGMSG "	#4813=" [#4813] "	(Z End)"
			LOGMSG "	#4806=" [#4806] "	(Peck increment (Q)"
			LOGMSG "	#4819=" [#4819] "	(Retract (R)"
			LOGMSG "	#4814=" [#4814] "	(Tool)"
			LOGMSG "	#4816=" [#4816] "	(Speed)"
			LOGMSG "	#4818=" [#4818] "	(Coolant)"
			LOGMSG "	#4804=" [#4804] "	(Feed)"
			LOGMSG "	#4807=" [#4807] "	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_CIRCULAR_DRILLING User canceled"
	Endif
Endsub

Sub SHOPFLOOR_TAPPING
	#3150=12
	Dlgmsg "shopfloor Tapping" "X" 4761 "Y" 4762 "Z start" 4771 "Z End" 4763  "Lead" 4770 "Retract" 4769  "Tool" 4764 "Speed" 4766 "Coolant" 4768 "Safe Z" 4772
	If [#5398 == 1]
		If [[#4771>#4763] AND [#4709>=1] AND [#4710>=1] AND [#4705>0] AND [#4706>0] AND [#4772>=[#4771+1]]]   ; Check input parameter integrity
			If [#3154==1]
				LOGFILE _shopfloor_part.cnc 1
			Else
				Gosub FileNew
				LOGFILE _shopfloor_teach.cnc 1
			Endif
			LOGMSG "(CYCLE DEFINITION Tapping"
			LOGMSG "	#3000=12		(CYCLE INDEX)"
			LOGMSG "	#4761=" [#4761] "	(X center)"
			LOGMSG "	#4762=" [#4762] "	(Y center)"
			LOGMSG "	#4770=" [#4770] "	(Lead)"
			LOGMSG "	#4769=" [#4769] "	(Retract)"
			LOGMSG "	#4771=" [#4771] "	(Z start)"
			LOGMSG "	#4763=" [#4763] "	(Z End)"
			LOGMSG "	#4764=" [#4764] "	(Tool)"
			LOGMSG "	#4766=" [#4766] "	(Speed)"
			LOGMSG "	#4768=" [#4768] "	(Coolant)"
			LOGMSG "	#4772=" [#4772]"	(Safe Z)"
			LOGMSG "(End CYCLE)"
			LOGMSG "M99"
			Gosub FileEnd
		Else
			msg "Input parameters incorrect!!!"
		Endif	
	Else	
		msg "SHOPFLOOR_TAPPING User canceled"
	Endif
Endsub

;#### CODE BASE SUBS ########

Sub SHOPFLOOR_HEADERS_CODE
	msg "Selection: " [#4700] 
	If [#4700 == 1]
		;########## Header XY plane, Cancel cutter comp, mm mode, Absolute distance, Work preset 1
		G17 G40 G21 G90 G54
		M5 M9 M27 M90
	Endif
	If [#4700 == 2]
		
	Endif
	If [#4700 == 3]
	
	Endif
	If [#4700 == 4]
	
	Endif
	If [#4700 == 5]
	
	Endif
	If [#4700 == 6]
	
	Endif
	If [#4700 == 7]
	
	Endif
	If [#4700 == 8]
		;########## Cyclus End
		M5 M9
	Endif
	If [#4700 == 9]
		;########## Program End stop spindle, coolant, G28 and reset
		M5 M9 G28
		M30
	Endif
Endsub

Sub SHOPFLOOR_FLATTEN_CODE
	#3015 = #[5500+#4914]	;tool comp
	#3070 = [#3015*#4905]	;stepover value
	#3015 = [#3015/2]		;half diameter
	#3018 = [#4903]			;init z increment

	M6 T[#4914]
	M3 S[#4916]			; Spindle on
	
	If [#5003 < #4907]]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4907]			; Else keep Z as-is
	Endif
	G0 X[#4901] Y[#4902] ; move to startposition xy
	G0 Z[#4907]			; move to safe Z

	If [#4918==1]		; check for Mist coolant
		M7
	Endif
	If [#4918==2]		; check for Flood coolant
		M8
	Endif

	If [[[#4911>#4912] AND [#4919==0]] OR [#4919==1]] ; X-dir if X-size > Y-size or of X-dir forced

		While [#3018>#4913] 			; Flatten in X direction
			#3018 = [#3018-#4906] 		; update Z increment
			If [#3018<#4913]			
				#3018 = [#4913]			; limit to Z-End if Z too low
			Endif
			#3009 = [#4902-#3015+#3070] ; init y increment
			G0 X[#4901-#3015] Y[#3009]	; Move to X/Y startposition
			G1 F[#4904] Z[#3018]		; Move to new Z depth
	
			While [#3009<[#4902+#4912+[#3070/2]]]
				G1 X[#4901+#4911]
				#3009 = [#3009+#3070]
				If [#3009<[#4902+#4912+[#3070/2]]]
					G3 Y[#3009] R[ #3070/2]
					G1 X[#4901]
				Endif
				#3009 = [#3009+#3070]
				If [#3009<[#4902+#4912+[#3070/2]]]
					G2 Y[#3009] R[ #3070/2]
				Endif
			Endwhile
			G0 Z[#4907]	;safe Z
		Endwhile
	
	Else 								: Flatten in Y- direction
	
		While [#3018>#4913] 			; Flatten in Y direction
			#3018 = [#3018-#4906] 		; update Z increment
			If [#3018<#4913]			
				#3018 = [#4913]			; limit to Z-End if Z too low
			Endif
			#3009 = [#4901-#3015+#3070] ; init X increment
			G0 X[#3009] Y[#4902-#3015]	; Move to X/Y startposition
			G1 F[#4904] Z[#3018]		; Move to new Z depth
	
			While [#3009<[#4901+#4911+[#3070/2]]]
				G1 Y[#4902+#4912]
				#3009 = [#3009+#3070]
				If [#3009<[#4901+#4911+[#3070/2]]]
					G2 X[#3009] R[ #3070/2]
					G1 Y[#4902]
				Endif
				#3009 = [#3009+#3070]
				If [#3009<[#4901+#4911+[#3070/2]]]
					G3 X[#3009] R[ #3070/2]
				Endif
			Endwhile
			G0 Z[#4907]	;safe Z
		Endwhile
	Endif
Endsub


Sub SHOPFLOOR_SIDEMILLING_CODE
	#3015 = #[5500+#4754]		;tool comp
	#3070 = [#3015*#4745]		;stepover value	
	#3015 = [#3015/2]			;half diameter
	#3001 = [#4741]				;init x position
	#3002 = [#4742]				;init y position
	#3003 = [#4743]				;init z position
	
	M6 T[#4754] 
	M3 S[#4756]					; spindle start
	
	If [#5003 < #4747]]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4747]			; Else keep Z as-is
	Endif
	If [#4758==1]
		M7
	Endif
	If [#4758==2]
		M8
	Endif
	G0 X[#4741] Y[#4742]		; move to X/Y start position
	G0 Z[#4747]	;safe Z			; move to safe Z-level
	F[#4904]					; feed rate for all futher G1 movements
	
	If [#4759==1]	; 1 = left side milling (X increment = +, Y direction = +)
		#3001 = [#4741-#3015]		; first X position (X-start - toolradius)
		#3003 = [#4743]				; first Z depth (Z-start)
		While [#3003>#4753]			; repeat until Z-End reached
			#3003 = [#3003-#4746]	; Z-level to first depth
			If [#3003<#4753]
				#3003=#4753			; correct if Z too low
			Endif
			While [#3001<[#4741+#4751-#3015]]	; repeat until final X reached
				#3001 = [#3001+#3070]			; X-position to first cut
				If [#3001>[#4741+#4751-#3015]]
					#3001 = [#4741+#4751-#3015]; correct if X too high
				Endif
				G0 X[#3001] Y[#4742-#3015] ; rapid to start position
				G1 Z[#3003]				; to Z mill depth
				G1 Y[#4742+#4752+#3015]	; mill to Y-start + Y-size + toolradius
				G0 Z[#4747]				;to safe Z
			Endwhile
			#3001 = [#4741-#3015] ; reset X position
		Endwhile
	Endif

	If [#4759==2]	; 2 = top side milling (Y increment = -, X direction = +)
		#3002 = [#4742+#3015]		; first Y position (Y-start + toolradius)
		#3003 = [#4743]				; first Z depth (Z-start)
		While [#3003>#4753]			; repeat until Z-End reached
			#3003 = [#3003-#4746]	; Z-level to first depth
			If [#3003<#4753]
				#3003=#4753			; correct if Z too low
			Endif
			While [#3002>[#4742-#4752+#3015]]	; repeat until final Y reached
				#3002 = [#3002-#3070]			; Y-position to first cut
				If [#3002<[#4742-#4752+#3015]]
					#3002 = [#4742-#4752+#3015]; correct if Y too low
				Endif
				G0 X[#4741-#3015] Y[#3002] ; rapid to start position
				G1 Z[#3003]				; to Z mill depth
				G1 X[#4741+#4751+#3015]	; mill to X-start + X-size + toolradius
				G0 Z[#4747]				;to safe Z
			Endwhile
			#3002 = [#4742+#3015] ; reset Y position
		Endwhile
	Endif

	If [#4759==3]	; 3 = right side milling (X increment = -, Y direction = -)
		#3001 = [#4741+#3015]		; first X position (X-start + toolradius)
		#3003 = [#4743]				; first Z depth (Z-start)
		While [#3003>#4753]			; repeat until Z-End reached
			#3003 = [#3003-#4746]	; Z-level to first depth
			If [#3003<#4753]
				#3003=#4753			; correct if Z too low
			Endif
			While [#3001>[#4741-#4751+#3015]]	; repeat until final X reached
				#3001 = [#3001-#3070]			; X-position to first cut
				If [#3001<[#4741-#4751+#3015]]
					#3001 = [#4741-#4751+#3015]; correct if X too low
				Endif
				G0 X[#3001] Y[#4742+#3015] ; rapid to start position
				G1 Z[#3003]				; to Z mill depth
				G1 Y[#4742-#4752-#3015]	; mill to Y-start - Y-size - toolradius
				G0 Z[#4747]				;to safe Z
			Endwhile
			#3001 = [#4741+#3015] ; reset X position
		Endwhile
	Endif

	If [#4759==4]	; 4 = lower side milling (Y increment = +, X direction = -)
		#3002 = [#4742-#3015]		; first Y position (Y-start - toolradius)
		#3003 = [#4743]				; first Z depth (Z-start)
		While [#3003>#4753]			; repeat until Z-End reached
			#3003 = [#3003-#4746]	; Z-level to first depth
			If [#3003<#4753]
				#3003=#4753			; correct if Z too low
			Endif
			While [#3002<[#4742+#4752-#3015]]	; repeat until final Y reached
				#3002 = [#3002+#3070]			; Y-position to first cut
				If [#3002>[#4742+#4752-#3015]]
					#3002 = [#4742+#4752-#3015]; correct if Y too high
				Endif
				G0 X[#4741+#3015] Y[#3002] ; rapid to start position
				G1 Z[#3003]				; to Z mill depth
				G1 X[#4741-#4751-#3015]	; mill to X-start + X-size + toolradius
				G0 Z[#4747]				;to safe Z
			Endwhile
			#3002 = [#4742-#3015] ; reset Y position
		Endwhile
	Endif
Endsub


Sub SHOPFLOOR_SQUARECONTOUR_CODE
	#3018 = [#4783]	;reset z increment
	#3001 = [#4791]	;X size
	#3002 = [#4792]	;Y size
	#3003 = [[#3001 *2]+[#3002*2]]	;total length toolpath
	#3004 = [#4786/#3003]	;Z lead in calculation
	#3011 = [#3004*#3001]	;Z lead in X
	#3012 = [#3004*#3002]	;Z lead in Y
	#3028 = [#4783]	;reset z increment
	#3029 = [#4783]	;reset z half increment
	If [#4795 == 1]	;calulate tool number for dia comp
		#3015 = -#[5500+#4794]	;outside comp
		#3015 = [#3015/2]
	Else
		#3015 = #[5500+#4794]	;inside comp
		#3015 = [#3015/2]
	Endif
	
	M6 T[#4794] 
	M3 S[#4796]	;Spindle on
	If [#5003 < #4787]]		; if Z is below safe Z, move to safe Z first
		G0 Z[#4787]			; Else keep Z as-is
	Endif
	If [#4798==1]
		M7
	Endif
	If [#4798==2]
		M8
	Endif
	
	G0 X[#4781+#3015] Y[#4782+#3015]	; rapid to xy startposition 
	G0 Z[#4787]							; rapid to safe Z
	G1 F[#4784] Z[#4783]				; Move to startposition z
	While [#3018>#4793]					; loop to Z target
		If [#3018 >= #4793]	; Ztarget reached?
			G1 F[#4784]
			If [#4795 == 1]	; inside 
				#3018 = [#3018-#3012]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 Y[#4782+#4792-#3015] Z[#3018]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				#3018 = [#3018-#3011]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 X[#4781+#4791-#3015] Z[#3018] 
				#3018 = [#3018-#3012]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 Y[#4782+#3015] Z[#3018]
				#3018 = [#3018-#3011]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 X[#4781+#3015] Z[#3018] 
			Else ;outside
				#3018 = [#3018-#3012]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 X[#4781+#4791-#3015] Z[#3018]
				#3018 = [#3018-#3011]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 Y[#4782+#4792-#3015] Z[#3018] 
				#3018 = [#3018-#3012]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 X[#4781+#3015] Z[#3018] 
				#3018 = [#3018-#3011]
				If [#3018<#4793]
					#3018 = [#4793]
				Endif
				G1 Y[#4782+#3015] Z[#3018] 
			Endif
		Endif
	Endwhile
	G1 Z[#4793]
	;  finalize cyclus
	If [#4795 == 1]	; outside?
		G1 Y[#4782+#4792-#3015]
		G1 X[#4781+#4791-#3015]
		G1 Y[#4782+#3015] 
		G1 X[#4781+#3015]
	Else
		G1 X[#4781+#4791-#3015]
		G1 Y[#4782+#4792-#3015]
		G1 X[#4781+#3015] 
		G1 Y[#4782+#3015]
	Endif
	G0 Z[#4787]	;safe Z
Endsub

Sub SHOPFLOOR_ROUNDCONTOUR_CODE
	If [#4835 == 1]	;calulate tool number for dia comp
		#3015 = #[5500+#4834];outside comp
		#3015 = [#3015/2]
	Else
		#3015 = -#[5500+#4834]	;inside comp
		#3015 = [#3015/2]
	Endif
	#3028 = [#4823]	;reset z increment
	#3029 = [#4823]	;reset z half increment
	#3025 = [#4831-[#4825/2]-#3015]	;negative circle start
	#3026 = [#4831+[#4825/2]+#3015]	;positive circle start
	#3027 = [[#4825 /2]+#3015]	;radius
	M6 T[#4834] 
	M3 S[#4836]
	If [#5003 < #4827]]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4827]			; Else keep Z as-is
	Endif
	If [#4838==1]
		M7
	Endif
	If [#4838==2]
		M8
	Endif
	G0 X #3026 Y[#4832]		; Rapid to startposition xy
	G0 Z[#4827]				; Rapid to safe Z
	G1 F[#4824] Z[#4823]	; Move to startposition z
	While [#3028>#4833]	; loop to Z target
		If [#3028 >= #4833]	; Ztarget reached?
			#3028 = [#3028-#4826]	; Z increment
			G0 X[#3026] Y[#4832]
			If [#3028<#4833]	; z overshoot?
				#3028 = [#4833]
				#3029 = [#3028+[#4826/2]]
				If [#4835 == 1]	; outside
					G2 X[#3025] Y[#4832] R[#3027] Z[#3029]
					G2 X[#3026] Y[#4832] R[#3027] Z[#3028]
				Else ;inside
					G3 X[#3025] Y[#4832] R[#3027] Z[#3029]
					G3 X[#3026] Y[#4832] R[#3027] Z[#3028]
				Endif
				#3028 = [#3028 -1]
			Endif
			If [#3028 >= #4833]	; Z normal
				#3029 = [#3028+[#4826/2]]
				If [#4835 == 1]	;outside
					G2 X[#3025] Y[#4832] R[#3027] Z[#3029]
					G2 X[#3026] Y[#4832] R[#3027] Z[#3028]
				Else ;inside
					G3 X[#3025] Y[#4832] R[#3027] Z[#3029]
					G3 X[#3026] Y[#4832] R[#3027] Z[#3028]
				Endif
			Endif
		Endif
	Endwhile
	;finalize cyclus
	If [#4835 == 1]	;outside
		G2 X[#3025] Y[#4832] R[#3027] Z[#4833]
		G2 X[#3026] Y[#4832] R[#3027] 
	Else ;inside
		G3 X[#3025] Y[#4832] R[#3027] Z[#4833]
		G3 X[#3026] Y[#4832] R[#3027] 
		Endif
	G0 Z[#4827]	;safe Z
Endsub

Sub SHOPFLOOR_SQUAREPOCKET_CODE
	#3015 = #[5500+#4854]	;Tool size
	#3070 = [#3015*#4845]	;stepover value
	#3015 = [#3015/2]		;radius
	#3068 = [#4843]			;reset z increment
	#3039 = 0				;reset stepover
	#3041 = [#4841-[2*#3015]] ;toolcomp X
	#3042 = [#4842-[2*#3015]] ;toolcomp Y
	#3043 = [#4851+#3015]	; start pos X
	#3044 = [#4852+#3015]	; start pos Y
	#3031 = [#3041/2]	; half X
	#3032 = [#3042/2]	; half Y
	#3033 = [#3041/2]	;X neg
	#3034 = [#3041/2]	;X pos
	#3035 = [#3042/2]	;Y neg
	#3036 = [#3042/2]	;Y pos
	#3048 = 0	; reset counter max range
	#3049 = 0	;reset counter safe z quick move
	;maxsize?
	If [#3041>#3042]
		#3047 = [#3041/2]
	Else
		#3047 = [#3042/2]
	Endif
	
	M6 T[#4854] 
	M3 S[#4856]
	If [#5003 < #4847]]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4847]			; Else keep Z as-is
	Endif
	If [#4858==1]
		M7
	Endif
	If [#4858==2]
		M8
	Endif
	G0 X[#3031+#3043] Y[#3032+#3044]	; Rapid to startposition xy
	G0 Z[#4847]	;safe Z					; Rapid to safe Z
	G1 Z[#4843] F[#4844]				; Move to startposition z
	While [#3068>#4853]					; loop to Z target
		If [#3068 >= #4853]				; ztarget reached?
			#3040 = [#3068]
			If [#3068<#4853]			; z overshoot?
				#3068 = [#4853]
			Endif
			If [#3068 >= #4853]	;z normal
				#3040 = [#3068]
				#3068 = [#3068-#4846]	;z increment
				If [#3068<#4853]	;z overshoot?
					#3068 = [#4853]
				Endif
				#3106 = [#3031+#3043]	;centerpoint x
				#3104 = [#4849]	;feed 
				#3105 = [#4848]	;lead)
				#3107= [#3070/2]	;stepover leadin
				Gosub HELIX_LEAD_IN
				G1 X[#3031+#3043] F[#4844] 
			Endif
		Endif
		;reset center vars
		#3033 = [[#3041/2]]	;X pos
		#3034 = [[#3041/2]]	;X neg
		#3035 = [[#3042/2]]	;Y pos
		#3036 = [[#3042/2]]	;Y neg
		While [#3048 <= #3047]
			; XYcyclus
			#3048 = [#3048+#3070]; add stepover
			If [#3033 >= 0]
				#3033 = [#3033-#3070]	;X neg
				If [#3033<0]
				#3033 = 0
				Endif
			Endif
			If [#3034 <= #3041]
				#3034 = [#3034+#3070]	;X pos
				If [#3034>#3041]
				#3034 = [#3041]
				Endif
			Endif
			If [#3035 >= 0 ]
				#3035 = [#3035-#3070]	;Y neg
				If [#3035<0]
				#3035 = 0
				Endif
			Endif
			If [#3036 <= #3042]
				#3036 = [#3036+#3070]	;Y pos
				If [#3036>#3042]
				#3036 = [#3042]
				Endif
			Endif
			If [#3036<>[#3042/2]]
				G1 Y[#3036+#3044] F[#4844]	;move Y positive stepover start
			Else
				G1 Y[#3036+#3044+#3015] F[#4844]	;move Y positive stepover
			Endif
			G1 X[#3033+#3043] F[#4844]	;move X  neg
			G1 Y[#3035+#3044]		;move Y neg
			G1 X[#3034+#3043]		;move X pos
			G1 Y[#3036+#3044]		;move Y pos
			G1 X[#3031+#3043]		;move X center
		Endwhile
		G1 X[#3031+#3043] Y[#3032+#3044]	; startposition xy
		#3048 = 0	; reset counter max range
	Endwhile
	G0 Z[#4847]	;safe Z
Endsub

Sub SHOPFLOOR_ROUNDPOCKET_CODE
	#3015 = #[5500+#4874]	;Tool size
	#3070 = [#3015*#4865]	;stepover value
	#3015 = [#3015/2]	;radius
	#3068 = [#4863]	;reset z increment
	#3069 = 0	;reset stepover
	#3078 = 0	;counter diameter
	#3079 = 0	;reset counter safe z quick move
	
	M6 T[#4874] 
	M3 S[#4876]	;Spindle on
	If [#5003 < #4867]]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4867]			; Else keep Z as-is
	Endif
	If [#4878==1]
		M7
	Endif
	If [#4878==2]
		M8
	Endif
	G0 X[#4871] Y[#4872]	; Rapid to startposition xy
	G0 Z[#4867]				; Rapid to safe Z
	G1 F[#4869] Z[#4863]	; Move to startposition z
	While [#3068>#4873]	; loop to Z-target
		If [#3068 >= #4873]	; Z-target reached?
			#3040 = [#3068]
			#3068 = [#3068-#4866]	; Z increment
			If [#3068<#4873]	; z overshoot?
				#3068 = [#4873]
			Endif
			#3106 = [#4871]	(centerpoint x)
			#3104 = [#4869]	(feed) 
			#3105 = [#4868]	(lead) 
			#3107 = [#3070/2]	;stepover leadin
			Gosub HELIX_LEAD_IN
		Endif
		#3118 = [#4861/2]	;convert to radius
		#3110 = [#3118-#3015]	;max radius size
		#3103 = [#3070]	;stepover value
		#3114 = [#3107]	;stepover counter
		#3116 = [#4871+#3103]	;start radius
		If [#3103>#3110] 
			#3116 = [#4871+#3110]
			#3103 = [#3110]
		Endif
			G03 X[#4871-#3107] Y[#4872] Z[#3068] R[#3107] F[#4869]
			G03 X[#4871+#3107] Y[#4872] R[#3107] F[#4864]
			G03 X[#4871-#3107] Y[#4872] R[#3107] F[#4864]
		#3114 = [#3114+#3103] 
		#3115 = [#3107]
		While [#3114<#3110]	;max radius?
			#3116 = [#3114]
			G03 X[#4871+#3116] Y[#4872] R[[#3116+#3115]/2] F[#4864]
			G03 X[#4871-#3116] Y[#4872] R[#3116] F[#4864]
			#3115 = [#3116]
			#3114 = [#3114+#3103] 
		Endwhile
		#3116 = [#3110] 
		G03 X[#4871+#3116] Y[#4872] R[[#3116+#3115]/2] F[#4864]
		G03 X[#4871-#3116] Y[#4872] R[#3116] F[#4864]
		#3115 = [#3116] 
		G03 X[#4871+#3110] Y[#4872] R[#3110]	;leadout
		G03 X[#4871] Y[#4872] R[#3110/2] 
		#3078 = 0 ; reset counter
		G0 X[#4871] Y[#4872]	; startposition xy
	Endwhile
	G0 Z[#4867]	;safe Z
Endsub

Sub SHOPFLOOR_SLOTTING_CODE
	#3015 = #[5500+#4894]	;Tool size
	#3015 = [#3015/2]		;radius
	#3088 = [#4883]			;reset z increment
	#3081 = [#4881/2]		;half x
	#3082 = [#4882/2]		;half y
	#3083 = [#3081-#3082]	;comp h
	#3084 = [#3082-#3081]	;comp v
	#3095 = [#4891-#3081]	;left
	#3096 = [#4891+#3081]	;right
	#3097 = [#4892-#3082]	;bottom
	#3098 = [#4892+#3082]	;top
	; Total length per pass:  #3003
	; Z lead-in G1:  #3011
	; Z lead-in R:  #3012
	
	M6 T[#4894]
	M3 S[#4896]			; Spindle on
	If [#5003 < #4887]]	; If Z is below safe Z, move to safe Z first
		G0 Z[#4887]		; Else keep Z as-is
	Endif
	If [#4898==1]
		M7
	Endif
	If [#4898==2]
		M8
	Endif
	G0 X[#4891] Y[#4892]	; Rapid to center point
	G0 Z[#4887]				; Rapid to safe Z

	If [#4881>#4882]
		; Shape is horizontal shaped slot
		G0 X[#3095+#3082] Y[#3097+#3015]	; startposition xy ;x wider horizontal
		#3003 = [[[[#3096-#3082]-[#3095+#3082]]*2]+[[#3082-#3015]*3.14159265359*2]];total length
		#3004 = [#4886/#3003]	;Z lead in calculation
		#3011 = [[[#3096-#3082]-[#3095+#3082]] *#3004]	;Z lead in X
		#3012 = [[[#3082-#3015]*3.14159265359]*#3004]	;Z lead in radius 
	Else
		; Shape is vertical shaped slot
		G0 X[#3096-#3015] Y[#3097+#3081]	; startposition xy ;y wider vertical
		#3003 = [[[[#3098-#3081]-[#3097+#3081]]*2]+[[#3081-#3015]*3.14159265359*2]];total length
		#3004 = [#4886/#3003]	;Z lead in calculation
		#3011 = [[[#3098-#3081]-[#3097+#3081]] *#3004]	;Z lead in Y
		#3012 = [[[#3081-#3015]*3.14159265359]*#3004]	;Z lead in radius 
	Endif

	G1 F[#4884] Z[#4883]	; startposition z
	While [#3088>#4893]	; loop to Z target
		If [#3088 >= #4893]	; Ztarget reached?
			If [#3088<[#4893+#4886]]	; z overshoot?
				;overshoot pass
				#3088 = [#4893+#4886]
				If [#4881>#4882]
					; single pass cyclus horizontal
					;G1 Z #3088
					;G1 X[#3095+#3082] Y[#3097+#3015]
					G1 X[#3096-#3082] Z[#3088-#3011]
					G3 X[#3096-#3082] Y[#3098-#3015] Z[#3088-#3011-#3012] R[#3082-#3015]
					G1 X[#3095+#3082] Z[#3088-#3011-#3012-#3011]
					G3 X[#3095+#3082] Y[#3097+#3015] Z[#3088-#3011-#3012-#3011-#3012] R[#3082-#3015]
				Else
					; single pass cyclus vertical
					;G1 X[#3096-#3015] Y[#3097+#3081]
					G1 Y[#3098-#3081] Z[#3088-#3011]
					G3 X[#3095+#3015] Y[#3098-#3081] Z[#3088-#3011-#3012] R[#3081-#3015]
					G1 Y[#3097+#3081] Z[#3088-#3011-#3012-#3011]
					G3 X[#3096-#3015] Y[#3097+#3081] Z[#3088-#3011-#3012-#3011-#3012] R[#3081-#3015]
				Endif
				#3088 = [#3088-#4881-1]
			Endif
			If [#3088 >= #4893]	; Z normal
				If [#4881>#4882]
				; single pass cyclus horizontal
					G1 X[#3096-#3082] Z[#3088-#3011]
					G3 X[#3096-#3082] Y[#3098-#3015] Z[#3088-#3011-#3012] R[#3082-#3015]
					G1 X[#3095+#3082] Z[#3088-#3011-#3012-#3011]
					G3 X[#3095+#3082] Y[#3097+#3015] Z[#3088-#3011-#3012-#3011-#3012] R[#3082-#3015]
				Else
					; single pass cyclus vertical
					G1 Y[#3098-#3081] Z[#3088-#3011]
					G3 X[#3095+#3015] Y[#3098-#3081] Z[#3088-#3011-#3012] R[#3081-#3015]
					G1 Y[#3097+#3081] Z[#3088-#3011-#3012-#3011]
					G3 X[#3096-#3015] Y[#3097+#3081] Z[#3088-#3011-#3012-#3011-#3012] R[#3081-#3015]
				Endif
				#3088 = [#3088-#4886]	; Z increment
			Endif
		Endif
	Endwhile
	If [#4881>#4882]
		; finalize cyclus horizontal
		G1 Z[#4893]
		G1 X[#3096-#3082]
		G3 X[#3096-#3082] Y[#3098-#3015] R[#3082-#3015]
		G1 X[#3095+#3082]
		G3 X[#3095+#3082] Y[#3097+#3015] R[#3082-#3015]
	Else
		; finalize cyclus vertical
		G1 Y[#3098-#3081]
		G3 X[#3095+#3015] Y[#3098-#3081] R[#3081-#3015]
		G1 Y[#3097+#3081]
		G3 X[#3096-#3015] Y[#3097+#3081] R[#3081-#3015]
	Endif
	G0 X[#4891] Y[#4892] Z[#4887]	;safe Z
Endsub

Sub SHOPFLOOR_SLITTING_CODE
	M6 T[#4734]
	M3 S[#4736]				; Spindle on
	If [#5003<#4727]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4727]			; Else keep Z axis as-is
	Endif	
	If [#4738==1]
		M7
	Endif
	If [#4738==2]
		M8
	Endif
	G0 X[#4721] Y[#4722]	; rapid to XY start position
	G0 Z[#4727]				; rapid to safe Z
	
	#3090 = [#4723 - #4726] ; init first depth
	While [#3090 > #4733]
		G1 Z[#3090] F[#4729] ; plunge to new depth (plunge feed rate)
		F[#4724]			 ; normal feed rate
		G1 X[#4731] Y[#4732] ; mill to End of slit
		G1 Z[#4727]			 ; back to safe Z
		G0 X[#4721] Y[#4722] ; rapid to starting point
		#3090 = [#3090 - #4726] ; calculate new depth
	Endwhile
	G1 Z[#4733] F[#4729]	; plunge to final depth
	F[#4724]				; restore normal feed rate
	G1 X[#4731] Y[#4732] 	; mill (last pass)
	G1 Z[#4727]				; back to safe Z
Endsub

Sub SHOPFLOOR_SQUARE_DRILLING_CODE
	M6 T[#4714] 
	M3 S[#4716]
	If [#5003 < #4707]]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4707]			; Else keep Z as-is
	Endif
	If [#4718==1]
		M7
	Endif
	If [#4718==2]
		M8
	Endif
	#3090 = #4709		; X & Y number of holes to temp var.
	#3091 = #4710
	#3092 = #4701		; X & Y start position to temp var.
	#3093 = #4702
	
	G0 X[#3092] Y[#3093] ; rapid to first hole position
	G0 Z[#4707]			; rapid to safe-Z

	While [#3091>0]		; Y-loop
		While [#3090>0]	; X-loop
			G0 X[#3092] Y[#3093]
			G1 Z[#4703] F[#4704]	; G1 move to Z startposition
			G83 Z[#4713] F[#4704] R[#4705] Q[#4706]	; drill cycle
			G0 Z[#4707]				; back to safe Z
			#3092 = [#3092 + #4711] ; next X position
			#3090 = [#3090 - 1]		; X holes count down
		Endwhile
		#3092 = #4701			; restore X position
		#3090 = #4709			; restore number of holes in X direction
		#3093 = [#3093 + #4712]	; next Y position
		#3091 = [#3091 - 1]		; Y holes count down
	Endwhile
	G80			; cancel canned cycle
Endsub

Sub SHOPFLOOR_CIRCULAR_DRILLING_CODE
	M6 T[#4814] 
	M3 S[#4816]
	If [#5003 < #4807]]		; If Z is below safe Z, move to safe Z first
		G0 Z[#4807]			; Else keep Z as-is
	Endif
	If [#4818==1]
		M7
	Endif
	If [#4818==2]
		M8
	Endif
	If [#4817>=360]	
		#4817=360		; check if full circle and limit to 360 deg if higher
		#3092=[#4817/#4802]	; angle between holes
	Else
		#3092=[#4817/[#4802-1]]	; angle between holes if arc
	Endif
	#3090=#4802 			; number of holes to temp variable
	#3091=#4805 			; set angle parameter to start angle
	G0 X[[[#4801/2]*cos[#3091]]+#4811] Y[[[#4801/2]*sin[#3091]]+#4812]  ;rapid to first hole
	G0 Z[#4807]				; rapid to safe Z
	While [#3090 > 0]
		G0 X[[[#4801/2]*cos[#3091]]+#4811] Y[[[#4801/2]*sin[#3091]]+#4812]  ;locate
		G1 Z[#4803] F[#4804]					; G1 move to Z startposition
		G83 Z[#4813] F[#4804] R[#4818] Q[#4806]	; drill cycle
		G0 Z[#4807]								; safe Z
		#3091 = [#3091 + #3092]					; angle parm to next hole
		#3090 = [#3090-1] 						; While loop count down
	Endwhile
	G80			; cancel canned cycle
Endsub

Sub SHOPFLOOR_TAPPING_CODE
	M6 T[#4764] 
	M3 S[#4766]
	If [#4768==1]
		M7
	Endif
	If [#4768==2]
		M8
	Endif
	G0 x[#4761] y[#4762] ; rapid to tap position
	G0 Z[#4772]			; rapid to safe Z
	G0 Z[#4769]
	F[#4770]
	g84 z[#4763] R[#4769]	;tap cycle
	G80
Endsub

Sub WARM_UP
	Dlgmsg "shopfloor WARMUP" 
	If [#5398 == 1]
		Gosub home_all
		M6 T0
		TCAGuard off
		G53 G0 Z#5113	;Move Z up
		M3 S1000
		G53 G0 X#5101 Y#5102	;Move negative
		G53 G0 X#5111 Y#5112	;Move positive
		G53 G0 Z#5103		;Move Z down
		G53 G0 Z#5113		;Move Z up
		G53 G0 X#5081 Y#5082	;Move XY home
		TCAGuard on
		G4 P60
		S2000
		G4 P300
		S4000
		G4 P300
		M5
		Gosub home_all
		M30
	Else	
		msg "SHOPFLOOR_WARM_UP User canceled"
	Endif
Endsub

;#### SPECIAL M CODES ########

Sub M99 ;OPERATION
	If [#3000==1]
		Gosub SHOPFLOOR_HEADERS_CODE
	Endif
	If [#3000==2]
		Gosub SHOPFLOOR_FLATTEN_CODE
	Endif
	If [#3000==3]
		Gosub SHOPFLOOR_SIDEMILLING_CODE
	Endif
	If [#3000==4]
		Gosub SHOPFLOOR_SQUARECONTOUR_CODE
	Endif
	If [#3000==5]
		Gosub SHOPFLOOR_ROUNDCONTOUR_CODE
	Endif
	If [#3000==6]
		Gosub SHOPFLOOR_SQUAREPOCKET_CODE
	Endif
	If [#3000==7]
		Gosub SHOPFLOOR_ROUNDPOCKET_CODE
	Endif
	If [#3000==8]
		Gosub SHOPFLOOR_SLOTTING_CODE
	Endif
	If [#3000==9]
		Gosub SHOPFLOOR_SLITTING_CODE
	Endif
	If [#3000==10]
		Gosub SHOPFLOOR_SQUARE_DRILLING_CODE
	Endif
	If [#3000==11]
		Gosub SHOPFLOOR_CIRCULAR_DRILLING_CODE
	Endif
	If [#3000==12]
		Gosub SHOPFLOOR_TAPPING_CODE
	Endif
Endsub

Sub HELIX_LEAD_IN
	G1 X[#3106+#3107] F[#3104]
	While [#3040>#3068]	; loop to Z SubTargettarget
		If [#3040 >= #3068]	; ZSubTarget reached?
			If [#3040>#3068] 
			#3040 = [#3040-#3105/2]	; ZLeadin increment
				If [#3040<#3068] 
				#3040 = [#3068]
				Endif
			Endif
			G3 X[#3106-#3107] Z[#3040] R[#3107]
			If [#3040>#3068] 
			#3040 = [#3040-#3105/2]	; ZLeadin increment
				If [#3040<#3068] 
				#3040 = [#3068]
				Endif
			Endif
			G3 X[#3106+#3107] Z[#3040] R[#3107]
		Endif
	Endwhile
	#3108 = [#3106+#3107]; End pass location
Endsub

Sub FileNew
LOGFILE "_shopfloor_teach.cnc" 0
Gosub SHOPFLOOR_HEADER
Endsub

Sub FileEnd
	If [#3154==0]
		LOGMSG "M2"
	Endif
Endsub

;##########################################################################################
;#################      END SHOPFLOOR PROGRAMMER FOR EDINGCNC       #######################
;##########################################################################################
