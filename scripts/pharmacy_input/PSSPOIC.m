PSSPOIC ;BIR/RTR-Orderable items by VA Name after Primary ; 09/01/98 7:10
 ;;1.0;PHARMACY DATA MANAGEMENT;**15**;9/30/97
 I '$G(PSMATCH) G CANT
 ;VA Generic Name after Primary checks that can auto-match
BEG F PPP=0:0 S PPP=$O(^PSDRUG(PPP)) Q:'PPP  D
 .S NDNOD=$G(^PSDRUG(PPP,"ND")),PSODNAME=$P($G(^(0)),"^"),PRIPTR=$P($G(^(2)),"^",6),PSOIPTR=$P($G(^(2)),"^") S DA=$P($G(PSNDO),"^"),K=$P($G(PSNDO),"^",3),X=$$PSJDF^PSNAPIS(DA,K),DOFO=X
 .Q:PSODNAME=""
 .I $D(^TMP("PSS",$J,PSODNAME)) Q
 .I +PSOIPTR Q
 .K ^TMP($J,"PSSPP") I +$P(NDNOD,"^"),+$P(NDNOD,"^",3) F AA=0:0 S AA=$O(^PSDRUG("AND",+NDNOD,AA)) Q:'AA  S OTHNAME=$P($G(^PSDRUG(AA,0)),"^") I $D(^TMP("PSS",$J,OTHNAME)) D
 ..S ONOD=$G(^PSDRUG(AA,"ND")) I +$P(ONOD,"^"),+$P(ONOD,"^",3),DOFO'=0 S DA=$P($G(ONOD),"^"),K=$P($G(ONOD),"^",3),X=$$PSJDF^PSNAPIS(DA,K),DOFO1=X I DOFO1'=0 D
 ...I DOFO=DOFO1 S ^TMP($J,"PSSPP",AA)=^TMP("PSS",$J,OTHNAME)
 .S (COMM,COMMSUP)=0 I $O(^TMP($J,"PSSPP",0)) S COMM=1 S WW=$O(^TMP($J,"PSSPP",0)),POII=^TMP($J,"PSSPP",WW) F WW=0:0 S WW=$O(^TMP($J,"PSSPP",WW)) Q:'WW  I POII'=^TMP($J,"PSSPP",WW) S COMMSUP=1
 .I COMM,COMMSUP Q
 .I COMM,'COMMSUP S ZZZ=$O(^TMP($J,"PSSPP",0)),ZZZ=^TMP($J,"PSSPP",ZZZ) S ^TMP("PSSD",$J,ZZZ,PSODNAME)="" Q
 .I +$P(NDNOD,"^"),+$P(NDNOD,"^",3) S DA=$P($G(NDNOD),"^"),K=$P($G(NDNOD),"^",3),X=$$PSJDF^PSNAPIS(DA,K),D1F1=X I D1F1'=0 D
 ..S DA=$P($G(NDNOD),"^"),X=$$VAGN^PSNAPIS(DA),VAGN=X I $L(VAGN)<41 D
 ...S ^TMP("PSSD",$J,VAGN_" "_$P(D1F1,"^",2),PSODNAME)=""
END K ^TMP($J,"PSSPP"),AA,APPU,COMM,COMMSUP,NDNOD,ONOD,OTHNAME,POII,PPP,PSOIPTR,PRIPTR,PSODF,PSODNAME,WW,ZZZ Q
CANT ;Generic Name after Primary, can't match
 F LLL=0:0 S LLL=$O(^PSDRUG(LLL)) Q:'LLL  D  I TMPFLG S ^TMP("PSSD",$J,"ZZZZ",PSNAME)=RSN
 .K RSN,DOSFO,POTDOS
 .S PSNDO=$G(^PSDRUG(LLL,"ND")),PSNAME=$P($G(^(0)),"^"),PSPTR=$P($G(^(2)),"^"),PSPRIM=$P($G(^(2)),"^",6) S DA=$P($G(PSNDO),"^"),K=$P($G(PSNDO),"^",3),X=$$PSJDF^PSNAPIS(DA,K),FRM1=X,TMPFLG=0
 .I +PSPTR Q
 .;If Primary, ZZZZ or PSS
 .I $D(^TMP("PSS",$J,PSNAME)) Q
 .K ^TMP($J,"PSSO") I +$P(PSNDO,"^"),+$P(PSNDO,"^",3) F BB=0:0 S BB=$O(^PSDRUG("AND",+PSNDO,BB)) Q:'BB  S OTHER=$P($G(^PSDRUG(BB,0)),"^") I $D(^TMP("PSS",$J,OTHER)) D
 ..S OTNO=$G(^PSDRUG(BB,"ND")) I +$P(OTNO,"^"),+$P(OTNO,"^",3),FRM1'=0 S DA=$P($G(OTNO),"^"),K=$P($G(OTNO),"^",3),X=$$PSJDF^PSNAPIS(DA,K),FRM2=X I FRM2'=0 D
 ...I FRM1=FRM2 D
 ....S SAME=0,POINAME=^TMP("PSS",$J,OTHER) F III=0:0 S III=$O(^TMP($J,"PSSO",III)) Q:'III  I POINAME=^(III) S SAME=1
 ....I 'SAME S ^TMP($J,"PSSO",BB)=^TMP("PSS",$J,OTHER)
 .S PSCOMMD=0 I $O(^TMP($J,"PSSO",0)) S TTT=$O(^TMP($J,"PSSO",0)),ORDNAM=^TMP($J,"PSSO",TTT) F TTT=0:0 S TTT=$O(^TMP($J,"PSSO",TTT)) Q:'TTT  I ORDNAM'=^TMP($J,"PSSO",TTT) S PSCOMMD=1
 .I $O(^TMP($J,"PSSO",0)),'PSCOMMD K ^TMP("PSSD",$J,"ZZZZ",PSNAME) Q
 .S CNT=0 I $O(^TMP($J,"PSSO",0)),'$D(^TMP("PSSD",$J,"ZZZZ",PSNAME)) S (CNT,TMPFLG)=1 F NN=0:0 S NN=$O(^TMP($J,"PSSO",NN)) Q:'NN  S ^TMP("PSSD",$J,"ZZZZ",PSNAME,CNT)=^TMP($J,"PSSO",NN) S CNT=CNT+1
 .I CNT S RSN="Multiple Orderable Items" Q
 .S QFLAG=0 I +$P(PSNDO,"^"),+$P(PSNDO,"^",3) S DA=$P($G(PSNDO),"^"),X=$$VAGN^PSNAPIS(DA),VAGN1=X I VAGN1'=0 S DOSFO=$P(FRM1,"^") D
 ..I DOSFO,$D(^PS(50.606,DOSFO,0)),$L(VAGN1)<41 S QFLAG=1
 .I QFLAG K ^TMP("PSSD",$J,"ZZZZ",PSNAME) Q
 .I $D(^TMP("PSSD",$J,"ZZZZ",PSNAME)) Q
 .S TMPFLG=1
 .I $P(PSNDO,"^")="" S RSN="NDF link missing or incomplete" Q
 .I $P(PSNDO,"^",3)="" S RSN="No PSNDF VA Product Name Entry" Q
 .I VAGN1=0 S RSN="Invalid National Drug File Entry" Q
 .S PVA=$P($G(PSNDO),"^",3),DA=$P($G(PSNDO),"^"),K=PVA,X=$$PROD0^PSNAPIS(DA,K) I X']"" S RSN="Invalid PSNDF VA Product Name Entry" Q
 .S DA=$P($G(PSNDO),"^"),K=PVA,X=$$PSJDF^PSNAPIS(DA,K),FRM0=X I FRM0=0 S RSN="No Dosage Form entry in NDF" Q
 .I FRM0=0 S RSN="Missing Dosage Form in NDF" Q
 .I FRM0=0 S RSN="Invalid Entry in Dosage Form File" Q
 .I $L(VAGN1)>40 S RSN="Generic name exceeds 40 characters" Q
 .S RSN="Undetermined problem" Q
DONE K ^TMP($J,"PSSO"),^TMP("PSS",$J),APL,BB,CNT,DOSFRM,DOSPNT,SAME,LLL,III,NN,ORDNAM,OTHER,OTNO,POINAME,PSCOMMD,PSNAME,PSPTR,PSPRIM,POTDOS,PSNDO,DOSFO,PVA,QFLAG,RSN,TTT,TMPFLG Q
