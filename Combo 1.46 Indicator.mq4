//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright ?2004, MetaQuotes Software Corp. |
//|                                       [url]http://www.metaquotes.net/[/url] |
//+------------------------------------------------------------------+
#property  copyright "Copyright ?2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 6
#property  indicator_color1  Green
#property  indicator_color2  Blue
#property  indicator_color3  MediumSpringGreen
#property  indicator_color4  Red
#property  indicator_color5  Magenta
#property  indicator_color6  DeepPink


//---------指标用于预测符合开仓的K线-----------
//---------BUY---------------
double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];
//----------SELL-------------
double     ind_buffer4[];
double     ind_buffer5[];
double     ind_buffer6[];

//---- indicator parameters
extern string maigc1_string = "magic1 在m15下面看----------------------";
extern bool magic1_indicator = false;
extern int g_shock_MA_m15_multiple        = 20;       
extern int g_shock_WPR_m15_open_bound_1   = 10;
extern int g_shock_close_m15_multiple     = -5;
extern int g_shock_WPR_m15_open_bound_2   = 6;
int g_period_shock_MA_m15  = 60;          //ind_period1,4
int g_period_shock_WPR_m15 = 18;          //ind_period5,6
int ind_period3 = 15;
int ind_period6 = 15;

extern string magic2_string = "magic2 在h1下面看---------------------";
extern bool magic2_indicator = false;
extern int g_period_break_ATR_h1          = 19;
extern int g_period_break_MA_h1           = 1;
extern double g_break_ATR_multiple        = 1.4;
extern double g_break_close_m5_multiple   = 13;

extern string magic3_string = "magic3 在h1下面看---------------------";
extern bool magic3_indicator = true;
extern int g_period_fish_ATR_m5 = 60;
extern int g_period_fish_bands = 26;
extern int fish_bands_width_min_multiple = 30;
extern int fish_bands_multiple = -3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,236);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,1);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,1);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,237);
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT,1);

   if(magic1_indicator == true){
      SetIndexDrawBegin(0,g_period_shock_MA_m15);
      SetIndexDrawBegin(1,g_period_shock_WPR_m15);
      SetIndexDrawBegin(2,ind_period3);
      SetIndexDrawBegin(3,g_period_shock_MA_m15);
      SetIndexDrawBegin(4,g_period_shock_WPR_m15);
      SetIndexDrawBegin(5,ind_period6);
      SetIndexLabel(0,"shock ma m15 buy");
      SetIndexLabel(1,"shock wpr m15 buy");
      SetIndexLabel(2,"shock close m15 buy FLAG");
      SetIndexLabel(3,"shock ma m15 sell");
      SetIndexLabel(4,"shock wpr m15 sell");
      SetIndexLabel(5,"shock close m15 sell FLAG");
   }
   if(magic2_indicator == true){
      SetIndexDrawBegin(0,g_period_break_ATR_h1);
      SetIndexDrawBegin(1,g_period_break_MA_h1);
      SetIndexDrawBegin(3,g_period_break_ATR_h1);
      SetIndexDrawBegin(4,g_period_break_MA_h1);
      SetIndexLabel(0,"break price ceiling buy");
      SetIndexLabel(1,"break close m5 buy FLAG");
      SetIndexLabel(3,"break price floor sell");
      SetIndexLabel(4,"break close m5 sell FLAG");
   }
   if(magic3_indicator == true){
      SetIndexDrawBegin(0,g_period_fish_bands);
      SetIndexDrawBegin(1,g_period_fish_bands);
      SetIndexDrawBegin(3,g_period_fish_bands);
      SetIndexDrawBegin(4,g_period_fish_bands);
      SetIndexLabel(0,"fish price ceiling buy");
      SetIndexLabel(1,"fish close m5 buy FLAG");
      SetIndexLabel(3,"fish price floor sell");
      SetIndexLabel(4,"fish close m5 sell FLAG");
   }
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) && !SetIndexBuffer(1,ind_buffer2)&& !SetIndexBuffer(2,ind_buffer3))
      Print("cannot set indicator buffers!");
   if(!SetIndexBuffer(3,ind_buffer4) && !SetIndexBuffer(4,ind_buffer5)&& !SetIndexBuffer(5,ind_buffer6))
      Print("cannot set indicator buffers!");
//---- initialization done
   return(0);
  }
int start()
  {
   double point_aid=0.0001;
   int timezone_revise_magic1_1 = 21;
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(int i=0; i<limit; i++){
      if(magic1_indicator == true){
         double wpr_m15    = iWPR(NULL,PERIOD_M15,g_period_shock_WPR_m15,i+1);
         double price_ilow = iLow(NULL,PERIOD_M15,i);
         double price_ihigh= iHigh(NULL,PERIOD_M15,i);
         double close_m15  = iClose(NULL,PERIOD_M15,i+1);
         
         //买单的
         //ma价格线, g_shock_MA_m15_multiple==20,g_period_shock_MA_m15==60
         ind_buffer1[i]=iMA(NULL,PERIOD_M15,g_period_shock_MA_m15,0,MODE_SMMA,PRICE_CLOSE,i+1)+g_shock_MA_m15_multiple*point_aid;
         //前一个柱子的收盘价线, g_shock_close_m15_multiple == -5
         ind_buffer3[i]=iClose(NULL,PERIOD_M15,i+1)-g_shock_close_m15_multiple*point_aid;
         //画箭头
         if(close_m15 > ind_buffer1[i] &&(iLow(NULL,PERIOD_M15,i) < ind_buffer3[i]) &&wpr_m15 < g_shock_WPR_m15_open_bound_1+(-100)){
            ind_buffer2[i]=iHigh(NULL,0,i)+5*point_aid;
         }
         //timezone_revise_magic1_1 == 21
         if((iLow(NULL,PERIOD_M15,i) < ind_buffer3[i]) && wpr_m15 < g_shock_WPR_m15_open_bound_2 + (-100) && Hour() == timezone_revise_magic1_1){
            ind_buffer2[i]=iHigh(NULL,0,i)+15*point_aid;
         }
         //卖单的
         //ma价格线, g_shock_MA_m15_multiple==20,g_period_shock_MA_m15==60
         ind_buffer4[i]=iMA(NULL,PERIOD_M15,g_period_shock_MA_m15,0,MODE_SMMA,PRICE_CLOSE,i+1)-g_shock_MA_m15_multiple*point_aid;
         //前一个柱子的收盘价线, g_shock_close_m15_multiple == -5
         ind_buffer6[i]=iClose(NULL,PERIOD_M15,i+1)+g_shock_close_m15_multiple*point_aid;
         //画箭头
         if(close_m15 < ind_buffer4[i] &&(iHigh(NULL,PERIOD_M15,i) > ind_buffer6[i]) &&wpr_m15 > (-g_shock_WPR_m15_open_bound_1)){
            ind_buffer5[i]=iLow(NULL,0,i)-5*point_aid;
         }
         //timezone_revise_magic1_1 == 21
         if((iHigh(NULL,PERIOD_M15,i) > ind_buffer6[i]) && wpr_m15 > (-g_shock_WPR_m15_open_bound_2)/* && Hour() == timezone_revise_magic1_1*/){
            ind_buffer5[i]=iLow(NULL,0,i)-15*point_aid;
         }
      }
      if(magic2_indicator == true){
         double break_ATR_h1 = iATR(NULL, PERIOD_H1, g_period_break_ATR_h1, i+1);                           //g_period_break_ATR_h1 == 19
         double break_MA_h1  = iMA(NULL, PERIOD_H1, g_period_break_MA_h1, 0, MODE_EMA, PRICE_CLOSE, i+1);   //g_period_break_MA_h1 == 1
         double break_channel_ceiling = break_MA_h1 + break_ATR_h1 * g_break_ATR_multiple;
         double break_channel_floor   = break_MA_h1 - break_ATR_h1 * g_break_ATR_multiple;
         double close_m5   = iClose(NULL,PERIOD_M5,i+1);
         ind_buffer1[i] = break_channel_ceiling + g_break_close_m5_multiple * point_aid;
         if(close_m5 >= ind_buffer1[i]){
            ind_buffer2[i] = iHigh(NULL,0,i)+5*point_aid;
         }
         ind_buffer4[i] = break_channel_floor - g_break_close_m5_multiple * point_aid;
         if(close_m5 <= ind_buffer4[i]){
            ind_buffer5[i] = iLow(NULL,0,i)-15*point_aid;
         }
      }
      if(magic3_indicator == true){
         double fish_ATR_m5 = iATR(NULL, PERIOD_M5, g_period_fish_ATR_m5, i+1);                                         //g_period_fish_ATR_m5 == 60
         double high_h1     = iHigh(NULL, PERIOD_H1, i+1);
         double low_h1	    = iLow(NULL, PERIOD_H1, i+1);
         double fish_bands_ceiling 	= iBands(NULL, PERIOD_H1, g_period_fish_bands, 2, 0, PRICE_CLOSE, MODE_UPPER, i+1); //g_period_fish_bands == 26
         double fish_bands_floor 	= iBands(NULL, PERIOD_H1, g_period_fish_bands, 2, 0, PRICE_CLOSE, MODE_LOWER, i+1); 
         //fish_bands_multiple == -3, fish_bands_width_min_multiple == 30
         ind_buffer1[i] = fish_bands_floor - fish_bands_multiple * point_aid;
         if(fish_bands_ceiling - fish_bands_floor >= fish_bands_width_min_multiple * point_aid && high_h1 < ind_buffer1[i]){
            ind_buffer2[i] = iHigh(NULL,0,i)+5*point_aid;
         }
         ind_buffer4[i] = fish_bands_ceiling + fish_bands_multiple * point_aid;
         if(fish_bands_ceiling - fish_bands_floor >= fish_bands_width_min_multiple * point_aid && high_h1 > ind_buffer1[i]){
            ind_buffer5[i] = iLow(NULL,0,i)-15*point_aid;
         }
      }
   }
//---- done
   return(0);
  }
