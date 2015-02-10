/*

Set of functions to trade using only limit orders, price will be adjusted
to be not worse than current market price as MT4 does not permit limit
orders with such prices. A number of tries will be attempted with reporting
errors and time taken.

*/


#import "Kernel32.dll"
int QueryPerformanceFrequency(int &a[]);
int QueryPerformanceCounter(int &a[]);
#import

void SetLimit(int type, double in_price, double lot, int magic, double TP = 0) {
	int ticket;
	int number = 0;
	double price;
	string msg;

	TP = NormalizeDouble(TP, Digits);
	while (number < 10) {
		number++;
		price = NormalizeDouble(in_price, Digits);
		RefreshRates();
		if (type == OP_SELLLIMIT) {
			msg = "SELL";
			if (Bid > price) price = Bid;
		} else if (type == OP_BUYLIMIT) {
			msg = "BUY";
			if (Ask < price) price = Ask;
		}
		Print(number, ": going to set ", msg, " limit: lot: ", DoubleToStr(lot, 2), " at price: ", DoubleToStr(price, Digits));
		PreciseTime(0);
		ticket = OrderSend(_Symbol, type, lot, price, 0, 0, TP, "", magic);
		if (ticket > 0) {
			Print("ticket #", ticket, "  ms: ", PreciseTime(1));
			return;
		} else {
			Print(number, ": error during OrderSend: ", GetLastError(), "  ms: ", PreciseTime(1));
		}
	}
	Print("failed to SetLimit");
}



void DelLimit(int type, int ticket) {
	bool done;
	string msg;

	if (type == OP_SELLLIMIT) {
		msg = "SELL";
	} else if (type == OP_BUYLIMIT) {
		msg = "BUY";
	}
	Print("going to delete ", msg, " limit ticket: #", ticket);
	PreciseTime(0);
	done = OrderDelete(ticket);
	if (done) {
		Print("ticket #", ticket, "  ms: ", PreciseTime(1));
	} else {
		Print("error during OrderDelete: ", GetLastError(), "  ms: ", PreciseTime(1));
	}
}



void ModifyPrice(int type, int ticket, double in_price, double in_TP) {
	bool done;
	int number = 0;
	double price, TP, msg_pr = 0;
	string msg1, msg2;

	done = OrderSelect(ticket, SELECT_BY_TICKET);
	while (number < 10) {
		number++;
		price = NormalizeDouble(in_price, Digits);
		TP = NormalizeDouble(in_TP, Digits);
		RefreshRates();
		if (type == OP_SELLLIMIT) {
			if (OrderOpenPrice() > Point && Bid - OrderOpenPrice() > Point) return;
			msg1 = "SELL limit";
			msg2 = "open price";
			if (price < Bid) price = Bid;
			if (MathAbs(NormalizeDouble(OrderOpenPrice() - price, Digits)) <= Point) return;
			msg_pr = price;
		} else if (type == OP_BUYLIMIT) {
			if (OrderOpenPrice() - Ask > Point) return;
			msg1 = "BUY limit";
			msg2 = "open price";
			if (price > Ask) price = Ask;
			if (MathAbs(NormalizeDouble(OrderOpenPrice() - price, Digits)) <= Point) return;
			msg_pr = price;
		} else if (type == OP_SELL) {
			if (OrderTakeProfit() - Ask > Point) return;
			msg1 = "SELL";
			msg2 = "TP";
			if (TP > Ask) TP = Ask;
			if (MathAbs(NormalizeDouble(OrderTakeProfit() - TP, Digits)) <= Point) return;
			msg_pr = TP;
		} else if (type == OP_BUY) {
			if (OrderTakeProfit() > Point && Bid - OrderTakeProfit() > Point) return;
			msg1 = "BUY";
			msg2 = "TP";
			if (TP < Bid) TP = Bid;
			if (MathAbs(NormalizeDouble(OrderTakeProfit() - TP, Digits)) <= Point) return;
			msg_pr = TP;
		}
		OrderPrint();
		Print(number, ": going to modify ", msg1, " ticket #", ticket, " set ", msg2, ": ", DoubleToStr(msg_pr, Digits));
		PreciseTime(0);
		done = OrderModify(ticket, price, 0, TP, 0);
		if (done) {
			Print("ticket #", ticket, "  ms: ", PreciseTime(1));
			return;
		} else {
			int error = GetLastError();
			Print(number, ": error during OrderModify: ", error, "  ms: ", PreciseTime(1));
			// 4108 ERR_INVALID_TICKET
			// 139  ERR_ORDER_LOCKED
			// 133  ERR_TRADE_DISABLED
			// 1    ERR_NO_RESULT
			// 136  ERR_OFF_QUOTES
			if (error == 4108 || error == 139 || error == 133 || error == 1 || error == 136) return;
		}
	}
	Print("failed to ModifyPrice");
}



string PreciseTime(int c) {
	static int start[2], end[2], freq[2];
	if (c == 0) {
		QueryPerformanceCounter(start);
		return "0";
	} else {
		QueryPerformanceCounter(end);
		if (QueryPerformanceFrequency(freq) == 0) return "0";
		double res = end[0] - start[0];
		return(DoubleToStr(res / freq[0] * 1000.0, 3));
	}
}



