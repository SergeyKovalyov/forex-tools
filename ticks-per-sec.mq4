#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"

int start_time;

void init() {
	start_time = TimeCurrent();
	return;
}

void start() {
	static int ticks = 0;
	int time;

	ticks++;
	time = TimeCurrent() - start_time;
	Print(""
		+ "t: " + ticks
		+ "  time elapsed: " + time
		+ "  p: " + DoubleToStr(Bid, Digits)
		+ "/"     + DoubleToStr(Ask, Digits)
		+ "  tps: " + DoubleToStr(ticks * 1.0 / time, 3)
	);
	return;
}



