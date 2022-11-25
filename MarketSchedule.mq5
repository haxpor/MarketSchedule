//+------------------------------------------------------------------+
//|                                               MarketSchedule.mq5 |
//|                                          Copyright 2022, haxpor. |
//|                                                 https://wasin.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, haxpor."
#property link      "https://wasin.io"
#property version   "1.01"
#property description "MarketSchedule displays market open/close time for each day throughout the week for current instrument as shown in the chart."

#include "MarketSchedule.mqh"

CMarketSchedule market_schedule;

void OnStart() {
	if (market_schedule.Init()) {
		while (!IsStopped())
			Sleep(50);	// avoid busy waiting before deinit
	}
	market_schedule.Deinit();
}
