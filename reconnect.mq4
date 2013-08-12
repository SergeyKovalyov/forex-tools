#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"
#define magic 42

int last_time = -1, ticket = -1;

void init() {
	int i;

	if (ticket != -1) return;

	for (i = OrdersTotal() - 1; i >= 0; i--) {
		OrderSelect(i, SELECT_BY_POS);
		if (OrderType() != OP_BUYLIMIT || OrderMagicNumber() != magic) continue;
		ticket = OrderTicket();
		break;
	}
	if (ticket != -1) return;

	ticket = OrderSend(Symbol(), OP_BUYLIMIT, 0.1, Ask - 10000 * Point, 0, 0, 0, "", magic);
	return;
}

void vstart() {
	int i;

	if (TimeLocal() - last_time < 28) return;

	/*
	Print(""
		+ "ticket #" + ticket
		+ "  last_time: " + last_time
		+ "  time: " + TimeToStr(last_time, TIME_DATE | TIME_SECONDS)
	);
	*/
	RefreshRates();
	i = Seconds() - 30;
	if (i == 0) i = 30;
	/*
	Print("going to modify ticket #" + ticket
		+ "  price: " + OrderOpenPrice()
		+ "  i: " + i
	);
	*/
	OrderSelect(ticket, SELECT_BY_TICKET);
	OrderModify(ticket, OrderOpenPrice() + i * Point, 0, 0, 0);
	last_time = TimeLocal();
}

void start() {
	while (!IsStopped()) {
		if (!IsConnected()) {
			Print("error: lost connection");
			return;
		}
		vstart();
		Sleep(1000);
	}
	return;
}



