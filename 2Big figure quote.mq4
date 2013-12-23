//+------------------------------------------------------------------+
//| Magnified Market Price.mq4        ver1.4             by Habeeb   |
//+------------------------------------------------------------------+

#property indicator_chart_window

  extern bool   Bid_Ask_Colors = False;
  extern color  clrs = White;
  extern int    Label_Size=40;
  double        Old_Price;

int init()
  {
   return(0);
  }

int deinit()
  {
  ObjectDelete("Market_Price_Label"); 
  
  return(0);
  }

int start()
  {
   if (Bid_Ask_Colors == True)
   {
    if (Bid > Old_Price) clrs = LawnGreen;
    if (Bid < Old_Price) clrs = Red;
    Old_Price = Bid;
   }
   
   string Market_Price = DoubleToStr(Bid, Digits);
  
   ObjectCreate("Market_Price_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Market_Price_Label", Market_Price, Label_Size, "Comic Sans MS", clrs);
  }
