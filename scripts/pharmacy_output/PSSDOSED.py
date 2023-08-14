def PSSDOSED():
    """
    ;BIR/RTR-Dosage edit ;03/09/00
    ;;1.0;PHARMACY DATA MANAGEMENT;**34,38,49,50**;9/30/97
    ;Reference to ^PS(50.607 supported by DBIA #2221
    ;
    W ! K DIC S DIC="^PSDRUG(",DIC(0)="QEAMZ",DIC("A")="Select Drug: " D ^DIC K DIC I +Y<1!($D(DTOUT)) Q
    """
    pass

def SET():
    """
    ;x-ref on Dispense Unit per Dose to set Dose field
    N PSSUNIT,PSSUNITV,PSSDOSEV,PSS2,PSS1,PSS3,PSSU1,PSSUNITA,PSSUNITB,PSSUSL,PSSUST,PSSU50,PSSUSL2,PSSUSL3,PSSUSL4,PSSUSL5
    N PSSUZ,PSSUZ1,PSSUZD
    S PSSDOSEV=+$G(X)*+$P($G(^PSDRUG(DA(1),"DOS")),"^")
    S $P(^PSDRUG(DA(1),"DOS1",DA,0),"^",2)=PSSDOSEV
    S PSSUNIT=$P($G(^PS(50.607,+$P($G(^PSDRUG(DA(1),"DOS")),"^",2),0)),"^")
    S PSSUSL=0 I PSSUNIT["/" S PSSHLDDA=$G(DA),PSSHLDX=$G(X) S PSSUST=$$PSJST^PSNAPIS(+$P($G(^PSDRUG(DA(1),"ND")),"^"),+$P($G(^PSDRUG(DA(1),"ND")),"^",3)) D  S PSSUST=+$P($G(PSSUST),"^",2) I $G(PSSUST),$G(PSSU50),+$G(PSSUST)'=+$G(PSSU50) S PSSUSL=1
        .S DA=$G(PSSHLDDA),X=$G(PSSHLDX) K PSSHLDDA,PSSHLDX
        .S PSSU50=$P($G(^PSDRUG(DA(1),"DOS")),"^")
    if PSSUNIT["/":
        PSSUNITA=$P(PSSUNIT,"/"),PSSUNITB=$P(PSSUNIT,"/",2),PSS1=+$G(PSSUNITA),PSSU1=+$G(PSSUNITB)
    if PSSUNIT["/" and PSSUSL:
        PSSUSL2=PSSU50/PSSUST,PSSUSL3=PSSUSL2*X S PSSUSL4=PSSUSL3*$S($G(PSSU1):PSSU1,1:1) S PSSUSL5=$S('$G(PSSU1):PSSUSL4_$G(PSSUNITB),1:PSSUSL4_$P(PSSUNITB,PSSU1,2))
    if PSSUNIT["/":
        PSSUNITV=$S('$G(PSS1):PSSDOSEV,1:($G(PSS1)*PSSDOSEV))_$S($G(PSS1):$P(PSSUNITA,PSS1,2),1:PSSUNITA)_"/"_$S($G(PSSUSL):$G(PSSUSL5),'$G(PSSU1):X_PSSUNITB,1:(X*+PSSU1)_$P(PSSUNITB,PSSU1,2))
    if PSSUNIT'["/":
        PSSUNITV=PSSDOSEV_PSSUNIT
    if $G(PSSUNITV)["/.":
        PSSUZD=$G(PSSUNITV)
        PSSUZ=$P(PSSUZD,"/."),PSSUZ1=$P(PSSUZD,"/.",2)
        PSSUNITV=$G(PSSUZ)_"/0."_$G(PSSUZ1)
    D EN^DDIOL("  Dosage = "_$S($E($G(PSSUNITV),1)=".":"0",1:"")_$G(PSSUNITV))
    """
    pass

def KILL():
    """
    S $P(^PSDRUG(DA(1),"DOS1",DA,0),"^",2)=""
    """
    pass

def SETS():
    """
    ;Set cross reference on Strength
    N PSS4,PSS5,PSS6,PSS7,PSS8,PSS9,PSSUNA1,PSSUNB1,PSSUA1,PSSUB1,PSSNDS,PSSLASH,PSSLASH1,PSSLASH2,PSSLASH3,PSSLASH4,PSSLASH5
    N PSSSZ,PSSSZ1,PSSSZD
    D EN^DDIOL(" ")
    D EN^DDIOL("Resetting possible dosages:")
    F PSS4=0:0 S PSS4=$O(^PSDRUG(DA,"DOS1",PSS4)) Q:'PSS4  S PSS5=+$P($G(^PSDRUG(DA,"DOS1",PSS4,0)),"^") D:PSS5
    .S PSS6=+$G(X)*+$G(PSS5)
    .S $P(^PSDRUG(DA,"DOS1",PSS4,0),"^",2)=PSS6
    .S PSS7=$P($G(^PS(50.607,+$P($G(^PSDRUG(DA,"DOS")),"^",2),0)),"^")
    .S PSSLASH=0 I PSS7["/" S PSSHLDDA=$G(DA),PSSHLDX=$G(X) S PSSNDS=$$PSJST^PSNAPIS(+$P($G(^PSDRUG(DA,"ND")),"^"),+$P($G(^PSDRUG(DA,"ND")),"^",3)) D  S PSSNDS=+$P($G(PSSNDS),"^",2) I $G(PSSNDS),$G(X),+$G(PSSNDS)'=+$G(X) S PSSLASH=1
    ..S DA=$G(PSSHLDDA),X=$G(PSSHLDX) K PSSHLDDA,PSSHLDX
    .I PSS7["/" S PSSUNA1=$P(PSS7,"/"),PSSUNB1=$P(PSS7,"/",2),PSSUA1=+$G(PSSUNA1),PSSUB1=+$G(PSSUNB1)
    .I PSS7["/" and PSSLASH:
        PSSLASH2=X/PSSNDS,PSSLASH3=PSSLASH2*PSS5 S PSSLASH4=PSSLASH3*$S($G(PSSUB1):PSSUB1,1:1) S PSSLASH5=$S('$G(PSSUB1):PSSLASH4_$G(PSSUNB1),1:PSSLASH4_$P(PSSUNB1,PSSUB1,2))
    .I PSS7["/":
        PSS9=$S('$G(PSSUA1):PSS6,1:($G(PSSUA1)*PSS6))_$S($G(PSSUA1):$P(PSSUNA1,PSSUA1,2),1:PSSUNA1)_"/"_$S($G(PSSLASH):$G(PSSLASH5),'$G(PSSUB1):PSS5_$G(PSSUNB1),1:(PSS5*+PSSUB1)_$P(PSSUNB1,PSSUB1,2))
    .I PSS7'["/":
        PSS9=PSS6_PSS7
    .if $G(PSS9)["/.":
        PSSSZD=$G(PSS9)
        PSSSZ=$P(PSSSZD,"/."),PSSSZ1=$P(PSSSZD,"/.",2)
        PSS9=$G(PSSSZ)_"/0."_$G(PSSSZ1)
    .D EN^DDIOL("  Possible Dosage = "_$S($E($G(PSS9),1)=".":"0",1:"")_$G(PSS9))
    """
    pass

def KILLS():
    """
    ;Kill cross reference on Strength
    N PSS10
    F PSS10=0:0 S PSS10=$O(^PSDRUG(DA,"DOS1",PSS10)) Q:'PSS10  S $P(^PSDRUG(DA,"DOS1",PSS10,0),"^",2)=""
    """
    pass

def IO():
    """
    ;Input Transform for Package field in Possible Dose multiple
    S X=$$UP^XLFSTR(X) I (X'?1"I")&(X'?1"O")&(X'?1"IO")&(X'?1"OI") K X Q
    S PSS12=$P($G(^PSDRUG(DA(1),"ND")),"^",3),PSS121=$P($G(^("ND")),"^") S PSSSAVEX=$G(X)
    S PSSSAVDA=$G(DA),PSSSAVD1=$G(DA(1))
    S PSSIOVAR="" I PSS12,PSS121 S PSSIOVAR=$$DFSU^PSNAPIS(PSS121,PSS12)
    S X=PSSSAVEX,DA=PSSSAVDA,DA(1)=PSSSAVD1
    S PSS13=$S($P($G(^PSDRUG(DA(1),"DOS")),"^",2):$P($G(^("DOS")),"^",2),1:+$P(PSSIOVAR,"^",5)),PSS14=+$P(PSSIOVAR,"^")
    I X["I",'$D(^PS(50.606,"ACONI",+$G(PSS14),+$G(PSS13))) D  K X D IOK Q
        .D EN^DDIOL("Unit/Dosage Form combination cannot be converted for Inpatient Medications")
    I X["O",'$D(^PS(50.606,"ACONO",+$G(PSS14),+$G(PSS13))) D  K X D IOK Q
        .D EN^DDIOL("Unit/Dosage Form combination cannot be converted for Outpatient Pharmacy")
    D IOK
    """
    pass

def IOK():
    """
    K PSS12,PSS13,PSSSAVEX,PSSIOVAR,PSSSAVDA,PSSSAVD1
    """
    pass