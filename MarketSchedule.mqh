//+------------------------------------------------------------------+
//|                                               MarketSchedule.mqh |
//|                                          Copyright 2022, haxpor. |
//|                                                 https://wasin.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, haxpor."
#property link      "https://wasin.io"

// include CChartObjectLabel for simplified access
#include <ChartObjects/ChartObjectsTxtControls.mqh>
#define PREFIX_NAME "MarketSchedule"

class CMarketSchedule {
public:
	CMarketSchedule();
	~CMarketSchedule();

	bool Init();
	void Deinit();

protected:
	// store maximum of days for the week for time open/close
	CChartObjectLabel m_schedule_label[7];
	// note line
	CChartObjectLabel m_note_label;
};

// --- implementation --- //
CMarketSchedule::CMarketSchedule() {
}

CMarketSchedule::~CMarketSchedule() {
}

bool CMarketSchedule::Init() {
	int y = 10;
	color color_info;

	// check if OHLC displayed on the chart, then we offset the y-position beginning of our multiple lines of info
	if (ChartGetInteger(0, CHART_SHOW_OHLC)) {
		y += 16;
	}

	// get contrast color applying to info from the background
	color_info = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND) ^ 0xFFFFFF;

	string day_strs[] = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" };
	ENUM_DAY_OF_WEEK dows[] = { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY };

	datetime trade_session_from, trade_session_to;

	// Statically print out the market schedule information out onto the chart window
	// when time crosses the open and close time, then it won't update.
	// User has to remove and put the script back in again.
	for (int i=0; i<7; i++) {
		m_schedule_label[i].Create(0, PREFIX_NAME + "-" + day_strs[i], 0, 6, y);

		// assume possibility of maximum market sessions can be is 2
		// e.g. it is a case for BTCUSD on certain broker that has a market break during the day for one hour.
		// Thus is spans into 2 sessions in a single day. Normally there is just 1 session for most instruments.
		//
		// NOTE: if such instrument has more than 2 sessions per day, then we need to update `j` to be higher value.
		string desc = day_strs[i];
		for (int j=0; j<2; j++) {
			if (!SymbolInfoSessionTrade(Symbol(), dows[i], j, trade_session_from, trade_session_to)) {
				if (j == 0) {
					// market closed (not an error)
					desc += " - market closed";
				}
				break;
			}
			else {
				if (j == 0) {
					desc += " - " + TimeToString(trade_session_from, TIME_MINUTES | TIME_SECONDS) + "-" + TimeToString(trade_session_to, TIME_MINUTES | TIME_SECONDS);
				}
				else {
					desc += ", " + TimeToString(trade_session_from, TIME_MINUTES | TIME_SECONDS) + "-" + TimeToString(trade_session_to, TIME_MINUTES | TIME_SECONDS);
				}
			}
		}
		m_schedule_label[i].Description(desc);

		m_schedule_label[i].Color(color_info);
		m_schedule_label[i].FontSize(8);
		y += 16;
	}

	m_note_label.Create(0, PREFIX_NAME + "-Timezone note", 0, 6, y);
	m_note_label.Description("(Time zone bases on your broker)");
	m_note_label.Color(color_info);
	m_note_label.FontSize(8);

	ChartRedraw(0);

	return true;
}

void CMarketSchedule::Deinit() {
	// we can either remove all objects via PREFIX_NAME
	// but we do so by removing all individuals to not spend time in finding those objects with prefixed name
	for (int i=0; i<7; i++) {
		m_schedule_label[i].Delete();
	}
	m_note_label.Delete();
}
