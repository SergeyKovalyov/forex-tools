#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"
//
// counts slippage on history (for SL and TP only)

extern bool skip_history = false;
int last_ticket = 0;


void init() {
	if (!skip_history) return;

	OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY);
	last_ticket = OrderTicket();
}



void start() {
	int i, ticket, type;
	double TP, SL, CP, OP, slippage, pl;

	for (i = 0; i < OrdersHistoryTotal(); i++) {
		OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
		ticket = OrderTicket();
		if (ticket <= last_ticket) continue;

		type = OrderType();
		if (type != OP_BUY && type != OP_SELL) continue;

		SL = OrderStopLoss();
		TP = OrderTakeProfit();
		if (TP < Point && SL < Point) continue;

		CP = OrderClosePrice();
		OP = OrderOpenPrice();
		if (type == OP_BUY) {
			pl = CP - OP;
			// FIXME: SL can slip to plus
			if (SL > Point && CP <= SL) {
				slippage = CP - SL;
			} else if (TP > Point && CP >= TP) {
				slippage = CP - TP;
			} else {
				continue;
			}
		} else if (type == OP_SELL) {
			pl = OP - CP;
			if (SL > Point && CP >= SL) {
				slippage = SL - CP;
			} else if (TP > Point && CP <= TP) {
				slippage = TP - CP;
			} else {
				continue;
			}
		}
		Print("ticket #"     + ticket
			+ "  pl: "   + DoubleToStr(pl / Point, 0)
			+ "  slip: " + DoubleToStr(slippage / Point, 0)
			+ "  cmnt: " + OrderComment()
		);
		last_ticket = ticket;
	}
}



