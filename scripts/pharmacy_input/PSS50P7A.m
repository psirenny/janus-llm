PSS50P7A ;BIR/LDT - API FOR INFORMATION FROM FILE 50.7; 5 Sep 03
 ;;1.0;PHARMACY DATA MANAGEMENT;**85**;9/30/97
 ;
LOOKUP ;
 N PSSSCRN,PSSLUPAR,PSSLUPP,PSSLKIEN,PSSCT507,PSSXSUB
 S SCR("S")=$S($G(PSSS)]"":PSSS,1:"")
 S PSSCT507=0
 I PSSFT["??" D LOOP^PSS50P7A(5) Q
 S PSSXSUB="" D SETXSUB
 K ^TMP("DILIST",$J),^TMP($J,"PSSLDONE")
 S PSSSCRN=$G(SCR("S")) S:$G(PSSD)="" PSSD="B" D PARSE^PSS50F(PSSD) I '$O(PSSLUPAR(0)) S ^TMP($J,LIST,0)=-1_"^"_"NO DATA FOUND" Q
 S PSSLUPP=0 F  S PSSLUPP=$O(PSSLUPAR(PSSLUPP)) Q:'PSSLUPP  D
 .S SCR("S")=$G(PSSSCRN)
 .D FIND^DIC(50.7,,"@;.01;.02IE;.04IE","QPB"_$S($P(PSSLUPAR(PSSLUPP),"^",2):"X",1:""),PSSFT,,PSSLUPAR(PSSLUPP),SCR("S"),,"")
 .I +$G(^TMP("DILIST",$J,0))'>0 Q
 .S PSS(2)=0
 .F  S PSS(2)=$O(^TMP("DILIST",$J,PSS(2))) Q:'PSS(2)  D
 ..S PSSLKIEN=$P($G(^TMP("DILIST",$J,PSS(2),0)),"^") I '$D(^TMP($J,"PSSLDONE",PSSLKIEN)) S ^TMP($J,"PSSLDONE",PSSLKIEN)="" D
 ...S PSSCT507=PSSCT507+1
 ...S ^TMP($J,LIST,+^TMP("DILIST",$J,PSS(2),0),.01)=$P(^TMP("DILIST",$J,PSS(2),0),"^",2)
 ...S ^TMP($J,LIST,$S($G(PSSXSUB)'="":$G(PSSXSUB),1:"B"),$P(^TMP("DILIST",$J,PSS(2),0),"^",2),+^TMP("DILIST",$J,PSS(2),0))=""
 ...S ^TMP($J,LIST,+^TMP("DILIST",$J,PSS(2),0),.02)=$S($P($G(^TMP("DILIST",$J,PSS(2),0)),"^",3)]"":$P(^TMP("DILIST",$J,PSS(2),0),"^",3,4),1:"")
 ...S ^TMP($J,LIST,+^TMP("DILIST",$J,PSS(2),0),.04)=$S($P($G(^TMP("DILIST",$J,PSS(2),0)),"^",5)]"":$P(^TMP("DILIST",$J,PSS(2),0),"^",5,6),1:"")
 S ^TMP($J,LIST,0)=$S(PSSCT507>0:PSSCT507,1:"-1^NO DATA FOUND")
 K ^TMP("DILIST",$J),^TMP($J,"PSSLDONE")
 Q
SETZRO ;
 S ^TMP($J,LIST,+PSS(1),.01)=$G(PSS50P7(50.7,PSS(1),.01,"I"))
 S ^TMP($J,LIST,"B",$G(PSS50P7(50.7,PSS(1),.01,"I")),+PSS(1))=""
 S ^TMP($J,LIST,+PSS(1),.02)=$S($G(PSS50P7(50.7,PSS(1),.02,"I"))="":"",1:PSS50P7(50.7,PSS(1),.02,"I")_"^"_PSS50P7(50.7,PSS(1),.02,"E"))
 S ^TMP($J,LIST,+PSS(1),.03)=$S($G(PSS50P7(50.7,PSS(1),.03,"I"))="":"",1:PSS50P7(50.7,PSS(1),.03,"I")_"^"_PSS50P7(50.7,PSS(1),.03,"E"))
 S ^TMP($J,LIST,+PSS(1),.04)=$S($G(PSS50P7(50.7,PSS(1),.04,"I"))="":"",1:PSS50P7(50.7,PSS(1),.04,"I")_"^"_PSS50P7(50.7,PSS(1),.04,"E"))
 S ^TMP($J,LIST,+PSS(1),.05)=$G(PSS50P7(50.7,PSS(1),.05,"I"))
 S ^TMP($J,LIST,+PSS(1),.06)=$S($G(PSS50P7(50.7,PSS(1),.06,"I"))="":"",1:PSS50P7(50.7,PSS(1),.06,"I")_"^"_PSS50P7(50.7,PSS(1),.06,"E"))
 S ^TMP($J,LIST,+PSS(1),.07)=$S($G(PSS50P7(50.7,PSS(1),.07,"I"))="":"",1:PSS50P7(50.7,PSS(1),.07,"I")_"^"_PSS50P7(50.7,PSS(1),.07,"E"))
 S ^TMP($J,LIST,+PSS(1),.08)=$G(PSS50P7(50.7,PSS(1),.08,"I"))
 S ^TMP($J,LIST,+PSS(1),.09)=$S($G(PSS50P7(50.7,PSS(1),.09,"I"))="":"",1:PSS50P7(50.7,PSS(1),.09,"I")_"^"_PSS50P7(50.7,PSS(1),.09,"E"))
 S ^TMP($J,LIST,+PSS(1),8)=$S($G(PSS50P7(50.7,PSS(1),8,"I"))="":"",1:PSS50P7(50.7,PSS(1),8,"I")_"^"_PSS50P7(50.7,PSS(1),8,"E"))
 S ^TMP($J,LIST,+PSS(1),5)=$S($G(PSS50P7(50.7,PSS(1),5,"I"))="":"",1:PSS50P7(50.7,PSS(1),5,"I")_"^"_PSS50P7(50.7,PSS(1),5,"E"))
 Q
 ;
SETZR2 ;
 S ^TMP($J,LIST,+PSS(2),.01)=$G(PSS50P7(50.7,PSS(2),.01,"I"))
 S ^TMP($J,LIST,"B",$G(PSS50P7(50.7,PSS(2),.01,"I")),+PSS(2))=""
 S ^TMP($J,LIST,+PSS(2),.02)=$S($G(PSS50P7(50.7,PSS(2),.02,"I"))="":"",1:PSS50P7(50.7,PSS(2),.02,"I")_"^"_PSS50P7(50.7,PSS(2),.02,"E"))
 Q
 ;
SETSYN ;
 S ^TMP($J,LIST,+PSSIEN,"SYN",+PSS(1),.01)=$G(PSS50P7(50.72,PSS(1),.01,"I"))
 Q
 ;
SETPTI ;
 S ^TMP($J,LIST,+PSS(1),.01)=$G(PSS50P7(50.7,PSS(1),.01,"I"))
 S ^TMP($J,LIST,"B",$G(PSS50P7(50.7,PSS(1),.01,"I")),+PSS(1))=""
 S ^TMP($J,LIST,+PSS(1),.02)=$S($G(PSS50P7(50.7,PSS(1),.02,"I"))="":"",1:PSS50P7(50.7,PSS(1),.02,"I")_"^"_PSS50P7(50.7,PSS(1),.02,"E"))
 S ^TMP($J,LIST,+PSS(1),7)=$G(PSS50P7(50.7,PSS(1),7,"I"))
 S ^TMP($J,LIST,+PSS(1),7.1)=$G(PSS50P7(50.7,PSS(1),7.1,"I"))
 Q
 ;
LOOP(PSS) ;
 N CNT,PSSIEN S CNT=0
 S PSSIEN=0 F  S PSSIEN=$O(^PS(50.7,PSSIEN)) Q:'PSSIEN  D
 .S ND=$P($G(^PS(50.7,+PSSIEN,0)),U,4) I ND=""!ND>$G(PSSFL) D @(PSS)
 S ^TMP($J,LIST,0)=$S(CNT>0:CNT,1:"-1^NO DATA FOUND")
 Q
 ;
1 ;
 K PSS50P7 D GETS^DIQ(50.7,+PSSIEN,".01;.02;.03;.04;.05;.06;.07;.08;.09;8;5","IE","PSS50P7") S PSS(1)=0
 F  S PSS(1)=$O(PSS50P7(50.7,PSS(1))) Q:'PSS(1)  D SETZRO^PSS50P7A S CNT=CNT+1
 Q
 ;
2 ;
 N CNT2 S CNT2=0
 K PSS50P7 D GETS^DIQ(50.7,+PSSIEN,".01;.02;2*","IE","PSS50P7") S PSS(1)=0
 F  S PSS(1)=$O(PSS50P7(50.72,PSS(1))) Q:'PSS(1)  D SETSYN^PSS50P7A S CNT2=CNT2+1
 S PSS(2)=0 F  S PSS(2)=$O(PSS50P7(50.7,PSS(2))) Q:'PSS(2)  D SETZR2^PSS50P7A S CNT=CNT+1
 S ^TMP($J,LIST,+PSSIEN,"SYN",0)=$S(CNT2>0:CNT2,1:"-1^NO DATA FOUND")
 Q
 ;
3 ;
 K PSS50P7 D GETS^DIQ(50.7,+PSSIEN,".01;.02;7;7.1","IE","PSS50P7") S PSS(1)=0
 F  S PSS(1)=$O(PSS50P7(50.7,PSS(1))) Q:'PSS(1)  D SETPTI^PSS50P7A S CNT=CNT+1
 Q
 ;
4 ;
 K PSS50P7 D GETS^DIQ(50.7,+PSSIEN,".01;.02","IE","PSS50P7") S PSS(2)=0
 F  S PSS(2)=$O(PSS50P7(50.7,PSS(2))) Q:'PSS(2)  D SETZR2^PSS50P7A S CNT=CNT+1
 Q
 ;
5 ;
 D FIND^DIC(50.7,,"@;.01;.02IE;.04IE","QP","`"_+PSSIEN,,"B",SCR("S"),,"")
 S CNT=CNT+1,^TMP($J,LIST,0)=+^TMP("DILIST",$J,0) S PSS(2)=0 D
 .F  S PSS(2)=$O(^TMP("DILIST",$J,PSS(2))) Q:'PSS(2)  D
 ..S ^TMP($J,LIST,+^TMP("DILIST",$J,PSS(2),0),.01)=$P(^TMP("DILIST",$J,PSS(2),0),"^",2)
 ..S ^TMP($J,LIST,"B",$P(^TMP("DILIST",$J,PSS(2),0),"^",2),+^TMP("DILIST",$J,PSS(2),0))=""
 ..S ^TMP($J,LIST,+^TMP("DILIST",$J,PSS(2),0),.02)=$S($P($G(^TMP("DILIST",$J,PSS(2),0)),"^",3)]"":$P(^TMP("DILIST",$J,PSS(2),0),"^",3,4),1:"")
 ..S ^TMP($J,LIST,+^TMP("DILIST",$J,PSS(2),0),.04)=$S($P($G(^TMP("DILIST",$J,PSS(2),0)),"^",5)]"":$P(^TMP("DILIST",$J,PSS(2),0),"^",5,6),1:"")
 K ^TMP("DILIST",$J)
 Q
SETXSUB ;
 Q:$G(PSSD)=""
 N PSSLSX,PSSLSXCT,PSSLCNT,PSSDSUB
 S PSSLSXCT=0
 F PSSLSX=1:1:$L(PSSD) I $E(PSSD,PSSLSX)="^" S PSSLSXCT=PSSLSXCT+1
 S PSSLSXCT=PSSLSXCT+1
 S PSSLCNT=0 F PSSLSX=1:1:PSSLSXCT S PSSDSUB=$P(PSSD,"^",PSSLSX) Q:PSSLCNT>1  S PSSXSUB=$S(PSSDSUB'="":PSSDSUB,PSSXSUB'="":PSSXSUB,1:"") S:PSSDSUB'="" PSSLCNT=PSSLCNT+1
 I PSSLCNT>1 S PSSXSUB=""
 Q
