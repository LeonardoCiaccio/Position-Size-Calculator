//+------------------------------------------------------------------+
//|                                     Position Size Calculator.mq4 |
//|                        Copyright © 2015 - 2016, Leonardo Ciaccio |
//|      https://github.com/LeonardoCiaccio/Position-Size-Calculator |
//|                                                                  |
//|             Donate Bitcoins : 1KHSR2S58y8WV6o3zRYeD5fBApvfTMtj8B |
//|             Donate PayPal   : microlabs@altervista.org           |
//+------------------------------------------------------------------+


enum __money{ 

   FreeMargin,
   Balance,
   Equity 

};

enum __position{

   Top = 1,
   Bottom = 3

};

#property copyright "Copyright © 2015-2016, Leonardo Ciaccio"
#property link      "https://github.com/LeonardoCiaccio/Position-Size-Calculator"
#property indicator_chart_window

extern string  Info            = "[ App Info ]";
extern string  Name            = "Position Size Calculator";
extern string  Version         = "v.1.0.1";
extern string  Contact         = "leonardo.ciaccio@gmail.com";
extern string  Web             = "https://github.com/LeonardoCiaccio/Position-Size-Calculator";
extern string  Donate_Bitcoins = "1KHSR2S58y8WV6o3zRYeD5fBApvfTMtj8B";
extern string  Donate_PayPal   = "microlabs@altervista.org";

extern string  Setup           = "[ App Setup ]";
extern __money AccountMoney    = FreeMargin;
extern double StopLossPips     = 30;
extern double Risk             = 5;

extern string  Box             = "[ App Box ]";
extern color Color_BackGround  = Black;
extern color Color_Lots        = Red;
extern color Color_Profit      = LightBlue;
extern color Color_Tick        = Orange;  
extern color Font_Color        = LightBlue;
extern int Font_Size           = 12;
extern string Font_Face        = "Courier";
extern __position Position      = Top;
extern int Distance_X          = 17;
extern int Distance_Y          = 15;
extern int BackGround_Size     = 165;

double MyPoint = 0.0;
string MySymbol = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   
   MyPoint = Point;
   if( Digits == 3 || Digits == 5 )MyPoint = Point * 10;
   
   MySymbol = Symbol();
   
   return( 0 );
   
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){

   remove_box();
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

   create_box();
   return( 0 );
}

//+------------------------------------------------------------------+
//| Current Spread for current pair                                  |
//+------------------------------------------------------------------+
double current_spread(){
   
   double spread;
   
   if( Digits == 3 || Digits == 5 ){
   
    spread = NormalizeDouble( MarketInfo( Symbol(), MODE_SPREAD ) / 10, 1 );
   
   }else{
   
    spread = NormalizeDouble( MarketInfo( Symbol(), MODE_SPREAD ), 0 );
   
   } 
   
   return(spread);

}

//+------------------------------------------------------------------+
//| Create a box information                                         |
//+------------------------------------------------------------------+
void create_box(){
   
   string txtBG = "g";
   string aName = "Account";
   string bName = "unknown";
   double size  = 0.0;
   
   switch( AccountMoney ){
   
      case 0 : 
         
         size  = AccountFreeMargin(); 
         aName = "Free Margin";
         break;
      
      case 1 : 
         
         size  = AccountBalance();
         aName = "Balance";
         break;
         
      case 2 : 
         
         size  = AccountEquity();
         aName = "Equity";
         break;
   
   }
   bName = DoubleToStr( size, 2 );
   
   double riskMoney = ( size / 100 ) * Risk;
   double unitCost = MarketInfo( Symbol(), MODE_TICKVALUE );
   double tickSize = MarketInfo( Symbol(), MODE_TICKSIZE );
   double positionSize = riskMoney / ( ( ( NormalizeDouble( StopLossPips * MyPoint, Digits ) ) * unitCost ) / tickSize );
   
   
   // Background
   ObjectCreate( "BoxBackground", OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSetText("BoxBackground", txtBG, BackGround_Size, "Webdings");      
   ObjectSet("BoxBackground", OBJPROP_CORNER, Position);
   ObjectSet("BoxBackground", OBJPROP_BACK, false);
   ObjectSet("BoxBackground", OBJPROP_XDISTANCE, 3 );
   ObjectSet("BoxBackground", OBJPROP_YDISTANCE, 3 );    
   ObjectSet("BoxBackground", OBJPROP_COLOR, Color_BackGround );
   
   ObjectCreate( "Spread", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Spread", OBJPROP_CORNER, Position );
   ObjectSet( "Spread", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Spread", OBJPROP_YDISTANCE, Distance_Y );
   ObjectSetText( "Spread", "SPREAD : " + DoubleToStr( current_spread(), 2 ) , Font_Size, Font_Face, Font_Color);   
   
   ObjectCreate("EntryLevel", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "EntryLevel", OBJPROP_CORNER, Position );
   ObjectSet( "EntryLevel", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "EntryLevel", OBJPROP_YDISTANCE, Distance_Y * 3 );
   ObjectSetText( "EntryLevel", "Level : " + DoubleToStr( Ask, Digits ), Font_Size, Font_Face, Font_Color);
   
   ObjectCreate("AccountSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "AccountSize", OBJPROP_CORNER, Position );
   ObjectSet( "AccountSize", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "AccountSize", OBJPROP_YDISTANCE, Distance_Y * 4 );   
   ObjectSetText( "AccountSize", aName + " : " + bName, Font_Size, Font_Face, Font_Color);
   
   ObjectCreate("StopLoss", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "StopLoss", OBJPROP_CORNER, Position );
   ObjectSet( "StopLoss", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "StopLoss", OBJPROP_YDISTANCE, Distance_Y * 5 );
   ObjectSetText( "StopLoss", "Stop Loss : " + StopLossPips , Font_Size, Font_Face, Font_Color);
      
   ObjectCreate("Risk", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Risk", OBJPROP_CORNER, Position );
   ObjectSet( "Risk", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Risk", OBJPROP_YDISTANCE, Distance_Y * 6 );
   ObjectSetText( "Risk", "Risk : " + DoubleToStr( Risk, 2 ) + " %" , Font_Size, Font_Face, Font_Color);
   
   ObjectCreate("RiskM", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "RiskM", OBJPROP_CORNER, Position );
   ObjectSet( "RiskM", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "RiskM", OBJPROP_YDISTANCE, Distance_Y * 7 );
   ObjectSetText( "RiskM", "Money : " + DoubleToStr( riskMoney, 2 ) , Font_Size, Font_Face, Font_Color); 
     
   ObjectCreate("TickValue", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "TickValue", OBJPROP_CORNER, Position );
   ObjectSet( "TickValue", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "TickValue", OBJPROP_YDISTANCE, Distance_Y * 9 );
   ObjectSetText( "TickValue", "Tick Value : " + DoubleToStr( unitCost, 3 ) , Font_Size, Font_Face, Color_Tick );
   
   ObjectCreate("TickSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "TickSize", OBJPROP_CORNER, Position );
   ObjectSet( "TickSize", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "TickSize", OBJPROP_YDISTANCE, Distance_Y * 10 );
   ObjectSetText( "TickSize", "Tick Size : " + DoubleToStr( tickSize, 3 ) , Font_Size, Font_Face, Color_Tick);
   
   ObjectCreate("PositionSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "PositionSize", OBJPROP_CORNER, Position );
   ObjectSet( "PositionSize", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "PositionSize", OBJPROP_YDISTANCE, Distance_Y * 11 );
   ObjectSetText( "PositionSize", "LOTS : " + DoubleToStr( positionSize, 3 ) , Font_Size, Font_Face, Color_Lots);
   
   ObjectCreate("Profit", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Profit", OBJPROP_CORNER, Position );
   ObjectSet( "Profit", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Profit", OBJPROP_YDISTANCE, Distance_Y * 13 );
   ObjectSetText( "Profit", "Profit : " + DoubleToStr( total_profit(), 2 ) , Font_Size, Font_Face, Color_Profit);
   
}

//+------------------------------------------------------------------+
//| Remove a box information                                         |
//+------------------------------------------------------------------+
void remove_box(){

   ObjectDelete( "Spread" );
   ObjectDelete( "EntryLevel" );
   ObjectDelete( "StopLoss" );
   ObjectDelete( "Risk" );
   ObjectDelete( "RiskM" );
   ObjectDelete( "AccountSize" );
   ObjectDelete( "PositionSize" );
   ObjectDelete( "TickValue" );
   ObjectDelete( "TickSize" );
   ObjectDelete( "Profit" );
   ObjectDelete( "BoxBackground" );
   
}

//+------------------------------------------------------------------+
//| Total profit                                                     |
//+------------------------------------------------------------------+
double total_profit(){
   
   double tt_profit  =  0.0;
   
   for( int x = 0; x < OrdersTotal(); x++ ){
   
       OrderSelect( x, SELECT_BY_POS, MODE_TRADES );
       
       if( OrderSymbol() == MySymbol ){
       
         tt_profit += OrderProfit();
       
       }
   
   }
   
   return(tt_profit);
}
