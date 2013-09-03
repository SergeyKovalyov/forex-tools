#property copyright "Sergey Kovalyov (sergey.kovalyov@gmail.com)"

void start() {
	static bool first_run = true;
	int i, fh, number;
	string symb, msg, full_msg = "";

	if (!first_run) return;
	first_run = false;

	fh = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
	if (fh == -1) {
		Print("error during FileOpenHistory");
		return;
	}
	number = (FileSize(fh) - 4) / 128;
	FileSeek(fh, 4, SEEK_CUR);
	for (i = 0; i < number; i++) {
		symb = FileReadString(fh, 12);
		msg = ""
			+ "symbol: "       + symb
			+ "  swap LONG: "  + DoubleToStr(MarketInfo(symb, MODE_SWAPLONG), 2)
			+ "  swap SHORT: " + DoubleToStr(MarketInfo(symb, MODE_SWAPSHORT), 2)
		;
		Print(msg);
		full_msg = full_msg + msg + "\n";
		FileSeek(fh, 116, SEEK_CUR);
	}
	FileClose(fh);
	Comment(full_msg);
	return;
}
