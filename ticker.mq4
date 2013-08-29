#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"
//
// saves ticks to file
// one Bid/Ask pair per file

int idx = 0, prev_time = -1;
string symb;


void init() {
	symb = Symbol();
	return;
}

void start() {
	int time, fh;
	string fname;

	time = TimeCurrent();
	if (time == prev_time) {
		idx++;
	} else {
		idx = 0;
		prev_time = time;
	}
	fname = time + "-" + idx + "-" + symb;
	fh = FileOpen(fname, FILE_WRITE);
	FileWrite(fh, Bid, Ask);
	FileClose(fh);
	return;
}



