#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"
#property strict
//
// Simple and robust way to pass live price data to other program.
// This program saves ticks to files one Ask/Bid snapshot per file.
// Be aware of disk overflow as use of disk space is very inefficient.
// So, intended usage -- some other program processes tick-files as
// they come and purges them.

void start() {
	static int idx = 0;
	static long prev_time = -1;

	long time = TimeLocal();
	if (time == prev_time) {
		idx++;
	} else {
		idx = 0;
		prev_time = time;
	}
	string fname = "ticks\\" + (string)time + "-" + StringSubstr((string)(idx + 1000), 1, 3) + "-" + _Symbol;
	int fh = FileOpen(fname, FILE_WRITE);
	FileWrite(fh, time, Ask, Bid, _Symbol);
	FileClose(fh);
}



