//+------------------------------------------------------------------+
//|                                     Position Size Calculator.mq4 |
//|                        Copyright © 2015 - 2016, Leonardo Ciaccio |
//|      https://github.com/LeonardoCiaccio/Position-Size-Calculator |
//|                                                                  |
//|             Donate Bitcoins : 1KHSR2S58y8WV6o3zRYeD5fBApvfTMtj8B |
//|             Donate PayPal   : microlabs@altervista.org           |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015-2016, Leonardo Ciaccio"
#property link      "https://github.com/LeonardoCiaccio/Position-Size-Calculator"
#property indicator_chart_window
#property description "Calculate the value of size in real-time with mode Money and Percentage."
#property strict // Extern/Input box trick ;) - http://docs.mql4.com/basis/preprosessor/compilation

enum __money{ 

   FreeMargin, //Free Margin
   Balance,
   Equity 

};

enum __position{
   
   TopLeft = 0,      // Top Left
   TopRight = 1,     // Top Right
   BottomLeft = 2,   // Bottom Left
   BottomRight = 3   // Bottom Right

};

enum __mode{

   Percentage = 1,
   Money = 2

};



extern string  Info            = "--------------------------------------------------------";         // ------- INDICATOR INFORMATION
extern string  Name            = "Position Size Calculator";
extern string  Version         = "v.1.0.5";
extern string  Contact         = "leonardo.ciaccio@gmail.com";
extern string  Web             = "https://github.com/LeonardoCiaccio/Position-Size-Calculator";
extern string  Donate_Bitcoins = "1KHSR2S58y8WV6o3zRYeD5fBApvfTMtj8B";  // Donate Bitcoins
extern string  Donate_PayPal   = "microlabs@altervista.org";            // Donate PayPal

extern string  Setup           = "--------------------------------------------------------";         // ------- SETUP INDICATOR
extern __money AccountMoney    = Balance;    // Money For The Calculation
extern __mode Mode             = Percentage; // Mode For The Calculation
extern double StopLossPips     = 30;         // Stop Loss In Pips
extern double RiskPercentage   = 5;          // Risk In Percentage
extern double RiskMoney        = 25;         // Risk In Money

extern string  Box             = "--------------------------------------------------------";         // ------- SETUP BOX STYLE
extern color Color_BackGround  = Black;      // Color Of Background Box
extern color Color_Lots        = Red;        // Color Of Size
extern color Color_Profit      = LightBlue;  // Color Of Profit
extern color Color_Tick        = Orange;     // Color Of Ticks
extern color Font_Color        = LightBlue;  // Color Of Common Fonts
extern int Font_Size           = 12;         // Font Size
extern string Font_Face        = "Courier";  // Font Face
extern __position Position     = BottomLeft;
extern int Distance_X          = 25;         // Distance Of Box Horizontal
extern int Distance_Y          = 15;         // Distance Of Box Vertical
extern int BackGround_Size     = 180;        // Size Of Box ( ignore it )

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
int create_box(){
   
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
   
   string myMode = ( Mode == Percentage ) ? "Percentage" : "Money";
   double riskMoney = ( Mode == Percentage ) ? ( size / 100 ) * RiskPercentage : RiskMoney;
   double riskPercentage = ( Mode == Percentage ) ? RiskPercentage : RiskMoney / ( size / 100 );
   
   double unitCost = MarketInfo( Symbol(), MODE_TICKVALUE );
   double tickSize = MarketInfo( Symbol(), MODE_TICKSIZE );
   
   // Important for startup MT4, without generate an error
   //if( unitCost == 0 )return( 0 );   
   double positionSize = ( unitCost > 0 ) ? riskMoney / ( ( ( NormalizeDouble( StopLossPips * MyPoint, Digits ) ) * unitCost ) / tickSize ) : 0 ;
   
   
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
   
   ObjectCreate("Mode", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Mode", OBJPROP_CORNER, Position );
   ObjectSet( "Mode", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Mode", OBJPROP_YDISTANCE, Distance_Y * 5 );   
   ObjectSetText( "Mode", "Mode : " + myMode, Font_Size, Font_Face, Color_Tick);
   
   ObjectCreate("StopLoss", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "StopLoss", OBJPROP_CORNER, Position );
   ObjectSet( "StopLoss", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "StopLoss", OBJPROP_YDISTANCE, Distance_Y * 6 );
   ObjectSetText( "StopLoss", "Stop Loss : " + DoubleToStr( StopLossPips, 2 ) , Font_Size, Font_Face, Font_Color);
      
   ObjectCreate("Risk", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Risk", OBJPROP_CORNER, Position );
   ObjectSet( "Risk", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Risk", OBJPROP_YDISTANCE, Distance_Y * 7 );
   ObjectSetText( "Risk", "Risk : " + DoubleToStr( riskPercentage, 2 ) + " %" , Font_Size, Font_Face, Font_Color);
   
   ObjectCreate("RiskM", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "RiskM", OBJPROP_CORNER, Position );
   ObjectSet( "RiskM", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "RiskM", OBJPROP_YDISTANCE, Distance_Y * 8 );
   ObjectSetText( "RiskM", "Money : " + DoubleToStr( riskMoney, 2 ) , Font_Size, Font_Face, Font_Color); 
     
   ObjectCreate("TickValue", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "TickValue", OBJPROP_CORNER, Position );
   ObjectSet( "TickValue", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "TickValue", OBJPROP_YDISTANCE, Distance_Y * 10 );
   ObjectSetText( "TickValue", "Tick Value : " + DoubleToStr( unitCost, 3 ) , Font_Size, Font_Face, Color_Tick );
   
   ObjectCreate("TickSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "TickSize", OBJPROP_CORNER, Position );
   ObjectSet( "TickSize", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "TickSize", OBJPROP_YDISTANCE, Distance_Y * 11 );
   ObjectSetText( "TickSize", "Tick Size : " + DoubleToStr( tickSize, 3 ) , Font_Size, Font_Face, Color_Tick);
   
   string pSize = ( positionSize > 0 ) ? DoubleToStr( positionSize, 3 ) : "loading ..." ;
   ObjectCreate("PositionSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "PositionSize", OBJPROP_CORNER, Position );
   ObjectSet( "PositionSize", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "PositionSize", OBJPROP_YDISTANCE, Distance_Y * 12 );
   ObjectSetText( "PositionSize", "LOTS : " + pSize , Font_Size, Font_Face, Color_Lots);
   
   ObjectCreate("Profit", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Profit", OBJPROP_CORNER, Position );
   ObjectSet( "Profit", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Profit", OBJPROP_YDISTANCE, Distance_Y * 14 );
   ObjectSetText( "Profit", "Profit : " + DoubleToStr( total_profit(), 2 ) , Font_Size, Font_Face, Color_Profit);
   
   return( 0 );
      
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
   ObjectDelete( "Mode" );
   
}

//+------------------------------------------------------------------+
//| Total profit                                                     |
//+------------------------------------------------------------------+
double total_profit(){
   
   double tt_profit  =  0.0;
   
   for( int x = 0; x < OrdersTotal(); x++ ){
   
       if( OrderSelect( x, SELECT_BY_POS, MODE_TRADES ) ){
       
         if( OrderSymbol() == MySymbol ){
       
            tt_profit += OrderProfit();
          
          }
       
       }
          
   }
   
   return(tt_profit);
}
