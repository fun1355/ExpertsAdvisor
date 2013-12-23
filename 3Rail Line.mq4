//+------------------------------------------------------------------+
//|                                                  SHI_Channel.mq4 |
//|                                 Copyright ?2004, Shurka & Kevin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2004, Shurka & Kevin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
double ExtMapBuffer1[];
//---- input parameters
extern int       AllBars=240;
extern int       BarsForFract=0;
int CurrentBar=0;
double Step=0;
int B1=-1,B2=-1;
int UpDown=0;
double P1=0,P2=0,PP=0;
int i=0,AB=300,BFF=0;
int ishift=0;
double iprice=0;
datetime T1,T2;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,164);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
//----
	
	
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }

void DelObj()
{
	ObjectDelete("TL1");
	ObjectDelete("TL2");
	ObjectDelete("MIDL");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//---- 
	if ((AllBars==0) || (Bars<AllBars)) AB=Bars; else AB=AllBars; //AB-觐腓麇耱忸 钺聍栩噱禧?徉痤?
	if (BarsForFract>0) 
		BFF=BarsForFract; 
	else
	{
		switch (Period())
		{
			case 1: BFF=12; break;
			case 5: BFF=48; break;
			case 15: BFF=24; break;
			case 30: BFF=24; break;
			case 60: BFF=12; break;
			case 240: BFF=15; break;
			case 1440: BFF=10; break;
			case 10080: BFF=6; break;
			default: DelObj(); return(-1); break;
		}
	}
	CurrentBar=2; //聍栩噱??蝠弪泐 徉疣, 黩钺?麴嚓蜞?"玎牮屣桦?
	B1=-1; B2=-1; UpDown=0;
	while(((B1==-1) || (B2==-1)) && (CurrentBar<AB))
	{
		//UpDown=1 珥圜栩 镥疴 麴嚓蜞?磬殇屙 疋屦躞, UpDown=-1 珥圜栩 镥疴 麴嚓蜞?
		//磬殇屙 耥桤? UpDown=0 珥圜栩 麴嚓蜞?妁?礤 磬殇屙.
		//? ?? - 眍戾疣 徉痤??麴嚓蜞豚扈, 麇疱?龛?耱痤桁 铒铕眢?腓龛?
		//? ?? - 耦铗忮蝰蜮屙眍 鲥睇 麇疱?觐蝾瘥?狍溴?腓龛?镳钼钿栩?

		if((UpDown<1) && (CurrentBar==Lowest(Symbol(),Period(),MODE_LOW,BFF*2+1,CurrentBar-BFF))) 
		{
			if(UpDown==0) { UpDown=-1; B1=CurrentBar; P1=Low[B1]; }
			else { B2=CurrentBar; P2=Low[B2];}
		}
		if((UpDown>-1) && (CurrentBar==Highest(Symbol(),Period(),MODE_HIGH,BFF*2+1,CurrentBar-BFF))) 
		{
			if(UpDown==0) { UpDown=1; B1=CurrentBar; P1=High[B1]; }
			else { B2=CurrentBar; P2=High[B2]; }
		}
		CurrentBar++;
	}
	if((B1==-1) || (B2==-1)) {DelObj(); return(-1);} // 琼圜栩 礤 磬?麴嚓蜞腩?耩邃?300 徉痤?8-)
	Step=(P2-P1)/(B2-B1);//蔓麒耠桦?? 羼腓 铐 镱腩骅蝈朦睇? 蝾 赅磬?龛聃钿?
	P1=P1-B1*Step; B1=0;//镥疱耱噔?屐 鲥眢 ?镥疴 徉??眢膻
	//?蝈镥瘘 铒铕眢?蝾麝?镳铗桠铒铍铈眍?腓龛?赅磬豚.
	ishift=0; iprice=0;
	if(UpDown==1)
	{ 
		PP=Low[2]-2*Step;
		for(i=3;i<=B2;i++) 
		{
			if(Low[i]<PP+Step*i) { PP=Low[i]-i*Step; }
		}
		if(Low[0]<PP) {ishift=0; iprice=PP;}
		if(Low[1]<PP+Step) {ishift=1; iprice=PP+Step;}
		if(High[0]>P1) {ishift=0; iprice=P1;}
		if(High[1]>P1+Step) {ishift=1; iprice=P1+Step;}
	} 
	else
	{ 
		PP=High[2]-2*Step;
		for(i=3;i<=B2;i++) 
		{
			if(High[i]>PP+Step*i) { PP=High[i]-i*Step;}
		}
		if(Low[0]<P1) {ishift=0; iprice=P1;}
		if(Low[1]<P1+Step) {ishift=1; iprice=P1+Step;}
		if(High[0]>PP) {ishift=0; iprice=PP;}
		if(High[1]>PP+Step) {ishift=1; iprice=PP+Step;}
	}
	//义镥瘘 镥疱耱噔桁 觐礤黜簋 鲥眢 ?徉?磬 缆, 黩钺?腓龛?赅磬豚 痂耦忄腓顸 镱潆桧礤?
	P2=P1+AB*Step;
	T1=Time[B1]; T2=Time[AB];

	//篷腓 礤 猁腩 镥疱皴麇龛 赅磬豚, 蝾 0, 桧圜?耱噔桁 锺桉?
	if(iprice!=0) ExtMapBuffer1[ishift]=iprice;
	DelObj();
	ObjectCreate("TL1",OBJ_TREND,0,T2,PP+Step*AB,T1,PP); 
		ObjectSet("TL1",OBJPROP_COLOR,Lime); 
		ObjectSet("TL1",OBJPROP_WIDTH,2); 
		ObjectSet("TL1",OBJPROP_STYLE,STYLE_SOLID); 
	ObjectCreate("TL2",OBJ_TREND,0,T2,P2,T1,P1); 
		ObjectSet("TL2",OBJPROP_COLOR,Lime); 
		ObjectSet("TL2",OBJPROP_WIDTH,2); 
		ObjectSet("TL2",OBJPROP_STYLE,STYLE_SOLID); 
	ObjectCreate("MIDL",OBJ_TREND,0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2);
		ObjectSet("MIDL",OBJPROP_COLOR,Lime); 
		ObjectSet("MIDL",OBJPROP_WIDTH,1); 
		ObjectSet("MIDL",OBJPROP_STYLE,STYLE_DOT);
		Comment(" Channel size = ", DoubleToStr(MathAbs(PP - P1)/Point,0), " Slope = ", DoubleToStr(-Step/Point, 2));
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
