#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"
#define magic 4210

void start() {
	int ticket, ticks, slippage;

	ticks = GetTickCount();
	ticket = OrderSend(Symbol(), OP_SELL, 0.01, 0, 0, 0, 0, "open-sell", magic);
	ticks = GetTickCount() - ticks;
	if (ticket == -1) {
		Print("error during OrderSend: " + GetLastError());
	} else {
		OrderSelect(ticket, SELECT_BY_TICKET);
		slippage = NormalizeDouble((OrderOpenPrice() - Bid) / Point, 0);
		Print(""
			+ "ticket #" + ticket
			+ "  ms: "   + ticks
			+ "  slip: " + slippage
			+ "  cmnt: " + OrderComment()
		);
	}
	return;
}
