#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"
#define magic 4212

int last_time = -1, ticket = -1;

void init() {
	int i;

	for (i = OrdersTotal() - 1; i >= 0; i--) {
		OrderSelect(i, SELECT_BY_POS);
		if (OrderType() != OP_BUYLIMIT || OrderMagicNumber() != magic) continue;
		ticket = OrderTicket();
		break;
	}
	if (ticket != -1) return;

	ticket = OrderSend(Symbol(), OP_BUYLIMIT, 0.1, Point, 0, 0, 0, "reconnect", magic);
	last_time = TimeLocal();
	return;
}

void vstart() {
	double price;

	if (TimeLocal() - last_time < 28) return;
	OrderSelect(ticket, SELECT_BY_TICKET);
	if (OrderOpenPrice() < 2 * Point) {
		price = 3 * Point;
	} else {
		price = Point;
	}
	OrderModify(ticket, price, 0, 0, 0);
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

