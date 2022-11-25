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

		if (!SymbolInfoSessionTrade(Symbol(), dows[i], 0, trade_session_from, trade_session_to)) {
			// market closed (not an error)
			m_schedule_label[i].Description(day_strs[i] + " - market closed");
		}
		else {
			m_schedule_label[i].Description(day_strs[i] + " - " + TimeToString(trade_session_from, TIME_MINUTES | TIME_SECONDS) + "-" + TimeToString(trade_session_to, TIME_MINUTES | TIME_SECONDS));
		}

		m_schedule_label[i].Color(color_info);
		m_schedule_label[i].FontSize(8);
		y += 16;
	}

	m_note_label.Create(0, PREFIX_NAME + "-Timezone note", 0, 6, y);
	m_note_label.Description("(Time zone bases on your broker)");
	m_note_label.Color(color_info);
	m_note_label.FontSize(8);

	return true;
}

void CMarketSchedule::Deinit() {
	for (int i=0; i<7; i++) {
		m_schedule_label[i].Delete();
	}
	m_note_label.Delete();
}