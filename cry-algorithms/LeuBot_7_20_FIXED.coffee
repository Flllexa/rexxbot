###
Leu Bot 1.1v Fixed version
###


#@ema_previous Module by Ken
class Functions
  @ema_previous: (data, period) ->
    results = talib.EMA
      inReal: data
      startIdx: 0
      endIdx: data.length - 2
      optInTimePeriod: period
    _.last(results)   


  @can_buy: (ins, min_btc, fee_percent) ->
    portfolio.positions[ins.curr()].amount >= ((ins.price * min_btc) * (1 + fee_percent / 100))

  @can_sell: (ins, min_btc) ->
    portfolio.positions[ins.asset()].amount >= min_btc
    
init: (context) ->
#DON'T MESS w/ this part
#@ema_previous Module by Ken
    context.invested = null




#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# USER CONTROL PANEL
    
    # Buying Slope
    context.BUY_min  = -0.3   #-0.3 #Start buying at this slope   
    context.BUY_max  = 0.1    #0.1  #Stop buying at this slope
    
    #Selling Slope
    context.SELL_max = -0.3   #-0.3 #Start selling at this slope
    context.SELL_min = -0.6   #-0.6 #Stop selling at this slope
    
    
    context.EMA_L   = 7     #Order Limit EMA; EMA(2) for 2h
    context.EMA     = 20     #Slope EMA; EMA(5) for 2h
    
    # % above and below Limit EMA to buy and sell
    context.B_limit = 1.00      #1.002 for more consistant orders
    context.S_limit = 0.99      #0.998 for more consistant orders
 
    # Minimum balance and buy/sell quantities
    # may use "null" for any of these
    context.bal_min = null  # if balance < this; sell all market order
    context.B = null      # buy this many units per candle  
    context.S = null      # sell this many units per candle
    
# /USER CONTROL PANEL
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# PERFORM EACH TICK    
handle: (context, data)->
    instrument = data.instruments[0]
    EMA_LAST = Functions.ema_previous(instrument.close,context.EMA)    
    EMA = instrument.ema(context.EMA)
    LIMIT = instrument.ema(context.EMA_L)
    SLOPE = EMA - EMA_LAST
    balance = portfolio.positions[instrument.asset()].amount
    Cbalance = portfolio.positions[instrument.curr()].amount
 # DRAW
    plot 
        EMA: EMA
        LIMIT: LIMIT

        
# LOGIC
    

    if LIMIT > EMA
      if buy(instrument,context.B,(Math.round(context.B_limit*LIMIT*100))/100,179)
        debug 'Assets: ' + (Math.floor(balance*100)/100) + ' | ' + 'Currency: ' + (Math.floor(Cbalance*1000)/1000)+' |' + ' Buy : LIMIT:' + LIMIT + ' EMA: ' + EMA
    if LIMIT < EMA
      if sell(instrument,context.S,(Math.round(context.S_limit*LIMIT*100))/100,179)
         debug 'Assets: ' + (Math.floor(balance*1000)/1000) + ' | ' + 'Currency: ' + (Math.floor(Cbalance*1000)/1000)+' |' + ' Sell : LIMIT:' + LIMIT + ' EMA: ' + EMA

